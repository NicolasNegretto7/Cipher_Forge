<?php

declare(strict_types=1);

namespace App\Core;

class Router{
    private array $routes=[];


public function add(string $method, string $path, string $controller, string $action, ?string $middleware = null): void{
$this->routes[] =[
    'method' => strtoupper($method),
    'parts' => explode('/', trim($path, '/')),
    'controller' => $controller,
    'action' => $action,
    'middleware' => $middleware,
];
}

public function dispatch(string $method, string $path): void{
    //Divide la ruta en partes para poder comparar
$requestedParts = explode('/', trim($path, '/'));

        foreach ($this->routes as $route) {

            if ($route['method'] !== strtoupper($method)) {
                continue;
            }
//Compara las cantidad de rutas separadas con las pedidas, de lo contrario la omite (mejor rendimiento que comparar palabra por palabra).
            if (count($route['parts']) !== count($requestedParts)) {
                continue;
            }

            $matches = true;
            $parameter = null;

            foreach ($route['parts'] as $position => $part) {

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

                AuthMiddleware::handle($route['middleware']);

                $controllerClass = $route['controller'];
                $actionMethod = $route['action'];

                if (!class_exists($controllerClass)) {
                    Response::error("Controlador {$controllerClass} no encontrado.", 500);
                }

                $controller = new $controllerClass();

                if (!method_exists($controller, $actionMethod)) {
                    Response::error("Acción {$actionMethod} no existe en el controlador.", 500);
                }

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