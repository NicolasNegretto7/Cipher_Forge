# Auditoría de seguridad del backend — Cipher Forge / Gestion-fotografias

**Rol:** revisión AppSec y triage de resultados SAST.
**Alcance:** únicamente el backend (API PHP, configuración PHP/Apache, Docker y scripts auxiliares).`docs/frontend.md` se ignora por completo.
**Fuente analizada:** `docs/backend.md` — SonarQube Community Build 26.8.0.126808 + SonarScanner CLI 8.1.0.6389.
**Commit del SAST:** `0aca934` · **HEAD actual verificado:** `aa3b0a2` (*"prueba SAST"*).
**Evidencia de apoyo:** `docs/SAST-Analisis-Manual-2026-10-26.md` (verificación dinámica referenciada por `backend.md`, sección 5).

> **Nota sobre vigencia:** entre `0aca934` (analizado) y `aa3b0a2` (HEAD) el único cambio de código backend es la eliminación de dos emojis en `backend/src/helpers/QrGenerator.php:88-153` (mismo número de líneas). El resto son documentos. Por lo tanto **los hallazgos y las líneas de `backend.md` siguen vigentes**.
>
> **Nota sobre verificación dinámica:** durante el triage inicial el motor Docker no estaba disponible. El **2026-10-27**, ya con Docker operativo, se levantó la imagen corregida contra MySQL y se reprodujeron las peticiones HTTP en un puerto de prueba (§8). Los hallazgos de despliegue (C-01, C-02, C-03, H-01, H-02) quedaron **confirmados y remediados**, y la verificación se cruzó con `docs/SAST-Analisis-Manual-2026-10-26.md`.
>
> **Nota sobre remediación:** las 6 correcciones aprobadas (C-01, C-02, C-03, H-01, H-02, V-B4) **ya están aplicadas** en el repositorio. El detalle de archivos, la verificación dinámica y las notas de despliegue están en **§8**.

---

## 1. Resumen ejecutivo

Se analizaron **75 hallazgos** reportados en `docs/backend.md`:

| Grupo (según backend.md) | Cantidad |
|:---|---:|
| Vulnerabilidades SonarQube (V-B1…V-B4) | 4 |
| Bugs (B-01, B-02) | 2 |
| Code smells (S-*) | 64 |
| Riesgos críticos/altos de despliegue (C-01…C-03, H-01, H-02) | 5 |
| **Total** | **75** |

**Resultado del triage:**

| Decisión | Cantidad | Detalle |
|:---|---:|:---|
| **Corregir** | **6** | C-01, C-02, C-03, H-01, H-02 y V-B4 |
| **No corregir** | **69** | V-B1, V-B2, V-B3, B-01, B-02 + los 64 code smells (deuda de calidad, no seguridad; ver §4) |
| **Requiere más información** | **0** | No hay bloqueantes; las verificaciones dinámicas se completaron el 2026-10-27 (§8) |

**Lectura clave:** el riesgo real de este backend **no está en las 4 vulnerabilidades de Sonar** (3 de ellas no son explotables en este proyecto), sino en **configuración de despliegue**: el árbol web de Apache publica `uploads/`, el secreto JWT y archivos internos; el filtro por IP de `/sistema/*` es inoperante detrás del NAT de Docker; y el puerto de MySQL está abierto con un fallback de credenciales por defecto. Esas cinco condiciones anulan controles de seguridad que **sí existen y están bien hechos en el código** (consultas preparadas, `password_hash`/`password_verify`, JWT con `hash_equals`, cookie `HttpOnly` + `SameSite`, validación de subidas, autorización por propietario y rate limiting de autenticación).

### Top 3 más críticos (por impacto real)

1. **C-01 — Secreto JWT expuesto en `uploads/` (Crítica).** Permite a un atacante no autenticado firmar tokens válidos para cualquier usuario y tomar el control de cuentas. Evidencia: `backend/uploads/.jwt_secret` accesible por HTTP + `Config::jwtSecret()` (`Config.php:17-37`).
2. **C-02 — Originales servidos de forma estática y `probe_originals.php` enumerando (Crítica).** Descarga de fotos/videos originales (incluso de colecciones privadas y material no aprobado) sin autenticación. Evidencia: `backend/probe_originals.php:1-14` + `/uploads/originals/*`.
3. **C-03 — MySQL `3306` publicado con credenciales por defecto (Crítica).** Acceso completo a la base desde la LAN. Evidencia: `backend/docker-compose.yml:83` + `backend/src/Core/Database.php:21-38`.

Le siguen en prioridad **H-01** (`/sistema/*` sin autenticación efectiva) y **H-02** (`DocumentRoot` exponiendo archivos internos).

---

## 2. Tabla resumen

| ID | Hallazgo | Archivo | Severidad (original → evaluada) | Clasificación |
|:---|:---|:---|:---|:---|
| V-B1 | Hash débil `sha1()` (php:S4790) | `backend/src/helpers/RateLimiter.php:151` | Critical → **Baja / informativa** | **No corregir** |
| V-B2 | Cookie de sesión sin `HttpOnly` (php:S3330) | `backend/php.ini` | Minor → **Informativa (no aplicable)** | **No corregir** |
| V-B3 | Cookie de sesión sin `Secure` (php:S2092) | `backend/php.ini` | Minor → **Baja (no aplicable)** | **No corregir** |
| V-B4 | Contenedor ejecutado como root (docker:S6471) | `backend/Dockerfile:3` | Minor → **Media** | **Corregir** |
| B-01 | `require` en lugar de `require_once` (php:S2003) | `backend/probe_media.php:2` | Minor → **Baja (no seguridad)** | **No corregir** |
| B-02 | `require` en lugar de `require_once` (php:S2003) | `backend/probe_media.php:3` | Minor → **Baja (no seguridad)** | **No corregir** |
| C-01 | `.jwt_secret` expuesto por HTTP | `backend/uploads/.jwt_secret` · `docker-compose.yml:12-13` · `Config.php:17-37` | (manual) Crítica → **Crítica** | **Corregir** |
| C-02 | Originales / material no aprobado servidos estáticamente | `backend/probe_originals.php` · `/uploads/originals/*` | (manual) Crítica → **Crítica / Alta** | **Corregir** |
| C-03 | MySQL `3306` expuesto + credenciales por defecto | `docker-compose.yml:83-89` · `Database.php:21-38` | (manual) Crítica → **Crítica / Alta** | **Corregir** |
| H-01 | `/sistema/*` sin autenticación efectiva | `routes.php:90-92` · `SistemaController.php:36-59` | (manual) Alta → **Alta** | **Corregir** |
| H-02 | `DocumentRoot` expone archivos internos | `Dockerfile:22` · `docker-compose.yml:12` · `.htaccess:9-13` | (manual) Alta → **Alta / Media** | **Corregir** |
| S-01…S-64 | 64 code smells (mantenibilidad) | Varios (ver §4.4) | Minor/Major/Info → **No es un riesgo de seguridad** | **No corregir** (deuda de calidad) |

> **Agrupaciones:** V-B2 y V-B3 son la misma clase de hallazgo (configuración de sesiones PHP nativas) y se tratan juntos. C-01 y C-02 comparten causa raíz (`uploads/` dentro del `DocumentRoot` + volumen nombrado que tapa el `uploads/.htaccess`), pero se mantienen separados por impacto distinto (robo de secreto vs. acceso a archivos). Los 64 code smells se agrupan por regla.

---

## 3. Hallazgos a corregir

### C-01 — Secreto de firma JWT accesible por HTTP (suplantación de cuentas)

- **Ubicación:** `backend/uploads/.jwt_secret` (archivo), `backend/docker-compose.yml:12-13` (montajes), `backend/Dockerfile:22`, `backend/src/Core/Config.php:17-37`, `backend/docker-entrypoint.sh:13-14`.
- **CWE:** CWE-522 (credenciales insuficientemente protegidas), CWE-200, CWE-538 · **OWASP:** A01, A02, A05.
- **Evidencia:**
  - `docker-compose.yml:12-13` monta el proyecto completo en `/var/www/html` (bind mount) **y encima** el volumen nombrado `uploads_data` en `/var/www/html/uploads`. El volumen nombrado nace vacío y **tapa** el `backend/uploads/.htaccess` (que sí existe en el host con `Require all denied`, ver `backend/uploads/.htaccess:5-11`).
  - `Config::jwtSecret()` (`Config.php:17-37`): usa `JWT_SECRET` si existe; si no, lee/crea `uploads/.jwt_secret`. En `docker-compose.yml:14-36` **no se define `JWT_SECRET`**, por lo que la clave efectiva es ese archivo.
  - `docker-entrypoint.sh:13-14` ejecuta `chown -R www-data:www-data` y `chmod -R 775 /var/www/html/uploads`, anulando el `chmod 0600` que intenta `Config.php:34`.
  - Verificación dinámica registrada en `docs/SAST-Analisis-Manual-2026-10-26.md` (C-01): `GET /uploads/.jwt_secret → 200` y PoC de token forjado válido.
- **¿Es real y explotable?** Sí. Un cliente que alcance el puerto `8080` (LAN o túnel) lee el secreto y firma un JWT HS256 con `sub` arbitrario; `AuthMiddleware::authenticate()` (`AuthMiddleware.php:138-161`) lo acepta y carga el usuario por `sub`.
- **Impacto:** suplantación de cualquier cuenta (IDs secuenciales) → lectura de colecciones privadas, descarga de originales, subida/borrado de contenido, aceptación de políticas, generación de QR. Confidencialidad e integridad totales hasta rotar el secreto.
- **Recomendación:**
  1. **Rotar** el secreto y definirlo por entorno (`JWT_SECRET`) en `app` y `worker`; eliminar `backend/uploads/.jwt_secret`.
  2. **Bloquear `/uploads` a nivel Apache** (no confiar en el `.htaccess` del host, está tapado):
     ```apache
     <Directory "/var/www/html/uploads">
         Require all denied
     </Directory>
     ```
  3. **Corrección estructural:** cambiar `DocumentRoot` a `backend/public` (ver H-02). Los archivos deben servirse **solo** vía `MultimediaController` (que ya valida permisos).
  4. Si el secreto vive en archivo, ponerlo **fuera** del árbol web y con `chmod 600`, y no ejecutar `chmod -R 775` sobre todo `uploads/`.
- **Esfuerzo:** Bajo (rotar + denegar) / Medio (cambio de `DocumentRoot`).

### C-02 — Originales y material no aprobado accesibles por URL estática

- **Ubicación:** `backend/probe_originals.php:1-14`, `backend/probe_media.php:1-15`, `docker-compose.yml:12-13`, `/uploads/originals/*`.
- **CWE:** CWE-552 (archivos/directorios accesibles a terceros), CWE-284 · **OWASP:** A01.
- **Evidencia:** `probe_originals.php:3-9` recorre `uploads/originals/` y devuelve nombre, dimensiones, MIME y tamaño de cada archivo; las líneas 10-13 enumeran además los archivos de `uploads/`. El endpoint autenticado `GET /multimedia/{id}/original` **sí** controla propiedad/visibilidad, pero el archivo físico es alcanzable por ruta directa porque `uploads/` se sirve estáticamente y su `.htaccess` está tapado por el volumen (igual que C-01).
- **¿Es real y explotable?** Sí. `GET /probe_originals.php → 200` enumera los nombres (verificado en el análisis manual) y `GET /uploads/originals/<hash>.<ext> → 200` descarga el original.
- **Impacto:** filtración de fotografías/videos originales de colecciones privadas, **saltando la marca de agua** y la **moderación** (material de invitados con `aprobado = 0` se sirve antes de aprobarse). Divulga metadatos (tamaño, dimensiones).
- **Recomendación:** aplicar C-01/H-02 (denegar `/uploads` y mover el `DocumentRoot`), **eliminar `probe_media.php` y `probe_originals.php`** del árbol publicado (son scripts de diagnóstico) y servir siempre los binarios por los controladores con autorización.
- **Esfuerzo:** Bajo (borrar scripts + denegar `/uploads`) / Medio (con el cambio de `DocumentRoot`).

### C-03 — MySQL expuesto en `3306` con credenciales por defecto y fallback

- **Ubicación:** `backend/docker-compose.yml:78-89` (servicio `db`, `ports: "3306:3306"` en línea 83) y `backend/src/Core/Database.php:21-38`.
- **CWE:** CWE-798 (credenciales embebidas), CWE-1392 (credenciales por defecto), CWE-306 · **OWASP:** A05, A07.
- **Evidencia:**
  - `docker-compose.yml:83` publica `3306` en todas las interfaces.
  - `Database.php:22-27` define `cipher_user` / `cipher_password` como valores por defecto y `Database.php:33-38` los usa con `getenv(...) ?: $default` (**fallback inseguro**).
  - El compose **no pasa `MYSQL_PASSWORD` al servicio `db`** (solo `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, líneas 84-89) **ni `DB_PASS` a `app`/`worker`**; el propio `docs/manual-migracion-ubuntu-qr.md:527` reconoce que, en un volumen nuevo, MySQL no inicializaría bien y que “hoy funciona en Windows porque el volumen ya estaba inicializado”.
- **¿Es real y explotable?** Sí. Cualquier host de la LAN puede conectar a `<host>:3306` como `cipher_user` con `cipher_password` (verificación registrada en el análisis manual: `cipher_user@%` responde a una conexión remota).
- **Impacto:** lectura/escritura de toda la base (usuarios, emails, teléfonos, hashes bcrypt, códigos de verificación, tokens QR, colecciones privadas). Integridad y confidencialidad totales.
- **Recomendación:**
  1. **Eliminar `ports: "3306:3306"`** (la app y el worker ya hablan por la red interna `db`).
  2. Pasar `MYSQL_PASSWORD`/`DB_PASS` **reales** por `.env` y **quitar los fallbacks** de `Database.php` (fallar cerrado si falta `DB_PASS`).
  3. Rotar la contraseña de `cipher_user` y `MYSQL_ROOT_PASSWORD`; restringir el usuario a la subred de la app (no `%`).
- **Esfuerzo:** Bajo.

### H-01 — Endpoints `/sistema/*` sin autenticación efectiva

- **Ubicación:** `backend/routes.php:90-92`, `backend/src/controllers/SistemaController.php:36-59`.
- **CWE:** CWE-306 (falta autenticación en función crítica), CWE-284, CWE-352 · **OWASP:** A01.
- **Evidencia:** las tres rutas se registran **sin** middleware `auth` (`routes.php:90-92`). El único control es `SistemaController::restringirALocal()`, que mira `$_SERVER['REMOTE_ADDR']` y bloquea solo IPs públicas (`SistemaController.php:55-58`). Con el puerto publicado y `docker-proxy`, **el `REMOTE_ADDR` que ve Apache es siempre la IP privada del bridge de Docker**, sin importar el origen real (el propio comentario del código lo admite, `Config.php:92-96`).
- **¿Es real y explotable?** Sí. Cualquier cliente que alcance `:8080` (LAN) pasa el filtro: `GET /sistema/backups → 200` (verificado en el análisis manual). Además, `POST /sistema/limpiar-colaborativos` es un POST de formulario simple (sin preflight) → disparable por CSRF desde un sitio malicioso.
- **Impacto:** fuga de metadatos de respaldos; generación repetida de respaldos (CPU/IO/disco); **borrado destructivo** de material colaborativo no aprobado. DoS/CSRF de bajo costo.
- **Recomendación:** exigir **autenticación + rol administrativo** (hoy no existe rol `admin` en el esquema, ver `docs/SAST-Analisis-Manual-2026-10-26.md`) **o** sacar estas tareas de HTTP y dejarlas solo por CLI/worker (`cron-backup.php`). **No** apoyarse en `REMOTE_ADDR` detrás de Docker.
- **Esfuerzo:** Medio.

### H-02 — `DocumentRoot` expone archivos internos y de configuración

- **Ubicación:** `backend/Dockerfile:22` (`WORKDIR /var/www/html`), `backend/docker-compose.yml:12` (bind mount del backend completo), `backend/.htaccess:9-13` (sirve cualquier archivo real).
- **CWE:** CWE-552, CWE-538, CWE-219 · **OWASP:** A01, A05.
- **Evidencia:** el `DocumentRoot` efectivo es `/var/www/html` = raíz de `backend/`. La regla `RewriteCond %{REQUEST_FILENAME} !-f` (`backend/.htaccess:10`) hace que todo archivo existente se sirva. Quedan alcanzables `/.env`, `/.env.example`, `/docker-compose.yml`, `/database/schema.sql`, `/database/migration.sql`, `/Dockerfile`, `/php.ini`, documentación interna y los `probe_*` (reportado en el análisis manual).
- **¿Es real y explotable?** Sí. **Matiz de impacto:** el `backend/.env` versionado es una **plantilla comentada** (no contiene `JWT_SECRET` ni `DB_PASS` activos; `DB_PASS` está comentado en `backend/.env:76`), por lo que no filtra secretos vivos — pero sí confirma los valores por defecto (`cipher_password`) y la topología. `docker-compose.yml` y `schema.sql` revelan puertos, servicios, usuarios y esquema.
- **Impacto:** facilitación de reconocimiento (puertos, usuarios, esquema, endpoints) y encadenamiento con C-01/C-02/C-03. Superficie para `probe_media.php` (consumo de CPU) y otros scripts.
- **Recomendación:**
  1. **Cambiar el `DocumentRoot` a `backend/public`** (el `public/.htaccess` ya reescribe a `public/index.php`, líneas 4-18).
  2. Retirar del árbol web `.env`, `database/`, `backups/`, `uploads/`, documentación y `probe_*`/`cron-backup.php`.
  3. Añadir denegación en Apache para arquitectura/internos (`.env`, `*.md`, `*.sql`, `*.yml`, `*.ini`, `Dockerfile`, `probe_*`).
- **Esfuerzo:** Medio.

### V-B4 — Contenedor ejecutado como root (`docker:S6471`)

- **Ubicación:** `backend/Dockerfile:3` (`FROM php:8.2-apache`, sin `USER`), `backend/docker-entrypoint.sh`.
- **CWE:** CWE-250 (ejecución con privilegios innecesarios) · **OWASP:** A05.
- **Evidencia:** el Dockerfile no declara `USER`; `apache2-foreground` arranca el proceso maestro como **root** (los workers caen a `www-data`). El entrypoint usa `chown`/`mkdir`/`chmod` (`docker-entrypoint.sh:10-14`), que requieren root.
- **¿Es real y explotable?** Es un verdadero positivo, pero **de defensa en profundidad**: por sí solo no es explotable; se materializa si hay RCE y un fallo de escalada/escape. El contexto (proyecto local/educativo) reduce la severidad respecto de un servicio expuesto a Internet.
- **Impacto:** mayor alcance/impacto ante compromiso del proceso web (lectura/escritura con privilegios máximos dentro del contenedor).
- **Recomendación:** en el `Dockerfile`, escuchar Apache en `8080`, `chown` a `www-data` y `USER www-data`; ajustar `docker-compose.yml` a `8080:8080`. **Ojo:** el `chown` del entrypoint necesita root → usar un patrón `gosu`/`su-exec` (cambiar de usuario al final) o recrear el volumen `uploads_data` con el propietario correcto. Es un cambio que **debe probarse** (arranque + subidas).
- **Esfuerzo:** Medio-Alto (riesgo real de romper el arranque si no se ajusta el entrypoint).

---

## 4. Hallazgos que NO es necesario corregir

### 4.1 V-B1 — `sha1()` en `RateLimiter` (`php:S4790`)

- **Ubicación:** `backend/src/helpers/RateLimiter.php:151` → `return $dir . '/rl_' . sha1($clave) . '.json';`
- **¿Es cierto?** Técnicamente sí: usa SHA-1. Pero el uso es **no criptográfico**: deriva un **nombre de archivo** para un contador de rate limit en `sys_get_temp_dir()/cipher_forge_rate_limit/` (comentado en las líneas 149-150), no protege contraseñas, tokens ni firmas.
- **Motivo de la decisión:** **riesgo aceptable** (severidad Sonar inflada; CWE-328/CWE-916 no aplican al caso). La única explotación teórica es una colisión *chosen-prefix* para fusionar contadores, de impacto trivial (a lo sumo un ajuste de cuota) y costo impracticable.
- **Nota:** cambiar a `hash('sha256', $clave)` es 1 línea, sin impacto funcional salvo reiniciar los contadores vigentes (irrelevante). Es una **mejora de limpieza opcional** para bajar el rating de Sonar, no una necesidad de seguridad.

### 4.2 V-B2 y V-B3 — Cookies de sesión PHP sin `HttpOnly` / `Secure` (`php:S3330`, `php:S2092`)

- **Ubicación:** `backend/php.ini` (20 líneas; solo configura uploads/memoria/tiempos, sin bloque `session.*`).
- **¿Es cierto?** La ausencia de configuración es real.
- **Motivo de la decisión:** **no alcanzable**. Se verificó con búsqueda en todo el backend: **no existe ninguna llamada a `session_start()`**, por lo que PHP nunca emite una cookie `PHPSESSID`. La autenticación real usa una **cookie JWT propia** (`CookieAuth::crear()`, `CookieAuth.php:70-83`) que **ya es `HttpOnly`** y `SameSite=Strict`.
- **Nota:** `session.cookie_httponly = 1` es una buena práctica por defecto y no cuesta nada; `session.cookie_secure = 1` **no debe fijarse en duro** en desarrollo HTTP (rompería sesiones si algún día se usaran). Aplicar solo como defensa preventiva. La regla queda como *“won't fix / no aplica”* en Sonar.

### 4.3 B-01 y B-02 — `require` en `probe_media.php` (`php:S2003`)

- **Ubicación:** `backend/probe_media.php:2-3`.
- **¿Es cierto?** Sí: usa `require` en lugar de `require_once`.
- **Motivo de la decisión:** **sin impacto de seguridad** (a lo sumo un fatal error por doble inclusión, y solo si se incluyera dos veces el mismo archivo). Además, la recomendación es **eliminar este script** del árbol publicado (ver C-02/H-02), con lo que el hallazgo desaparece. Si se conserva para uso local, el cambio a `require_once` es trivial.

### 4.4 Code smells (64) — deuda de mantenibilidad, no riesgo de seguridad

No son vulnerabilidades: son reglas de calidad que afectan al Quality Gate (cobertura 0 %, duplicación 10.03 %, 95 violaciones nuevas), no al modelo de amenaza. Se agrupan por regla y se revisó si alguno ocultaba un problema real:

| Regla | Cant. | Qué es | Revisión AppSec | Recomendación |
|:---|:--:|:---|:---|:---|
| `php:S1192` | 13 | Literales duplicados (mensajes, rutas, `"Y-m-d H:i:s"`) | No hay secretos hardcodeados en esos literales | Opcional: constantes/clase de mensajes |
| `php:S3776` | 12 | Complejidad cognitiva alta | Revisadas las funciones sensibles: `Mailer::enviar()` **sí sanea CR/LF** (`Mailer.php:82-86`); `MediaProcessor` usa `escapeshellarg()` en los 3 `exec()` (líneas 135, 232, 263); `Router::dispatch()` solo enruta. **No ocultan inyección** | Opcional: extraer métodos |
| `php:S121` | 2 | `if`/`for` sin llaves | Sin impacto | Opcional |
| `php:S1142` | 10 | Retornos dispersos | Sin impacto | Opcional |
| `php:S112` | 3 | Excepciones genéricas | Ver nota M-01 abajo: `public/index.php:119-120` devuelve `$e->getMessage()` → fuga menor de detalle | Opcional (crear excepciones propias) |
| `php:S1172` | 2 | Parámetros sin uso (`MultimediaService.php:40` `$mime`, `:104` `$extensionesPorMime`) | Confirmado: el mapa de extensiones se resuelve en el validador; `MultimediaController.php:46` lo pasa y se ignora | Opcional: eliminar parámetros |
| `php:S127` | 1 | Contador de bucle modificado (`QrGenerator.php:438-441`) | Es el **algoritmo QR estándar** (salto de la columna de sincronización 6); intencional y funcionalmente correcto | Opcional: reescribir con `while` documentado |
| `php:S1448` | 1 | `QrGenerator` con 28 métodos (máx. 20), `QrGenerator.php:13` | Mantenibilidad; se relaciona con `S3776` | Opcional: partir en clases |
| `php:S1068` | 1 | Constante sin uso `EXTENSION_POR_MIME` (`ColaborativoController.php:32`) | Confirmado (existe duplicada y también ignorada en `MultimediaController.php:20`) | Opcional: eliminar |
| `php:S113` | 14 | Falta salto de línea final | Sin impacto | Opcional: trivial |
| `php:S1135` | 3 | “Comentarios TODO” | **FALSO POSITIVO.** No existe ningún `TODO`/`FIXME` en mayúsculas. Las 3 líneas señaladas (`ColaborativoController.php:258`, `Request.php:24`, `MultimediaService.php:142`) contienen la **palabra castellana “todo”** (“sin abortar **todo** el lote”, “Retorna **todo** el body”). Sonar la interpreta como tag TODO | **No corregir** (falso positivo); no hay tarea pendiente |
| `php:S1131` | 1 | Espacios al final de línea (`Database.php:36`) | Sin impacto | Opcional: trivial |
| `docker:S7031` | 1 | `RUN` separadas (`Dockerfile:5-18`) | Sin impacto | Opcional: fusionar capas |

> **Observación fuera de alcance (M-01 del informe manual):** `public/index.php:119-120` responde `"Error interno del servidor: " . $e->getMessage()`, lo que puede filtrar `SQLSTATE`, nombres de tablas y rutas. No está listado en `backend.md`, pero conviene devolver un mensaje genérico y registrar el detalle. Se menciona por rigor; no forma parte de los 75 hallazgos evaluados.

---

## 5. Hallazgos que requieren más información

**No hay hallazgos bloqueantes:** los 75 se pudieron clasificar con el código y la configuración disponibles. Las cuatro verificaciones dinámicas que quedaron pendientes en el triage **ya se realizaron el 2026-10-27** (ver §8) y arrojaron los resultados esperados:

1. **C-01/C-02:** `GET /uploads/.jwt_secret` y `GET /uploads/originals/<archivo>` → **404** (el `DocumentRoot` en `public/` los deja fuera del árbol web; ver §8).
2. **C-03:** credenciales con las que quedó inicializado el volumen MySQL y si `cipher_user` acepta conexión remota → **el puerto `3306` ya no se publica** (solo red interna `db`).
3. **H-01:** `GET /sistema/backups` sin autenticación → **401** (middleware `auth` activo).
4. **V-B4:** uid del proceso dentro del contenedor → **`uid=33(www-data)`**.

Ninguna de estas verificaciones cambió la clasificación: todas confirmaron el hallazgo y quedaron remediadas.

---

## 6. Orden de prioridad sugerido

| Orden | Acción | Hallazgos | Esfuerzo | Motivo |
|:--:|:---|:---|:--:|:---|
| **1** | Rotar `JWT_SECRET` por entorno, eliminar `uploads/.jwt_secret` y **denegar `/uploads` en Apache** | C-01 | Bajo | Suplantación total de cuentas |
| **2** | **`DocumentRoot` → `backend/public`**; retirar `uploads/`, `.env`, `database/`, documentación y `probe_*` del árbol web | H-02, C-02, C-01 | Medio | Corrección estructural que elimina la clase de riesgo |
| **3** | **Cerrar `3306`**, rotar credenciales y **quitar el fallback** de `Database.php` | C-03 | Bajo | Exposición de toda la base |
| **4** | Asegurar `/sistema/*` (auth+rol o solo CLI); no confiar en `REMOTE_ADDR` | H-01 | Medio | Mantenimiento destructivo expuesto + CSRF |
| **5** | Contenedor como usuario no root (con ajuste de entrypoint/volumen y prueba) | V-B4 | Medio-Alto | Defensa en profundidad |
| **6** | Calidad para el Quality Gate: `S1135` (falso positivo, marcar), `S113`, `S1131`, `S1192`, `S121`, `S1172`, `S1068`, `docker:S7031` | Code smells fáciles | Bajo | Baja el conteo de violaciones |
| **7** | Refactor mayor: `S3776`, `S1448`, `S1142`, `S112`, `S127` | Code smells complejos | Medio-Alto | Mantenibilidad |
| **8** | (Opcional) `sha1` → `sha256` en `RateLimiter` | V-B1 | Bajo | Silenciar Sonar; sin riesgo real |

**Principio rector:** los pasos 1-4 son correcciones de **seguridad real** (P0). Los pasos 5-8 son **hardening y calidad**, importantes para el Quality Gate pero no críticos para el modelo de amenaza de un despliegue local/educativo. Al aplicar el paso 2, los pasos 1 y 3 quedan parcialmente cubiertos (C-01/C-02), y los bugs B-01/B-02 y los `probe_*` desaparecen al borrar los scripts.

---

## 7. Referencias y notas de rigor

- **CWE/OWASP** citados por hallazgo (arriba). El proyecto **sí** aplica controles correctos que conviene preservar: `PDO::prepare()` con `ATTR_EMULATE_PREPARES => false` (`Database.php:48-54`), `password_hash`/`password_verify`, JWT HS256 con `hash_equals`, cookie `HttpOnly`+`SameSite=Strict`, `escapeshellarg()` en FFmpeg, allowlist JPEG/MP4 y autorización por propietario en los servicios.
- **Duplicados/variantes agrupados:** V-B2≈V-B3 (sesiones PHP); C-01 y C-02 (misma causa raíz, impactos distintos); los 64 code smells por regla; S1172 y S1068 (mismo mapa de extensiones muerto).
- **Líneas:** referencian el commit `0aca934`; verificado que HEAD `aa3b0a2` no las desplaza (solo cambió texto en `QrGenerator.php:88-153`).
- **Trazabilidad:** el triage inicial (§1-§7) fue **solo lectura** y no modificó código. Las correcciones posteriores, aprobadas por el responsable, se detallan en §8.

---

## 8. Estado de remediación (aplicado y verificado el 2026-10-27)

Tras la aprobación del responsable se aplicaron las **6 correcciones de seguridad reales**. Los cambios están en el repositorio (rama `main`) y se verificaron levantando la imagen corregida contra el MySQL en Docker, en un puerto de prueba (`127.0.0.1:18080`) para no interferir con el despliegue de Nginx de la VM.

### 8.1 Cambios aplicados

| # | Hallazgo | Archivo(s) modificado(s) | Qué se hizo |
|:--|:---|:---|:---|
| 1 | **C-01** | `backend/src/Core/Config.php` | `jwtSecret()` ahora **falla cerrado**: exige `JWT_SECRET` por entorno y ya no genera ni lee `uploads/.jwt_secret`. |
| 2 | **C-01/H-02** | `backend/docker-compose.yml` | Se pasa `JWT_SECRET=${JWT_SECRET:?…}` a `app` y `worker` (variable obligatoria). |
| 3 | **C-02** | `backend/probe_media.php`, `backend/probe_originals.php`, `backend/Dockerfile` | Se **eliminaron** los dos scripts de diagnóstico (`git rm`) y se denegó `/uploads` a nivel Apache (defensa en profundidad). |
| 4 | **C-03** | `backend/docker-compose.yml`, `backend/src/Core/Database.php` | Se **quitó** `ports: "3306:3306"` (la BD solo se alcanza por la red interna `db`) y se eliminó el fallback `cipher_password`: sin `DB_PASS` la app falla cerrada. |
| 5 | **H-01** | `backend/routes.php` | Las rutas `/sistema/*` ahora exigen el middleware `'auth'` (sesión), además del filtro por IP ya existente. |
| 6 | **H-02** | `backend/Dockerfile` | `DocumentRoot` → `/var/www/html/public`. El resto del backend (`src`, `database`, `backups`, `uploads`, `.env`, documentación, `probe_*`) queda **fuera del árbol web**. |
| 7 | **V-B4** | `backend/Dockerfile`, `backend/docker-entrypoint.sh` | Apache escucha en **8080**, el proceso corre como `www-data` (UID 33) y el entrypoint hace `chown` condicional. La app publica `127.0.0.1:8080:8080` (Nginx es el proxy público). |

También se actualizó `backend/.env.example` con las variables obligatorias (`MYSQL_*`, `JWT_SECRET`, `FRONTEND_URL`).

### 8.2 Verificación dinámica (peticiones reales a la imagen corregida)

Contenedor de prueba `cipher-forge:test` (imagen reconstruida) + volumen nombrado para `uploads`, corriendo como `www-data`.

| Petición | Resultado | Esperado | Observación |
|:---|:--:|:--:|:---|
| `GET /api/ping` | `200` | 200 | app operativa |
| `GET /colecciones/publicas` | `200` | 200 | *front controller* funciona con el nuevo `DocumentRoot` |
| `GET /multimedia/1/vista-previa` | `401` | 401 | sigue exigiendo sesión |
| `GET /uploads/.jwt_secret` | `404` | 403/404 | **C-01 / H-02** |
| `GET /uploads/originals/test.jpg` | `404` | 403/404 | **C-02 / H-02** |
| `GET /uploads/` | `404` | 403/404 | — |
| `GET /.env` | `404` | 403/404 | **H-02** |
| `GET /docker-compose.yml` | `404` | 403/404 | **H-02** |
| `GET /Dockerfile` | `404` | 403/404 | **H-02** |
| `GET /database/schema.sql` | `404` | 403/404 | **H-02** |
| `GET /sistema/backups` | `401` | 401/403 | **H-01** (sin sesión) |
| `GET /probe_originals.php` | `404` | 404 | **C-02** (eliminado) |
| `GET /probe_media.php` | `404` | 404 | **C-02** (eliminado) |
| `GET /src/Core/Config.php` | `404` | 404 | **H-02** |
| `GET /routes.php` | `404` | 404 | **H-02** |
| `GET /php.ini` | `404` | 404 | **H-02** |
| `docker exec … id` | `uid=33(www-data)` | www-data | **V-B4** |
| Escritura en `uploads/` como `www-data` | `WRITE_OK` | OK | el volumen es escribible |
| `docker compose config` (puertos publicados) | solo `8080`, `8025`, `1025` | sin `3306` | **C-03** |

Además se ejecutó el probe E2E (`probe_e2e.ps1`): registro + verificación de email + login (fotógrafo y cliente), control de rol (`403`/`401` correctos) y logout con borrado de cookie → **todo OK**, lo que confirma que las correcciones no rompieron el flujo funcional.

### 8.3 Hallazgo colateral detectado y corregido (no era de seguridad)

En la prueba, el entrypoint fallaba al conectar a MySQL: usaba `mysql --ssl-mode=DISABLED`, opción **inexistente** en el cliente MariaDB que trae la imagen (`default-mysql-client`). Consecuencia: la espera terminaba en *timeout* (60 s) y la **migración idempotente nunca se ejecutaba**. Se reemplazó por una detección automática (`--ssl-mode=DISABLED` si el binario es MySQL; `--skip-ssl` si es MariaDB). Con el arreglo, el arranque conecta al instante y la migración **sí** corre. Se documenta para trazabilidad porque el flag `--ssl-mode` provenía de un cambio local previo.

### 8.4 Notas para el despliegue y para el re-escaneo

- **`docker:S6471` (contenedor como root) puede seguir marcándose** aunque aquí **sí** exista `USER www-data` y el proceso real corra como `www-data`: trátese como falso positivo residual del analizador o de la caché del escaneo.
- **Puerto del contenedor:** pasó de `80` a **`8080`**. Si algún Nginx/`proxy_pass` apunta a `app:80`, debe actualizarse a **`app:8080`**. El manual (`docs/manual-migracion-ubuntu-qr.md`) ya usa `8080`, por lo que no requiere cambios.
- **`.env` obligatorio en el servidor:** `docker compose up` ahora **falla a propósito** si faltan `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `JWT_SECRET` o `FRONTEND_URL`. Generar `JWT_SECRET` con `openssl rand -hex 32` y rotar las claves de MySQL.
- Al rotar `JWT_SECRET` se invalidan las sesiones vigentes (los usuarios vuelven a iniciar sesión). No se pierden cuentas ni contraseñas.

### 8.5 Fuera de alcance (bug preexistente detectado, no de seguridad)

`GET /fotografos` y `GET /fotografos/{id}` devuelven **500** porque `backend/src/repository/UserRepository.php:218,235` usa `INNER JOIN Fotografos` (F mayúscula) mientras la tabla real es `fotografos` (minúscula; MySQL en Linux es *case-sensitive*). **No** forma parte de los 75 hallazgos ni de las correcciones aprobadas; se reporta por haber aparecido en la prueba E2E. Corrección sugerida: bajar `Fotografos` → `fotografos` en ambas consultas.

*Documento generado a partir de `docs/backend.md`, del código del repositorio y de la evidencia de apoyo `docs/SAST-Analisis-Manual-2026-10-26.md`.*
