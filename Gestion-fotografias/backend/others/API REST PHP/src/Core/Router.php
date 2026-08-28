<?php

declare(strict_types=1);

namespace App\Core;

/**
 * ENRUTADOR HTTP POR TABLA DECLARATIVA
 * ==============================================================================
 * WHAT: Compara el método HTTP y la URI solicitada contra las rutas registradas,
 *       extrae parámetros dinámicos `{id}`, ejecuta el middleware y despacha al controlador.
 * WHY:  Reemplaza los switch gigantes en index.php por una estructura orientada a
 *       objetos escalable y limpia.
 * ==============================================================================
 */
class Router
{
    /**
     * @var array<int, array{method: string, parts: array<int, string>, controller: string, action: string, middleware: ?string}>
     */
    private array $routes = [];

    /**
     * Registra una nueva ruta en la tabla de despacho.
     *
     * @param string $method Método HTTP (GET, POST, PUT, DELETE).
     * @param string $path Patrón de ruta (ej. '/productos' o '/productos/{id}').
     * @param string $controller Nombre de la clase del controlador (FQN).
     * @param string $action Nombre del método del controlador.
     * @param string|null $middleware Requisito de seguridad (null, 'auth', 'admin').
     */
    public function add(string $method, string $path, string $controller, string $action, ?string $middleware = null): void
    {
        $this->routes[] = [
            'method'     => strtoupper($method),
            'parts'      => explode('/', trim($path, '/')),
            'controller' => $controller,
            'action'     => $action,
            'middleware' => $middleware,
        ];
    }

    /**
     * Busca la ruta coincidente y ejecuta el flujo de middleware y controlador.
     *
     * @param string $method Método HTTP de la petición entrante.
     * @param string $path Ruta URL solicitada.
     */
    public function dispatch(string $method, string $path): void
    {
        $requestedParts = explode('/', trim($path, '/'));

        foreach ($this->routes as $route) {
            if ($route['method'] !== strtoupper($method)) {
                continue;
            }

            if (count($route['parts']) !== count($requestedParts)) {
                continue;
            }

            $matches = true;
            $parameter = null;

            foreach ($route['parts'] as $position => $part) {
                // Comodín {id} para rutas parametrizadas
                if ($part === '{id}') {
                    $parameter = $requestedParts[$position];
                    continue;
                }

                if ($part !== $requestedParts[$position]) {
                    $matches = false;
                    break;
                }
            }

            if ($matches) {
                // 1. Ejecutar Middleware antes de instanciar el controlador
                AuthMiddleware::handle($route['middleware']);

                // 2. Instanciación dinámica del controlador
                $controllerClass = $route['controller'];
                $actionMethod = $route['action'];

                if (!class_exists($controllerClass)) {
                    Response::error("Controlador {$controllerClass} no encontrado.", 500);
                }

                $controller = new $controllerClass();

                if (!method_exists($controller, $actionMethod)) {
                    Response::error("Acción {$actionMethod} no existe en el controlador.", 500);
                }

                // Invoca la acción pasando el parámetro de ruta si existe
                if ($parameter !== null) {
                    $controller->$actionMethod($parameter);
                } else {
                    $controller->$actionMethod();
                }

                return;
            }
        }

        Response::error("No existe esa dirección, o no se puede usar con el método {$method}.", 404);
    }
}
