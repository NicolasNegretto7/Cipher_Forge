<?php

declare(strict_types=1);

namespace App\Middlewares;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\TokenHelper;
use App\Repositories\UserRepository;

/**
 * Middleware para validar el Token Bearer en encabezado Authorization.
 */
class AuthMiddleware
{
    private UserRepository $userRepository;
    private bool $optional;

    public function __construct(bool $optional = false, ?UserRepository $userRepository = null)
    {
        $this->optional = $optional;
        $this->userRepository = $userRepository ?? new UserRepository();
    }

    /**
     * Intercepta la petición para validar el token Bearer antes del controlador.
     * 
     * @param Request $request Petición HTTP.
     * @return void
     */
    public function handle(Request $request): void
    {
        $token = $request->getBearerToken();

        if ($token === null || trim($token) === '') {
            if ($this->optional) {
                return;
            }
            Response::error('No autorizado: Se requiere encabezado Authorization: Bearer <token>', 401);
        }

        $tokenHash = TokenHelper::hashToken($token);
        $user = $this->userRepository->findUserByToken($tokenHash);

        if ($user === null) {
            if ($this->optional) {
                return;
            }
            Response::error('No autorizado: Token inválido o expirado.', 401);
        }

        // Asigna el usuario autenticado a la petición para que los controladores lo lean
        $request->setUser($user);
    }
}
