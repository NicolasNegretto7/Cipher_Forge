<?php

/**
 * CONTROLLER DE INICIO  (hijo de Controller)
 * ------------------------------------------------------------------
 * Atiende la dirección raíz "/" y devuelve la lista de lo que se
 * puede pedir. Sirve para saber de una que la API está andando.
 */
class HomeController extends Controller
{
    public function index($id = null)
    {
        /**
         * En producción no mostramos el mapa de la API ni usuarios de prueba.
         * Esto evita publicar información innecesaria, pero NO reemplaza la
         * autenticación y la autorización de cada endpoint.
         */
        if (APP_ENV === 'production') {
            Response::success([
                'api' => 'API de productos - UTU',
            ], 'API funcionando.');
        }

        // Esta ayuda es útil únicamente mientras desarrollamos y aprendemos.
        Response::success([
            'api' => 'API de productos - UTU',
            'entorno' => APP_ENV,
            'endpoints' => [
                'POST   /registro'           => 'crear una cuenta',
                'POST   /login'              => 'iniciar sesión y recibir la cookie',
                'POST   /logout'             => 'cerrar sesión y borrar la cookie',
                'GET    /perfil'             => 'mis datos (necesita sesión)',
                'GET    /productos'          => 'listar productos (?categoria=audio)',
                'GET    /productos/1'        => 'ver un producto',
                'POST   /productos'          => 'crear (necesita sesión)',
                'PUT    /productos/1'        => 'modificar (necesita sesión)',
                'DELETE /productos/1'        => 'borrar (solo admin)',
                'POST   /productos/1/vender' => 'vender: descuenta stock (necesita sesión)',
            ],
            // Nunca deben existir cuentas con estas claves en producción.
            'usuarios_de_prueba' => [
                'admin@utu.edu.uy / admin123 (admin)',
                'alumno@utu.edu.uy / alumno123 (usuario)',
            ],
        ]);
    }
}
