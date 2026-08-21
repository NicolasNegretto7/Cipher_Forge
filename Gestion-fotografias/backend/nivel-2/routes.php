<?php

/**
 * ==================================================================
 * EL MAPA DE LA API
 * ==================================================================
 * Todas las direcciones que existen, juntas y en una sola pantalla.
 * Si alguien pregunta "¿qué se le puede pedir a esta API?", se le
 * muestra este archivo y listo.
 *
 * Cada línea se lee así:
 *
 *   método HTTP  |  dirección  |  qué clase atiende  |  qué método
 *
 * ------------------------------------------------------------------
 * FIJATE EN /productos: la MISMA dirección hace cosas distintas
 * según el método (GET lista, POST crea). Eso es REST.
 *
 * Y {id} es un comodín: vale para /productos/1, /productos/2, etc.
 * Ese número le llega al método como parámetro.
 *
 * (Las direcciones quedan en español porque son la cara visible de
 * la API: es lo que escriben los que la consumen. El código, en
 * cambio, va en inglés, que es la convención.)
 *
 * ------------------------------------------------------------------
 * EL QUINTO PARÁMETRO: EL MIDDLEWARE
 *
 * Ahí se declara quién puede entrar a esa ruta, ANTES de que el
 * pedido llegue al controller (ver core/AuthMiddleware.php):
 *
 *   (nada)   -> ruta pública, cualquiera puede pedirla
 *   'auth'   -> hay que estar logueado (cualquier rol)
 *   'admin'  -> hay que estar logueado Y ser admin
 * ==================================================================
 */

$router = new Router();

// ---- Inicio ------------------------------------------------------
$router->add('GET', '/', 'HomeController', 'index');

// ---- Entrar al sistema -------------------------------------------
$router->add('POST', '/registro', 'AuthController', 'register');
$router->add('POST', '/login',    'AuthController', 'login');

// Logout es público para poder borrar incluso una cookie vencida o inválida.
$router->add('POST', '/logout',   'AuthController', 'logout');
$router->add('GET',  '/perfil',   'AuthController', 'profile', 'auth');

// ---- Productos ---------------------------------------------------
$router->add('GET',    '/productos',      'ProductController', 'index');
$router->add('GET',    '/productos/{id}', 'ProductController', 'show');
$router->add('POST',   '/productos',      'ProductController', 'store',   'auth');
$router->add('PUT',    '/productos/{id}', 'ProductController', 'update',  'auth');
$router->add('DELETE', '/productos/{id}', 'ProductController', 'destroy', 'admin');

// Una acción que no es un CRUD: vender descuenta stock.
$router->add('POST', '/productos/{id}/vender', 'ProductController', 'sell', 'auth');

return $router;
