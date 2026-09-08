<?php
// QUÉ: Alias de compatibilidad hacia atrás para AuthMiddleware.
// POR QUÉ: Permite que el autoloader resuelva tanto App\Core\AuthMiddleware como App\middlewares\AuthMiddleware.

declare(strict_types=1);

namespace App\Core;

require_once __DIR__ . '/../middlewares/AuthMiddleware.php';

class_alias(\App\middlewares\AuthMiddleware::class, 'App\Core\AuthMiddleware');
