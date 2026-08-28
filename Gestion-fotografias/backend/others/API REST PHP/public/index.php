<?php

declare(strict_types=1);

/**
 * FRONT CONTROLLER — PUNTO DE ENTRADA ÚNICO
 * ==============================================================================
 * WHAT: Todas las peticiones HTTP ingresan por este archivo único.
 * WHY:  Centraliza la inicialización del entorno, el registro del autocargador PSR-4,
 *       la política de CORS con credenciales para SPA, y el despacho seguro de rutas.
 * ==============================================================================
 */

// 1. Cargar archivo de configuración y variables de entorno
require_once __DIR__ . '/../config.php';

// 2. Autocargador PSR-4 (Soporta Composer si existe 'vendor/autoload.php' y fallback nativo)
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    $baseDir = __DIR__ . '/../src/';

    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }

    $relativeClass = substr($class, $len);
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (file_exists($file)) {
        require_once $file;
    }
});

use App\Core\Response;

// 3. Configuración de Seguridad y CORS (Cross-Origin Resource Sharing)
$origin = $_SERVER['HTTP_ORIGIN'] ?? null;

if ($origin === FRONTEND_ORIGIN) {
    header('Access-Control-Allow-Origin: ' . FRONTEND_ORIGIN);
    header('Access-Control-Allow-Credentials: true');
    header('Vary: Origin');
}

header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');

// Respuesta inmediata a peticiones preflight OPTIONS
if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// 4. Captura del Método y Ruta HTTP solicitada
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($uri, PHP_URL_PATH) ?? '/';

// 5. Despacho seguro de la petición hacia el Router
try {
    /** @var \App\Core\Router $router */
    $router = require __DIR__ . '/../routes.php';

    $router->dispatch($method, $path);
} catch (PDOException $exception) {
    error_log('Error PDO en API REST: ' . $exception->getMessage());
    Response::error('Ocurrió un error interno con la base de datos.', 500);
} catch (Throwable $exception) {
    error_log('Error crítico en API REST: ' . $exception->getMessage());
    Response::error('Ocurrió un error interno en el servidor.', 500);
}
