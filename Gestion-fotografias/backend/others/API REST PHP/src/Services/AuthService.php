<?php

declare(strict_types=1);

namespace App\Services;

use App\Core\Response;
use App\Core\Token;
use App\DTOs\LoginDTO;
use App\DTOs\RegisterDTO;
use App\Repositories\UserRepository;

/**
 * SERVICIO DE AUTENTICACIÓN (REGLAS DE NEGOCIO)
 * ==============================================================================
 * WHAT: Aplica las reglas del dominio para registro, inicio de sesión y perfiles.
 * WHY:  El servicio no sabe de HTTP (`$_POST`, `$_GET`, headers), solo de reglas:
 *       - El email no puede estar repetido.
 *       - La contraseña se hashea con algoritmos criptográficos antes de persistir.
 *       - El rol asignado por defecto al registrarse es siempre 'usuario'.
 *       - Cuentas inactivas tienen el acceso bloqueado (403).
 * ==============================================================================
 */
class AuthService
{
    private UserRepository $repository;

    public function __construct(?UserRepository $repository = null)
    {
        $this->repository = $repository ?? new UserRepository();
    }

    /**
     * Registra un nuevo usuario aplicando las reglas del sistema.
     *
     * @param RegisterDTO $dto
     * @return array<string, mixed>
     */
    public function register(RegisterDTO $dto): array
    {
        // Regla 1: El correo electrónico debe ser único en el sistema
        if ($this->repository->findByEmail($dto->getEmail()) !== null) {
            Response::error('Ya existe una cuenta con ese email.', 400);
        }

        // Regla 2: La contraseña siempre se almacena hasheada (Bcrypt)
        $passwordHash = password_hash($dto->getPassword(), PASSWORD_DEFAULT);

        // Regla 3: El rol es siempre 'usuario' (evita escalada de privilegios)
        $user = $this->repository->create(
            $dto->getName(),
            $dto->getEmail(),
            $passwordHash,
            'usuario'
        );

        return $user->toArray();
    }

    /**
     * Valida credenciales de acceso y retorna la sesión con token JWT.
     *
     * @param LoginDTO $dto
     * @return array{token: string, usuario: array<string, mixed>}
     */
    public function login(LoginDTO $dto): array
    {
        $user = $this->repository->findByEmail($dto->getEmail());

        // Mensaje genérico para no dar pistas a atacantes sobre existencia de emails
        if ($user === null || !$user->checkPassword($dto->getPassword())) {
            Response::error('Email o contraseña incorrectos.', 401);
        }

        // Regla de negocio: Cuentas deshabilitadas no pueden ingresar
        if (!$user->isActive()) {
            Response::error('Tu cuenta está deshabilitada.', 403);
        }

        return [
            'token'   => Token::create($user),
            'usuario' => $user->toArray(),
        ];
    }

    /**
     * Obtiene el perfil de un usuario por su ID.
     *
     * @param int $id
     * @return array<string, mixed>
     */
    public function getProfile(int $id): array
    {
        $user = $this->repository->findById($id);

        if ($user === null) {
            Response::error('El usuario ya no existe.', 404);
        }

        return $user->toArray();
    }
}
