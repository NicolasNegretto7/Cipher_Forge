# Análisis SAST — Cipher Forge / Gestion-fotografias

**Fecha:** 2026-10-26  
**Tipo de análisis:** Static Application Security Testing (SAST) manual + verificación controlada de configuración y despliegue  
**Proyecto:** `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias`  
**Stack revisado:** PHP 8.2 / Apache / MySQL 8.0 / JavaScript / HTML / CSS / Docker Compose  
**Entorno de verificación:** stack local `cipher_forge_app` (`http://localhost:8080`), `cipher_forge_db` (`3306`), `cipher_forge_mail` (`8025`/`1025`)  
**Resultado global:** **FAIL** — 3 hallazgos críticos, 2 altos, 6 medios y 7 bajos.

> Este documento no reproduce secretos activos, tokens de sesión, contraseñas de usuarios ni datos personales. La contraseña `cipher_password` se cita únicamente como evidencia del valor por defecto ya presente en el código (`backend/src/Core/Database.php`) y en la documentación del proyecto, no como credencial de una cuenta. Las pruebas dinámicas fueron de solo lectura: no se ejecutaron `POST /sistema/backup` ni `POST /sistema/limpiar-colaborativos`, no se descargaron respaldos y las consultas SQL realizadas se limitaron a `SELECT 1` y `SELECT CURRENT_USER()`.

---

## 1. Resumen ejecutivo

La revisión manual del backend, los dos frontends, la configuración de Apache/PHP, Docker Compose y los scripts auxiliares permitió identificar **18 hallazgos de seguridad**. Tres de ellos son críticos y, encadenados, permiten a un atacante no autenticado:

1. **Firmar sus propios JWT** usando la clave secreta expuesta en `http://localhost:8080/uploads/.jwt_secret` y suplantar cualquier cuenta.
2. **Descargar los archivos originales** de las colecciones directamente desde `/uploads/originals/...`, sin autenticación, sin comprobar propiedad y sin marca de agua.
3. **Acceder a la base de datos completa** desde la red usando las credenciales por defecto `cipher_user` / `cipher_password`, ya que el puerto `3306` está publicado y el usuario MySQL es `cipher_user@%`.

La causa raíz común de los dos primeros hallazgos es de **despliegue**, no de una regla SAST clásica: el `DocumentRoot` de Apache es la raíz del backend (`/var/www/html`) y el volumen Docker `uploads_data` tapa el archivo `backend/uploads/.htaccess`. Por eso el directorio `uploads/` queda servido estáticamente y su `.htaccess` de denegación no existe dentro del contenedor.

El resto de hallazgos incluye endpoints administrativos sin autenticación (`/sistema/*`), exposición de archivos internos (`.env`, `docker-compose.yml`, `schema.sql`, documentación de auditoría), fuga de mensajes de excepción con SQL, XSS en la hoja imprimible de QR, token JWT aceptado por query string, CORS demasiado permisivo para `localhost`, cookie sin `Secure`, Mailpit expuesto sin autenticación, enumeración de usuarios, código de verificación en claro, ausencia de cabeceras de seguridad, contenedor como root, respaldos con PII sin cifrar y falta de rate limiting en subidas.

### Acciones inmediatas (0–24 h)

1. **Rotar el secreto JWT** y eliminar `backend/uploads/.jwt_secret` del volumen expuesto.
2. **Bloquear `/uploads` a nivel Apache** (`Require all denied`) y, preferiblemente, mover los archivos fuera del `DocumentRoot`.
3. **Cerrar el puerto `3306`** y cambiar la contraseña de `cipher_user`; eliminar el fallback `cipher_password` de `Database.php`.
4. **Deshabilitar `/sistema/*` por HTTP** o exigir autenticación y rol administrativo.
5. **Cambiar el `DocumentRoot` a `backend/public`** y retirar del árbol web `.env`, `database/`, `backups/`, `uploads/`, documentación y scripts de diagnóstico.
6. **Invalidar todas las sesiones** existentes (al rotar el JWT) y revisar accesos anómalos.

---

## 2. Alcance y metodología

### 2.1 Alcance

| Componente | Elementos revisados |
|:---|:---|
| Backend PHP | `public/index.php`, `routes.php`, `src/Core/*`, `src/controllers/*`, `src/services/*`, `src/repository/*`, `src/validators/*`, `src/middlewares/*`, `src/helpers/*` |
| Frontends | `frontend-cliente/` y `frontend-fotografo/`: JS de `dom/` y `services/`, HTML y CSS |
| Infraestructura | `Dockerfile`, `docker-compose.yml`, `docker-entrypoint.sh`, `.htaccess` de raíz, `public/`, `uploads/` y `backups/`, `php.ini` |
| Base de datos | `database/schema.sql`, `migration.sql`, consultas preparadas y control de acceso |
| Scripts auxiliares | `cron-backup.php`, `probe_media.php`, `probe_originals.php` |
| Documentación | `README.md`, `important.md`, `docs/SAST-SonarQube-Reporte.md`, `SISTEMA_LOCAL.md`, `critical-problems/CRITICAL.md`, `FAILS-TESTED.md` |

### 2.2 Método

- Revisión manual dirigida por sinks y controles: autenticación, autorización, exposición de archivos, subida de archivos, SQL, comandos del sistema, XSS, CORS, cookies, secretos y configuración Docker.
- Verificación controlada de los hallazgos de configuración contra el stack local ya levantado, mediante peticiones HTTP de solo lectura y una consulta SQL `SELECT 1`.
- Prueba de concepto de JWT forjado **solo de lectura** (`GET /favoritos` y `GET /colecciones/mias`), sin modificar datos.
- No se ejecutó SonarQube en esta pasada porque el servidor no estaba disponible; se tomó como línea base el reporte `docs/SAST-SonarQube-Reporte.md` (2026-09-11) y se complementó con revisión manual y de despliegue.

### 2.3 Limitaciones

- No es un pentest completo ni un análisis de infraestructura de red externo.
- No se probaron cargas maliciosas reales, fuerza bruta, denegación de servicio ni explotación destructiva.
- No se descargaron respaldos ni se accedió a datos personales; no se explotó la base de datos más allá de consultas de metadatos (`SELECT 1`, `SELECT CURRENT_USER()`).
- Las credenciales de prueba aportadas por el solicitante no fueron necesarias para demostrar los hallazgos y no se registran en este documento.
- El esquema solo define los roles `fotografo` y `cliente` (`backend/database/schema.sql:12`); no existe un rol `admin`, lo que condiciona la remediación de `/sistema/*`.

---

## 3. Matriz de hallazgos

| ID | Severidad | Hallazgo | CWE principal | OWASP Top 10 | Ubicación principal |
|:--|:--|:--|:--|:--|:--|
| **C-01** | **Crítico** | Secreto de firma JWT expuesto en `/uploads/.jwt_secret`; permite forjar tokens de cualquier usuario | CWE-522 / CWE-200 | A01, A02, A07 | `docker-compose.yml:13`, `Config.php:17-37`, `uploads/.htaccess` ausente |
| **C-02** | **Crítico** | Originales y material no aprobado accesibles directamente en `/uploads/originals/*` | CWE-552 / CWE-284 | A01 | `docker-compose.yml:13`, `uploads/`, `probe_originals.php` |
| **C-03** | **Crítico** | Credenciales MySQL por defecto y puerto `3306` expuesto a la red | CWE-798 / CWE-1392 | A05, A07 | `Database.php:21-38`, `docker-compose.yml:82-89` |
| **H-01** | **Alto** | `/sistema/*` sin autenticación; el filtro por IP se evade con el NAT de Docker | CWE-306 / CWE-284 | A01 | `routes.php:90-92`, `SistemaController.php:36-59` |
| **H-02** | **Alto** | `DocumentRoot` expone `.env`, `docker-compose.yml`, SQL, documentación y scripts internos | CWE-552 / CWE-538 | A01, A05 | `Dockerfile:22`, `docker-entrypoint.sh`, `.htaccess:9-13` |
| **M-01** | Medio | Mensajes de excepción con SQLSTATE, nombres de tablas y rutas | CWE-209 | A05 | `public/index.php:119-120` |
| **M-02** | Medio | XSS almacenado/reflejado en la hoja imprimible de QR | CWE-79 | A03 | `QrGenerator.php:88-153` |
| **M-03** | Medio | Token JWT aceptado por `?token=` en cualquier endpoint autenticado | CWE-598 | A02, A07 | `AuthMiddleware.php:86-90` |
| **M-04** | Medio | CORS refleja orígenes y permite credenciales a cualquier `localhost` | CWE-942 | A05 | `public/index.php:61-92` |
| **M-05** | Medio | Cookie JWT sin `Secure` y aplicación servida por HTTP | CWE-614 / CWE-319 | A02, A05 | `docker-compose.yml:35`, `CookieAuth.php:32-40` |
| **M-06** | Medio | Mailpit expuesto sin autenticación en `8025`/`1025` | CWE-306 / CWE-200 | A05, A07 | `docker-compose.yml:70-76` |
| **L-01** | Bajo | Enumeración de usuarios por respuestas diferenciadas | CWE-203 | A07 | `AuthService.php:40-42, 136-138, 167-169` |
| **L-02** | Bajo | Código de verificación almacenado en claro y comparado con `!==` | CWE-312 / CWE-208 | A02 | `UserRepository.php:115-127`, `AuthService.php:144` |
| **L-03** | Bajo | Ausencia de cabeceras de seguridad (CSP, HSTS, nosniff, frame-ancestors) | CWE-693 / CWE-1021 | A05 | `public/index.php`, `QrGenerator.php` |
| **L-04** | Bajo | Contenedor Docker ejecutado como root | CWE-250 | A05 | `Dockerfile` (sin `USER`) |
| **L-05** | Bajo | Respaldos SQL con PII y hashes, sin cifrar y con permisos laxos | CWE-312 / CWE-359 | A02 | `BackupService.php:111-164`, `backend/backups/` |
| **L-06** | Bajo | Sin rate limiting en subidas; agotamiento de cuota/CPU con tokens QR | CWE-770 | A04 | `RateLimitMiddleware.php:42-57`, `ColaborativoController.php:222-302` |
| **L-07** | Bajo | SMTP sin TLS/STARTTLS; credenciales AUTH LOGIN en claro si se usa SMTP externo | CWE-319 | A02 | `Mailer.php:91-120` |

---

## 4. Hallazgos críticos

### C-01 — Secreto de firma JWT expuesto y suplantación de cualquier cuenta

**Severidad:** Crítica  
**CWE:** CWE-522 (Insufficiently Protected Credentials), CWE-200 (Exposure of Sensitive Information), CWE-306 (Missing Authentication for Critical Function)  
**OWASP:** A01 Broken Access Control, A02 Cryptographic Failures, A07 Identification and Authentication Failures

#### Evidencia

- `docker-compose.yml:13` monta el volumen nombrado `uploads_data` sobre `/var/www/html/uploads`, tapando el archivo `backend/uploads/.htaccess` que existe en el host.
- Dentro del contenedor, el directorio no contiene `.htaccess`:

```text
docker exec cipher_forge_app ls -la /var/www/html/uploads
-rwxrwxr-x 1 www-data www-data 64 .jwt_secret
drwxrwxr-x 2 www-data www-data originals
drwxrwxr-x 2 www-data www-data previews
drwxrwxr-x 2 www-data www-data standard
```

- El secreto es accesible por HTTP sin autenticación:

```text
GET http://localhost:8080/uploads/.jwt_secret
HTTP/1.1 200 OK
Content-Length: 64
```

- `Config::jwtSecret()` (`backend/src/Core/Config.php:17-37`) usa `JWT_SECRET` si existe; si no, lee `uploads/.jwt_secret`, y si no existe lo genera y lo guarda allí. En el contenedor **no está definida `JWT_SECRET`**, por lo que la clave efectiva es el archivo expuesto.
- `docker-entrypoint.sh:13-14` ejecuta `chown -R www-data:www-data` y `chmod -R 775 /var/www/html/uploads`, lo que vuelve el secreto legible por todos los usuarios del contenedor y anula el `chmod 0600` que intenta aplicar `Config::jwtSecret()`.
- `AuthMiddleware::authenticate()` (`backend/src/middlewares/AuthMiddleware.php:138-162`) valida el JWT con `Config::jwtSecret()` y carga el usuario por el `sub` del token.
- **PoC de solo lectura:** se firmó un JWT HS256 con el secreto expuesto, usando `sub = 1` y una expiración corta. Sin cookie ni credenciales:

```text
GET /favoritos          con Authorization: Bearer <token_forjado>  -> 200
GET /colecciones/mias   con Authorization: Bearer <token_forjado>  -> 200
```

La respuesta de `/colecciones/mias` devolvió colecciones del usuario `id = 1`, confirmando la suplantación.

#### Impacto

Cualquier atacante con acceso HTTP al puerto `8080` puede firmar tokens válidos para **cualquier `id` de usuario** (los IDs son secuenciales). Esto permite:

- Acceder a colecciones privadas, originales y descargas.
- Subir, modificar o eliminar contenido en nombre de un fotógrafo.
- Aceptar políticas, generar QR y realizar cualquier acción autenticada.
- Persistir el acceso hasta que se rote el secreto.

Es el hallazgo de mayor prioridad porque convierte una exposición de archivo estático en una **toma de control total de cuentas**.

#### Remediación

1. **Rotar el secreto ya:** definir un `JWT_SECRET` fuerte (32+ bytes aleatorios) por variable de entorno/secreto, eliminar `uploads/.jwt_secret`, reiniciar la aplicación. Esto invalida todos los tokens existentes.
2. **Bloquear `/uploads` en Apache**, no solo con `.htaccess`:

```apache
<Directory "/var/www/html/uploads">
    Require all denied
</Directory>
```

3. **Mover `uploads/` fuera del `DocumentRoot`** o cambiar el `DocumentRoot` a `backend/public` (ver H-02). Es la corrección estructural.
4. **No montar un volumen nombrado sobre un directorio que contiene archivos de seguridad**; si se necesita persistencia, montar el `.htaccess` como archivo de solo lectura o aplicar la denegación en la configuración de Apache.
5. **Ajustar permisos**: `chmod 600` para `.jwt_secret`, propietario `www-data`; evitar `chmod -R 775` sobre todo `uploads/`.
6. Añadir una comprobación de arranque que falle si `.jwt_secret` es accesible por HTTP.

#### Verificación posterior

```text
curl -i http://localhost:8080/uploads/.jwt_secret   -> 403/404
JWT forjado con el secreto antiguo                  -> 401
Login legítimo y cookie HttpOnly                    -> 200
```

---

### C-02 — Originales y material no aprobado accesibles por URL estática

**Severidad:** Crítica  
**CWE:** CWE-552 (Files or Directories Accessible to External Parties), CWE-284 (Improper Access Control), CWE-200  
**OWASP:** A01 Broken Access Control

#### Evidencia

- El endpoint protegido `GET /multimedia/{id}/original` sí comprueba sesión, visibilidad de la colección y propiedad (`backend/src/services/MultimediaService.php:466-506`). Sin embargo, el mismo archivo se sirve directamente desde el sistema de archivos:

```text
GET http://localhost:8080/uploads/originals/<hash>.jpg
HTTP/1.1 200 OK
Content-Length: 134137
```

- `probe_originals.php` (`backend/probe_originals.php:1-14`) está en la raíz web y lista todos los nombres de archivo de `uploads/originals/`:

```text
GET http://localhost:8080/probe_originals.php
HTTP/1.1 200 OK
<hash>.jpg => 1920x1280 mime=image/jpeg (134137 bytes)
<hash>.jpg => 1920x1140 mime=image/jpeg (112066 bytes)
...
```

- `uploads/.htaccess` existe en el host (`backend/uploads/.htaccess:5-10`) con `Require all denied`, pero **no está presente en el volumen** que ve Apache (ver C-01). Por eso la denegación no se aplica.
- El material de invitados pendiente de aprobación (`aprobado = 0`) también se guarda en `uploads/originals/` y `uploads/previews/`; la URL estática lo sirve antes de la moderación, saltando los controles añadidos en `MultimediaService` para H-01/H-04.

#### Impacto

- Descarga de fotografías y videos originales de **colecciones privadas** sin autenticación.
- Exposición de material de invitados **antes de la aprobación** del fotógrafo.
- Bypass de la marca de agua y de las reglas de negocio (RF11/HU20, RF14/RF15).
- Los nombres aleatorios no son un control de acceso: `probe_originals.php` los enumera y, aunque se elimine, un atacante con acceso al listado de la API o a un enlace compartido puede obtenerlos.

#### Remediación

1. Aplicar la corrección de `DocumentRoot`/Apache de H-02 y C-01.
2. Eliminar `probe_originals.php`, `probe_media.php` y cualquier script de diagnóstico del árbol web.
3. Servir siempre los archivos a través de los controladores que validan permisos; para archivos grandes, usar `X-Sendfile`/`X-Accel-Redirect` desde una ruta fuera del `DocumentRoot`.
4. Mantener `uploads/` fuera de la raíz web y con `Require all denied` como defensa en profundidad.
5. Verificar que el material no aprobado solo sea accesible por el fotógrafo dueño, incluso a través de rutas estáticas.

#### Verificación posterior

```text
GET /uploads/originals/<hash>.jpg        -> 403/404
GET /probe_originals.php                 -> 404
GET /multimedia/<id>/original sin sesión -> 401
GET /multimedia/<id>/original con dueño  -> 200
```

---

### C-03 — Credenciales MySQL por defecto y base de datos expuesta en `3306`

**Severidad:** Crítica  
**CWE:** CWE-798 (Use of Hard-coded Credentials), CWE-1392 (Use of Default Credentials), CWE-306  
**OWASP:** A05 Security Misconfiguration, A07 Identification and Authentication Failures

#### Evidencia

- `backend/src/Core/Database.php:21-38` define credenciales por defecto:

```php
public function __construct(
    string $host = 'db',
    string $user = 'cipher_user',
    string $password = 'cipher_password',
    string $port = '3306',
    string $name = 'cipher_forge',
    string $charset = 'utf8mb4',
)
```

- `docker-compose.yml:82-89` publica el puerto y crea el usuario:

```yaml
ports:
  - "3306:3306"
environment:
  - MYSQL_ROOT_PASSWORD
  - MYSQL_DATABASE
  - MYSQL_USER=cipher_user
```

- El contenedor de base de datos sí recibe `MYSQL_ROOT_PASSWORD` y `MYSQL_DATABASE`, pero **no** `MYSQL_PASSWORD`; el contenedor de la aplicación no define `DB_PASS`. El comentario del compose (líneas 85-86) afirma que `MYSQL_PASSWORD` se carga desde `.env`, pero la variable no está incluida en la lista. Por eso `Database.php` cae en `cipher_password`. El usuario creado por la imagen oficial es `cipher_user@%`.
- Verificación controlada:

```text
docker exec cipher_forge_db mysql -ucipher_user -pcipher_password -e "SELECT CURRENT_USER();"
cipher_user@%

docker run --rm mysql:8.0 mysql --host=host.docker.internal --port=3306 \
  --user=cipher_user --password=cipher_password \
  --execute="SELECT CURRENT_USER(), 'conexion_remota_ok';"
cipher_user@%    conexion_remota_ok
```

La segunda prueba confirma que la base de datos es accesible **desde fuera del contenedor** por el puerto publicado.

#### Impacto

Un atacante en la misma red (o cualquier proceso que alcance el puerto `3306`) puede leer y modificar toda la base de datos:

- Usuarios, emails, teléfonos y hashes bcrypt.
- Códigos de verificación de email y tokens QR.
- Colecciones privadas, accesos, favoritos y metadatos.
- Registros de respaldos.

También puede crear usuarios, cambiar roles, borrar datos o usar la base como pivote. Los hashes bcrypt no son recuperables directamente, pero pueden crackearse offline; los códigos de verificación y tokens QR son utilizables de inmediato.

#### Remediación

1. **Eliminar `ports: "3306:3306"`** de `docker-compose.yml`; la base solo debe ser accesible por la red interna de Docker.
2. Exigir `DB_PASS`/`MYSQL_PASSWORD` fuertes desde un gestor de secretos; **no** usar valores por defecto en `Database.php` (fallar cerrado si falta la variable).
3. Restringir el usuario MySQL a la red/host de la aplicación (`'cipher_user'@'app'` o subred Docker), no `%`.
4. Rotar la contraseña de `cipher_user` y `MYSQL_ROOT_PASSWORD`; verificar que no se reutilicen.
5. Sacar `.env` del árbol web (H-02) y no versionar secretos.
6. No publicar Mailpit ni otros servicios de desarrollo (M-06).

#### Verificación posterior

```text
nc -vz localhost 3306                         -> cerrado/filtrado
mysql -h localhost -u cipher_user -p ...      -> falla
app -> db por red interna                     -> OK
```

---

## 5. Hallazgos altos

### H-01 — Endpoints `/sistema/*` sin autenticación y filtro de IP evadible

**Severidad:** Alta  
**CWE:** CWE-306 (Missing Authentication for Critical Function), CWE-284 (Improper Access Control), CWE-352 (CSRF)  
**OWASP:** A01 Broken Access Control

#### Evidencia

- `backend/routes.php:90-92` registra los tres endpoints sin middleware `auth`:

```php
$router->add('POST', '/sistema/backup', SistemaController::class, 'backup');
$router->add('GET', '/sistema/backups', SistemaController::class, 'listarBackups');
$router->add('POST', '/sistema/limpiar-colaborativos', SistemaController::class, 'limpiarColaborativos');
```

- `SistemaController::restringirALocal()` (`backend/src/controllers/SistemaController.php:36-59`) solo mira `REMOTE_ADDR` y permite cualquier IP privada/reservada. El propio comentario reconoce que el tráfico del host llega por el NAT del bridge de Docker con una IP privada (por ejemplo, `172.x`).
- En el stack verificado, una petición sin cookie ni token devolvió `200`:

```text
GET http://localhost:8080/sistema/backups
HTTP/1.1 200 OK
{"ok":true,"datos":[{"id_backup":23,...}, ...]}
```

- Cualquier cliente que alcance el puerto `8080` pasa el filtro, porque Docker presenta una IP privada. Además, un sitio web malicioso puede enviar un formulario `POST` a `http://localhost:8080/sistema/limpiar-colaborativos` (petición simple, sin preflight) y provocar la purga de material sin que la víctima lo sepa.

#### Impacto

- `GET /sistema/backups`: fuga de nombres, rutas y fechas de respaldos.
- `POST /sistema/backup`: generación repetida de respaldos, consumo de CPU/IO y disco.
- `POST /sistema/limpiar-colaborativos`: **eliminación destructiva** de material colaborativo no aprobado con más de 24 h, sin consentimiento del fotógrafo.
- Superficie de CSRF/DoS de bajo coste contra una aplicación local.

#### Remediación

1. Añadir middleware `auth` y un rol administrativo explícito (hoy no existe; el esquema solo tiene `fotografo`/`cliente`).
2. Si las tareas deben ser solo locales, usar `Require local` de Apache y **no** publicar el puerto a través del NAT de Docker; el chequeo por `REMOTE_ADDR` no distingue clientes remotos en este despliegue.
3. Preferir ejecución por CLI/worker (`cron-backup.php`) y deshabilitar los endpoints HTTP en producción.
4. Añadir CSRF si se mantienen endpoints con cookie; limitar tasa y auditar cada invocación.
5. Documentar y probar la restricción con un cliente externo, no solo desde el host.

#### Verificación posterior

```text
GET /sistema/backups sin token             -> 401/403
POST /sistema/backup sin token             -> 401/403
POST desde un origen externo (CSRF)        -> bloqueado
GET /sistema/backups con rol autorizado    -> 200
```

---

### H-02 — `DocumentRoot` expone archivos internos, configuración y documentación

**Severidad:** Alta  
**CWE:** CWE-552 (Files or Directories Accessible to External Parties), CWE-538 (Insertion of Sensitive Information into Externally-Accessible File or Directory), CWE-219 (Storage of File with Sensitive Data Under Web Root)  
**OWASP:** A01 Broken Access Control, A05 Security Misconfiguration

#### Evidencia

El `DocumentRoot` efectivo es `/var/www/html` (valor por defecto de la imagen `php:8.2-apache`), que corresponde a la raíz de `backend/`; `Dockerfile:22` fija ese directorio como `WORKDIR` y el compose monta el proyecto completo en él (`docker-compose.yml:12`). La regla de `backend/.htaccess:9-13` sirve cualquier archivo o carpeta real, por lo que los archivos internos son accesibles:

| Ruta | Resultado | Contenido |
|:---|:---|:---|
| `/.env` | `200` (3.899 bytes) | Comentarios de configuración; documenta la contraseña por defecto `cipher_password` y la ubicación de `.jwt_secret` |
| `/.env.example` | `200` | Claves de configuración y valores por defecto |
| `/docker-compose.yml` | `200` | Puertos, servicios, usuarios, `COOKIE_SECURE=false`, Mailpit |
| `/database/schema.sql` | `200` | Esquema completo de la base |
| `/database/migration.sql` | `200` | Migraciones y nombres de columnas |
| `/Dockerfile` | `200` | Imagen base, entrypoint, configuración |
| `/php.ini` | `200` | Límites de subida y ejecución |
| `/important.md` | `200` | Hallazgos H01–H11 y estado de seguridad |
| `/AUDITORIA_ENDPOINTS.md` | `200` (59.945 bytes) | Documentación interna de endpoints |
| `/critical-problems/CRITICAL.md` | `200` | Problemas críticos internos |
| `/SISTEMA_LOCAL.md` | `200` | Cómo se restringen `/sistema/*` |
| `/EMAIL_CONFIG.md` | `200` | Configuración de correo |
| `/FAILS-TESTED.md` | `200` | Fallos funcionales y pruebas |
| `/probe_originals.php` | `200` | Listado de archivos originales |
| `/probe_media.php` | expuesto (no invocado) | Procesamiento de imágenes de prueba |
| `/cron-backup.php` | expuesto (no invocado) | Script de mantenimiento |
| `/uploads/.jwt_secret` | `200` | Secreto JWT (C-01) |
| `/uploads/originals/<hash>.jpg` | `200` | Originales (C-02) |

- `sonar-project.properties:6` excluye `backend/uploads/**` y `backend/backups/**` del análisis, por lo que el SAST previo no cubrió estos directorios.
- `probe_media.php` y `cron-backup.php` son scripts CLI/de diagnóstico que quedan ejecutables por HTTP; según el SAPI y `$argv`, pueden provocar procesamiento de imágenes o tareas de mantenimiento no deseadas.

#### Impacto

- Divulgación de arquitectura, esquema, endpoints, puertos, usuarios y medidas de seguridad.
- Divulgación de la contraseña por defecto de MySQL y de la ubicación del secreto JWT.
- Futuras claves en `.env` (`JWT_SECRET`, `DB_PASS`, SMTP) quedarían expuestas automáticamente.
- Los scripts de diagnóstico pueden usarse para denegación de servicio o para generar archivos.
- Facilita el encadenamiento con C-01, C-02 y C-03.

#### Remediación

1. **Cambiar el `DocumentRoot` a `/var/www/html/public`** y ajustar el entrypoint/Apache; el `index.php` y el `.htaccess` de `public/` ya existen.
2. Si no se puede cambiar el `DocumentRoot`, denegar en Apache todo excepto `public/` y las rutas de la API:

```apache
<Directory "/var/www/html">
    Require all denied
</Directory>
<Directory "/var/www/html/public">
    Require all granted
</Directory>
```

3. Mover `.env`, `database/`, `backups/`, `uploads/`, documentación y scripts fuera del árbol web.
4. Eliminar `probe_media.php`, `probe_originals.php` y `cron-backup.php` de la imagen de producción; el worker debe ejecutarlos por CLI.
5. Añadir reglas de denegación para `.env`, `.md`, `.sql`, `.yml`, `.ini`, `Dockerfile`, `probe_*` y `cron-backup.php`.
6. Mantener `.dockerignore` y un pipeline que verifique que no se publique ningún archivo interno.

#### Verificación posterior

```text
GET /.env                      -> 403/404
GET /docker-compose.yml        -> 403/404
GET /database/schema.sql       -> 403/404
GET /important.md              -> 403/404
GET /probe_originals.php       -> 403/404
GET /api/ping                  -> 200
GET /colecciones/publicas      -> 200
```

---

## 6. Hallazgos medios

### M-01 — Fuga de información por mensajes de excepción

**Severidad:** Media  
**CWE:** CWE-209 (Generation of Error Message Containing Sensitive Information)  
**OWASP:** A05 Security Misconfiguration

**Evidencia:** `backend/public/index.php:119-120` captura `Throwable` y devuelve el mensaje interno:

```php
} catch (Throwable $e) {
    Response::error("Error interno del servidor: " . $e->getMessage(), 500);
}
```

Una petición a `/fotografos` devolvió:

```json
{"ok":false,"mensaje":"Error interno del servidor: SQLSTATE[42S02]: Base table or view not found: 1146 Table 'cipher_forge.Fotografos' doesn't exist","errores":[]}
```

Esto revela el motor de base de datos, el nombre de la base y la tabla. El error se produce además por un problema funcional: `UserRepository.php:218` y `:235` usan `Fotografos` con mayúscula, mientras que la tabla es `fotografos` (MySQL en Linux es case-sensitive).

**Impacto:** divulgación de esquema, rutas y detalles internos; ayuda a ataques de inyección y a la enumeración de la base. El error funcional deja el directorio de fotógrafos inoperativo.

**Remediación:** registrar el detalle en el log del servidor y devolver un mensaje genérico con un identificador de correlación; no concatenar `getMessage()` en la respuesta. Corregir el nombre de la tabla a `fotografos`. Asegurar `APP_DEBUG=false` y `display_errors=0` en producción.

### M-02 — XSS en la hoja imprimible de QR

**Severidad:** Media  
**CWE:** CWE-79 (Improper Neutralization of Input During Web Page Generation)  
**OWASP:** A03 Injection

**Evidencia:** `QrGenerator::renderPrintableHtml()` (`backend/src/helpers/QrGenerator.php:88-153`) interpola sin escapar:

- `$tituloEvento` en `<title>` (línea 100) y `<h1>` (línea 128).
- `$urlAcceso` en `<div class="url-box">` (línea 146).
- `$expiracion` en el párrafo de expiración (línea 91).
- Además, usa un `onclick="window.print()"` inline (línea 148) y no define CSP.

`ColaborativoController::imprimir()` (`backend/src/controllers/ColaborativoController.php:139-177`) pasa el título de la colección, que es un campo controlado por el fotógrafo (`VARCHAR(60)`), y `$urlAcceso` se construye a partir de `FRONTEND_URL`, `HTTP_REFERER` o `HTTP_HOST` (`armarUrlColaborativo`, líneas 354-387; `armarUrlFront`, líneas 338-343).

**Impacto:** un fotógrafo con una colección titulada con HTML/JS puede ejecutar script en el origen de la API cuando se abre la hoja imprimible; si la página se comparte o si un rol administrativo la visualiza, el XSS es almacenado. El token de sesión es HttpOnly, pero el script puede realizar acciones autenticadas y leer respuestas. La URL basada en `Referer`/`Host` permite inyectar contenido adicional si se controla esa cabecera.

**Remediación:**

```php
$titulo = htmlspecialchars($tituloEvento, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
$url    = htmlspecialchars($urlAcceso, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
$exp    = htmlspecialchars((string) $expiracion, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
```

Construir la URL solo desde `FRONTEND_URL` configurado (ignorar `Host`/`Referer`), añadir CSP (`default-src 'none'; style-src 'unsafe-inline'; img-src data:;`) y reemplazar el `onclick` por un listener JS. Validar el título contra un conjunto de caracteres permitido.

### M-03 — Token JWT aceptado por query string

**Severidad:** Media  
**CWE:** CWE-598 (Use of GET Request Method With Sensitive Query Strings)  
**OWASP:** A02 Cryptographic Failures, A07 Identification and Authentication Failures

**Evidencia:** `AuthMiddleware::obtenerCabeceraAuth()` (`backend/src/middlewares/AuthMiddleware.php:86-90`) acepta `?token=` como fallback para ventanas de impresión/descarga:

```php
if (isset($_GET['token']) && is_string($_GET['token']) && trim($_GET['token']) !== '') {
    $tokenQuery = trim($_GET['token']);
    return str_starts_with($tokenQuery, 'Bearer ') ? $tokenQuery : 'Bearer ' . $tokenQuery;
}
```

El fallback aplica a **cualquier** endpoint con middleware `auth`, no solo a impresión/descarga.

**Impacto:** el JWT queda en el historial del navegador, logs de Apache/proxies, cabecera `Referer` hacia terceros y capturas de pantalla. Un atacante con acceso a esos registros puede reutilizarlo durante 24 h (sin revocación). También facilita fugas por enlaces compartidos.

**Remediación:** eliminar el fallback; usar la cookie HttpOnly (ya es el mecanismo principal) o un token de descarga de un solo uso, con alcance y expiración cortos. Si se necesita imprimir en otra pestaña, usar una ruta dedicada que reciba el token por `POST` o un nonce. Configurar `Referrer-Policy: no-referrer` y redactar tokens en logs.

### M-04 — CORS demasiado permisivo para orígenes locales

**Severidad:** Media  
**CWE:** CWE-942 (Permissive Cross-domain Policy with Untrusted Domains)  
**OWASP:** A05 Security Misconfiguration

**Evidencia:** `backend/public/index.php:61-92` refleja el `Origin` recibido. Si el host es `localhost`, `127.0.0.1` o `::1` (cualquier puerto), responde:

```http
Access-Control-Allow-Origin: <origen>
Access-Control-Allow-Credentials: true
Vary: Origin
```

Para orígenes no locales, refleja el origen con `Access-Control-Allow-Credentials: false`.

**Impacto:** cualquier página servida en `http://localhost:<puerto>` (otra aplicación local, un servicio de desarrollo comprometido o una extensión) puede realizar peticiones autenticadas y leer las respuestas. El riesgo es menor que un `*` con credenciales, pero sigue siendo una política demasiado amplia; en producción no debería existir la excepción de “cualquier localhost”.

**Remediación:** usar una allowlist exacta de orígenes (esquema, host y puerto) desde configuración; no reflejar orígenes desconocidos; eliminar la excepción de localhost en producción; mantener `Vary: Origin`; permitir credenciales solo para el origen exacto del frontend.

### M-05 — Cookie JWT sin `Secure` y aplicación por HTTP

**Severidad:** Media  
**CWE:** CWE-614 (Sensitive Cookie in HTTPS Session Without 'Secure' Attribute), CWE-319 (Cleartext Transmission of Sensitive Information)  
**OWASP:** A02 Cryptographic Failures, A05 Security Misconfiguration

**Evidencia:** `docker-compose.yml:35` define `COOKIE_SECURE=false`; la aplicación se publica en `http://localhost:8080`. `CookieAuth::segura()` (`backend/src/helpers/CookieAuth.php:32-40`) devuelve `false`, por lo que la cookie JWT se envía por HTTP sin `Secure`. La cookie sí es `HttpOnly` y `SameSite=Strict` (`CookieAuth.php:70-83`), lo que mitiga XSS de lectura y CSRF, pero no la interceptación en red.

**Impacto:** un atacante en la misma red Wi-Fi/LAN puede capturar el JWT y suplantar la sesión. En producción, sin HTTPS ni HSTS, el riesgo es alto; en desarrollo local es aceptable solo si se documenta y se aísla.

**Remediación:** terminar TLS en un reverse proxy, forzar HTTPS y `COOKIE_SECURE=true` en producción; añadir `Strict-Transport-Security`; redirigir HTTP a HTTPS. Mantener `HttpOnly` y `SameSite=Strict`. Para desarrollo, usar un perfil separado con `COOKIE_SECURE=false`.

### M-06 — Mailpit expuesto sin autenticación

**Severidad:** Media  
**CWE:** CWE-306 (Missing Authentication for Critical Function), CWE-200  
**OWASP:** A05 Security Misconfiguration, A07 Identification and Authentication Failures

**Evidencia:** `docker-compose.yml:70-76` publica la interfaz y el SMTP de Mailpit en todas las interfaces:

```yaml
ports:
  - "8025:8025"
  - "1025:1025"
```

Verificación: `GET http://localhost:8025/` devuelve `200`; `GET /api/v1/messages` devuelve `200`. Mailpit no tiene autenticación. Los correos de verificación contienen códigos de 6 dígitos.

**Impacto:** un atacante en la red puede leer los códigos de verificación y verificar cuentas ajenas, leer correos de phishing/reset (si se añaden), y enviar correo a través del SMTP local. Combinado con L-01 (enumeración) y C-03, facilita la toma de cuentas.

**Remediación:** enlazar Mailpit solo a loopback (`127.0.0.1:8025:8025`, `127.0.0.1:1025:1025`) y no incluirlo en el compose de producción. Para producción, usar un SMTP real con TLS y autenticación. Restringir el acceso por red y eliminar la UI de desarrollo.

---

## 7. Hallazgos bajos

### L-01 — Enumeración de usuarios

**Severidad:** Baja  
**CWE:** CWE-203 (Observable Discrepancy), CWE-204  
**OWASP:** A07

`AuthService::register()` devuelve `409` con “El correo electrónico ya está registrado” (`AuthService.php:40-42`); `verificarEmail()` y `reenviarCodigo()` devuelven `404` con “No existe ningún usuario con ese correo” (`:136-138`, `:167-169`). El login sí usa un mensaje genérico, lo cual es correcto.

**Impacto:** un atacante puede determinar qué correos están registrados y dirigir phishing o credential stuffing.

**Remediación:** respuestas genéricas del tipo “Si el correo existe, se envió un código”, independientemente de la existencia; mantener rate limiting y añadir CAPTCHA en registro/reenvío.

### L-02 — Código de verificación en claro y comparación no constante

**Severidad:** Baja  
**CWE:** CWE-312 (Cleartext Storage of Sensitive Information), CWE-208 (Observable Timing Discrepancy)  
**OWASP:** A02

`UserRepository::guardarCodigoVerificacion()` (`UserRepository.php:115-127`) guarda el código de 6 dígitos en claro; `AuthService::verificarEmail()` lo compara con `!==` (`AuthService.php:144`). El código expira en 1 h y hay rate limiting (6/10 min), lo que limita la fuerza bruta, pero un acceso a la BD (C-03) permite usarlo directamente. Los respaldos también lo incluyen.

**Remediación:** almacenar un HMAC/hash del código, comparar con `hash_equals()`, invalidarlo tras el primer uso, bajarlo a 10–15 min y excluirlo de los respaldos. Mantener el rate limiting.

### L-03 — Ausencia de cabeceras de seguridad

**Severidad:** Baja  
**CWE:** CWE-693 (Protection Mechanism Failure), CWE-1021 (Improper Restriction of Rendered UI Layers)  
**OWASP:** A05

`public/index.php` solo define cabeceras CORS. No hay `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`/`frame-ancestors`, `Referrer-Policy`, `Permissions-Policy` ni `Strict-Transport-Security`. La hoja imprimible usa JavaScript inline.

**Impacto:** clickjacking, MIME sniffing, fuga de `Referer` (especialmente con M-03), y mayor impacto de cualquier XSS.

**Remediación:** añadir en Apache/PHP:

```http
Content-Security-Policy: default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Permissions-Policy: camera=(), microphone=(), geolocation=()
Strict-Transport-Security: max-age=31536000; includeSubDomains (solo HTTPS)
```

Ajustar la CSP a los recursos reales y eliminar `onclick` inline.

### L-04 — Contenedor Docker como root

**Severidad:** Baja  
**CWE:** CWE-250 (Execution with Unnecessary Privileges)  
**OWASP:** A05

`backend/Dockerfile` no define `USER`; `apache2-foreground` arranca como root y los workers como `www-data`. Un RCE en la aplicación se ejecuta normalmente como `www-data`, pero el proceso principal y el entrypoint conservan privilegios de root; un fallo de escalada o permisos laxos sobre volúmenes puede comprometer el contenedor completo y su configuración. Es el hallazgo `docker:S6471` del reporte Sonar previo.

**Remediación:** crear un usuario no root, ejecutar Apache en un puerto alto (`8080`) y mapear `80:8080`; o usar `php-fpm` + Nginx no root. Añadir `read_only: true`, `tmpfs`, `cap_drop: [ALL]`, `security_opt: [no-new-privileges:true]` y límites de recursos.

### L-05 — Respaldos SQL con PII, sin cifrar y con permisos laxos

**Severidad:** Baja  
**CWE:** CWE-312 (Cleartext Storage of Sensitive Information), CWE-359 (Exposure of Private Personal Information), CWE-732  
**OWASP:** A02

`BackupService::generarSqlDump()` (`BackupService.php:111-164`) vuelca todas las tablas, incluidos `usuarios` (emails, teléfonos, hashes bcrypt, códigos de verificación) y tokens QR. Los archivos de `backend/backups/` tienen permisos `644` y el directorio `755`; el `.htaccess` bloquea HTTP (`403`), pero cualquier usuario/proceso con acceso al volumen puede leerlos. No hay cifrado en reposo.

**Impacto:** exposición de PII y credenciales si se filtra el volumen, un backup o el host; incumplimiento de la Ley 18.331.

**Remediación:** cifrar los respaldos (GPG/age o cifrado nativo), permisos `600`/`700`, almacenarlos fuera del árbol web, excluir columnas sensibles cuando sea posible, definir retención y borrado seguro, y auditar el acceso. Probar la restauración cifrada.

### L-06 — Sin rate limiting en subidas y agotamiento de recursos

**Severidad:** Baja  
**CWE:** CWE-770 (Allocation of Resources Without Limits or Throttling)  
**OWASP:** A04 Insecure Design

`RateLimitMiddleware::REGLAS` (`RateLimitMiddleware.php:42-57`) solo cubre login, registro, verificación y reenvío. `POST /colecciones/{id}/multimedia` y `POST /colaborativo/{token}/subir` no tienen límite por IP/token; cada archivo dispara GD/FFmpeg y consume cuota de 3 GB. Un token QR filtrado o compartido permite subir muchos archivos y agotar CPU/disco; la comprobación de cuota no es atómica frente a subidas concurrentes.

**Remediación:** limitar peticiones y archivos por IP/token, procesar en cola asíncrona, hacer la comprobación de cuota atómica (transacción/bloqueo), añadir CAPTCHA o prueba de trabajo en el flujo de invitados y monitorear el uso.

### L-07 — SMTP sin TLS/STARTTLS

**Severidad:** Baja  
**CWE:** CWE-319 (Cleartext Transmission of Sensitive Information)  
**OWASP:** A02

`Mailer::enviar()` usa `fsockopen($host, $port, ...)` (`Mailer.php:91`) sin `ssl://` ni STARTTLS, y `AUTH LOGIN` envía usuario/contraseña en base64 (no cifrado) en `Mailer.php:108-120`. En desarrollo con Mailpit local es aceptable; si se configura un SMTP externo en producción, las credenciales y los correos viajan en claro.

**Remediación:** usar `ssl://`/`tls://` o STARTTLS, validar el certificado, exigir autenticación y no usar Mailpit en producción. Documentar que el transporte debe ser TLS.

---

## 8. Controles positivos observados

- **SQL injection:** las consultas usan `PDO::prepare()` y `PDO::ATTR_EMULATE_PREPARES => false` (`Database.php:48-54`); las cláusulas `IN` dinámicas se construyen con `intval` y placeholders (`MultimediaRepository.php:179-221`). No se encontraron concatenaciones de entrada de usuario en SQL.
- **Command injection:** `MediaProcessor` usa `escapeshellarg()` en las llamadas a FFmpeg (`MediaProcessor.php:135-139, 232-237, 263-268`).
- **Contraseñas:** `password_hash(PASSWORD_DEFAULT)` y `password_verify()` (`AuthService.php:45, 89`); el login usa un mensaje genérico y bloquea cuentas no verificadas.
- **JWT:** HS256 con `hash_equals()` para la firma y validación de `exp` (`Jwt.php:60-77`); la cookie es `HttpOnly` y `SameSite=Strict` (`CookieAuth.php:70-83`).
- **Subidas:** `is_uploaded_file()`, `mime_content_type()`, límites de tamaño, nombres aleatorios y allowlist JPEG/MP4 (`MultimediaValidator.php:32-96`, `MediaProcessor::nombreUnico`).
- **Autorización:** los servicios de colecciones y multimedia comprueban propiedad y acceso (`ColeccionService.php:139-152, 248-251, 273-276`; `MultimediaService.php:512-530`); el material no aprobado se bloquea en las rutas del controlador (`MultimediaService.php:217-223, 274-281, 483-490`).
- **Rate limiting:** login, registro, verificación y reenvío tienen reglas por IP/email (`RateLimitMiddleware.php:42-57`).
- **Backups:** `backend/backups/.htaccess` sí bloquea HTTP (`403` verificado); el problema es `uploads/` y el resto del árbol web.
- **Frontend:** no se encontraron sinks DOM XSS clásicos (`innerHTML`, `outerHTML`, `document.write`, `eval`, `new Function`, `srcdoc`) en los JS revisados.
- **Errores PHP:** `display_errors=0` y `log_errors=1` en `public/index.php:7-8`; el `register_shutdown_function` devuelve un mensaje genérico para errores fatales (la fuga está en el `catch` de M-01).

---

## 9. Relación con el reporte SonarQube previo

El reporte `docs/SAST-SonarQube-Reporte.md` (2026-09-11) registró 4 vulnerabilidades:

| Hallazgo Sonar | Estado actual | Observación |
|:---|:---|:---|
| `php:S3330` cookie sin HttpOnly | **No aplica al JWT** | La app usa una cookie JWT propia (`CookieAuth`), no `PHPSESSID`; la cookie sí es `HttpOnly`. La regla de `php.ini` sobre sesiones PHP es un falso positivo para este flujo. |
| `php:S2092` cookie sin Secure | **Parcialmente vigente** | La cookie JWT se crea con `Secure` según `COOKIE_SECURE`, pero el compose lo fija en `false` (M-05). |
| `php:S5122` CORS `*` | **Corregido en código, pero aún permisivo** | Ya no se usa `*`; se refleja el origen y se permite credenciales a cualquier `localhost` (M-04). |
| `docker:S6471` contenedor root | **Vigente** | El `Dockerfile` sigue sin `USER` (L-04). |

Además, el SAST previo **no cubrió** `backend/uploads/**` ni `backend/backups/**` (`sonar-project.properties:6`). Los hallazgos C-01, C-02 y C-03 son de configuración/despliegue y no suelen ser detectados por reglas SAST de código; requieren revisión de infraestructura y pruebas de exposición.

---

## 10. Plan de remediación priorizado

| Prioridad | Plazo | Acciones | Hallazgos |
|:--|:--|:--|:--|
| **P0** | 0–24 h | Rotar `JWT_SECRET`; eliminar/renombrar `uploads/.jwt_secret`; bloquear `/uploads` en Apache; cerrar `3306`; cambiar contraseña de `cipher_user`; eliminar `cipher_password` como fallback; deshabilitar `/sistema/*` por HTTP; invalidar sesiones | C-01, C-02, C-03, H-01 |
| **P1** | 2–7 días | `DocumentRoot` a `backend/public`; retirar `.env`, `database/`, `backups/`, `uploads/`, documentación y scripts del árbol web; eliminar `probe_*` y `cron-backup.php` del HTTP; corregir XSS y fuga de excepciones; quitar `?token=`; allowlist CORS; TLS + `COOKIE_SECURE=true`; Mailpit solo loopback | C-02, H-02, M-01, M-02, M-03, M-04, M-05, M-06 |
| **P2** | 2–4 semanas | Cifrar respaldos; permisos 600/700; rate limiting de subidas; usuario no root en Docker; `read_only`/`cap_drop`; respuestas genéricas de enumeración; hash del código de verificación; cabeceras de seguridad; SMTP TLS; monitoreo/alertas | L-01…L-07 |
| **P3** | Continuo | Reevaluar con SonarQube/Trivy; pruebas de regresión de seguridad; revisión de dependencias e imágenes; auditoría de logs; plan de respuesta a incidentes; formación del equipo | Todos |

### Comandos de verificación sugeridos

> Ejecutar solo en un entorno de prueba controlado. En un sistema sin corregir, `POST /sistema/backup` genera un respaldo real y `POST /sistema/limpiar-colaborativos` elimina material.

```powershell
# Exposición de archivos
curl.exe -i http://localhost:8080/uploads/.jwt_secret
curl.exe -i http://localhost:8080/uploads/originals/<hash>.jpg
curl.exe -i http://localhost:8080/.env
curl.exe -i http://localhost:8080/important.md

# Endpoints administrativos
curl.exe -i http://localhost:8080/sistema/backups
curl.exe -i -X POST http://localhost:8080/sistema/backup

# Base de datos
Test-NetConnection localhost -Port 3306
mysql -h localhost -u cipher_user -p

# Cabeceras y cookies
curl.exe -i http://localhost:8080/api/ping
```

Para las pruebas de JWT, usar un token de un usuario de prueba y verificar que un token firmado con el secreto anterior devuelve `401` después de la rotación.

---

## 11. Conclusión

El proyecto tiene controles de seguridad razonables en el código de aplicación (consultas preparadas, bcrypt, JWT firmado, cookies HttpOnly/SameSite, validación de subidas, autorización por propietario y rate limiting de autenticación). Sin embargo, **la configuración de despliegue anula esos controles**: el árbol web expone `uploads/`, el secreto JWT y archivos internos; el filtro de `/sistema/*` no funciona detrás de Docker; y la base de datos queda accesible con credenciales por defecto.

Los tres hallazgos críticos deben tratarse como **incidente de seguridad** y no solo como deuda técnica: rotar el secreto, cerrar la base de datos y bloquear `uploads/` son acciones inmediatas. Una vez aplicadas las correcciones P0/P1, se recomienda reejecutar SonarQube, un escaneo de imágenes (Trivy/Grype) y una prueba de exposición externa para confirmar que no quedan rutas estáticas sensibles.

---

**Fin del reporte.**
