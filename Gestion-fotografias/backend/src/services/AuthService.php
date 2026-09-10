<?php
// QUÉ: Lógica de negocio para autenticación (registro y login).
// POR QUÉ: Separa las reglas de negocio (hasheo, duplicados) del controlador
//           y del acceso a datos — cada capa tiene una sola responsabilidad.

declare(strict_types=1);

namespace App\services;

use App\Core\Config;
use App\Core\Database;
use App\Core\Response;
use App\dtos\RegisterDto;
use App\dtos\LoginDto;
use App\helpers\Jwt;
use App\helpers\Mailer;
use App\repository\UserRepository;

class AuthService
{
    private UserRepository $userRepository;

    public function __construct()
    {
        $database = new Database();
        $this->userRepository = new UserRepository($database->getConnection());
    }

    /**
     * Registra un nuevo usuario.
     * Verifica duplicado de email, hashea la contraseña, inserta en DB.
     * Retorna los datos del usuario creado (sin la contraseña).
     */
    public function register(RegisterDto $dto): array
    {
        // 1. Verificar que el correo no esté registrado (RF2)
        $existingUser = $this->userRepository->findByEmail($dto->email);

        if ($existingUser !== null) {
            Response::error('El correo electrónico ya está registrado.', 409);
        }

        // 2. Hashear contraseña con bcrypt (PASSWORD_DEFAULT usa bcrypt en PHP 8.x)
        $hashedPassword = password_hash($dto->password, PASSWORD_DEFAULT);

        // 3. Insertar usuario + tabla hija dentro de transacción
        $userId = $this->userRepository->create($dto, $hashedPassword);

        // 4. Generar código de verificación de 6 dígitos con expiración a 1 hora (HU21 / RF18)
        $codigo = (string) random_int(100000, 999999);
        $expiracion = date('Y-m-d H:i:s', time() + 3600);
        $this->userRepository->guardarCodigoVerificacion($dto->email, $codigo, $expiracion);

        // 5. Enviar el código por correo con un mensaje personalizado (CF-02 / RF18).
        //    Si el transporte falla (ej. Mailpit caído) se registra y se continúa, de modo
        //    que el registro no se rompa; el código sigue disponible en dev para testing.
        $enviado = Mailer::enviarVerificacion($dto->email, $dto->nombreCompleto, $codigo, $expiracion);
        if (!$enviado) {
            error_log('[CF-02] No se pudo enviar el correo de verificación a ' . $dto->email . ': ' . Mailer::lastError());
        }

        return [
            'id'                  => $userId,
            'nombre_completo'     => $dto->nombreCompleto,
            'email'               => $dto->email,
            'telefono'            => $dto->telefono,
            'rol'                 => $dto->rol,
            'email_verificado'    => false,
            'email_enviado'       => $enviado,
            'codigo_verificacion' => $codigo, // Expuesto en dev/entorno local para testing ágil
        ];
    }

    /**
     * Autentica un usuario con email y contraseña.
     * Retorna los datos del usuario si las credenciales son correctas.
     */
    public function login(LoginDto $dto): array
    {
        // 1. Buscar usuario por email
        $user = $this->userRepository->findByEmail($dto->email);

        // Mismo mensaje genérico para email inexistente y contraseña incorrecta
        // para no revelar si un email está registrado o no
        if ($user === null) {
            Response::error('Credenciales incorrectas.', 401);
        }

        // 2. Verificar contraseña contra el hash almacenado
        if (!password_verify($dto->password, $user['password_hash'])) {
            Response::error('Credenciales incorrectas.', 401);
        }

        // 2b. CF-09: bloquear el login hasta que el correo esté verificado (RF18 / HU8).
        if (!(bool) $user['email_verificado']) {
            Response::error('Debes verificar tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada o solicita un nuevo código.', 403);
        }

        // 3. Emitir un token JWT firmado para las peticiones autenticadas posteriores.
        $token = Jwt::encode(
            ['sub' => (int) $user['id'], 'rol' => $user['rol'], 'email' => $user['email']],
            Config::jwtSecret(),
            Config::tokenHoras()
        );

        // 4. Comprobar si aceptó las políticas obligatorias (HU31 para fotógrafo; CF-15 para cliente).
        $politicasAceptadas = $user['rol'] === 'fotografo'
            ? $this->userRepository->politicasAceptadas((int) $user['id'])
            : $this->userRepository->politicasClienteAceptadas((int) $user['id']);

        // 5. Retornar datos del usuario (sin el hash) junto con el token de acceso.
        return [
            'id'                  => $user['id'],
            'nombre_completo'     => $user['nombre_completo'],
            'email'               => $user['email'],
            'telefono'            => $user['telefono'],
            'rol'                 => $user['rol'],
            'email_verificado'    => (bool) $user['email_verificado'],
            'politicas_aceptadas' => $politicasAceptadas,
            'token'               => $token,
        ];
    }

    /**
     * Valida el código de verificación recibido por email (HU21).
     */
    public function verificarEmail(string $email, string $codigo): array
    {
        $registro = $this->userRepository->obtenerCodigoVerificacion($email);

        if ($registro === null) {
            Response::error('No existe ningún usuario con ese correo.', 404);
        }

        if ((bool) $registro['email_verificado']) {
            Response::error('El correo electrónico ya se encuentra verificado.', 400);
        }

        if ($registro['codigo_verificacion'] !== trim($codigo)) {
            Response::error('El código de verificación es incorrecto.', 400);
        }

        if (strtotime($registro['codigo_expiracion']) < time()) {
            Response::error('El código de verificación ha expirado. Solicita uno nuevo.', 400);
        }

        $this->userRepository->marcarEmailVerificado($email);

        return [
            'email'            => $email,
            'email_verificado' => true,
        ];
    }

    /**
     * Genera y reenvía un nuevo código de verificación al email (HU21).
     */
    public function reenviarCodigo(string $email): array
    {
        $user = $this->userRepository->findByEmail($email);

        if ($user === null) {
            Response::error('No existe ningún usuario con ese correo.', 404);
        }

        if ((bool) $user['email_verificado']) {
            Response::error('El correo electrónico ya se encuentra verificado.', 400);
        }

        $codigo = (string) random_int(100000, 999999);
        $expiracion = date('Y-m-d H:i:s', time() + 3600);
        $this->userRepository->guardarCodigoVerificacion($email, $codigo, $expiracion);

        // Reenviar el código por correo con mensaje personalizado (CF-02 / RF18 / HU21).
        $enviado = Mailer::enviarVerificacion($email, (string) $user['nombre_completo'], $codigo, $expiracion);
        if (!$enviado) {
            error_log('[CF-02] No se pudo reenviar el correo de verificación a ' . $email . ': ' . Mailer::lastError());
        }

        return [
            'email'               => $email,
            'email_enviado'       => $enviado,
            'codigo_verificacion' => $codigo,
        ];
    }
}