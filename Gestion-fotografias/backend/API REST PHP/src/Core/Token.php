<?php

declare(strict_types=1);

namespace App\Core;

use App\Models\User;
use Exception;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * GESTIÓN DE TOKENS JWT Y COOKIES HTTPONLY (WRAPPER CRIPTOGRÁFICO)
 * ==============================================================================
 * WHAT: Emite, valida y gestiona el ciclo de vida de tokens JWT firmados,
 *       almacenándolos en cookies seguras HttpOnly en el navegador.
 * WHY:  Las cookies HttpOnly no son accesibles desde JavaScript (document.cookie),
 *       lo que neutraliza ataques de robo de sesión mediante XSS (Cross-Site Scripting).
 *       El patrón Wrapper aísla la dependencia de firebase/php-jwt en un solo archivo.
 * ==============================================================================
 */
class Token
{
    private const ALGORITHM = 'HS256';
    private const COOKIE_NAME = 'access_token';

    /**
     * Genera un JWT firmado con los datos esenciales del usuario.
     *
     * @param User $user Entidad del usuario autenticado.
     * @return string Token JWT en formato `cabecera.payload.firma`.
     */
    public static function create(User $user): string
    {
        $payload = [
            'id'     => $user->getId(),
            'nombre' => $user->getName(),
            'email'  => $user->getEmail(),
            'rol'    => $user->getRole(),
            'iat'    => time(),
            'exp'    => time() + TOKEN_LIFETIME,
        ];

        if (class_exists(JWT::class)) {
            return JWT::encode($payload, SECRET_KEY, self::ALGORITHM);
        }

        // Fallback nativo educativo: HMAC-SHA256
        return self::encodeNative($payload, SECRET_KEY);
    }

    /**
     * Envía la cabecera Set-Cookie con el JWT protegido contra lectura en JS.
     *
     * @param string $token Token JWT firmado.
     */
    public static function sendCookie(string $token): void
    {
        setcookie(self::COOKIE_NAME, $token, [
            'expires'  => time() + TOKEN_LIFETIME,
            'path'     => '/',
            'secure'   => self::isHttps(),
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
    }

    /**
     * Invalida y elimina la cookie en el cliente y en la petición actual.
     */
    public static function clearCookie(): void
    {
        setcookie(self::COOKIE_NAME, '', [
            'expires'  => time() - 3600,
            'path'     => '/',
            'secure'   => self::isHttps(),
            'httponly' => true,
            'samesite' => 'Lax',
        ]);

        unset($_COOKIE[self::COOKIE_NAME]);
    }

    /**
     * Lee y valida la firma criptográfica y la vigencia del token recibido en la cookie.
     *
     * @return array<string, mixed>|null Payload decodificado si es válido, null si no existe o expiró.
     */
    public static function read(): ?array
    {
        $token = $_COOKIE[self::COOKIE_NAME] ?? null;

        if ($token === null || trim($token) === '') {
            return null;
        }

        try {
            if (class_exists(JWT::class)) {
                $payload = JWT::decode($token, new Key(SECRET_KEY, self::ALGORITHM));
                return (array) $payload;
            }

            return self::decodeNative($token, SECRET_KEY);
        } catch (Exception) {
            return null;
        }
    }

    private static function isHttps(): bool
    {
        return isset($_SERVER['HTTPS']) && strtolower((string) $_SERVER['HTTPS']) !== 'off';
    }

    private static function encodeNative(array $payload, string $secret): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $b64Header = self::base64UrlEncode((string) json_encode($header));
        $b64Payload = self::base64UrlEncode((string) json_encode($payload));
        $signature = hash_hmac('sha256', "{$b64Header}.{$b64Payload}", $secret, true);
        $b64Signature = self::base64UrlEncode($signature);

        return "{$b64Header}.{$b64Payload}.{$b64Signature}";
    }

    private static function decodeNative(string $jwt, string $secret): ?array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            return null;
        }

        [$b64Header, $b64Payload, $b64Signature] = $parts;
        $expectedSignature = self::base64UrlEncode(hash_hmac('sha256', "{$b64Header}.{$b64Payload}", $secret, true));

        if (!hash_equals($expectedSignature, $b64Signature)) {
            return null;
        }

        $payload = json_decode(self::base64UrlDecode($b64Payload), true);
        if (!is_array($payload)) {
            return null;
        }

        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return null;
        }

        return $payload;
    }

    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string
    {
        return base64_decode(strtr($data, '-_', '+/'));
    }
}
