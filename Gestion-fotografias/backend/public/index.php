<?php


declare(strict_types=1);

// No exponer warnings/notices de PHP en el body de la respuesta (rompen el JSON y las cabeceras).
ini_set('display_errors', '0');
ini_set('log_errors', '1');

// Capturar errores fatales (ej. max_execution_time) que escapan al try/catch
// y emitir una respuesta JSON con código 500 en lugar de HTML con 200.
register_shutdown_function(function (): void {
    $error = error_get_last();

    // Solo intervenir ante errores fatales (E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR)
    if ($error !== null && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        // Limpiar cualquier output previo parcial que PHP haya emitido
        if (ob_get_length()) {
            ob_end_clean();
        }

        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode([
            'ok'      => false,
            'mensaje' => 'Error interno del servidor.',
        ], JSON_UNESCAPED_UNICODE);
    }
});

spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    $baseDir = __DIR__ . '/../src/';

    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }

    $relativeClass = substr($class, $len);
    // Convierte App\Core\Router en src/Core/Router.php
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (file_exists($file)) {
        require_once $file;
    }
});

use App\Core\Response;
use App\Core\Router;

//Cabeceras CORS básicas (para permitir peticiones desde el frontend)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
// Expone Content-Disposition para que el frontend use el nombre real del archivo en las descargas
// (sin esto, un fetch cross-origin no puede leer la cabecera y el navegador cae a un nombre genérico).
header('Access-Control-Expose-Headers: Content-Disposition, Content-Length');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($uri, PHP_URL_PATH) ?? '/';

// Despacho seguro hacia el Router
try {
    $router = require_once __DIR__ . '/../routes.php';
    $router->dispatch($method, $path);
} catch (Throwable $e) {
    Response::error("Error interno del servidor: " . $e->getMessage(), 500);
}