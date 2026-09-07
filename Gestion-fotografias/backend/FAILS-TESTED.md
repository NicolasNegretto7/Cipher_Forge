# FAILS-TESTED

> Resultado de la auditoría funcional del backend (**Gestion-fotografias/backend**) ejecutada contra el stack Docker real (`docker-compose up -d`, Apache + PHP 8.2 + MySQL 8.0, `http://localhost:8080`).

## Resumen de la prueba

- Suite automatizada: **62 pruebas** end-to-end (registro, login, verificación de correo, fotógrafos, colecciones, multimedia, carga colaborativa, favoritos, sistema, eliminaciones y casos 404/403 sin token).
- Resultado: **60 PASS / 2 FAIL** (los 2 fallos corresponden al mismo bug: `GET /fotografos/cuota`).
- Además del fallo anterior, se detectó **1 bug latente de código** (reproducible solo con imágenes muy pequeñas) y **2 problemas de despliegue** que rompen el entorno.
- Total de hallazgos: **5** (3 de código + 2 de infraestructura).

---

## BUG 1 — `GET /fotografos/cuota` siempre responde 404

**Reproducción:** `GET /fotografos/cuota` con token válido de fotógrafo → `404` (esperado `200` y la cuota). Con token de cliente → `404` (esperado `403`).

**Causa raíz — conflicto de rutas por orden de registro:**

En `routes.php`:

```php
// línea 32 — se registra PRIMERO la ruta con parámetro
$router->add('GET', '/fotografos/{id}', FotografoController::class, 'perfil');

// línea 35 — nunca se alcanza
$router->add('GET', '/fotografos/cuota', FotografoController::class, 'cuota', 'auth');
```

El `Router` despacha comparando segmento a segmento y en el **orden de registro**. `/fotografos/cuota` tiene 2 segmentos, igual que `/fotografos/{id}`, y `{id}` matchea cualquier valor literal, incluida la palabra `cuota`. Por eso la petición entra siempre a `FotografoController::perfil('cuota')`, el valor se castea a `int` (`0`) y el controlador responde `404` (fotógrafo inexistente) antes de que se evalúe el middleware `auth`.

**Impacto:**
- El endpoint de cuota del fotógrafo es inalcanzable.
- No se aplica el control de rol (cliente debería recibir `403`, recibe `404`).

**Solución:** registrar la ruta literal antes que la parametrizada (mismo patrón que ya funciona en `/colecciones/publicas` antes de `/colecciones/{id}`):

```php
$router->add('GET', '/fotografos/cuota', FotografoController::class, 'cuota', 'auth');
$router->add('GET', '/fotografos/{id}', FotografoController::class, 'perfil');
```

---

## BUG 2 — Loop infinito en `MediaProcessor::generarPreviewImagen` con imágenes pequeñas

**Reproducción:** subir un PNG de 1×1 px (o cualquier imagen con alto ≤ 5 px) por `POST /colecciones/{id}/multimedia` o `POST /colaborativo/{token}/subir` → el proceso cuelga 30 segundos y termina en:

```
Fatal error: Maximum execution time of 30 seconds exceeded in .../MediaProcessor.php on line 96
```

**Causa raíz — `$paso` puede quedar en 0:**

`src/helpers/MediaProcessor.php` líneas 86-101:

```php
$tamLetra = 1;
$xIni = (int) ($ancho * 0.05);
$yIni = (int) ($alto * 0.05);
$paso = (int) ($alto * 0.18);   // <-- 0 para $alto <= 5

$y = $yIni;
while ($y < $alto) {            // <-- nunca avanza
    $x = $xIni;
    while ($x < $ancho) {
        imagestring(...);
        imagestring(...);
        $x += (int) ($texto === '' ? 200 : 180);
    }
    $y += $paso;                // <-- $paso = 0 => loop infinito
}
```

Para un `$alto ≤ 5`, `(int)(0.18 * alto)` = `0`, así que `$y += 0` eternamente. Con imágenes normales (fotos de cámara) funciona correctamente; solo falla con imágenes diminutas.

**Impacto:**
- El upload de imágenes pequeñas (iconos, avatares, logos, thumbnails) bloquea el worker 30 s y termina en error.
- En la auditoría inicial apareció como "los uploads dan `200` con `datos.subidos` inválido": el fatal no se convierte en `500`, sino que el stack respondió `200` con el HTML del error (ver BUG 3).

**Solución:** garantizar un paso mínimo de 1 px:

```php
$paso = max(1, (int) ($alto * 0.18));
```

(Con imágenes de alto 1-5 px la marca de agua queda demasiado pegada, pero el endpoint deja de colgarse y responde con `201`.)

---

## BUG 3 — Un fatal error de PHP responde HTTP 200 en vez de 500

**Reproducción:** al dispararse el fatal del BUG 2, el cliente recibe:

```
HTTP 200
<br /><b>Fatal error</b>: Maximum execution time of 30 seconds exceeded ...
```

**Causa raíz:** el front controller (`public/index.php`) y/o la configuración del stack no traducen un `Fatal error` de PHP a un código `5xx`. Con `display_errors=On`, el HTML del error se entrega con el `200` por defecto.

**Impacto:**
- Los consumidores no pueden distinguir un error real de una respuesta exitosa: el body no es JSON y el código no es `500`.
- Enmascaró el BUG 2 durante las primeras corridas de la auditoría (se interpretó como "upload fallido con 200" en lugar de "fatal 500").

**Solución recomendada:**
- Asegurar `display_errors=Off` en producción y un manejador global (`set_exception_handler` / `register_shutdown_function`) que emita JSON con `http_response_code(500)`.
- Subir `max_execution_time` razonable solo si el procesado lo amerita; lo correcto es corregir el BUG 2.

---

## HALLAZGO 4 — `database/migration.sql` es incompatible con MySQL 8.0 del Docker

**Reproducción:** ejecutar `database/migration.sql` contra el MySQL 8.0 del `docker-compose`:

```
ERROR 1064 (42000): You have an error in your SQL syntax ... near 'ADD COLUMN IF NOT EXISTS'
```

**Causa raíz:** `migration.sql` usa `ADD COLUMN IF NOT EXISTS`, sintaxis que la imagen `mysql:8.0` del stack **no soporta** (solo está disponible en MariaDB y en MySQL a partir de versiones posteriores de la serie 8.0.x).

**Impacto:**
- No se puede migrar una base existente con el script provisto.
- Ante un volumen persistente con esquema viejo, los endpoints que usan columnas nuevas (`biografia`, `especialidad`, `codigo_verificacion`, `codigo_expiracion`, `aprobado`, `creado_en`, etc.) devuelven `500` (reproducido en la auditoría con un volumen previo).

**Solución recomendada:**
- Reescribir las migraciones sin `IF NOT EXISTS` (chequear columnas con `information_schema` antes del `ALTER`), o
- cambiar la imagen a una versión de MySQL 8.0 posterior (≥ 8.0.29) / MariaDB que soporte la sintaxis.

---

## HALLAZGO 5 — No hay migración automática al arrancar el stack

**Reproducción:** con un volumen `db_data` persistente (creado por una corrida anterior), `docker-compose up` no aplica las migraciones: el esquema queda desactualizado y la API devuelve `500` en varios endpoints.

**Causa raíz:** `docker-entrypoint-initdb.d` de la imagen oficial de MySQL solo ejecuta los scripts SQL **la primera vez** que se inicializa el volumen. En arranques posteriores no corre nada, y tampoco existe un paso de migración en `docker-entrypoint.sh` ni en el entry del contenedor PHP.

**Impacto:**
- El esquema "diverge" entre entornos/despliegues.
- Un reinicio con volumen viejo rompe la API sin un mensaje claro (se ve como errores `500` generalizados).

**Solución recomendada:**
- Añadir un paso de migración idempotente al arranque (ej. un script PHP que compare el esquema contra lo esperado y aplique `ALTER`s), o
- documentar y forzar `docker-compose down -v` cuando cambie el modelo de datos, o versionar migrations numeradas bajo un runner.

---

## Notas de la suite

- Script de pruebas: `test-api.ps1` + resultados `resultados-api.csv` (en temp del entorno de auditoría).
- El resto de la API validada funciona según lo especificado: auth (registro/login/verificación/reenvío), directorio y perfil de fotógrafos, políticas, colecciones públicas/privadas, hashtags, invitaciones y canje, subidas y gestión de multimedia, vista previa/original/descargas por calidad, QR colaborativo (generación, SVG, registro, subida, aprobación/rechazo), favoritos y sistema (backup/listado/limpieza).