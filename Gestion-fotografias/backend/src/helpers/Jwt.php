<?php
// QUÉ: Generación y validación de tokens JWT (JSON Web Token) firmados con HMAC-SHA256.
// POR QUÉ: El login emite un token firmado que el cliente reenvía en la cabecera Authorization
//          (Bearer) para que el backend pueda identificar al usuario sin depender de sesiones PHP.
//          Se implementa en PHP puro (sin librerías externas) usando la extensión hash.

declare(strict_types=1);

namespace App\helpers;

class Jwt
{
    // BASE64URL se usa porque JWT exige caracteres seguros en URLs (sin + / =).
    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder > 0) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'), true);
    }

    /**
     * Construye un token JWT HS256 con el payload dado.
     * Expiración: exp = tiempo actual en segundos + horas de validez.
     */
    public static function encode(array $payload, string $secret, int $horasValidez = 24): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];

        $payload['iat'] = time();
        $payload['exp'] = time() + ($horasValidez * 3600);

        $headerEncoded  = self::base64UrlEncode(json_encode($header));
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));

        $signature = hash_hmac('sha256', $headerEncoded . '.' . $payloadEncoded, $secret, true);

        return $headerEncoded . '.' . $payloadEncoded . '.' . self::base64UrlEncode($signature);
    }

    /**
     * Valida la firma y la expiración de un token.
     * Retorna el payload (array) si es válido, o null si es inválido/vencido.
     */
    public static function decode(string $jwt, string $secret): ?array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            return null;
        }

        [$headerEncoded, $payloadEncoded, $signatureProvided] = $parts;

        $expectedSignature = hash_hmac('sha256', $headerEncoded . '.' . $payloadEncoded, $secret, true);
        $signatureProvided = self::base64UrlDecode($signatureProvided);

        // Comparación en tiempo constante para evitar ataques de temporización.
        if (!hash_equals($expectedSignature, $signatureProvided)) {
            return null;
        }

        $payload = json_decode(self::base64UrlDecode($payloadEncoded), true);

        if (!is_array($payload)) {
            return null;
        }

        // Rechaza tokens vencidos.
        if (isset($payload['exp']) && time() >= (int) $payload['exp']) {
            return null;
        }

        return $payload;
    }
}
