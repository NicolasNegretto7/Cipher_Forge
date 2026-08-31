<?php
// QUÉ: Controlador que maneja las peticiones de autenticación (register y login).
// POR QUÉ: Coordina el flujo Request → Validator → Service → Response
//           sin contener lógica de negocio ni queries SQL.

declare(strict_types=1);

namespace App\controllers;

use App\Core\Request;
use App\Core\Response;
use App\services\AuthService;
use App\validators\AuthValidator;

class AuthController
{
    private AuthService   $authService;
    private AuthValidator $authValidator;

    public function __construct()
    {
        $this->authService   = new AuthService();
        $this->authValidator = new AuthValidator();
    }

    /**
     * POST /auth/register
     * Registra un nuevo usuario (fotógrafo o cliente).
     */
    public function register(): void
    {
        // 1. Leer el body JSON de la petición
        $request = new Request();
        $data    = $request->getBody();

        // 2. Validar → retorna RegisterDto o corta con 400
        $dto = $this->authValidator->validateRegister($data);

        // 3. Registrar → verifica duplicado, hashea, inserta
        $userData = $this->authService->register($dto);

        // 4. Responder con 201 Created
        Response::success($userData, 'Usuario registrado correctamente.', 201);
    }

    /**
     * POST /auth/login
     * Autentica un usuario con email y contraseña.
     */
    public function login(): void
    {
        // 1. Leer el body JSON de la petición
        $request = new Request();
        $data    = $request->getBody();

        // 2. Validar → retorna LoginDto o corta con 400
        $dto = $this->authValidator->validateLogin($data);

        // 3. Autenticar → verifica credenciales
        $userData = $this->authService->login($dto);

        // 4. Responder con 200 OK
        Response::success($userData, 'Inicio de sesión exitoso.');
    }
}