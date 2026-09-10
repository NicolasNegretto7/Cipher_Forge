<?php
// QUÉ: Envío de correos vía SMTP en PHP puro (sin Composer ni librerías externas).
// POR QUÉ: CF-02: RF18/HU21 exigen enviar el código de verificación por correo con un
//          mensaje personalizado; el backend no tenía ningún envío real. Se implementa un
//          cliente SMTP mínimo contra el buzón de desarrollo (Mailpit) para que la
//          verificación sea demostrable en local sin servicios de terceros (Gmail queda
//          excluido del alcance; ver EMAIL_CONFIG.md).
// CÓMO: Abre un socket con fsockopen, habla SMTP (EHLO → MAIL FROM → RCPT TO → DATA) y
//       entrega un mensaje MIME multi-parte (texto plano + HTML).

declare(strict_types=1);

namespace App\helpers;

class Mailer
{
    private const DEFAULT_HOST = 'mailpit';
    private const DEFAULT_PORT = 1025;

    private static ?string $lastError = null;

    public static function lastError(): ?string
    {
        return self::$lastError;
    }

    /**
     * Envía el correo personalizado con el código de verificación (CF-02 / RF18 / HU21).
     */
    public static function enviarVerificacion(string $email, string $nombre, string $codigo, string $expiracion): bool
    {
        $asunto = 'Cipher Forge: tu código de verificación';

        $texto = "Hola {$nombre}:\n\n"
            . "Gracias por registrarte en Cipher Forge. Para confirmar tu correo electrónico, "
            . "ingresa el siguiente código de verificación:\n\n"
            . "   {$codigo}\n\n"
            . "El código es válido por 1 hora (expira el {$expiracion}). Si no fuiste vos quien se "
            . "registró, podés ignorar este correo.\n\n"
            . "Saludos,\nEl equipo de Cipher Forge";

        $html = "<p>Hola <strong>" . htmlspecialchars($nombre, ENT_QUOTES, 'UTF-8') . "</strong>,</p>"
            . "<p>Gracias por registrarte en <strong>Cipher Forge</strong>. Para confirmar tu correo "
            . "electrónico, ingresá el siguiente código:</p>"
            . '<p style="font-size:24px;font-weight:bold;letter-spacing:4px">' . htmlspecialchars($codigo) . '</p>'
            . "<p>El código es válido por 1 hora (expira el {$expiracion}). Si no fuiste vos quien se "
            . "registró, podés ignorar este correo.</p>"
            . "<p>Saludos,<br>El equipo de Cipher Forge</p>";

        return self::enviar($email, $asunto, $texto, $html);
    }

    /**
     * Compone un mensaje MIME (texto plano + HTML) y lo entrega por SMTP.
     * Configuración por variables de entorno: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS,
     * MAIL_FROM, MAIL_FROM_NAME. En desarrollo apunta a Mailpit (EMail_CONFIG.md).
     */
    public static function enviar(string $destinatario, string $asunto, string $textoPlano, string $html): bool
    {
        self::$lastError = null;

        if (!filter_var($destinatario, FILTER_VALIDATE_EMAIL)) {
            self::$lastError = 'Dirección de correo inválida: ' . $destinatario;
            return false;
        }

        $envHost = getenv('SMTP_HOST');
        $envPort = getenv('SMTP_PORT');
        $host = is_string($envHost) && $envHost !== '' ? $envHost : self::DEFAULT_HOST;
        $port = is_string($envPort) && $envPort !== '' ? (int) $envPort : self::DEFAULT_PORT;

        $envUser = getenv('SMTP_USER');
        $envPass = getenv('SMTP_PASS');
        $usuario = is_string($envUser) && $envUser !== '' ? $envUser : null;
        $clave   = is_string($envPass) && $envPass !== '' ? $envPass : null;

        $envFrom = getenv('MAIL_FROM');
        $envName = getenv('MAIL_FROM_NAME');
        $fromEmail = is_string($envFrom) && $envFrom !== '' ? $envFrom : 'no-reply@cipherforge.local';
        $fromName  = is_string($envName) && $envName !== '' ? $envName : 'Cipher Forge';

        // Sanear contra inyección de cabeceras (CR/LF) en todos los campos derivados de entrada.
        $destinatario = str_replace(["\r", "\n"], '', $destinatario);
        $fromEmail    = str_replace(["\r", "\n"], '', $fromEmail);
        $fromName     = str_replace(["\r", "\n"], '', $fromName);
        $asunto       = str_replace(["\r", "\n"], '', $asunto);

        $subjectB64 = '=?UTF-8?B?' . base64_encode($asunto) . '?=';
        $fromHeader = '"' . str_replace(['"', '\\'], '', $fromName) . '" <' . $fromEmail . '>';

        $conn = @fsockopen($host, $port, $errno, $errstr, 5);
        if ($conn === false) {
            self::$lastError = "No se pudo conectar al servidor SMTP {$host}:{$port} ({$errstr})";
            return false;
        }
        stream_set_timeout($conn, 5);

        try {
            if (!self::leerRespuesta($conn, '220')) {
                return false;
            }

            self::enviarComando($conn, 'EHLO cipherforge.local');
            if (!self::leerRespuestaMultilinea($conn)) {
                return false;
            }

            if ($usuario !== null && $clave !== null) {
                self::enviarComando($conn, 'AUTH LOGIN');
                if (!self::leerRespuesta($conn, '334')) {
                    return false;
                }
                self::enviarComando($conn, base64_encode($usuario));
                if (!self::leerRespuesta($conn, '334')) {
                    return false;
                }
                self::enviarComando($conn, base64_encode($clave));
                if (!self::leerRespuesta($conn, '235')) {
                    return false;
                }
            }

            self::enviarComando($conn, "MAIL FROM:<{$fromEmail}>");
            if (!self::leerRespuesta($conn, '250')) {
                return false;
            }

            self::enviarComando($conn, "RCPT TO:<{$destinatario}>");
            if (!self::leerRespuesta($conn, '250')) {
                return false;
            }

            self::enviarComando($conn, 'DATA');
            if (!self::leerRespuesta($conn, '354')) {
                return false;
            }

            $mensaje = self::compilarMensaje($destinatario, $fromHeader, $subjectB64, $textoPlano, $html);
            fwrite($conn, $mensaje . "\r\n.\r\n");
            if (!self::leerRespuesta($conn, '250')) {
                return false;
            }

            self::enviarComando($conn, 'QUIT');
            fclose($conn);
            return true;
        } catch (\Throwable $e) {
            self::$lastError = $e->getMessage();
            @fclose($conn);
            return false;
        }
    }

    private static function compilarMensaje(
        string $destinatario,
        string $fromHeader,
        string $subjectB64,
        string $textoPlano,
        string $html
    ): string {
        $boundary = 'cfboundary' . bin2hex(random_bytes(8));

        $cabeceras = "From: {$fromHeader}\r\n"
            . "To: <{$destinatario}>\r\n"
            . "Subject: {$subjectB64}\r\n"
            . 'Date: ' . date('r') . "\r\n"
            . 'Message-ID: <' . bin2hex(random_bytes(16)) . '@cipherforge.local>' . "\r\n"
            . "MIME-Version: 1.0\r\n"
            . "Content-Type: multipart/alternative; boundary=\"{$boundary}\"\r\n";

        return $cabeceras . "\r\n"
            . "--{$boundary}\r\n"
            . "Content-Type: text/plain; charset=UTF-8\r\n"
            . "Content-Transfer-Encoding: 8bit\r\n"
            . "\r\n{$textoPlano}\r\n"
            . "--{$boundary}\r\n"
            . "Content-Type: text/html; charset=UTF-8\r\n"
            . "Content-Transfer-Encoding: 8bit\r\n"
            . "\r\n{$html}\r\n"
            . "--{$boundary}--\r\n";
    }

    private static function enviarComando($conn, string $comando): void
    {
        fwrite($conn, $comando . "\r\n");
    }

    private static function leerLinea($conn): string
    {
        $linea = fgets($conn);
        if ($linea === false) {
            throw new \RuntimeException('El servidor SMTP cerró la conexión inesperadamente.');
        }
        return rtrim($linea, "\r\n");
    }

    private static function leerRespuesta($conn, string $codigoEsperado): bool
    {
        $linea = self::leerLinea($conn);
        if (substr($linea, 0, 4) !== $codigoEsperado . ' ') {
            self::$lastError = 'Respuesta SMTP inesperada: ' . $linea;
            return false;
        }
        return true;
    }

    private static function leerRespuestaMultilinea($conn): bool
    {
        do {
            $linea = self::leerLinea($conn);
            $sep = $linea[3] ?? '';
            if (substr($linea, 0, 3) !== '250') {
                self::$lastError = 'Respuesta SMTP inesperada: ' . $linea;
                return false;
            }
        } while ($sep === '-');
        return true;
    }
}