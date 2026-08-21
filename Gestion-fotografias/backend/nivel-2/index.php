<?php

/**
 * ==================================================================
 * INDEX.PHP - NIVEL 2: CON ROUTER  -  LA PUERTA DE ENTRADA
 * ==================================================================
 * TODOS los pedidos entran por acá. No hay un login.php, un
 * productos.php y un borrar.php sueltos: hay UN solo archivo que
 * recibe todo y se lo pasa al router.
 *
 * Es hermana de nivel-1/: las dos apps son independientes entre sí y
 * responden exactamente igual, pero acá hay más capas resolviendo
 * cosas por vos en un solo lugar en vez de repetirlas en cada
 * controller — el Router (en vez de un switch), la clase Controller
 * (en vez de funciones sueltas) y el AuthMiddleware (en vez de pedir
 * el login a mano en cada método). Mirá nivel-1/index.php para
 * comparar la versión sin nada de eso.
 *
 * Lo que hace, en orden:
 *
 *   1. Carga los archivos de cada capa
 *   2. Mira QUÉ MÉTODO usaron (GET, POST, PUT, DELETE)
 *   3. Mira QUÉ DIRECCIÓN pidieron (/productos/3)
 *   4. Se lo entrega al router, que sabe quién lo atiende
 *
 * ------------------------------------------------------------------
 * EL RECORRIDO Y LAS RESPONSABILIDADES:
 *
 *   ROUTER      ¿quién atiende este pedido?
 *      |
 *   MIDDLEWARE  ¿está logueado? ¿tiene el rol necesario?
 *      |
 *   CONTROLLER  recibe y responde HTTP
 *      |
 *   VALIDATOR   ¿los datos vienen bien?
 *      |
 *   DTO         transporta los datos válidos
 *      |
 *   SERVICE     las reglas del negocio                    (el sistema)
 *      |
 *   REPOSITORY  buscar y guardar                          (los datos)
 *
 * Cada pieza conoce solo lo necesario. El controller usa validator, DTO
 * y service; el repository no sabe que existe HTTP y el controller no
 * sabe qué es una tabla SQL.
 *
 * ------------------------------------------------------------------
 * NOTA SOBRE EL IDIOMA
 * El código (clases, métodos, variables) va en INGLÉS, que es la
 * convención en programación y lo que te vas a encontrar en Laravel,
 * en Symfony y en cualquier proyecto. Las explicaciones y los mensajes
 * quedan en español.
 * ==================================================================
 */

// ------------------------------------------------------------------
// 1) CARGAR LOS ARCHIVOS
// Están agrupados por capa. El orden importa: primero las clases
// padre, después las hijas.
// ------------------------------------------------------------------
require_once __DIR__ . '/config.php';

/**
 * LIBRERÍAS EXTERNAS (las que instalamos con Composer)
 *
 * Esta única línea carga TODAS las librerías que instalamos. Hoy es una
 * sola, firebase/php-jwt, la que se usa en PHP para los tokens.
 *
 * ¿Cómo llegó ahí? Con un comando:
 *
 *     composer require firebase/php-jwt
 *
 * Composer la descargó, la dejó en la carpeta vendor/ y anotó en
 * composer.json que este proyecto la necesita. La carpeta vendor/ NO se
 * toca ni se modifica: es código de otra gente.
 *
 * El "autoload" es un cargador automático: cuando PHP se encuentra con
 * una clase que no conoce, sale a buscar el archivo solo. Por eso acá
 * no hay que poner un require por cada archivo de la librería.
 */
require_once __DIR__ . '/vendor/autoload.php';

// Core: las herramientas que usa todo el resto.
require_once __DIR__ . '/core/Database.php';
require_once __DIR__ . '/core/Response.php';
require_once __DIR__ . '/core/Token.php';
require_once __DIR__ . '/core/AuthMiddleware.php';
require_once __DIR__ . '/core/Router.php';

// Models: las cosas del problema (un usuario, un producto).
require_once __DIR__ . '/models/User.php';
require_once __DIR__ . '/models/Product.php';

// Validators: revisan la forma de los datos de cada endpoint.
require_once __DIR__ . '/validators/AuthValidator.php';
require_once __DIR__ . '/validators/ProductValidator.php';

// DTOs: transportan datos ya validados y normalizados.
require_once __DIR__ . '/dtos/RegisterDTO.php';
require_once __DIR__ . '/dtos/LoginDTO.php';
require_once __DIR__ . '/dtos/CreateProductDTO.php';
require_once __DIR__ . '/dtos/UpdateProductDTO.php';
require_once __DIR__ . '/dtos/SellProductDTO.php';

// Repositories: acceso a los datos.
require_once __DIR__ . '/repositories/Repository.php';          // clase padre
require_once __DIR__ . '/repositories/UserRepository.php';      // hija
require_once __DIR__ . '/repositories/ProductRepository.php';   // hija

// Services: las reglas del negocio.
require_once __DIR__ . '/services/AuthService.php';
require_once __DIR__ . '/services/ProductService.php';

// Controllers: la puerta con el mundo de afuera.
require_once __DIR__ . '/controllers/Controller.php';         // clase padre
require_once __DIR__ . '/controllers/HomeController.php';     // hija
require_once __DIR__ . '/controllers/AuthController.php';     // hija
require_once __DIR__ . '/controllers/ProductController.php';  // hija

// ------------------------------------------------------------------
// 2) PERMISOS PARA EL NAVEGADOR (CORS)
// Sin esto, una página hecha en otro puerto (por ejemplo un front en
// React) no puede consumir nuestra API: el navegador la bloquea.
// ------------------------------------------------------------------
// $_SERVER es un arreglo superglobal con información de la petición.
// HTTP_ORIGIN indica desde qué origen (dominio y puerto) llamó el frontend.
// El operador ?? usa null y evita un aviso si no viene desde un navegador.
$origin = $_SERVER['HTTP_ORIGIN'] ?? null;

// Las cookies con CORS no permiten usar Access-Control-Allow-Origin: *.
// === exige que el origen recibido coincida exactamente con el configurado.
if ($origin === FRONTEND_ORIGIN) {
    // header() agrega una cabecera HTTP a la respuesta.
    header('Access-Control-Allow-Origin: ' . FRONTEND_ORIGIN);

    // Esta cabecera autoriza al navegador a enviar y recibir cookies.
    header('Access-Control-Allow-Credentials: true');

    // Vary avisa a cachés que la respuesta puede cambiar según el Origin.
    header('Vary: Origin');
}

// Cabeceras y métodos que el frontend tiene permitido utilizar.
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');

// Antes de un POST o un DELETE, el navegador manda un pedido OPTIONS
// preguntando "¿me dejás?". Le contestamos que sí y listo.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // 204 significa que la petición fue aceptada pero no hay cuerpo JSON.
    http_response_code(204);

    // exit termina esta petición antes de llegar al router.
    exit;
}

// ------------------------------------------------------------------
// 3) ¿QUÉ MÉTODO Y QUÉ DIRECCIÓN PIDIERON?
// ------------------------------------------------------------------

// GET, POST, PUT o DELETE
$method = $_SERVER['REQUEST_METHOD'];

// La dirección, sin lo que viene después del "?"
// Ejemplo: /productos/3?x=1  ->  /productos/3
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// ------------------------------------------------------------------
// 4) AL ROUTER
// routes.php arma el router con todas las rutas y nos lo devuelve.
// ------------------------------------------------------------------
/**
 * try contiene código que podría lanzar una EXCEPCIÓN.
 * catch captura esa excepción para que la API responda JSON en lugar de
 * mostrar un error interno de PHP.
 */
try {
    $router = require __DIR__ . '/routes.php';

    $router->dispatch($method, $path);
} catch (PDOException $exception) {
    // PDOException es el tipo específico que PDO lanza ante un fallo de BD.
    // Guardamos el detalle para poder investigar el problema, pero no
    // mostramos consultas ni información de la conexión al cliente.
    error_log($exception->getMessage());

    Response::error(
        'Ocurrió un error interno con la base de datos.',
        500
    );
} catch (Throwable $exception) {
    // Throwable es el tipo general: captura otras excepciones y errores PHP.
    // También evitamos que cualquier otro error inesperado muestre
    // información interna de la aplicación.
    error_log($exception->getMessage());

    Response::error(
        'Ocurrió un error interno.',
        500
    );
}
