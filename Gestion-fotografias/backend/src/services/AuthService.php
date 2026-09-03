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

        return [
            'id'               => $userId,
            'nombre_completo'  => $dto->nombreCompleto,
            'email'            => $dto->email,
            'telefono'         => $dto->telefono,
            'rol'              => $dto->rol,
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

        // 3. Emitir un token JWT firmado para las peticiones autenticadas posteriores.
        $token = Jwt::encode(
            ['sub' => (int) $user['id'], 'rol' => $user['rol'], 'email' => $user['email']],
            Config::jwtSecret(),
            Config::tokenHoras()
        );

        // 4. Retornar datos del usuario (sin el hash) junto con el token de acceso.
        return [
            'id'               => $user['id'],
            'nombre_completo'  => $user['nombre_completo'],
            'email'            => $user['email'],
            'telefono'         => $user['telefono'],
            'rol'              => $user['rol'],
            'email_verificado' => (bool) $user['email_verificado'],
            'token'            => $token,
        ];
    }
}