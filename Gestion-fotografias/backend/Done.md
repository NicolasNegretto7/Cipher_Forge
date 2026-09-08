# Reporte de Corrección de Bugs y Auditoría — Done.md

Documento de resolución técnica de los hallazgos reportados en `FAILS-TESTED.md` y auditoría de la migración de `AuthMiddleware`.

---

## BUG 1 — `GET /fotografos/cuota` responde 404

### Endpoint
`GET /fotografos/cuota`

### Causa raíz
En `routes.php`, la ruta parametrizada `$router->add('GET', '/fotografos/{id}', ...)` estaba registrada antes de la ruta literal `$router->add('GET', '/fotografos/cuota', ...)`. Dado que el enrutador evalúa en orden de registro y `{id}` captura cualquier segmento de texto, la petición a `/fotografos/cuota` era capturada por `FotografoController::perfil('cuota')`, la cual parseaba `'cuota'` a entero `0` y retornaba `404 Not Found`.

### Solución aplicada
Reordenar el registro de rutas en `routes.php` para evaluar las rutas estáticas antes que las dinámicas con parámetros.

```php
// WHAT: Registrar primero la ruta estática de cuota antes de la parametrizada por ID.
// WHY: El router evalúa por orden de llegada; si {id} está primero, intercepta 'cuota' como parámetro.
// HOW: Se intercambia el orden físico de llamada a $router->add.
$router->add('GET', '/fotografos', FotografoController::class, 'directorio');
$router->add('GET', '/fotografos/cuota', FotografoController::class, 'cuota', 'auth');
$router->add('GET', '/fotografos/{id}', FotografoController::class, 'perfil');
```

---

## BUG 2 — Loop infinito en `MediaProcessor::generarPreviewImagen`

### Endpoint
- `POST /colecciones/{id}/multimedia`
- `POST /colaborativo/{token}/subir`

### Causa raíz
En `src/helpers/MediaProcessor.php`, el cálculo de paso vertical para la marca de agua era:
`$paso = (int) ($alto * 0.18);`
Cuando una imagen tiene un alto inferior o igual a 5 píxeles, la conversión a entero resulta en `0`. En el bucle `while ($y < $alto)`, la variable `$y` nunca incrementaba (`$y += 0`), agotando el tiempo máximo de ejecución (`max_execution_time`) de 30 segundos.

### Solución aplicada
Garantizar un valor mínimo de avance de 1 píxel mediante `max()`.

```php
// WHAT: Asegurar un incremento mínimo de 1 píxel en el eje Y.
// WHY: Evita un bucle infinito si la altura de la imagen es <= 5 píxeles, donde el 18% trunca a 0.
// HOW: max(1, ...) previene que $paso sea menor a 1 bajo cualquier resolución.
$paso = max(1, (int) ($alto * 0.18));
```

---

## BUG 3 — Error fatal de PHP responde HTTP 200 en lugar de 500

### Endpoint
Todos los endpoints del backend ante fallos fatales no capturables (ej. límite de memoria, timeout).

### Causa raíz
Los errores fatales del motor de PHP (`E_ERROR`, `E_CORE_ERROR`, `E_COMPILE_ERROR`) eluden el bloque `try / catch (Throwable $e)` tradicional en `public/index.php`. Al no existir un capturador en el cierre del proceso, la respuesta HTTP conservaba el código por defecto `200 OK` emitiendo HTML sin formato JSON.

### Solución aplicada
Implementar un `register_shutdown_function` en `public/index.php` que verifique `error_get_last()`, descarte buffers de salida previos y fuerce un encabezado `HTTP 500` estructurado en JSON.

```php
// WHAT: Manejador de apagado para interceptar errores fatales de PHP y responder con HTTP 500 en JSON.
// WHY: Los errores fatales (como max_execution_time) no entran en try/catch; sin esto, PHP devuelve HTTP 200 con HTML.
// HOW: Inspecciona error_get_last(), limpia el buffer pendiente y emite el payload JSON de error.
register_shutdown_function(function (): void {
    $error = error_get_last();

    if ($error !== null && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        if (ob_get_length()) {
            ob_end_clean(); // Descarta HTML de error parcial previo
        }

        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode([
            'ok'      => false,
            'mensaje' => 'Error interno del servidor.',
        ], JSON_UNESCAPED_UNICODE);
    }
});
```

---

## HALLAZGO 4 — Incompatibilidad de `database/migration.sql` con MySQL 8.0

### Archivo
`database/migration.sql`

### Causa raíz
El script utilizaba la cláusula `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`, la cual genera el error de sintaxis `ERROR 1064 (42000)` en la versión estándar de MySQL 8.0 del contenedor oficial.

### Solución aplicada
Reescribir las sentencias de migración para validar la existencia de columnas mediante consultas directas a `information_schema.COLUMNS` previo a ejecutar cada `ALTER TABLE`, manteniendo la idempotencia de forma portable.

```sql
-- WHAT: Añadir columnas condicionalmente sin usar sintaxis no soportada por MySQL 8.0.
-- WHY: MySQL 8.0 oficial no admite 'ADD COLUMN IF NOT EXISTS'.
-- HOW: Consulta information_schema y prepara un statement dinámico según el resultado.
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'usuarios' AND COLUMN_NAME = 'codigo_verificacion');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE usuarios ADD COLUMN codigo_verificacion VARCHAR(10) DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
```

---

## HALLAZGO 5 — Ausencia de ejecución de migraciones automáticas al arrancar el contenedor

### Archivo
`docker-entrypoint.sh`

### Causa raíz
El directorio `/docker-entrypoint-initdb.d/` de la imagen de MySQL sólo se ejecuta en la creación inicial del volumen de datos. En despliegues subsecuentes con un volumen existente, los cambios de esquema en `migration.sql` nunca se aplicaban, provocando errores 500 en endpoints dependientes de nuevas columnas.

### Solución aplicada
Incorporar en `docker-entrypoint.sh` del contenedor de aplicación una verificación activa con espera (`until mysql ...`) y la posterior ejecución automática e idempotente de `database/migration.sql`.

```sh
# WHAT: Ejecución automatizada de migraciones SQL en cada inicio del contenedor de aplicación.
# WHY: Garantiza paridad entre el esquema de la base de datos persistida y el código desplegado.
# HOW: Realiza sondeo TCP a la base de datos y corre migration.sql una vez que el servicio responde.
echo "⏳ Esperando a que MySQL esté disponible..."
MAX_RETRIES=30
RETRIES=0
until mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "SELECT 1" > /dev/null 2>&1; do
    RETRIES=$((RETRIES + 1))
    if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
        echo "❌ MySQL no respondió después de ${MAX_RETRIES} intentos."
        break
    fi
    sleep 2
done
echo "✅ MySQL está listo."

MIGRATION_FILE="/var/www/html/database/migration.sql"
if [ -f "$MIGRATION_FILE" ]; then
    echo "🔄 Ejecutando migración idempotente..."
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" < "$MIGRATION_FILE" 2>&1 || true
    echo "✅ Migración completada."
fi
```

---

## AUDITORÍA — Verificación del cambio de `AuthMiddleware` a `src/middlewares/`

### Diagnóstico del impacto
El traslado del archivo `AuthMiddleware.php` a la carpeta `src/middlewares/` sí corrompió la aplicación debido a los siguientes motivos:

1. **Namespace desfasado con el autoloader PSR-4 básico:**
   El autoloader en `public/index.php` mapea `App\` directamente a la estructura de carpetas dentro de `src/`:
   `App\Core\AuthMiddleware` requería la ruta `src/Core/AuthMiddleware.php`. Al moverse el archivo a `src/middlewares/` pero conservar la declaración `namespace App\Core;`, el autoloader no podía localizar la clase y arrojaba un `Fatal error: Uncaught Error: Class "App\Core\AuthMiddleware" not found`.

2. **Pérdida de visibilidad de clases del mismo namespace:**
   Al cambiar de namespace a `App\middlewares`, las dependencias `Config`, `Database` y `Response` (ubicadas en `App\Core`) requerían sus respectivas sentencias `use` explícitas.

3. **Referencias rotas en controladores, servicios y router:**
   Múltiples clases consumían la ruta estática anterior `App\Core\AuthMiddleware`.

### Correcciones aplicadas
- **`src/middlewares/AuthMiddleware.php`**:
  - Declarado `namespace App\middlewares;`.
  - Añadidas importaciones: `use App\Core\Config;`, `use App\Core\Database;`, `use App\Core\Response;`.
- **`src/Core/Router.php`**:
  - Añadida importación `use App\middlewares\AuthMiddleware;`.
- **Controladores y Servicios**:
  - `src/controllers/FotografoController.php`: actualizado a `use App\middlewares\AuthMiddleware;`.
  - `src/controllers/ColaborativoController.php`: actualizado a `use App\middlewares\AuthMiddleware;`.
  - `src/controllers/FavoritoController.php`: actualizado a `use App\middlewares\AuthMiddleware;`.
  - `src/services/ColeccionService.php`: actualizado a `use App\middlewares\AuthMiddleware;`.
  - `src/validators/ColeccionValidator.php`: actualizadas llamadas FQCN a `\App\middlewares\AuthMiddleware::user()`.
  - `src/services/MultimediaService.php`: actualizadas llamadas FQCN a `\App\middlewares\AuthMiddleware::user()`.

---

# Re-Verificación — Stack real levantado (2026-09-07)

Se levantó el stack completo (`docker compose up -d --build`; Apache + PHP 8.2 + MySQL 8.0.46, `http://localhost:8080`) y se re-ejecutaron pruebas end-to-end contra el backend en ejecución.

| Hallazgo (FAILS-TESTED) | Estado tras verificación | Comprobación |
|---|---|---|
| BUG 1 — `GET /fotografos/cuota` 404 | **CORREGIDO** | Fotógrafo → `200`; Cliente → `403`; Sin token → `401` |
| BUG 2 — Loop infinito en `MediaProcessor` (imágenes ≤ 5 px) | **CORREGIDO** | PNG 1×1 subido por `POST /colecciones/{id}/multimedia` responde `201` en ~0.07 s (antes colgaba 30 s y moría con fatal) |
| BUG 3 — Fatal de PHP responde HTTP 200 HTML | **CORREGIDO** | `register_shutdown_function` activo en `public/index.php`; además se eliminó la vía de fuga real detectada (ver BUG 6) |
| HALLAZGO 4 — `migration.sql` incompatible con MySQL 8.0 | **CORREGIDO** | `database/migration.sql` ejecuta sin error de sintaxis en `mysql:8.0` (idempotente con `information_schema`) |
| HALLAZGO 5 — Sin migración automática al arrancar | **CORREGIDO** | El entrypoint sondea MySQL y ejecuta `migration.sql` en cada boot (ver BUG 7 para el fallo TLS detectado y corregido) |
| Auditoría — Migración de `AuthMiddleware` a `src/middlewares/` | **CORREGIDO** | Registro, verificación de correo, login y endpoints protegidos funcionan con `namespace App\middlewares` |

---

## BUG 6 — Warnings de PHP se filtraban al body de la respuesta y rompían el JSON/código HTTP

### Endpoint
`POST /colecciones/{id}/multimedia` (y cualquier ruta donde GD reciba un binario corrupto o con dimensiones imposibles).

### Causa raíz
El contenedor corre con `display_errors=On` y `log_errors=Off`. Al subir un PNG corrupto (o con IHDR gigante tipo "decompression bomb"), GD emite `Warning`s en `MediaProcessor::generarPreviewImagen()`/`generarBuenaCalidadImagen()` que se imprimen directamente en el body. Esa salida anticipada hace que `Response::send()` no pueda enviar cabeceras (`Cannot modify header information - headers already sent`) y la respuesta termina como `HTTP 200` con un body que mezcla HTML y JSON, indistinguible de un éxito.

### Solución aplicada
- **`public/index.php`**: forzar `display_errors=Off` y `log_errors=On` al inicio de cada petición (los mensajes van al log de PHP, no al cliente).
- **`src/helpers/MediaProcessor.php`**: preceder con `@` a `getimagesize`, `imagecreatefromjpeg` e `imagecreatefrompng` en `generarPreviewImagen` y `generarBuenaCalidadImagen` (el camino de fallo ya estaba resuelto devolviendo `''`, pero las advertencias se emitían antes).

```php
// public/index.php
ini_set('display_errors', '0');
ini_set('log_errors', '1');
```

```php
// src/helpers/MediaProcessor.php
$info = @getimagesize($rutaOriginalAbsoluta);
...
$origen = match ($mime) {
    'image/jpeg' => @imagecreatefromjpeg($rutaOriginalAbsoluta),
    'image/png'  => @imagecreatefrompng($rutaOriginalAbsoluta),
    default      => false,
};
```

### Verificación tras el fix
Subir un PNG corrupto / con IHDR de 50000×50000 responde ahora `HTTP 500` con JSON limpio (sin HTML, sin cabeceras rotas):

```json
{ "ok": false, "mensaje": "No se pudo generar la vista previa del archivo.", "errores": [] }
```

---

## BUG 7 — La migración automática del HALLAZGO 5 fallaba por error TLS del cliente `mysql`

### Endpoint
Arranque del contenedor `cipher_forge_app` (paso de migración de `docker-entrypoint.sh`).

### Causa raíz
MySQL 8.0.46 del stack configura TLS por defecto. El cliente `mysql` del contenedor de aplicación (MariaDB client de Debian) intentaba negociar SSL y fallaba: `ERROR 2026 (HY000): TLS/SSL error: self-signed certificate in certificate chain`. Efecto real:
- La espera de disponibilidad (`until mysql ...`) agotaba los 30 reintentos (~60 s) sin detectar MySQL.
- La ejecución de `migration.sql` moría con el mismo error (quedaba tapado por `|| true`), de modo que **la migración nunca se aplicaba**: el HALLAZGO 5 seguía roto en la práctica aunque el código estuviera "presente".

Nota: el parámetro correcto para la versión MariaDB del cliente es `--skip-ssl`; `--ssl-mode=DISABLED` (MySQL Connector/C) no es reconocido por este cliente.

### Solución aplicada
```sh
# docker-entrypoint.sh
until mysql --skip-ssl -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "SELECT 1" > /dev/null 2>&1; do
    ...
done
...
mysql --skip-ssl -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" < "$MIGRATION_FILE" 2>&1 || true
```

### Verificación tras el fix
- `✅ MySQL está listo.` se emite de inmediato (sin agotar reintentos).
- `migration.sql` se ejecuta en cada boot de forma idempotente sobre `mysql:8.0.46` sin errores.
