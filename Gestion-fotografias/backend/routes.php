<?php

declare(strict_types=1);

use App\Core\Router;
use App\controllers\HomeController;

$router = new Router();

// Endpoint de prueba / diagnóstico
$router->add('GET', '/api/ping', HomeController::class, 'ping');

return $router;