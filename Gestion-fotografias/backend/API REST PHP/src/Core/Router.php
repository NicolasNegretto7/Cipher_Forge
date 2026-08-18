<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Enrutador HTTP avanzado con soporte para parámetros dinámicos y cadena de Middlewares.
 */
class Router
{
    /**
     * @var array<int, array{method: string, pattern: string, regex: string, paramNames: array<string>, handler: callable|array, middlewares: array<object>}>
     */
    private array $routes = [];

    public function get(string $path, callable|array $handler, array $middlewares = []): void
    {
        $this->addRoute('GET', $path, $handler, $middlewares);
    }

    public function post(string $path, callable|array $handler, array $middlewares = []): void
    {
        $this->addRoute('POST', $path, $handler, $middlewares);
    }

    public function put(string $path, callable|array $handler, array $middlewares = []): void
    {
        $this->addRoute('PUT', $path, $handler, $middlewares);
    }

    public function delete(string $path, callable|array $handler, array $middlewares = []): void
    {
        $this->addRoute('DELETE', $path, $handler, $middlewares);
    }

    private function addRoute(string $method, string $path, callable|array $handler, array $middlewares = []): void
    {
        $normalizedPath = '/' . trim($path, '/');
        if ($normalizedPath !== '/') {
            $normalizedPath = rtrim($normalizedPath, '/');
        }

        preg_match_all('/\{([a-zA-Z0-9_]+)\}/', $normalizedPath, $paramMatches);
        $paramNames = $paramMatches[1];

        $regexPattern = preg_replace('/\{[a-zA-Z0-9_]+\}/', '([^/]+)', $normalizedPath);
        $regex = '#^' . $regexPattern . '$#';

        $this->routes[] = [
            'method'      => strtoupper($method),
            'pattern'     => $normalizedPath,
            'regex'       => $regex,
            'paramNames'  => $paramNames,
            'handler'     => $handler,
            'middlewares' => $middlewares,
        ];
    }

    public function dispatch(Request $request): void
    {
        $requestMethod = $request->getMethod();
        $requestUri = $request->getUri();
        $allowedMethodsForUri = [];

        foreach ($this->routes as $route) {
            if (preg_match($route['regex'], $requestUri, $matches)) {
                $allowedMethodsForUri[] = $route['method'];

                if ($route['method'] === $requestMethod) {
                    array_shift($matches);

                    $routeParams = [];
                    foreach ($route['paramNames'] as $index => $name) {
                        $routeParams[$name] = $matches[$index] ?? null;
                    }
                    $request->setRouteParams($routeParams);

                    // 1. Ejecutar cadena de middlewares asignados a la ruta
                    foreach ($route['middlewares'] as $middleware) {
                        if (method_exists($middleware, 'handle')) {
                            $middleware->handle($request);
                        }
                    }

                    // 2. Ejecutar el controlador final
                    $this->executeHandler($route['handler'], $request, $routeParams);
                    return;
                }
            }
        }

        if (!empty($allowedMethodsForUri)) {
            header('Allow: ' . implode(', ', array_unique($allowedMethodsForUri)));
            Response::error(
                "Método {$requestMethod} no permitido para {$requestUri}. Permitidos: " . implode(', ', array_unique($allowedMethodsForUri)),
                405
            );
        }

        Response::error("Ruta no encontrada: {$requestMethod} {$requestUri}", 404);
    }

    private function executeHandler(callable|array $handler, Request $request, array $params): void
    {
        if (is_array($handler)) {
            [$controllerClass, $method] = $handler;
            if (!class_exists($controllerClass)) {
                Response::error("Controlador {$controllerClass} no encontrado.", 500);
            }

            $controllerInstance = new $controllerClass();
            if (!method_exists($controllerInstance, $method)) {
                Response::error("Acción {$method} no existe en el controlador.", 500);
            }

            $controllerInstance->$method($request, $params);
            return;
        }

        if (is_callable($handler)) {
            call_user_func($handler, $request, $params);
            return;
        }

        Response::error("Manejador de ruta inválido.", 500);
    }
}
