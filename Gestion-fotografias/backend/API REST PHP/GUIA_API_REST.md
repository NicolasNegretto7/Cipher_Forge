# Guía Maestra: Arquitectura por Capas para API REST en PHP

Bienvenido a la guía integral de arquitectura de backend para **APIs REST en PHP nativo orientado a objetos**. Este documento explica en profundidad el flujo estándar de la industria: **Router → Middleware → Controller → Validator → DTO → Service → Repository → Model**.

---

## 1. 🗺️ Mapa Visual de la Arquitectura

```
                        Petición HTTP entrante
                        (JSON, Query params, Cookie HttpOnly)
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │     public/index.php         │  ── Front Controller: Entorno, CORS y Autoload
                   └──────────────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │      src/Core/Router.php     │  ── ¿Quién atiende esta ruta? (routes.php)
                   └──────────────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │  src/Core/AuthMiddleware.php │  ── ¿Está autenticado? ¿Tiene rol admin?
                   └──────────────────────────────┘     (Corta con 401/403 si no cumple)
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │       src/Controllers/       │  ── Coordina el pedido HTTP y la respuesta
                   └──────────────────────────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  ▼                               ▼
     ┌────────────────────────┐      ┌────────────────────────┐
     │    src/Validators/     │      │       src/DTOs/        │
     │  ¿Tienen buen formato  │      │  Empaqueta y normaliza │
     │  los datos de entrada? │      │  datos válidos         │
     └────────────────────────┘      └────────────────────────┘
                  │                               │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │        src/Services/         │  ── REGLAS DE NEGOCIO DEL SISTEMA
                   │                              │     (No sabe qué es HTTP ni qué es SQL)
                   └──────────────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │      src/Repositories/       │  ── ACCESO A DATOS (SQL PDO Prepared Statements)
                   └──────────────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │         src/Models/          │  ── ENTIDADES DE DOMINIO Y SUS INVARIANTES
                   └──────────────────────────────┘
                                  │
                                  ▼
                   ┌──────────────────────────────┐
                   │      Base de Datos MySQL     │
                   └──────────────────────────────┘
```

---

## 2. 🏛️ Responsabilidades: Quién hace qué (y qué NUNCA debe hacer)

| Capa | Qué SÍ hace | Qué NUNCA debe hacer | Equivalente en Java |
| :--- | :--- | :--- | :--- |
| **Front Controller** (`public/index.php`) | Inicializa el entorno, CORS y despacha la petición al Router. | Escribir lógica de negocio o consultas SQL. | `SpringApplication.run()` |
| **Router** (`src/Core/Router.php`) | Compara método y URL, extrae comodines `{id}` y llama al controlador. | Validar entradas o contestar JSON directamente. | DispatcherServlet / `@RequestMapping` |
| **Middleware** (`src/Core/AuthMiddleware.php`) | Valida la firma del JWT en la cookie HttpOnly y verifica roles. | Contener reglas de stock o manipular la base de datos de negocio. | Spring Security Filter |
| **Controller** (`src/Controllers/`) | Lee HTTP, llama al Validator, instancia el DTO y responde JSON. | Consultar la base de datos o verificar contraseñas. | `@RestController` |
| **Validator** (`src/Validators/`) | Revisa sintaxis, formato, tipos (int, float) y longitudes mínimas. | Consultar la base de datos o responder HTTP. | Hibernate Validator (`@Valid`) |
| **DTO** (`src/DTOs/`) | Objeto inmutable tipado que transporta datos limpios al Service. | Validar datos o ejecutar operaciones SQL. | Records de Java (`record CreateProductDTO`) |
| **Service** (`src/Services/`) | Aplica las reglas del negocio (unicidad, cálculos, control de stock). | Tocar `$_GET`/`$_POST` o escribir sentencias SQL. | `@Service` |
| **Repository** (`src/Repositories/`) | Ejecuta consultas SQL con PDO (`prepare`, `bindValue`, `execute`). | Validar roles o decidir códigos HTTP (404/400). | Spring Data JPA / DAO (`@Repository`) |
| **Model** (`src/Models/`) | Representa la entidad y protege sus invariantes (setters con reglas). | Saber de dónde vino o enviar respuestas HTTP. | Entidad JPA (`@Entity`) |

---

## 3. 🔍 Validator vs DTO: ¿Por qué no son lo mismo?

Una confusión habitual al iniciar en arquitecturas profesionales es mezclar la validación con la transferencia de datos.

```
[ Petición JSON ] ──► [ Validator ] ──(¿Datos válidos?)──► [ DTO ] ──► [ Service ]
```

### 1. El Validator trabaja con datos "sucios"
El validador recibe el array asociativo crudo desde HTTP (`$data`). Su única misión es responder: **"¿Tienen la forma y tipo correctos estos datos?"**. Devuelve una lista de errores (`array`).
- No lanza excepciones.
- No instancia entidades.
- No consulta la base de datos.

### 2. El DTO trabaja con datos "limpios"
El DTO se instancia **únicamente después** de que el validador confirmó que no hay errores. Su trabajo es:
- Normalizar cadenas con `trim()` o `strtolower()`.
- Convertir tipos de datos con casts explícitos `(int)`, `(float)`.
- Encapsular las propiedades en campos privados con getters tipados.

```php
// En el Controlador (ProductController.php):

// 1. El Validator revisa la entrada cruda
$errors = ProductValidator::validateStore($data);
if (count($errors) > 0) {
    Response::error('Revisá los datos.', 400, $errors);
}

// 2. Recién aquí creamos el DTO con la certeza de que no romperá tipos
$dto = new CreateProductDTO($data);

// 3. El Service recibe el objeto DTO, garantizando un contrato estricto
$product = $this->service->create($dto);
```

---

## 4. 🧪 La Prueba de Fuego: ¿Por qué el Service no sabe de HTTP?

Observa el método `sell()` en `src/Services/ProductService.php`:

```php
// WHAT: Descuenta stock de un producto y registra la venta aplicando las reglas del sistema.
// WHY:  Permite reutilizar la misma lógica de venta desde la Web API, una app móvil o un script de terminal.
public function sell(int $id, SellProductDTO $dto): array
{
    $quantity = $dto->getQuantity();
    $product = $this->repository->findById($id);

    // Regla 1: El producto debe existir
    if ($product === null) {
        Response::error("No existe el producto con ID {$id}.", 404);
    }

    // Regla 2: No se puede vender más de lo que hay
    if ($product->getStock() < $quantity) {
        Response::error("No hay stock suficiente. Quedan {$product->getStock()} unidades.", 400);
    }

    // Si pasó todas las reglas: descontamos y persistimos
    $product->setStock($product->getStock() - $quantity);
    $this->repository->update($product);

    return [
        'vendidas'      => $quantity,
        'total_a_pagar' => $quantity * $product->getPrice(),
        'producto'      => $product->toArray(),
    ];
}
```

Si estas validaciones de stock estuvieran dentro de `ProductController.php`, cuando el día de mañana quieras procesar pedidos desde un archivo CSV o desde una terminal de consola, tendrías que **duplicar todo el código**. Al estar en el **Service**, cualquier punto de entrada puede ejecutar la venta de forma segura.

---

## 5. 🔐 Seguridad: JWT en Cookies `HttpOnly`

### ¿Por qué NO guardar el token en `localStorage`?
Guardar tokens de autenticación en `localStorage` permite que cualquier script malicioso inyectado mediante **XSS** lea el token con `localStorage.getItem('token')` y robe la identidad del usuario.

### La Solución: Cookie `HttpOnly`
Cuando el usuario inicia sesión (`POST /login`):
1. `AuthService` verifica el hash con `password_verify()`.
2. `Token::create($user)` firma un JWT con `HS256` y la clave `SECRET_KEY`.
3. `Token::sendCookie($jwt)` envía la cabecera `Set-Cookie` con los atributos:
   - **`HttpOnly`**: JavaScript (`document.cookie`) **no puede leerla**.
   - **`SameSite=Lax`**: Protege contra ataques CSRF (Cross-Site Request Forgery).
   - **`Path=/`**: La cookie viaja automáticamente en cada petición a la API.

---

## 6. 🚀 Cómo Ejecutar y Probar la API

### Paso 1: Configurar la Base de Datos
Importa el esquema en MySQL:
```bash
mysql -u root -p < database/schema.sql
```

### Paso 2: Crear el archivo `.env`
Copia la plantilla de configuración:
```bash
cp .env.example .env
```

### Paso 3: Levantar el Servidor Local
Ejecuta el servidor web apuntando al directorio `public/`:
```bash
php -S localhost:8000 -t public
```

### Paso 4: Pruebas con `peticiones.http`
Abre el archivo `peticiones.http` en VS Code con la extensión **REST Client** y ejecuta las peticiones interactivamente:
1. `POST /login` con `admin@utu.edu.uy` y `admin123`.
2. `GET /perfil` (verás los datos sin enviar headers manuales, gracias a la cookie).
3. `POST /productos/1/vender` con `{"cantidad": 2}`.
4. `DELETE /productos/4` con rol admin.

---

## 7. 📚 Glosario de Conceptos POO (Equivalencias Java / PHP)

| Concepto | Java | PHP 8.2 | Explicación |
| :--- | :--- | :--- | :--- |
| **Propiedades Privadas** | `private String name;` | `private string $name;` | Solo accesibles dentro de la propia clase. |
| **Constructor** | `public User(...)` | `public function __construct(...)` | Se ejecuta al hacer `new User(...)`. |
| **Referencia al Objeto** | `this.name` | `$this->name` | Apunta a la instancia actual. |
| **Métodos Estáticos** | `Response.success()` | `Response::success()` | Se ejecutan sin instanciar la clase (`Class::metodo()`). |
| **Herencia** | `class A extends B` | `class A extends B` | Hereda métodos y propiedades `protected`/`public`. |
| **Prepared Statements** | `PreparedStatement` | `PDOStatement` (`$db->prepare(...)`) | Consultas SQL precompiladas inmunes a inyección SQL. |
