# API REST en PHP — proyecto para aprender

API REST con **PHP orientado a objetos**, armada con la separación en capas que se usa
en cualquier proyecto ordenado: **Router → Controller → Service → Repository**.

Tiene login con token, roles y el CRUD completo de productos.
Sin framework: PHP simple hablándole a MySQL con PDO.

> **Sobre el idioma:** el código (clases, métodos, variables, carpetas) está en **inglés**,
> que es la convención en programación y lo que se van a encontrar en Laravel, en Symfony
> y en cualquier proyecto real. Las explicaciones, los mensajes y las direcciones de la API
> quedan en **español**.

---

## Cómo levantarla

Necesitás PHP 8 con la extensión `pdo_mysql` habilitada (probá `php -v` y
`php -m | grep pdo_mysql`), y un MySQL corriendo (con XAMPP/WAMP ya viene
incluido).

**1. Creá la base y las tablas**, importando [database.sql](database.sql):

```bash
mysql -u root -p < database.sql
```

(o desde phpMyAdmin: Importar → elegir `database.sql` → Continuar). Trae
las tablas `usuarios` y `productos` con los mismos datos de prueba de
siempre.

**2. Creá tu archivo de configuración local** copiando la plantilla:

```bash
cp .env.example .env        # Linux/Mac
copy .env.example .env      # Windows
```

Revisá que `DB_HOST`, `DB_NAME`, `DB_USER` y `DB_PASSWORD` coincidan con
tu MySQL (los valores por defecto sirven para una instalación típica de
XAMPP con el usuario `root` sin contraseña). Usá `APP_ENV=development` para
ver la ayuda educativa en `/`; antes de publicar, cambialo a `production`.

**3. Levantala:**

```bash
cd nivel-2
php -S localhost:8000 index.php
```

Las librerías externas no se guardan en Git. Después de clonar el proyecto se
reconstruye la carpeta `vendor/` con:

```bash
composer install
```

> ¿Qué es el `.env` y por qué hace falta? Ver [docs/variables-de-entorno.md](../docs/variables-de-entorno.md).

Entrá a <http://localhost:8000> y te contesta en JSON.

También podés levantar los tres niveles y MySQL juntos mediante Docker siguiendo
la guía del [README principal](../README.md#levantar-todo-con-docker).

**Para probar:** abrí [peticiones.http](peticiones.http) en VS Code con la extensión
*REST Client* y apretá "Send Request". O copiá los pedidos en Postman.

**Usuarios de prueba:**

| Email | Contraseña | Rol |
|---|---|---|
| `admin@utu.edu.uy` | `admin123` | admin (puede borrar) |
| `alumno@utu.edu.uy` | `alumno123` | usuario |

Para volver todo al estado inicial: borrá la base y volvé a importar
[database.sql](database.sql) (`DROP DATABASE utu_demo;` y de nuevo
`mysql -u root -p < database.sql`).

Con Docker, `docker compose down -v` elimina el volumen de MySQL. La siguiente
vez que ejecutes `docker compose up --build`, la base se crea nuevamente. Este
comando borra todos los datos guardados dentro de ese volumen.

---

## El recorrido por capas y clases de apoyo

Esto es lo importante del proyecto. Router, controller, service y repository
forman el recorrido principal. El middleware filtra el acceso, el validator
revisa la entrada y el DTO transporta datos entre controller y service.

```
        El cliente pide:  POST /productos/3/vender
                    │
                    ▼
   ┌────────────────────────────────┐
   │  ROUTER                        │  ¿quién atiende este pedido?
   │  core/Router.php               │
   └────────────────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────┐
   │  MIDDLEWARE                    │  ¿está logueado? ¿es admin?
   │  core/AuthMiddleware.php       │  corta acá si no corresponde
   └────────────────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────┐
   │  CONTROLLER                    │  coordina el pedido y la respuesta
   │  controllers/                  │  usa Validator y DTO; SABE DE HTTP
   └────────────────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────┐
   │  SERVICE                       │  las reglas del sistema
   │  services/                     │  "no se puede vender más
   │                                │   de lo que hay"
   └────────────────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────┐
   │  REPOSITORY                    │  buscar y guardar
   │  repositories/                 │  SABE DE DATOS (SQL)
   └────────────────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────┐
   │  MODEL                         │  un producto, un usuario
   │  models/                       │  los datos y sus reglas propias
   └────────────────────────────────┘
```

### Quién hace qué

| Capa | Sí hace | No hace |
|---|---|---|
| **Router** | mirar la dirección y llamar al middleware + al controlador | nada más |
| **Middleware** | validar el JWT de la cookie, exigir el rol necesario | reglas del negocio, contestar el pedido en sí |
| **Controller** | leer el pedido, llamar al validator, crear el DTO y responder JSON | reglas del negocio, SQL |
| **Validator** | revisar campos, tipos y formatos de cada endpoint | consultar la base, transportar datos, responder HTTP |
| **DTO** | normalizar y transportar datos ya validados | validar, consultar la base, responder HTTP |
| **Service** | las reglas del sistema | tocar `$_GET`, contestar HTTP, escribir SQL |
| **Repository** | buscar, guardar, borrar | decidir si algo está permitido |
| **Model** | guardar sus datos y cuidarlos | saber de dónde vino ni a dónde va |

### Repository o DAO: el mismo trabajo, dos nombres

A la capa que busca y guarda datos le vas a ver dos nombres:

- **Repository** — es el que se usa en el PHP de hoy: así lo llaman Laravel y
  Symfony/Doctrine (`ProductRepository`).
- **DAO** (Data Access Object) — el nombre que viene del mundo Java.

En proyectos como este, con una clase por tabla, son la misma cosa. La diferencia
fina: un repository "de manual" se comporta como una colección de objetos en memoria
(un `save($product)` que decide solo si es un INSERT o un UPDATE), mientras que un
DAO es un espejo de la tabla. Acá dejamos `create()` y `update()` separados
justamente para que se vean las dos consultas SQL distintas.

### La prueba de que la separación sirve

Mirá el método `sell()` de [ProductService.php](services/ProductService.php):

```php
public function sell($id, $quantity)
{
    $product = $this->repository->findById($id);

    // Las tres reglas del negocio, una abajo de la otra:
    if ($product === null) {
        Response::error('No existe el producto ' . $id, 404);
    }

    if ($quantity < 1) {
        Response::error('La cantidad tiene que ser 1 o más.', 400);
    }

    if ($product->getStock() < $quantity) {
        Response::error('No hay stock suficiente.', 400);
    }

    // Si pasó todas: descontamos y guardamos.
    $product->setStock($product->getStock() - $quantity);
    $this->repository->update($product);

    return [...];
}
```

**Ese método se puede usar igual desde la API, desde el sistema de la caja del
local, o desde un proceso que importa pedidos de un archivo.** Si esas reglas
estuvieran adentro del controlador, solo servirían para pedidos web.

Y el controlador, al lado, queda en tres líneas (el login ya lo exigió el
middleware de la ruta, mirá [routes.php](routes.php)):

```php
public function sell($id = null)
{
    $data = $this->requestData();

    $sale = $this->service->sell($id, $data['cantidad'] ?? 1);

    Response::success($sale, 'Venta registrada.');
}
```

### ¿Cómo avisa el service que algo salió mal?

Llamando a `Response::error()`, que **contesta y corta el programa** (adentro hace
un `exit`). Por eso después de un `Response::error()` no hace falta ningún `return`:
lo que sigue no se ejecuta nunca.

Eso simplifica todo: no hay que ir devolviendo códigos de error de una capa a otra
ni preguntando "¿salió bien?" en cada paso. Si algo no cumple una regla, se avisa
ahí mismo y listo.

> Es exactamente lo que hace Laravel con su función `abort(404, 'No existe')`,
> que también se puede llamar desde cualquier parte y corta la ejecución.

---

## Los archivos

```
nivel-2/
│
├── index.php          ← la puerta: carga todo y llama al router
├── routes.php         ← EL MAPA: todas las direcciones juntas
├── config.php         ← la clave secreta y los datos de conexión a MySQL
├── database.sql       ← crea la base, las tablas y los datos de prueba
├── composer.json      ← qué librerías externas necesita el proyecto
│
├── core/              ← herramientas que usa todo el resto
│   ├── Router.php          decide qué controlador atiende
│   ├── AuthMiddleware.php  filtro de login/admin, antes del controller
│   ├── Database.php        conexión PDO a MySQL
│   ├── Response.php        contesta en JSON
│   └── Token.php           crea y valida el token (JWT)
│
├── controllers/       ← CAPA 1: hablan con el mundo (HTTP)
│   ├── Controller.php          clase PADRE
│   ├── HomeController.php      hija
│   ├── AuthController.php      hija: registro, login, perfil
│   └── ProductController.php   hija: el CRUD
│
├── validators/        ← validación básica de los datos de entrada
│   ├── AuthValidator.php
│   └── ProductValidator.php
│
├── dtos/              ← objetos que transportan datos ya validados
│   ├── RegisterDTO.php
│   ├── LoginDTO.php
│   ├── CreateProductDTO.php
│   ├── UpdateProductDTO.php
│   └── SellProductDTO.php
│
├── services/          ← CAPA 2: las reglas del negocio
│   ├── AuthService.php
│   └── ProductService.php
│
├── repositories/      ← CAPA 3: buscar y guardar datos (consultas SQL con PDO)
│   ├── Repository.php          clase PADRE: la conexión
│   ├── UserRepository.php      hija
│   └── ProductRepository.php   hija
│
├── models/            ← las cosas del problema
│   ├── User.php
│   └── Product.php
│
└── vendor/            ← las librerías que instaló Composer (NO SE TOCA)
    └── firebase/php-jwt/
```

### Validator y DTO: por qué están separados

El validator trabaja con la entrada cruda y devuelve una lista de errores. No
consulta la base ni responde HTTP. Cada endpoint tiene un método con nombre
explícito, por ejemplo `validateStore()` o `validateUpdate()`.

El DTO se crea únicamente después de que el validator terminó sin errores. Su
trabajo es limpiar y transportar los datos hasta el service. No decide si un
producto existe o si queda stock: esas son reglas de negocio del service.

```text
JSON → Controller → Validator → DTO → Service → Repository
```

---

## Qué hace cada pedido

| Método | Dirección | Qué hace | ¿Sesión? |
|---|---|---|---|
| `GET` | `/` | Ayuda | no |
| `POST` | `/registro` | Crear una cuenta | no |
| `POST` | `/login` | Iniciar sesión y crear la cookie | no |
| `POST` | `/logout` | Cerrar sesión y borrar la cookie | no |
| `GET` | `/perfil` | Mis datos | sí |
| `GET` | `/productos` | Listar (`?categoria=audio`) | no |
| `GET` | `/productos/3` | Ver uno | no |
| `POST` | `/productos` | Crear | sí |
| `PUT` | `/productos/3` | Modificar | sí |
| `DELETE` | `/productos/3` | Borrar | sí, **y ser admin** |
| `POST` | `/productos/3/vender` | Vender: descuenta stock | sí |

`/productos/3` aparece tres veces con **el mismo texto** y hace cosas distintas
según el método. **Eso es REST.**

El mapa completo está en [routes.php](routes.php), y se lee de un vistazo
(el último parámetro es el middleware — mirá la sección "El middleware de
autenticación" más abajo):

```php
$router->add('GET',    '/productos',      'ProductController', 'index');
$router->add('GET',    '/productos/{id}', 'ProductController', 'show');
$router->add('POST',   '/productos',      'ProductController', 'store',   'auth');
$router->add('PUT',    '/productos/{id}', 'ProductController', 'update',  'auth');
$router->add('DELETE', '/productos/{id}', 'ProductController', 'destroy', 'admin');
```

### Los nombres de los métodos del controlador

Son los que genera Laravel para un CRUD, así que conviene acostumbrarse desde ahora:

| Método | Qué hace | Pedido |
|---|---|---|
| `index()` | listar todos | `GET /productos` |
| `show()` | ver uno | `GET /productos/3` |
| `store()` | crear | `POST /productos` |
| `update()` | modificar | `PUT /productos/3` |
| `destroy()` | borrar | `DELETE /productos/3` |

---

## Esto mismo, en Laravel

El proyecto está armado para que el día que abran Laravel les resulte conocido.
Cada pieza de acá tiene su equivalente allá:

| Acá | En Laravel |
|---|---|
| `routes.php` con `$router->add('GET', '/productos', ...)` | `routes/api.php` con `Route::get('/productos', ...)` |
| `controllers/ProductController.php` | `app/Http/Controllers/ProductController.php` |
| `index()`, `show()`, `store()`, `update()`, `destroy()` | **los mismos nombres** |
| `services/ProductService.php` | `app/Services/ProductService.php` |
| `repositories/ProductRepository.php` | lo reemplaza **Eloquent**: `Product::all()`, `Product::find($id)` |
| `models/Product.php` | `app/Models/Product.php` (más corto: Eloquent no necesita getters) |
| `Response::success($data)` | `response()->json($data)` |
| `Response::error('No existe', 404)` | `abort(404, 'No existe')` |
| `AuthMiddleware` declarado en la ruta | el middleware `auth:sanctum` en la ruta |
| `Token` + cookie HttpOnly | autenticación SPA con Laravel Sanctum |
| `validators/ProductValidator.php` | un Form Request o `$request->validate(...)` |
| los DTOs de `dtos/` | clases DTO/Data propias (Laravel no obliga a usarlas) |
| `composer require` | igual, idéntico |

Comparalo con el `store()` de [ProductController.php](controllers/ProductController.php):

```php
// LARAVEL
public function store(Request $request)
{
    $data = $request->validate([
        'nombre' => 'required|min:3',
        'precio' => 'required|numeric|min:0',
    ]);

    $product = Product::create($data);

    return response()->json($product, 201);
}
```

Es más corto porque el framework ya trae hecha la validación y el acceso a datos.
**Pero el orden es el mismo:** validar → hacer el trabajo → contestar. Eso es lo
que hay que entender ahora; lo otro son atajos que se aprenden en un rato.

---

## ¿Dónde valido cada cosa?

La pregunta que siempre aparece cuando se separa en capas:

| Dónde | Qué se controla | Ejemplo |
|---|---|---|
| **Controller** | que los datos **vengan** y tengan la forma correcta | "falta el nombre", "el precio no es un número" |
| **Service** | las **reglas del sistema** | "ese nombre ya existe", "no hay stock suficiente" |
| **Model** | que el objeto no quede en un estado imposible | `setStock()` no acepta negativos |

**Regla práctica:** si para saber la respuesta hay que ir a buscar datos, es del service.

---

## La POO que aparece acá

| Concepto | Dónde mirarlo |
|---|---|
| **Clase y objeto** | `new Product(...)` en [ProductService.php](services/ProductService.php) |
| **Propiedades privadas** | `private float $price;` en [Product.php](models/Product.php) |
| **Constructor** | `__construct()` en [User.php](models/User.php) |
| **`$this`** | en todos lados: es "yo mismo, este objeto" |
| **Getters** | `getName()`, `getPrice()` |
| **Setters con reglas** | `setStock()` en [Product.php](models/Product.php) |
| **Encapsulamiento** | `User` no tiene `getPasswordHash()`: la contraseña entra y no sale más |
| **Métodos propios** | `hasStock()`, `checkPassword()` |
| **Métodos estáticos** | `Response::success()`, `Token::create()` |
| **Herencia (`extends`)** | `ProductRepository extends Repository`, `AuthController extends Controller` |
| **`protected`** | lo ve la clase y sus hijas, nadie más |
| **Composición** | el controller tiene un service adentro, y el service un repository |
| **Namespace y `use`** | [Token.php](core/Token.php): `use Firebase\JWT\JWT;` para usar la librería |
| **`try` / `catch`** | `Token::read()`: la librería avisa de los errores lanzando excepciones |

### Los ejemplos para mostrar en el pizarrón

**1. Para qué sirve un setter** — [Product.php](models/Product.php)

```php
public function setStock($stock)
{
    // El objeto se protege solo: nunca va a tener stock negativo,
    // no importa quién intente modificarlo.
    $this->stock = max(0, (int) $stock);
}
```

Probalo: mandá `{"stock": -50}` en un PUT y mirá qué se guarda.

**2. Para qué sirve la herencia** — [Repository.php](repositories/Repository.php)

`UserRepository` y `ProductRepository` necesitan las dos una conexión a la
base para hacer sus consultas. Ese código (conseguir la conexión PDO) está
escrito **una sola vez** en la clase padre y las dos hijas lo usan gratis,
sin escribir su propio constructor.

**3. Para qué sirve el encapsulamiento** — [User.php](models/User.php)

La clase `User` no tiene ningún método para leer la contraseña. Lo único que se
puede hacer es **preguntarle** si una contraseña es la correcta:

```php
$user->checkPassword('admin123');   // true o false
```

---

## Cómo funciona el login con cookie HttpOnly

```
1. POST /login  { email, clave }
        ▼
2. El service busca el usuario y verifica la contraseña
        ▼
3. Si está bien, arma un TOKEN FIRMADO
        ▼
4. El backend lo manda en una cookie HttpOnly
        ▼
5. El navegador guarda y manda la cookie automáticamente
        ▼
6. El servidor recalcula la firma. ¿Coincide? Pasa. ¿No? 401.
```

**Tres cosas para tener claras:**

1. El servidor **no guarda ninguna sesión**. La información viaja en el JWT de la cookie.
2. El contenido del token **se puede leer** (pegá uno en <https://jwt.io> y mirá).
   Está en Base64, **no está encriptado** → nunca se pone una contraseña adentro.
3. Lo que lo protege es **la firma**: si alguien cambia `"rol":"usuario"` por
   `"rol":"admin"`, la firma deja de coincidir y el token se rechaza. Para
   recalcularla necesitaría la clave secreta, que solo la tiene el servidor.

Como la cookie es `HttpOnly`, el frontend no puede leer el JWT. Solo tiene que
pedirle al navegador que incluya cookies tanto en el login como en las demás
peticiones:

```javascript
fetch('http://localhost:8000/login', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, clave })
});
```

El origen del frontend se configura en `.env`:

```env
FRONTEND_ORIGIN=http://localhost:5173
```

---

## El middleware de autenticación

¿Quién revisa la cookie y su token en cada pedido? [AuthMiddleware.php](core/AuthMiddleware.php),
y lo hace **antes** de que el controller se entere de que hubo un pedido.

Cada ruta declara, en [routes.php](routes.php), con qué middleware corre —
es el quinto parámetro de `$router->add(...)`:

```php
$router->add('GET',    '/productos',      'ProductController', 'index');            // pública
$router->add('POST',   '/productos',      'ProductController', 'store',   'auth');   // hay que estar logueado
$router->add('DELETE', '/productos/{id}', 'ProductController', 'destroy', 'admin');  // hay que ser admin
```

Y [Router::dispatch()](core/Router.php) lo corre justo antes de instanciar el
controller:

```php
AuthMiddleware::handle($route['middleware']);   // corta acá si no corresponde

$controller = new $class();
$controller->$action($parameter);
```

Si `AuthMiddleware::handle()` no está conforme, contesta 401/403 y listo — ni
siquiera se llega a crear el `ProductController`. Por eso los controllers ya
no tienen ningún `requireLogin()` ni `requireAdmin()`: esa pregunta ("¿quién
puede entrar acá?") se contesta en un solo lugar, mirando routes.php, en vez
de tener que abrir cada controller para saberlo.

Cuando un controller sí necesita los datos del usuario logueado (no solo
saber que hay uno), los pide con `$this->user()` — mirá
[AuthController::profile()](controllers/AuthController.php):

```php
public function profile($id = null)
{
    $user = $this->service->getProfile($this->user()['id']);

    Response::success($user);
}
```

> Esto es exactamente lo que hace Laravel con el middleware `auth:sanctum`
> declarado en la ruta, y `$request->user()` para leer quién está logueado.

---

## La librería de tokens

El trabajo sucio del token no lo hacemos nosotros: lo hace
**[firebase/php-jwt](https://github.com/firebase/php-jwt)**, que es la librería
estándar de PHP para esto. La instalamos con Composer y quedó en `vendor/`,
carpeta que **no se toca nunca**: es código de otra gente.

Con eso, [Token.php](core/Token.php) queda en dos líneas de verdad:

```php
// crear
return JWT::encode($payload, SECRET_KEY, 'HS256');

// validar
$payload = JWT::decode($token, new Key(SECRET_KEY, 'HS256'));
```

### ¿Por qué no lo escribimos nosotros, si son 30 líneas?

Porque en seguridad **"casi bien" es igual a "mal"**. Un detalle chico y la puerta
queda abierta:

- comparar la firma con `==` en vez de en tiempo constante,
- aceptar un token que dice `"alg": "none"` (o sea, sin firma),
- olvidarse de mirar el vencimiento.

Esa librería la revisaron y la atacaron miles de personas durante años. Nuestro
código, no. **La seguridad no se improvisa:** contraseñas, tokens y encriptación
se hacen siempre con herramientas ya probadas.

### Por qué `Token` sigue existiendo igual

Podríamos llamar a `JWT::encode()` directo desde el service, pero entonces la
librería quedaría desparramada por todo el proyecto. Así, si algún día cambiamos
de librería, se toca **un solo archivo**.

A eso se le dice *envolver* una librería (wrapper): nuestro código le habla a
`Token`, y `Token` es el único que le habla a la librería.

### Cómo lo hacíamos a mano

Vale la pena mirarlo una vez para entender que adentro no hay magia. Un JWT
firmado con HS256 es esto:

```php
$part1 = base64url(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
$part2 = base64url(json_encode($payload));

// la firma es un HMAC-SHA256 de las dos partes, con la clave secreta
$signature = base64url(hash_hmac('sha256', "$part1.$part2", SECRET_KEY, true));

$token = "$part1.$part2.$signature";
```

Validar es recalcular la firma y compararla con `hash_equals()`. Nada más.
La librería hace exactamente eso, pero contemplando todos los casos borde.

---

## Composer, el gestor de librerías

Nadie escribe todo desde cero. Cuando necesitás algo que ya está resuelto (tokens,
mandar mails, generar PDFs, hablar con una API de pagos), buscás la librería y la
instalás. En PHP eso se hace con **Composer**.

Se instaló así, con un comando:

```bash
composer require firebase/php-jwt
```

Y eso hizo cuatro cosas:

| Qué hizo | Para qué sirve |
|---|---|
| Descargó la librería a `vendor/` | es el código que vamos a usar |
| Creó `composer.json` | la **lista de compras**: qué necesita este proyecto |
| Creó `composer.lock` | la versión **exacta** que quedó instalada (v7.1.0) |
| Generó `vendor/autoload.php` | carga las clases solo, sin `require` a mano |

### Los dos comandos que hay que saber

```bash
composer install    # lee composer.json y descarga todo lo que falta
composer update     # actualiza las librerías a versiones más nuevas
```

`composer install` es el importante: si le pasás este proyecto a alguien **sin**
la carpeta `vendor/`, con ese comando la reconstruye igual, con las mismas
versiones (para eso está el `.lock`).

### El autoload

Fijate que en [index.php](index.php) hay **una sola línea** para la librería:

```php
require_once __DIR__ . '/vendor/autoload.php';
```

No hay un `require` por cada archivo de la librería. El *autoload* es un cargador
automático: cuando PHP se topa con una clase que no conoce, va y busca el archivo
solo. Nuestras clases sí las cargamos a mano, a propósito, para que se vea la
lista completa de archivos del proyecto.

### Qué NO hay que hacer

- **No se modifica nada adentro de `vendor/`.** Si tocás ahí, el próximo
  `composer update` te pisa los cambios.
- **`vendor/` no se sube al repositorio** en un proyecto con Git: se sube
  `composer.json` y `composer.lock`, y cada uno corre `composer install`.
  (Acá la dejamos incluida para que en el liceo funcione copiando la carpeta.)

---

## Los códigos HTTP que usamos

| Código | Significa | Cuándo |
|---|---|---|
| `200` | OK | Salió todo bien |
| `201` | Created | Se creó algo (POST) |
| `400` | Bad Request | Datos mal, o una regla del negocio que no se cumple |
| `401` | Unauthorized | **No sé quién sos**: falta la cookie o venció el JWT |
| `403` | Forbidden | **Sé quién sos, pero no podés**: te falta el rol |
| `404` | Not Found | Eso no existe |

> El 401 y el 403 se confunden siempre.
> **401 = autenticación** (¿quién sos?) · **403 = autorización** (¿podés?).

---

## La seguridad que tiene (y por qué)

| Qué | Dónde |
|---|---|
| Las contraseñas se guardan encriptadas con `password_hash()` | [AuthService.php](services/AuthService.php) |
| Se verifican con `password_verify()`, nunca con `==` | [User.php](models/User.php) |
| La contraseña nunca sale en el JSON | `User::toArray()` |
| El mismo mensaje si falla el email o la contraseña | `AuthService::login()` |
| El rol nunca se acepta desde el pedido (nadie se hace admin solo) | `AuthService::register()` |
| Los tokens los maneja una librería probada, no código nuestro | [Token.php](core/Token.php) |
| Se exige el algoritmo HS256 al validar (evita el ataque `alg: none`) | `Token::read()` |
| El token vence | `Token::create()` |
| Todo lo que manda el cliente se valida | `AuthValidator` y `ProductValidator` |
| El JWT viaja en una cookie que JavaScript no puede leer | `Token::sendCookie()` con `HttpOnly` |
| Consultas preparadas contra inyección SQL | las consultas PDO de los repositories |

**Lo que le falta para un sistema real:** HTTPS obligatorio, protección CSRF
completa y frenar al que prueba mil contraseñas seguidas en el login (ver
[docs/seguridad-sqli-xss.md](../docs/seguridad-sqli-xss.md)
y [docs/variables-de-entorno.md](../docs/variables-de-entorno.md) para lo que ya está resuelto).

El estudiante que quiera continuar mejorando este nivel tiene una hoja de ruta
en [Mejoras opcionales para acercar el nivel 2 a una API profesional](../docs/mejoras-opcionales-nivel-2.md).

---

## La base de datos: MySQL con PDO

Los datos viven en una base MySQL de verdad, con dos tablas: `usuarios` y
`productos`. [database.sql](database.sql) las crea con el mismo esquema y
los mismos datos de prueba que se usaron siempre — importalo una vez (ver
"Cómo levantarla" más arriba) y listo.

[core/Database.php](core/Database.php) abre la conexión PDO (una sola vez
por pedido, con el patrón *singleton*) y se la pasa a
[Repository.php](repositories/Repository.php), la clase padre de la que
heredan `UserRepository` y `ProductRepository`. Cada método de esos dos
repositories hace su consulta SQL directo:

```php
public function findById($id)
{
    $sql = 'SELECT * FROM productos WHERE id = :id';

    $query = $this->db->prepare($sql);
    $query->execute([':id' => $id]);
    $row = $query->fetch();

    return $row === false ? null : $this->buildProduct($row);
}
```

**No hay que tocar ni los controllers, ni los services, ni los models**:
ellos le piden al repository "dame el producto 3" y no saben (ni les
importa) si por dentro hay una consulta SQL, un archivo o cualquier otra
cosa. Ese es todo el punto de haber separado en capas.

### Por qué el SQL se escribe así

```php
// MAL: cualquiera puede robar toda la base
$sql = "SELECT * FROM usuarios WHERE email = '" . $_POST['email'] . "'";

// BIEN: consulta preparada
$sql = "SELECT * FROM usuarios WHERE email = :email";
$query->execute([':email' => $email]);
```

En la primera, si alguien manda `' OR '1'='1` como email, la consulta cambia de
significado y devuelve **todos** los usuarios. Eso es **inyección SQL**. En la
segunda, el valor viaja aparte del SQL y el motor lo trata siempre como dato,
nunca como código.

---

## Documentación aparte

Estos temas se explican acá mismo, pero de pasada. Si quieren el detalle
completo de alguno, están desarrollados en `docs/`:

| Doc | De qué habla |
|---|---|
| [docs/http-y-rest.md](../docs/http-y-rest.md) | métodos HTTP, códigos de estado, qué es REST |
| [docs/variables-de-entorno.md](../docs/variables-de-entorno.md) | qué es un `.env`, cómo se lee, por qué no se sube a git |
| [docs/git-y-gitignore.md](../docs/git-y-gitignore.md) | qué archivos van a git y cuáles no, y por qué |
| [docs/seguridad-sqli-xss.md](../docs/seguridad-sqli-xss.md) | inyección SQL y XSS: qué son, y cómo las evita esta API |
| [docs/uso-de-ia.md](../docs/uso-de-ia.md) | cómo usar la IA para aprender (y no para copiar sin entender) |

---

## Ejercicios

De más fácil a más difícil:

1. Agregarle el campo `marca` al producto (model, repository, validator y DTO).
2. Agregar la regla "no se puede crear un producto con precio 0" — pensá primero
   **en qué capa** va.
3. Agregar `GET /productos/{id}/stock` que devuelva solo la cantidad.
4. Hacer que `DELETE` no borre de verdad: que ponga `activo = false` y que el
   listado no muestre los inactivos (*borrado lógico*).
5. Agregar paginación: `GET /productos?pagina=2&cantidad=5`.
6. Crear `Category` completa: `Category`, `CategoryRepository`, `CategoryService`,
   `CategoryController` y sus rutas.
7. Guardar las ventas de verdad: `Sale`, `SaleRepository`, y que `sell()` además de
   descontar stock registre la venta.
8. Agregar `GET /usuarios` que liste todos, **solo para admin**.

### Preguntas para pensar

- ¿Por qué `POST /productos` y no `GET /crearProducto`?
- Si las propiedades de `Product` fueran públicas, ¿qué problema traería?
- ¿Por qué después de un `Response::error()` no hace falta escribir `return`?
- Si `sell()` estuviera en el controller, ¿qué pasaría cuando haya que vender
  desde el sistema de la caja?
- ¿Qué pasa si le sacás el `exit` al método `send()` de `Response`?

---

## Para más adelante

Cuando esto se entienda bien, los pasos que siguen en un proyecto de verdad:

1. Que Composer cargue **también nuestras clases**, y no solo las librerías. Se agrega
   esto a `composer.json` y se corre `composer dump-autoload`:

   ```json
   "autoload": {
       "classmap": ["core/", "models/", "repositories/", "services/", "controllers/", "validators/", "dtos/"]
   }
   ```

   Con eso desaparecen los `require_once` de index.php. Los dejamos a propósito
   para que se vea qué archivos tiene el proyecto.
2. Manejar los errores con **excepciones** (`throw` / `try` / `catch`) en vez de `exit`.
3. **Inyección de dependencias**: que el repository se le pase al service desde afuera,
   en vez de que el service haga `new ProductRepository()`. Sirve para poder probarlo
   con datos falsos.

Ninguna de esas cosas hace falta para que la API funcione: son ordenamientos que
recién valen la pena cuando el proyecto crece.
