<?php
// QUÉ: Middleware de autenticación y control de acceso por roles.
// POR QUÉ: Intercepta las peticiones antes del controlador. Si la ruta es pública
//          ($requirement === null) deja pasar; si está protegida exige un token JWT
//          válido y carga el usuario autenticado en la petición actual.

declare(strict_types=1);

namespace App\Core;

use App\helpers\Jwt;
use App\repository\UserRepository;

class AuthMiddleware
{
    private static ?array $user = null;

    /**
     * Valida el requisito de seguridad de la ruta actual.
     * - null      : ruta pública, no bloquea ni autentica.
     * - 'auth'    : exige un token JWT válido (401 si falta o es inválido).
     * - 'optional': autentica si se envía token, pero permite anónimos (para colecciones públicas).
     */
    public static function handle(?string $requirement): void
    {
        if ($requirement === null) {
            return;
        }

        if ($requirement === 'auth') {
            self::authenticate();
            return;
        }

        if ($requirement === 'optional') {
            self::authenticateIfPresent();
        }
    }

    /**
     * Autentica sólo si la petición trae un token Bearer; si no trae, continúa sin usuario.
     * Los errores de firma/expiración siguen bloqueando (token corrupto no se ignora).
     */
    private static function authenticateIfPresent(): void
    {
        $auth = $_SERVER['HTTP_AUTHORIZATION'] ?? '';

        if ($auth === '' || !str_starts_with($auth, 'Bearer ')) {
            return; // Usuario anónimo (colección pública).
        }

        self::authenticate();
    }

    /**
     * Lee la cabecera Authorization (Bearer), valida el token JWT y carga el usuario.
     * Si el token falta o es inválido, interrumpe con 401.
     */
    private static function authenticate(): void
    {
        $auth = $_SERVER['HTTP_AUTHORIZATION'] ?? '';

        if (!preg_match('/^Bearer\s+(.+)$/i', $auth, $matches)) {
            Response::error('Debes iniciar sesión para acceder a este recurso.', 401);
        }

        $payload = Jwt::decode(trim($matches[1]), Config::jwtSecret());

        if ($payload === null || !isset($payload['sub'])) {
            Response::error('Sesión inválida o expirada. Inicia sesión nuevamente.', 401);
        }

        // Cargar el usuario desde la base de datos para usar siempre datos vigentes.
        $database = new Database();
        $userRepository = new UserRepository($database->getConnection());
        $user = $userRepository->findById((int) $payload['sub']);

        if ($user === null) {
            Response::error('El usuario asociado al token ya no existe.', 401);
        }

        self::$user = $user;
    }

    /**
     * Retorna los datos del usuario autenticado en la petición actual (o null si es pública).
     */
    public static function user(): ?array
    {
        return self::$user;
    }
}
