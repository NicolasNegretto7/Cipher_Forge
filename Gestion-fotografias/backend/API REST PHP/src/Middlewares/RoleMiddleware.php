<?php

declare(strict_types=1);

namespace App\Middlewares;

use App\Core\Request;
use App\Core\Response;

/**
 * Middleware para control de acceso basado en roles (RBAC).
 */
class RoleMiddleware
{
    /**
     * @var array<string> Roles autorizados para ejecutar la ruta.
     */
    private array $allowedRoles;

    public function __construct(string ...$allowedRoles)
    {
        $this->allowedRoles = $allowedRoles;
    }

    /**
     * Comprueba si el rol del usuario autenticado coincide con los permitidos.
     * 
     * @param Request $request Petición HTTP que ya contiene el usuario autenticado.
     * @return void
     */
    public function handle(Request $request): void
    {
        $user = $request->getUser();

        if ($user === null) {
            Response::error('No autenticado: Se requiere iniciar sesión.', 401);
        }

        $userRole = $user['role'] ?? '';

        if (!in_array($userRole, $this->allowedRoles, true)) {
            Response::error(
                "Acceso prohibido: Esta acción requiere rol de [" . implode(', ', $this->allowedRoles) . "]. Tu rol actual es '{$userRole}'.",
                403
            );
        }
    }
}
