<?php

declare(strict_types=1);

use App\Core\Router;
use App\controllers\HomeController;
use App\controllers\AuthController;

$router = new Router();

// Endpoint de prueba / diagnóstico
$router->add('GET', '/api/ping', HomeController::class, 'ping');

// Auth Endpoints
$router->add('POST', '/auth/register', AuthController::class, 'register');
$router->add('POST', '/auth/login', AuthController::class, 'login');

return $router;