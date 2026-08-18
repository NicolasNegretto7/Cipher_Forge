<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\TokenHelper;
use App\Repositories\UserRepository;
use Throwable;

/**
 * Controlador de Autenticación mediante Tokens Bearer y Argon2id.
 */
class AuthController
{
    private UserRepository $userRepository;

    public function __construct(?UserRepository $userRepository = null)
    {
        $this->userRepository = $userRepository ?? new UserRepository();
    }

    /**
     * POST /api/auth/register
     * Registra un nuevo usuario con contraseña hasheada en Argon2id.
     */
    public function register(Request $request): void
    {
        try {
            $body = $request->getBody();

            $name = trim((string) ($body['name'] ?? ''));
            $email = trim((string) ($body['email'] ?? ''));
            $password = (string) ($body['password'] ?? '');
            $role = (string) ($body['role'] ?? 'cliente');

            $errors = [];
            if ($name === '') {
                $errors['name'] = 'El nombre es obligatorio.';
            }
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errors['email'] = 'El formato de correo electrónico es inválido.';
            }
            if (strlen($password) < 8) {
                $errors['password'] = 'La contraseña debe tener al menos 8 caracteres.';
            }
            if (!in_array($role, ['fotografo', 'cliente'], true)) {
                $errors['role'] = 'El rol debe ser "fotografo" o "cliente".';
            }

            if (!empty($errors)) {
                Response::error('Errores de validación.', 422, $errors);
            }

            if ($this->userRepository->findByEmail($email) !== null) {
                Response::error('El correo electrónico ya está registrado.', 422, ['email' => 'Correo ya en uso.']);
            }

            $passwordHash = TokenHelper::hashPassword($password);
            $userId = $this->userRepository->create($name, $email, $passwordHash, $role);

            $user = $this->userRepository->findById($userId);

            Response::success($user, 'Usuario registrado exitosamente.', 201);
        } catch (Throwable $e) {
            Response::error('Error al registrar usuario: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/auth/login
     * Valida credenciales con password_verify y emite un Token Bearer de 24 horas.
     */
    public function login(Request $request): void
    {
        try {
            $body = $request->getBody();

            $email = trim((string) ($body['email'] ?? ''));
            $password = (string) ($body['password'] ?? '');

            if ($email === '' || $password === '') {
                Response::error('Debe proporcionar correo y contraseña.', 400);
            }

            $user = $this->userRepository->findByEmail($email);
            if ($user === null || !TokenHelper::verifyPassword($password, $user['password_hash'])) {
                Response::error('Credenciales incorrectas.', 401);
            }

            // Genera token seguro y calcula su hash para la BD
            $plainToken = TokenHelper::generateToken(32);
            $tokenHash = TokenHelper::hashToken($plainToken);
            $expiresAt = date('Y-m-d H:i:s', time() + (24 * 3600)); // Vigencia 24 horas

            $this->userRepository->createAuthToken((int) $user['id'], $tokenHash, $expiresAt);

            unset($user['password_hash']);

            Response::success([
                'user'       => $user,
                'token'      => $plainToken,
                'token_type' => 'Bearer',
                'expires_at' => $expiresAt,
            ], 'Inicio de sesión exitoso.', 200);
        } catch (Throwable $e) {
            Response::error('Error en el servidor al iniciar sesión: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/auth/logout
     * Invalida el token actual en la base de datos.
     */
    public function logout(Request $request): void
    {
        try {
            $token = $request->getBearerToken();
            if ($token !== null) {
                $tokenHash = TokenHelper::hashToken($token);
                $this->userRepository->deleteAuthToken($tokenHash);
            }

            Response::success(null, 'Sesión cerrada correctamente.', 200);
        } catch (Throwable $e) {
            Response::error('Error al cerrar sesión: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/auth/me
     * Retorna los datos del usuario autenticado.
     */
    public function me(Request $request): void
    {
        $user = $request->getUser();
        Response::success($user, 'Perfil de usuario obtenido.', 200);
    }
}
