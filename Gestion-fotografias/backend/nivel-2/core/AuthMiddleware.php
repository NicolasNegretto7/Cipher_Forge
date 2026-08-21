<?php

/**
 * CLASE AUTHMIDDLEWARE (middleware de autenticación)
 * ==================================================================
 * ¿QUÉ ES UN MIDDLEWARE?
 *
 * Es un filtro que corre ANTES de que el pedido llegue al controller.
 * La idea es: "revisá esto primero, y si no pasa, ni te molestes en
 * seguir". El nombre es literal: queda "en el medio" (middle) entre
 * el pedido que llega y el controller que lo atiende.
 *
 * En nivel-1 (que no tiene Router ni middleware) cada controller pide
 * el login por su cuenta, adentro del método (`requireLogin()` al
 * principio de store(), de destroy(), etc. — mirá
 * controllers/ProductController.php de nivel-1). Eso funciona, pero
 * mezcla dos preguntas distintas: "¿quién puede entrar a esta ruta?"
 * (autenticación) y "¿qué hace esta ruta?" (el trabajo del
 * controller).
 *
 * Acá esa primera pregunta se contesta en UN solo lugar (este
 * archivo) y se declara al lado de cada ruta, en routes.php:
 *
 *     $router->add('DELETE', '/productos/{id}', 'ProductController', 'destroy', 'admin');
 *                                                                                  ^^^^^^^
 *                                                                    con qué middleware corre
 *
 * Así, con solo mirar routes.php, sabés qué rutas piden login y
 * cuáles no, sin tener que abrir cada controller.
 *
 * ------------------------------------------------------------------
 * ¿QUIÉN LO LLAMA?
 *
 * Router::dispatch(), justo antes de instanciar el controller. Mirá
 * ahí el "AuthMiddleware::handle($route['middleware']);".
 * ==================================================================
 */
class AuthMiddleware
{
    /**
     * El usuario del token, una vez validado. Lo dejamos guardado acá
     * (en una propiedad ESTÁTICA, compartida por toda la clase) para
     * que el controller lo pueda pedir después con self::user(), sin
     * tener que leer el token de nuevo.
     */
    private static ?array $user = null;

    /**
     * Corre el filtro que le corresponda a la ruta.
     *
     * @param string|null $requirement  null (ruta pública), 'auth'
     *                                  (hay que estar logueado) o
     *                                  'admin' (hay que ser admin).
     */
    public static function handle(?string $requirement): void
    {
        // Ruta pública: no hay nada que revisar.
        if ($requirement === null) {
            return;
        }

        // Token::read() busca la cookie HttpOnly, valida el JWT y devuelve
        // sus datos. Si no hay cookie o el JWT no sirve, devuelve null.
        $user = Token::read();

        // 401 = "no sé quién sos". Corta acá (Response::error() hace exit).
        if ($user === null) {
            Response::error('Tenés que iniciar sesión.', 401);
        }

        // 403 = "sé quién sos, pero no podés hacer esto".
        if ($requirement === 'admin' && $user['rol'] !== 'admin') {
            Response::error('Solo un administrador puede hacer esto.', 403);
        }

        self::$user = $user;
    }

    /** El usuario logueado, para el controller que lo necesite (ej. profile()). */
    public static function user(): ?array
    {
        return self::$user;
    }
}
