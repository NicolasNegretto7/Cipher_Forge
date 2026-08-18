<?php

declare(strict_types=1);

/**
 * Front Controller: Punto de entrada único para la API REST de Cipher_Forge.
 * 
 * Configura CORS, registra el autocargador PSR-4, define rutas con
 * protección por Middlewares y despacha la petición actual.
 */

// 1. Encabezados CORS (Cross-Origin Resource Sharing)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Responder de inmediato a las peticiones Preflight (OPTIONS) de los navegadores
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 2. Autocargador PSR-4 nativo sin Composer
spl_autoload_register(function (string $class): void {
    $prefixes = [
        'App\\'    => __DIR__ . '/../src/',
        'Config\\' => __DIR__ . '/../config/',
    ];

    foreach ($prefixes as $prefix => $baseDir) {
        $len = strlen($prefix);
        if (strncmp($prefix, $class, $len) === 0) {
            $relativeClass = substr($class, $len);
            $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

            if (file_exists($file)) {
                require_once $file;
                return;
            }
        }
    }
});

use App\Controllers\AuthController;
use App\Controllers\CollectionController;
use App\Controllers\DownloadController;
use App\Controllers\FileController;
use App\Controllers\ImageController;
use App\Core\Request;
use App\Core\Response;
use App\Core\Router;
use App\Middlewares\AuthMiddleware;
use App\Middlewares\RoleMiddleware;

// 3. Captura global de excepciones no controladas
set_exception_handler(function (Throwable $e): void {
    Response::error(
        'Error crítico en el servidor: ' . $e->getMessage(),
        500
    );
});

// 4. Instancias del Núcleo
$request = new Request();
$router = new Router();

// Middleware helpers reutilizables
$authRequired = new AuthMiddleware(optional: false);
$authOptional = new AuthMiddleware(optional: true);
$onlyPhotographer = new RoleMiddleware('fotografo');

// --- RUTAS DE LA API ---

// Health check / Índice de bienvenida
$router->get('/', function (Request $req): void {
    Response::success([
        'system'      => 'Cipher_Forge REST API',
        'version'     => '1.0.0',
        'status'      => 'online',
        'auth_mode'   => 'Stateless Bearer Tokens (No Cookies)',
        'endpoints'   => [
            'POST /api/auth/register'            => 'Registro de usuarios (fotografo/cliente)',
            'POST /api/auth/login'               => 'Login (emite Bearer token de 24h)',
            'POST /api/auth/logout'              => 'Cierre de sesión / Invalidar token',
            'GET /api/auth/me'                   => 'Perfil del usuario autenticado',
            'GET /api/collections'               => 'Listar colecciones accesibles',
            'GET /api/collections/{uuid}'        => 'Detalle de colección por UUID',
            'POST /api/collections'              => 'Crear colección (Solo fotógrafo)',
            'PUT /api/collections/{uuid}'        => 'Actualizar colección (Solo fotógrafo)',
            'DELETE /api/collections/{uuid}'     => 'Eliminar colección (Solo fotógrafo)',
            'POST /api/collections/{uuid}/images'=> 'Subir imagen multipart (Solo fotógrafo)',
            'GET /api/files/{id}'                => 'Servir imagen (preview / watermarked / original)',
            'GET /api/collections/{uuid}/download'=> 'Descarga masiva de la colección en ZIP',
        ],
    ], 'API Cipher_Forge en funcionamiento');
});

// Módulo 1: Autenticación
$router->post('/api/auth/register', [AuthController::class, 'register']);
$router->post('/api/auth/login', [AuthController::class, 'login']);
$router->post('/api/auth/logout', [AuthController::class, 'logout'], [$authRequired]);
$router->get('/api/auth/me', [AuthController::class, 'me'], [$authRequired]);

// Módulo 2: Colecciones / Galerías
$router->get('/api/collections', [CollectionController::class, 'index'], [$authOptional]);
$router->get('/api/collections/{uuid}', [CollectionController::class, 'show'], [$authOptional]);
$router->post('/api/collections', [CollectionController::class, 'store'], [$authRequired, $onlyPhotographer]);
$router->put('/api/collections/{uuid}', [CollectionController::class, 'update'], [$authRequired, $onlyPhotographer]);
$router->delete('/api/collections/{uuid}', [CollectionController::class, 'destroy'], [$authRequired, $onlyPhotographer]);

// Módulo 3: Subida y procesamiento de imágenes
$router->post('/api/collections/{uuid}/images', [ImageController::class, 'upload'], [$authRequired, $onlyPhotographer]);

// Módulo 4: Entrega segura de archivos binarios
$router->get('/api/files/{id}', [FileController::class, 'serve'], [$authOptional]);

// Módulo 5: Descarga masiva ZIP
$router->get('/api/collections/{uuid}/download', [DownloadController::class, 'downloadZip'], [$authOptional]);

// 5. Despachar la petición entrante
$router->dispatch($request);
