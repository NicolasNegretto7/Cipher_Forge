<?php

/**
 * CONTROLLER DE AUTENTICACIÓN  (hijo de Controller)
 * ==================================================================
 * Registro, login y perfil.
 *
 * EL CIRCUITO COMPLETO:
 *
 *   1. El usuario manda email y contraseña          -> POST /login
 *   2. El SERVICE busca el usuario y verifica la contraseña
 *   3. Si está todo bien, crea un TOKEN
 *   4. El backend lo guarda en una cookie HttpOnly
 *   5. El navegador manda la cookie automáticamente en cada pedido
 *
 * El controller coordina el flujo HTTP. AuthValidator valida la entrada,
 * los DTOs transportan datos y AuthService aplica las reglas del sistema.
 * ==================================================================
 */
class AuthController extends Controller
{
    private AuthService $service;

    public function __construct()
    {
        $this->service = new AuthService();
    }

    /**
     * POST /registro
     * Recibe: { "nombre": "...", "email": "...", "clave": "..." }
     */
    public function register($id = null)
    {
        // requestData() convierte el JSON recibido en un arreglo PHP.
        $data = $this->requestData();

        // :: llama al método static sin crear un objeto AuthValidator.
        $errors = AuthValidator::validateRegister($data);

        // count() devuelve cuántos errores hay. Response::error() responde y hace exit.
        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        // new crea el DTO. Recién se crea después de validar los datos.
        $dto = new RegisterDTO($data);

        // El service recibe un objeto claro, no el arreglo HTTP crudo.
        $user = $this->service->register($dto);

        Response::success($user, 'Cuenta creada.', 201);
    }

    /**
     * POST /login
     * Recibe: { "email": "...", "clave": "..." }
     */
    public function login($id = null)
    {
        $data = $this->requestData();

        // Este método valida específicamente los datos de POST /login.
        $errors = AuthValidator::validateLogin($data);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        // LoginDTO transporta únicamente email y contraseña ya validados.
        $dto = new LoginDTO($data);

        // $session contiene temporalmente el JWT y los datos públicos del usuario.
        $session = $this->service->login($dto);

        // sendCookie() genera la cabecera HTTP Set-Cookie antes de enviar el JSON.
        Token::sendCookie($session['token']);

        // unset() quita el JWT del arreglo: no queremos exponerlo a JavaScript.
        // El navegador ya lo recibió dentro de la cookie HttpOnly.
        unset($session['token']);

        Response::success($session, 'Sesión iniciada.');
    }

    /** POST /logout */
    public function logout($id = null)
    {
        // Envía una cookie vencida para que el navegador elimine la sesión.
        Token::clearCookie();

        Response::success(null, 'Sesión cerrada.');
    }

    /**
     * GET /perfil   (hay que estar logueado)
     * Devuelve los datos del dueño del token.
     *
     * La ruta lleva el middleware 'auth' (mirá routes.php): si no hay
     * token válido, el pedido ni llega hasta acá. $this->user() ya
     * tiene los datos que dejó el AuthMiddleware.
     */
    public function profile($id = null)
    {
        $user = $this->service->getProfile($this->user()['id']);

        Response::success($user);
    }
}
