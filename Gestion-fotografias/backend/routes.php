<?php

declare(strict_types=1);

use App\Core\Router;
use App\controllers\HomeController;

$router = new Router();

// Endpoint de prueba / diagnóstico
$router->add('GET', '/api/ping', HomeController::class, 'ping');

// Auth Endpoints
$router->add('POST', '/auth/register', AuthController::class, 'register');
$router->add('POST', '/auth/login', AuthController::class, 'login');
$router->add('POST', '/auth/logout', AuthController::class, 'logout');

return $router;