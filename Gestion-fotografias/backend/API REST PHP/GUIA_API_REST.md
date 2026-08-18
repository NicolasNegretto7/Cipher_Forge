# Guía Maestra: Desarrollo de la API REST Cipher_Forge en PHP Vanilla

Manual técnico y pedagógico estructurado según el **Roadmap de Cipher_Forge**. Explica paso a paso la arquitectura, el código del backend en PHP 8.2 puro (sin frameworks), la comunicación con el Frontend y la Base de Datos MySQL.

---

## 🗺️ Mapa de Capas del Backend

```
[ Frontend Web (JavaScript Fetch / FormData) ]
         │ (HTTP Request: Method + URI + Headers + Bearer Token / JSON / File)
         ▼
[ public/index.php ]  ── Front Controller (CORS, Autoload PSR-4, Manejo Global de Errores)
         │
         ▼
[ src/Core/Router.php ]
         │
         ├──► [ src/Middlewares/AuthMiddleware.php ]  ── Valida Bearer Token en BD
         ├──► [ src/Middlewares/RoleMiddleware.php ]  ── Verifica rol ('fotografo' / 'cliente')
         │
         ▼
[ src/Controllers/ ]  ── AuthController, CollectionController, ImageController, FileController, DownloadController
         │
         ├──► [ src/Helpers/ ]      ── TokenHelper (Argon2id, UUID), WatermarkHelper (GD), ZipHelper
         │
         ▼
[ src/Repositories/ ] ── UserRepository, CollectionRepository, ImageRepository (PDO + Prepared Statements)
         │
         ▼
[ MySQL 8.0 (Docker / Local) ]
```

---

## BLOQUE 1 — El Entorno y Fundamentos

### 1.1 Docker, Redes y el Host `db`

En un entorno Docker con `docker-compose.yml`, existen dos contenedores independientes en una red privada virtual:
1. Contenedor Web/PHP (`web` o `app`): Ejecuta Apache y PHP 8.2.
2. Contenedor de Base de Datos (`db`): Ejecuta MySQL 8.0.

#### ¿Por qué el host no es `localhost`?
Dentro del contenedor PHP, `localhost` se refiere al propio contenedor web (donde no está instalado MySQL). Para conectarse a la base de datos, Docker resuelve el nombre del servicio en `docker-compose.yml` (`db`) como dirección IP interna mediante su DNS interno.

```php
<?php
// WHAT: Construye la cadena DSN para la conexión PDO utilizando variables de entorno o valores predeterminados.
// WHY: Permite que el código funcione tanto dentro del contenedor Docker (host 'db') como en un servidor local estándar ('127.0.0.1') sin modificar el archivo.

$host = getenv('DB_HOST') ?: '127.0.0.1'; // En Docker Compose se configura DB_HOST=db
$dsn = "mysql:host={$host};port=3306;dbname=cipher_forge;charset=utf8mb4";
```

---

### 1.2 PHP 8.2 Orientado a Objetos vs Java

Para quien domina Programación Orientada a Objetos en Java:

| Concepto | Java | PHP 8.2 |
| :--- | :--- | :--- |
| **Punto de Entrada** | `public static void main(String[] args)` | `public/index.php` (se ejecuta por cada petición HTTP) |
| **Ciclo de Vida** | Proceso persistente en memoria JVM | *Shared-Nothing*: cada petición HTTP inicia y muere al enviar la respuesta |
| **Acceso a Miembros** | `this.propiedad` / `this.metodo()` | `$this->propiedad` / `$this->metodo()` |
| **Propiedades Promovidas** | `public record Usuario(String name, ...)` | `public function __construct(private string $name) {}` |
| **Acceso a Base de Datos** | JDBC / Hibernate | PDO (*PHP Data Objects*) |
| **Inyección de Dependencias** | Spring `@Autowired` | Inyección por constructor explícita |

---

## BLOQUE 2 — Base de Datos con PDO (MySQL)

### 2.1 Conexión Segura con PDO (`config/Database.php`)

```php
<?php
// WHAT: Crea y devuelve una instancia única de conexión PDO configurada contra inyecciones SQL.
// WHY: PDO proporciona una capa de abstracción robusta y permite desactivar la emulación de sentencias preparadas.

namespace Config;

use PDO;

class Database
{
    public function getConnection(): PDO
    {
        $dsn = "mysql:host=127.0.0.1;port=3306;dbname=cipher_forge;charset=utf8mb4";

        $options = [
            // Lanza excepciones PDOException ante cualquier fallo en una consulta SQL
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            // Devuelve filas como arrays asociativos ['columna' => 'valor']
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            // Fuerza a MySQL a compilar la sentencia real antes de enviar los datos (previene Inyección SQL)
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        return new PDO($dsn, 'root', '', $options);
    }
}
```

---

### 2.2 Consultas con Parámetros Nombrados y `bindValue`

Nunca se deben concatenar cadenas en SQL (`"SELECT * WHERE id = " . $id`). La forma correcta es usar marcadores de posición (`:id`, `:email`):

```php
<?php
// WHAT: Consulta un usuario por correo utilizando parámetros nombrados en PDO.
// WHY: Separa el código de la consulta de los datos de entrada del usuario, impidiendo ataques de inyección SQL.

namespace App\Repositories;

use PDO;

class UserRepository
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function findByEmail(string $email): ?array
    {
        $sql = "SELECT id, name, email, password_hash, role FROM users WHERE LOWER(email) = LOWER(:email) LIMIT 1";

        $stmt = $this->db->prepare($sql);
        // bindValue enlaza el dato con su tipo de datos explícito
        $stmt->bindValue(':email', trim($email), PDO::PARAM_STR);
        $stmt->execute();

        $user = $stmt->fetch();
        return $user ?: null;
    }
}
```

---

### 2.3 Consultas Intermedias con `JOIN` y Control de Visibilidad

En Cipher_Forge, las colecciones tienen visibilidad condicional: los fotógrafos ven todo, mientras que los clientes solo ven colecciones públicas (`is_private = 0`) o las que ellos crearon:

```php
<?php
// WHAT: Consulta colecciones con agregación de conteo de imágenes y filtro por rol.
// WHY: LEFT JOIN permite incluir colecciones incluso si aún no tienen imágenes cargadas (COUNT retorna 0).

$sql = "SELECT c.id, c.uuid, c.title, c.is_private, u.name AS author_name,
               COUNT(i.id) AS total_images
        FROM collections c
        INNER JOIN users u ON u.id = c.user_id
        LEFT JOIN images i ON i.collection_id = c.id
        WHERE c.is_private = 0 OR c.user_id = :userId
        GROUP BY c.id
        ORDER BY c.id DESC";
```

---

## BLOQUE 3 — Arquitectura REST API y Enrutamiento

### 3.1 Anatomía de una Petición HTTP

Una petición HTTP está compuesta por cuatro elementos:
1. **Método (Verbo)**: `GET` (lectura), `POST` (creación), `PUT` (actualización), `DELETE` (eliminación), `OPTIONS` (CORS preflight).
2. **URI / Path**: `/api/collections/f47ac10b-58cc-4372-a567-0e02b2c3d479`.
3. **Encabezados (Headers)**: `Authorization: Bearer <token>`, `Content-Type: application/json`.
4. **Cuerpo (Body)**: Carga útil en formato JSON o `multipart/form-data`.

### 3.2 Formato Estándar de Respuesta JSON (Regla del Proyecto)

Toda respuesta de la API cumple con el estándar estricto:

**Respuesta Exitosa (200 OK / 201 Created):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "uuid": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
        "title": "Boda Playa Norte"
    }
}
```

**Respuesta de Error (400 / 401 / 403 / 404 / 422 / 500):**
```json
{
    "success": false,
    "error": "El correo electrónico ya está registrado.",
    "errors": {
        "email": "Correo ya en uso."
    }
}
```

---

## BLOQUE 4 — Autenticación con Tokens Bearer y Roles

> [!IMPORTANT]
> **Sin Cookies ni Sesiones**: Las APIs REST profesionales son **Stateless** (sin estado). En lugar de usar `$_SESSION` y cookies del navegador, el servidor emite un **Token de Autenticación** (`Bearer Token`) tras el login. El frontend almacena este token y lo envía en el encabezado `Authorization: Bearer <token>` en cada solicitud.

```
Frontend (JS)                                                                 Backend (PHP)
     │                                                                             │
     │ ──── 1. POST /api/auth/login {"email": "...", "password": "..."} ─────────► │ (Verifica Argon2id)
     │ ◄─── 2. Retorna JSON con token "a9f3b7..." (Vigencia 24h) ──────────────── │ (Guarda hash en auth_tokens)
     │                                                                             │
     │ ──── 3. GET /api/collections [Header: Authorization: Bearer a9f3b7...] ───► │ (AuthMiddleware busca hash en BD)
     │ ◄─── 4. Retorna datos autorizados ───────────────────────────────────────── │
```

---

### 4.1 Hash de Contraseñas con Argon2id

Argon2id es el algoritmo estándar actual para protección contra ataques de fuerza bruta y GPUs:

```php
<?php
// WHAT: Aplica hash seguro con Argon2id a la contraseña del usuario al registrarse.
// WHY: password_hash genera una sal (salt) criptográfica única en cada ejecución y la incluye en el hash resultante.

namespace App\Helpers;

class TokenHelper
{
    public static function hashPassword(string $password): string
    {
        return password_hash($password, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536, // 64 MB de memoria RAM requerida por intento
            'time_cost'   => 4,     // 4 iteraciones
            'threads'     => 1,
        ]);
    }

    public static function verifyPassword(string $password, string $hash): bool
    {
        // Compara en tiempo constante para prevenir ataques de temporización (timing attacks)
        return password_verify($password, $hash);
    }
}
```

---

### 4.2 Middleware de Autenticación (`AuthMiddleware.php`)

```php
<?php
// WHAT: Intercepta la petición, extrae el token Bearer del encabezado Authorization y verifica su vigencia.
// WHY: Protege los endpoints privados sin depender de cookies o sesiones del servidor.

namespace App\Middlewares;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\TokenHelper;
use App\Repositories\UserRepository;

class AuthMiddleware
{
    public function handle(Request $request): void
    {
        $token = $request->getBearerToken();

        if ($token === null) {
            Response::error('No autorizado: Falta encabezado Authorization: Bearer <token>', 401);
        }

        // Se calcula el hash SHA-256 del token recibido para buscarlo en la BD
        $tokenHash = TokenHelper::hashToken($token);
        $user = (new UserRepository())->findUserByToken($tokenHash);

        if ($user === null) {
            Response::error('No autorizado: Token inválido o expirado.', 401);
        }

        // Inyecta el usuario autenticado en la petición actual
        $request->setUser($user);
    }
}
```

---

### 4.3 Control de Acceso por Roles (`RoleMiddleware.php`)

```php
<?php
// WHAT: Valida que el rol del usuario autenticado coincida con el rol requerido por la ruta ('fotografo' o 'cliente').
// WHY: Impide que clientes ejecuten operaciones reservadas (como subir fotos o crear colecciones).

namespace App\Middlewares;

use App\Core\Request;
use App\Core\Response;

class RoleMiddleware
{
    private string $requiredRole;

    public function __construct(string $requiredRole)
    {
        $this->requiredRole = $requiredRole;
    }

    public function handle(Request $request): void
    {
        $user = $request->getUser();

        if (!$user || $user['role'] !== $this->requiredRole) {
            Response::error("Acceso denegado: Esta acción requiere rol de {$this->requiredRole}.", 403);
        }
    }
}
```

---

## BLOQUE 5 — Subida de Archivos y Procesamiento de Imágenes

### 5.1 Subida Segura e Inspección MIME Real (`finfo`)

> [!WARNING]
> Nunca confíes en `$_FILES['image']['type']` ni en la extensión del archivo enviada por el cliente. Un atacante puede renombrar un script malicioso `virus.php` a `virus.jpg`. La verificación de seguridad obligatoria se hace con `finfo_file()`.

```php
<?php
// WHAT: Inspecciona los bytes de cabecera reales del archivo temporal para verificar su tipo MIME auténtico.
// WHY: Previene la ejecución remota de código (RCE) por subida de scripts PHP disfrazados de imágenes.

$finfo = new finfo(FILEINFO_MIME_TYPE);
$realMime = $finfo->file($_FILES['image']['tmp_name']);

$allowedMimes = [
    'image/jpeg' => 'jpg',
    'image/png'  => 'png',
];

if (!array_key_exists($realMime, $allowedMimes)) {
    Response::error("Formato no permitido ({$realMime}). Solo se aceptan JPEG y PNG.", 422);
}

// Genera nombre físico aleatorio para evitar sobreescrituras e inyecciones en el sistema de archivos
$safeName = bin2hex(random_bytes(16)) . '.' . $allowedMimes[$realMime];
move_uploaded_file($_FILES['image']['tmp_name'], __DIR__ . '/../../storage/uploads/' . $safeName);
```

---

### 5.2 Procesamiento con PHP GD (Marca de Agua y Miniaturas)

```php
<?php
// WHAT: Redimensiona una imagen JPEG o PNG generando una vista previa optimizada.
// WHY: Reduce el consumo de ancho de banda y mejora la velocidad de carga en el frontend.

namespace App\Helpers;

class WatermarkHelper
{
    public static function generateThumbnail(string $sourcePath, string $destPath, int $maxDimension = 350): bool
    {
        [$width, $height, $type] = getimagesize($sourcePath);

        $ratio = $width / $height;
        $newWidth = $ratio > 1 ? $maxDimension : (int) ($maxDimension * $ratio);
        $newHeight = $ratio > 1 ? (int) ($maxDimension / $ratio) : $maxDimension;

        $source = match ($type) {
            IMAGETYPE_JPEG => imagecreatefromjpeg($sourcePath),
            IMAGETYPE_PNG  => imagecreatefrompng($sourcePath),
            default        => null
        };

        $thumb = imagecreatetruecolor($newWidth, $newHeight);

        // Mantiene canal alfa para archivos PNG transparentes
        if ($type === IMAGETYPE_PNG) {
            imagealphablending($thumb, false);
            imagesavealpha($thumb, true);
        }

        imagecopyresampled($thumb, $source, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);
        imagejpeg($thumb, $destPath, 85);

        imagedestroy($source);
        imagedestroy($thumb);
        return true;
    }
}
```

---

### 5.3 Despacho Seguro de Archivos con `readfile()` (`FileController.php`)

Los archivos originales se almacenan en `storage/uploads/` fuera del directorio raíz público `public/` y con un archivo `.htaccess` con `Deny from all`. Para que un cliente descargue la imagen, PHP actúa como intermediario de transmisión:

```php
<?php
// WHAT: Transmite el archivo binario protegido al cliente tras comprobar sus permisos en PHP.
// WHY: Impide el acceso público directo a fotos originales sin autorización.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;

class FileController
{
    public function serve(Request $request, array $params): void
    {
        $filePath = __DIR__ . '/../../storage/uploads/' . $image['filename'];

        // Envía encabezados HTTP indicando el tipo de contenido y su tamaño en bytes
        header('Content-Type: ' . $image['mime_type']);
        header('Content-Length: ' . (string) filesize($filePath));
        header('Content-Disposition: inline; filename="' . $image['original_name'] . '"');

        // readfile vacía el archivo directamente al flujo de red hacia el navegador
        readfile($filePath);
        exit;
    }
}
```

---

## BLOQUE 6 — Funcionalidades Avanzadas

### 6.1 Descargas Masivas con `ZipArchive` (`DownloadController.php`)

```php
<?php
// WHAT: Empaqueta múltiples fotos en un archivo ZIP temporal y lo transmite al navegador.
// WHY: Permite a los clientes descargar álbumes completos en un solo clic.

namespace App\Helpers;

use ZipArchive;

class ZipHelper
{
    public static function createZip(array $files): string
    {
        $tempZipPath = tempnam(sys_get_temp_dir(), 'cipher_') . '.zip';

        $zip = new ZipArchive();
        $zip->open($tempZipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE);

        foreach ($files as $file) {
            if (file_exists($file['path'])) {
                $zip->addFile($file['path'], $file['name']);
            }
        }

        $zip->close();
        return $tempZipPath;
    }
}
```

---

### 6.2 Prevención de Ataques IDOR con UUIDs

- **Problema (IDOR - Insecure Direct Object Reference)**: Si una galería privada tiene URL `/api/collections/3`, un atacante puede cambiar el número a `4` o `5` y adivinar los IDs de otros usuarios.
- **Solución (UUID v4)**: Identificadores pseudoaleatorios de 128 bits generados criptográficamente: `/api/collections/f47ac10b-58cc-4372-a567-0e02b2c3d479`. Es matemáticamente imposible adivinar el enlace de otra colección.

---

## BLOQUE 7 — Integración Frontend (JavaScript `fetch` Paso a Paso)

Explicación exhaustiva para principiantes en JavaScript:

### 1. Iniciar Sesión y Guardar Token en `localStorage`

```javascript
// WHAT: Envía credenciales de login y guarda el token Bearer en el almacenamiento del navegador.
// WHY: El token almacenado se reutilizará en las cabeceras de todas las solicitudes futuras.

async function loginUser(email, password) {
    try {
        // fetch envía una solicitud HTTP POST al backend
        const response = await fetch('http://localhost:8000/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json' // Indica que el cuerpo enviado es un JSON
            },
            body: JSON.stringify({ email: email, password: password }) // Serializa el objeto JS a texto JSON
        });

        // Espera a que el backend envíe los datos y los convierte a objeto JS
        const result = await response.json();

        if (!response.ok) {
            throw new Error(result.error || 'Error al iniciar sesión');
        }

        // Guarda el token en el navegador (persiste entre recargas de página)
        localStorage.setItem('auth_token', result.data.token);
        localStorage.setItem('user_role', result.data.user.role);

        console.log('Login exitoso. Bienvenido:', result.data.user.name);
    } catch (error) {
        console.error('Error de login:', error.message);
    }
}
```

---

### 2. Petición Autenticada con Token Bearer (`GET`)

```javascript
// WHAT: Solicita las colecciones privadas adjuntando el Token Bearer en el encabezado Authorization.
// WHY: Permite al backend identificar quién es el usuario y qué colecciones tiene permiso de ver.

async function getMyCollections() {
    const token = localStorage.getItem('auth_token');

    try {
        const response = await fetch('http://localhost:8000/api/collections', {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}` // Envío del token de autenticación
            }
        });

        const result = await response.json();

        if (!response.ok) {
            throw new Error(result.error);
        }

        console.log('Colecciones recibidas:', result.data);
    } catch (error) {
        console.error('Error al obtener colecciones:', error.message);
    }
}
```

---

### 3. Subir una Imagen con `FormData` (`POST multipart`)

```javascript
// WHAT: Sube un archivo binario seleccionado desde un <input type="file"> al backend.
// WHY: FormData permite enviar archivos binarios sin necesidad de convertirlos a Base64.

async function uploadImageToCollection(collectionUuid, fileInputElement) {
    const token = localStorage.getItem('auth_token');
    const file = fileInputElement.files[0]; // Obtiene el archivo físico seleccionado por el usuario

    if (!file) {
        alert('Por favor selecciona una imagen primero.');
        return;
    }

    // Crea un contenedor multipart/form-data
    const formData = new FormData();
    formData.append('image', file); // 'image' coincide con $request->getFile('image') en PHP

    try {
        const response = await fetch(`http://localhost:8000/api/collections/${collectionUuid}/images`, {
            method: 'POST',
            headers: {
                // NOTA: NO agregar 'Content-Type': el navegador lo autogenera con el 'boundary' requerido
                'Authorization': `Bearer ${token}`
            },
            body: formData
        });

        const result = await response.json();

        if (!response.ok) {
            throw new Error(result.error);
        }

        console.log('Imagen subida con éxito:', result.data);
    } catch (error) {
        console.error('Error al subir imagen:', error.message);
    }
}
```

---

## 8. Anti-Patrones Comunes y sus Soluciones

1. **Guardar contraseñas con MD5 o SHA-256**:
   - *Error*: `md5($pass)` o `hash('sha256', $pass)`.
   - *Impacto*: Son algoritmos diseñados para velocidad, no para contraseñas. Se descifran en segundos con tablas *Rainbow*.
   - *Solución*: Utilizar siempre `password_hash($pass, PASSWORD_ARGON2ID)`.

2. **Usar `$_FILES['image']['type']` para validar el formato**:
   - *Error*: Comprobar `if ($_FILES['image']['type'] === 'image/jpeg')`.
   - *Impacto*: El valor del header es enviado por el cliente y se falsea fácilmente.
   - *Solución*: Usar `(new finfo(FILEINFO_MIME_TYPE))->file($tmpName)`.

3. **Exponer imágenes originales en la carpeta pública `public/`**:
   - *Error*: Guardar las fotos en `public/uploads/` y accederlas con `http://servidor/uploads/foto.jpg`.
   - *Impacto*: Cualquier persona puede descargar las fotos originales de alta resolución sin pagar ni autenticarse.
   - *Solución*: Guardar en `storage/uploads/` con `Deny from all` y despachar mediante `FileController` con `readfile()`.

4. **Confundir Sesiones PHP (`$_SESSION`) con APIs REST**:
   - *Error*: Usar `session_start()` y esperar que clientes móviles o frontends desacoplados mantengan cookies de sesión.
   - *Impacto*: Falla en arquitecturas desacopladas, microservicios y clientes móviles.
   - *Solución*: Utilizar **Tokens Bearer** en el header `Authorization`.

---

## 9. Guía Rápida de Pruebas con cURL

### 1. Registrar un Fotógrafo
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Ana Fotógrafa\",\"email\":\"ana@cipherforge.com\",\"password\":\"Segura123!\",\"role\":\"fotografo\"}"
```

### 2. Iniciar Sesión (Obtener Token)
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"ana@cipherforge.com\",\"password\":\"Segura123!\"}"
```

### 3. Crear una Colección (Con Token Bearer)
```bash
curl -X POST http://localhost:8000/api/collections \
  -H "Authorization: Bearer <TOKEN_OBTENIDO>" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Sesión de Graduación 2026\",\"description\":\"Fotos en el campus universitario\",\"is_private\":true}"
```

### 4. Subir una Imagen a la Colección
```bash
curl -X POST http://localhost:8000/api/collections/<UUID_COLECCION>/images \
  -H "Authorization: Bearer <TOKEN_OBTENIDO>" \
  -F "image=@/ruta/a/mi_foto.jpg"
```

### 5. Descargar la Colección Completa en ZIP
```bash
curl -X GET http://localhost:8000/api/collections/<UUID_COLECCION>/download \
  -H "Authorization: Bearer <TOKEN_OBTENIDO>" \
  --output coleccion.zip
```
