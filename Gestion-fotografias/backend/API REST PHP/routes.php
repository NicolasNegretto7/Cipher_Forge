<?php

declare(strict_types=1);

/**
 * MAPA DE RUTAS DE LA API REST
 * ==============================================================================
 * WHAT: Registra todas las rutas HTTP disponibles asociándolas a su Controlador,
 *       Método de acción y Middleware de seguridad correspondiente.
 * WHY:  Centraliza el mapa de la API en un único archivo declarativo. Permite
 *       inspeccionar de un vistazo todos los endpoints y sus permisos sin
 *       necesidad de abrir cada controlador individual.
 * ==============================================================================
 */

use App\Controllers\AuthController;
use App\Controllers\HomeController;
use App\Controllers\ProductController;
use App\Core\Router;

$router = new Router();

// ------------------------------------------------------------------------------
// 1. Endpoints Públicos / Diagnóstico
// ------------------------------------------------------------------------------
$router->add('GET', '/', HomeController::class, 'index');

// ------------------------------------------------------------------------------
// 2. Endpoints de Autenticación (Auth)
// ------------------------------------------------------------------------------
$router->add('POST', '/registro', AuthController::class, 'register');
$router->add('POST', '/login',    AuthController::class, 'login');
$router->add('POST', '/logout',   AuthController::class, 'logout');
$router->add('GET',  '/perfil',   AuthController::class, 'profile', 'auth');

// ------------------------------------------------------------------------------
// 3. Endpoints de Productos (CRUD + Operaciones de Negocio)
// ------------------------------------------------------------------------------
$router->add('GET',    '/productos',           ProductController::class, 'index');
$router->add('GET',    '/productos/{id}',      ProductController::class, 'show');
$router->add('POST',   '/productos',           ProductController::class, 'store',   'auth');
$router->add('PUT',    '/productos/{id}',      ProductController::class, 'update',  'auth');
$router->add('DELETE', '/productos/{id}',      ProductController::class, 'destroy', 'admin');
$router->add('POST',   '/productos/{id}/vender', ProductController::class, 'sell',  'auth');

return $router;
