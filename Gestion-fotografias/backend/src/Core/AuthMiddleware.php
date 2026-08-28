<?php
// QUÉ: Middleware de autenticación y control de acceso por roles.
// POR QUÉ: Intercepta las peticiones antes del controlador; si la ruta es pública ($requirement === null), deja pasar la petición sin trabas.

declare(strict_types=1);

namespace App\Core;

class AuthMiddleware
{
    private static ?array $user = null;

    /**
     * Valida el requisito de seguridad de la ruta actual.
     * Si es null (ruta pública), retorna de inmediato y no bloquea nada.
     */
    public static function handle(?string $requirement): void
    {
        // 1. Si la ruta es pública, no requiere autenticación
        if ($requirement === null) {
            return;
        }

        // TODO (Fase Auth): Leer y validar el token JWT / sesión
        // if (self::$user === null) {
        //     Response::error('Debes iniciar sesión para acceder a este recurso.', 401);
        // }
    }

    /**
     * Retorna los datos del usuario autenticado en la petición actual.
     */
    public static function user(): ?array
    {
        return self::$user;
    }
}