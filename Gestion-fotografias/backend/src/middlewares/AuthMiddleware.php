<?php
// QUÉ: Middleware de autenticación y control de acceso por roles.
// POR QUÉ: Intercepta las peticiones antes del controlador. Si la ruta es pública
//          ($requirement === null) deja pasar; si está protegida exige un token JWT
//          válido y carga el usuario autenticado en la petición actual.

declare(strict_types=1);

namespace App\middlewares;

use App\Core\Config;
use App\Core\Database;
use App\Core\Response;
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
     * Lee la cabecera Authorization (Bearer) desde todas las fuentes posibles.
     * POR QUÉ: según la configuración de Apache/Docker, PHP puede exponerla como
     * HTTP_AUTHORIZATION, REDIRECT_HTTP_AUTHORIZATION (tras RewriteRule) o solo
     * vía apache_request_headers()/getallheaders(). Si solo se mira una, los
     * endpoints con 'auth' devuelven 401 aunque el token sea válido.
     */
    private static function obtenerCabeceraAuth(): string
    {
        $candidatos = [
            $_SERVER['HTTP_AUTHORIZATION'] ?? '',
            $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '',
            $_SERVER['REDIRECT_REDIRECT_HTTP_AUTHORIZATION'] ?? '',
        ];

        foreach ($candidatos as $valor) {
            if (is_string($valor) && trim($valor) !== '') {
                return trim($valor);
            }
        }

        if (function_exists('apache_request_headers')) {
            $cabeceras = apache_request_headers();
            foreach ($cabeceras as $nombre => $valor) {
                if (strtolower((string) $nombre) === 'authorization' && trim((string) $valor) !== '') {
                    return trim((string) $valor);
                }
            }
        }

        if (function_exists('getallheaders')) {
            $cabeceras = getallheaders();
            if (is_array($cabeceras)) {
                foreach ($cabeceras as $nombre => $valor) {
                    if (strtolower((string) $nombre) === 'authorization' && trim((string) $valor) !== '') {
                        return trim((string) $valor);
                    }
                }
            }
        }

        // Fallback para ventanas/pestañas de impresión o descargas abiertas directamente por el navegador
        if (isset($_GET['token']) && is_string($_GET['token']) && trim($_GET['token']) !== '') {
            $tokenQuery = trim($_GET['token']);
            return str_starts_with($tokenQuery, 'Bearer ') ? $tokenQuery : 'Bearer ' . $tokenQuery;
        }

        return '';
    }

    /**
     * Autentica sólo si la petición trae un token Bearer; si no trae, continúa sin usuario.
     * Los errores de firma/expiración siguen bloqueando (token corrupto no se ignora).
     */
    private static function authenticateIfPresent(): void
    {
        $auth = self::obtenerCabeceraAuth();

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
        $auth = self::obtenerCabeceraAuth();

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
