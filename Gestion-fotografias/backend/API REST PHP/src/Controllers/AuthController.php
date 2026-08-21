<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Response;
use App\Core\Token;
use App\DTOs\LoginDTO;
use App\DTOs\RegisterDTO;
use App\Services\AuthService;
use App\Validators\AuthValidator;

/**
 * CONTROLADOR DE AUTENTICACIÓN
 * ==============================================================================
 * WHAT: Orquesta el flujo HTTP para registro, inicio de sesión, logout y perfil.
 * WHY:  El controlador coordina la validación con AuthValidator, encapsula los datos
 *       en DTOs, delega el trabajo al servicio AuthService y responde JSON.
 * ==============================================================================
 */
class AuthController extends Controller
{
    private AuthService $service;

    public function __construct(?AuthService $service = null)
    {
        $this->service = $service ?? new AuthService();
    }

    /**
     * POST /registro
     */
    public function register(): void
    {
        $data = $this->requestData();

        // 1. Validar formato de entrada
        $errors = AuthValidator::validateRegister($data);
        if (count($errors) > 0) {
            Response::error('Revisá los datos ingresados.', 400, $errors);
        }

        // 2. Construir DTO inmutable
        $dto = new RegisterDTO($data);

        // 3. Ejecutar lógica en el servicio
        $user = $this->service->register($dto);

        Response::success($user, 'Cuenta creada exitosamente.', 201);
    }

    /**
     * POST /login
     */
    public function login(): void
    {
        $data = $this->requestData();

        // 1. Validar formato
        $errors = AuthValidator::validateLogin($data);
        if (count($errors) > 0) {
            Response::error('Revisá los datos ingresados.', 400, $errors);
        }

        // 2. DTO
        $dto = new LoginDTO($data);

        // 3. Autenticación en el servicio
        $session = $this->service->login($dto);

        // 4. Envío de cookie HttpOnly al cliente antes de responder JSON
        Token::sendCookie($session['token']);

        // Se remueve el token del cuerpo JSON: el navegador ya lo tiene en la cookie protegida
        unset($session['token']);

        Response::success($session, 'Sesión iniciada correctamente.');
    }

    /**
     * POST /logout
     */
    public function logout(): void
    {
        Token::clearCookie();

        Response::success(null, 'Sesión cerrada correctamente.');
    }

    /**
     * GET /perfil (Requiere sesión 'auth')
     */
    public function profile(): void
    {
        $currentUser = $this->user();
        $userId = (int) ($currentUser['id'] ?? 0);

        $user = $this->service->getProfile($userId);

        Response::success($user, 'Perfil obtenido.');
    }
}
