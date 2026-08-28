<?php

declare(strict_types=1);

namespace App\Core;

/**
 * MIDDLEWARE DE AUTENTICACIÓN Y AUTORIZACIÓN POR ROLES
 * ==============================================================================
 * WHAT: Intercepta la petición antes de que el controlador sea instanciado y
 *       valida si el usuario está autenticado y posee el rol exigido.
 * WHY:  Desacopla la seguridad de la lógica del controlador. Centraliza el control
 *       de acceso para que ninguna acción protegida se ejecute si falta la sesión
 *       o no se tienen permisos suficientes (401 Unauthorized / 403 Forbidden).
 * ==============================================================================
 */
class AuthMiddleware
{
    /**
     * @var array<string, mixed>|null Datos del usuario autenticado en la petición actual.
     */
    private static ?array $user = null;

    /**
     * Valida el requerimiento de seguridad de la ruta actual.
     *
     * @param string|null $requirement null (pública), 'auth' (sesión requerida), 'admin' (rol admin).
     */
    public static function handle(?string $requirement): void
    {
        // Rutas públicas: no requieren verificación
        if ($requirement === null) {
            return;
        }

        // Lee y valida el JWT de la cookie HttpOnly
        $user = Token::read();

        // 401 = No autenticado (falta la cookie o el token expiró)
        if ($user === null) {
            Response::error('Tenés que iniciar sesión para acceder a este recurso.', 401);
        }

        // 403 = Autenticado pero no autorizado (rol insuficiente)
        if ($requirement === 'admin' && ($user['rol'] ?? '') !== 'admin') {
            Response::error('Solo un administrador puede realizar esta acción.', 403);
        }

        self::$user = $user;
    }

    /**
     * Retorna los datos del usuario logueado en la petición actual.
     *
     * @return array<string, mixed>|null
     */
    public static function user(): ?array
    {
        return self::$user;
    }
}
