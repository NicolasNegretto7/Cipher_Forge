<?php

declare(strict_types=1);

use App\Core\Router;
use App\controllers\HomeController;
use App\controllers\AuthController;
use App\controllers\ColeccionController;
use App\controllers\MultimediaController;

$router = new Router();

// Endpoint de prueba / diagnóstico
$router->add('GET', '/api/ping', HomeController::class, 'ping');

// Auth Endpoints
$router->add('POST', '/auth/register', AuthController::class, 'register');
$router->add('POST', '/auth/login', AuthController::class, 'login');

// Colecciones Endpoints
$router->add('POST', '/colecciones', ColeccionController::class, 'create');

// Multimedia Endpoints (HU5, HU14, HU20)
$router->add('POST', '/colecciones/{id}/multimedia', MultimediaController::class, 'upload', 'auth');
$router->add('GET', '/colecciones/{id}/multimedia', MultimediaController::class, 'listar', 'optional');
$router->add('GET', '/multimedia/{id}/vista-previa', MultimediaController::class, 'vistaPrevia', 'optional');
$router->add('GET', '/multimedia/{id}/original', MultimediaController::class, 'original', 'optional');

return $router;