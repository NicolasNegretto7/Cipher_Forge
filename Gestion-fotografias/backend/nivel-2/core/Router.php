<?php

/**
 * CLASE ROUTER (enrutador)
 * ==================================================================
 * Es el "recepcionista" de la API: mira qué dirección pidieron y
 * decide QUÉ CONTROLLER y QUÉ MÉTODO la atienden.
 *
 * Antes esto era un switch gigante adentro de index.php. El problema
 * del switch es que crece y crece: con 20 direcciones se vuelve
 * ilegible. Con el router, todas las rutas quedan juntas en una sola
 * tabla (mirá el archivo routes.php) y se leen de un vistazo.
 *
 * Se usa así:
 *
 *     $router->add('GET', '/productos/{id}', 'ProductController', 'show');
 *
 * Que se lee: "si piden GET /productos/5, creá un ProductController
 * y llamá a su método show(5)".
 *
 * Hay un quinto parámetro opcional para el middleware (ver más abajo
 * y AuthMiddleware.php):
 *
 *     $router->add('DELETE', '/productos/{id}', 'ProductController', 'destroy', 'admin');
 * ==================================================================
 */
class Router
{
    /** Acá se van guardando todas las rutas. */
    private array $routes = [];

    /**
     * Anota una ruta en la tabla.
     *
     * @param string      $method     GET, POST, PUT o DELETE
     * @param string      $path       '/productos' o '/productos/{id}'
     * @param string      $controller nombre de la clase que atiende
     * @param string      $action     nombre del método que hay que llamar
     * @param string|null $middleware null (ruta pública), 'auth' (hay que
     *                                estar logueado) o 'admin' (hay que
     *                                ser administrador). Ver AuthMiddleware.
     */
    public function add($method, $path, $controller, $action, $middleware = null)
    {
        $this->routes[] = [
            'method' => $method,
            // Guardamos la dirección ya partida en pedazos:
            // '/productos/{id}'  ->  ['productos', '{id}']
            'parts'      => explode('/', trim($path, '/')),
            'controller' => $controller,
            'action'     => $action,
            'middleware' => $middleware,
        ];
    }

    /**
     * Busca la ruta que coincide con el pedido y la ejecuta.
     */
    public function dispatch($method, $path)
    {
        // Partimos la dirección que pidieron, igual que las guardadas.
        $requestedParts = explode('/', trim($path, '/'));

        foreach ($this->routes as $route) {

            // ¿Es el mismo método? (GET, POST...)
            if ($route['method'] !== $method) {
                continue; // no es esta, sigo con la próxima
            }

            // ¿Tienen la misma cantidad de pedazos?
            // '/productos' (1) nunca puede ser '/productos/5' (2).
            if (count($route['parts']) !== count($requestedParts)) {
                continue;
            }

            // Comparamos pedazo por pedazo, en la misma posición.
            // Ejemplo con la ruta guardada '/productos/{id}' y el
            // pedido '/productos/5':
            //   $route['parts']   = ['productos', '{id}']
            //   $requestedParts   = ['productos', '5']
            // posición 0: 'productos' vs 'productos' -> coinciden
            // posición 1: '{id}'      vs '5'          -> comodín, no se compara
            $matches   = true; // hasta ahora, todo pinta bien
            $parameter = null; // acá guardamos el valor real del {id}, si hay

            foreach ($route['parts'] as $position => $part) {

                // Si el pedazo guardado es "{id}", no importa qué texto
                // vino en el pedido: ES un match, y encima nos quedamos
                // con ese valor para pasárselo después al controller.
                if ($part === '{id}') {
                    $parameter = $requestedParts[$position];
                    continue; // paso al siguiente pedazo
                }

                // No es comodín: acá el texto tiene que ser EXACTAMENTE
                // igual (ej. 'productos' === 'productos'). Si no lo es,
                // esta ruta no es la que buscamos: cortamos el loop.
                if ($part !== $requestedParts[$position]) {
                    $matches = false;
                    break;
                }
            }

            if ($matches) {
                /**
                 * ANTES de instanciar el controller, corremos el
                 * MIDDLEWARE que le corresponda a esta ruta (mirá
                 * AuthMiddleware.php). Si la ruta pide login o ser
                 * admin y no corresponde, esto corta acá mismo con un
                 * 401/403 — el controller ni se entera de que hubo un
                 * pedido.
                 */
                AuthMiddleware::handle($route['middleware']);

                /**
                 * ACÁ PASA ALGO QUE LLAMA LA ATENCIÓN LA PRIMERA VEZ:
                 * el nombre de la clase y el del método están guardados
                 * en variables (son texto). PHP permite usarlos así:
                 *
                 *     $class = 'ProductController';
                 *     $object = new $class();      // new ProductController()
                 *
                 *     $action = 'show';
                 *     $object->$action(5);         // $object->show(5)
                 *
                 * Gracias a esto el router funciona con CUALQUIER
                 * controller, sin tener que conocerlos de antemano.
                 */
                $class  = $route['controller'];
                $action = $route['action'];

                $controller = new $class();

                if ($parameter !== null) {
                    $controller->$action($parameter);
                } else {
                    $controller->$action();
                }

                return;
            }
        }

        // Si recorrimos toda la tabla y ninguna coincidió...
        Response::error('No existe esa dirección, o no se puede usar con ' . $method . '.', 404);
    }
}
