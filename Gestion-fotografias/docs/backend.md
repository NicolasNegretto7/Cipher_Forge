# SAST — Hallazgos del Backend (Cipher Forge)

**Fecha del análisis:** 26/10/2026, 13:18 (UTC-3)  
**Herramienta:** SonarQube Community Build 26.8.0.126808 + SonarScanner CLI 8.1.0.6389  
**Proyecto:** `cipher-forge` — `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias`  
**Commit analizado:** `0aca934dfe4662c406da22d5ac4cd9f84b951013`  
**Dashboard:** <http://localhost:9000/dashboard?id=cipher-forge>  
**Quality Gate global:** **ERROR**

> Este documento contiene únicamente los hallazgos del backend: API PHP, configuración PHP/Apache, Docker y scripts auxiliares. Los hallazgos del frontend están en [`frontend.md`](frontend.md).
>
> En SonarQube, `Critical`, `Major`, `Minor` e `Info` son severidades de mantenibilidad. Solo la sección de **vulnerabilidades** tiene impacto directo de seguridad.

---

## 1. Resumen del backend

| Vulnerabilidades | Bugs | Code smells | Total |
|:---:|:---:|:---:|:---:|
| 4 | 2 | 64 | **70** |

### 1.1 Quality Gate global

El Quality Gate es del proyecto completo; se incluye aquí porque condiciona la entrega. Las métricas de cobertura y duplicación no se pueden atribuir solo al backend.

| Condición | Valor real | Umbral | Estado |
|:---|:---:|:---:|:---:|
| Cobertura del código nuevo | 0.0 % | ≥ 80 % | ERROR |
| Duplicación del código nuevo | 10.03 % | ≤ 3 % | ERROR |
| Violaciones nuevas | 95 | 0 | ERROR |

**Estado global: ERROR.** Corregir los hallazgos de este documento reduce las violaciones, pero el Quality Gate también exige pruebas automatizadas y menos duplicación.

### 1.2 Prioridad del backend

| Prioridad | Qué corregir | Cantidad |
|:---|:---|:---:|
| **P0 — Seguridad** | 4 vulnerabilidades + riesgos críticos de despliegue | 9 |
| **P1 — Bugs** | `require` duplicables en `probe_media.php` | 2 |
| **P2 — Code smells críticos** | `php:S1192` (13), `php:S3776` (12), `php:S121` (2) | 27 |
| **P3 — Code smells mayores** | `php:S1142` (10), `php:S112` (3), `php:S1172` (2), `php:S127`, `php:S1448`, `php:S1068` | 18 |
| **P4 — Menores e informativos** | `php:S113` (14), `php:S1135` (3), `php:S1131`, `docker:S7031` | 19 |
| **P5 — Quality Gate** | Cobertura y duplicación globales | — |

La fila P0 suma 9 porque incluye las 4 vulnerabilidades de Sonar más los 5 riesgos críticos de despliegue de la sección 5, que son adicionales a los 70 hallazgos del escaneo.

---

## 2. Vulnerabilidades (4)

| ID | Severidad | Regla | Ubicación | Cambio requerido |
|:---|:---|:---|:---|:---|
| V-B1 | **Critical** | `php:S4790` | `backend/src/helpers/RateLimiter.php:151` | Sustituir `sha1()` por SHA-256 o justificar la excepción. |
| V-B2 | Minor | `php:S3330` | `backend/php.ini` | Añadir `session.cookie_httponly = 1`. |
| V-B3 | Minor | `php:S2092` | `backend/php.ini` | Añadir `session.cookie_secure = 1`. |
| V-B4 | Minor | `docker:S6471` | `backend/Dockerfile:3` | Ejecutar el contenedor con un usuario no root. |

### V-B1 — Hash débil en el rate limiter (`php:S4790`)

**Archivo:** `backend/src/helpers/RateLimiter.php:151`  
**Código actual:**

```php
return $dir . '/rl_' . sha1($clave) . '.json';
```

**Problema:** SonarQube marca `sha1()` como algoritmo débil. En este caso se usa para generar un nombre de archivo de contador, no para contraseñas ni firmas, por lo que el riesgo real es bajo; aun así, la regla queda abierta y el rating de seguridad baja a **E**.

**Cambio recomendado:**

```php
return $dir . '/rl_' . hash('sha256', $clave) . '.json';
```

Si se decide conservar SHA-1 por compatibilidad con los contadores existentes, documentar la excepción con `// NOSONAR` y una justificación técnica. No usar `md5()` ni `sha1()` para contraseñas, tokens o firmas.

**Verificación:** el nuevo escaneo no debe mostrar `php:S4790`.

### V-B2 — Cookie de sesión sin `HttpOnly` (`php:S3330`)

**Archivo:** `backend/php.ini` (la propiedad no está definida)  
**Cambio:** añadir al final del archivo:

```ini
session.cookie_httponly = 1
```

**Motivo:** impide que JavaScript lea la cookie de sesión nativa de PHP en caso de XSS. La aplicación usa una cookie JWT propia que ya es `HttpOnly`, pero la configuración de PHP debe ser segura por defecto.

**Verificación:**

```powershell
docker exec cipher_forge_app php -i | Select-String "cookie_httponly"
```

### V-B3 — Cookie de sesión sin `Secure` (`php:S2092`)

**Archivo:** `backend/php.ini`  
**Cambio:** añadir:

```ini
session.cookie_secure = 1
```

**Motivo:** la cookie solo debe viajar por HTTPS. En el entorno local actual la aplicación se sirve por HTTP, pero no se encontró ningún uso de `session_start()` en el backend; la cookie de autenticación real es la cookie JWT de `CookieAuth`. Si en el futuro se habilitan sesiones PHP sobre HTTP local, usar `0` solo en el perfil de desarrollo y `1` en producción.

**Verificación:**

```powershell
docker exec cipher_forge_app php -i | Select-String "cookie_secure"
```

### V-B4 — Contenedor ejecutado como root (`docker:S6471`)

**Archivo:** `backend/Dockerfile:3`  
**Problema:** la imagen `php:8.2-apache` arranca Apache como root. Un fallo de la aplicación o del entrypoint se ejecuta con privilegios máximos dentro del contenedor.

**Cambio requerido:**

1. Ejecutar Apache en un puerto no privilegiado, por ejemplo `8080`.
2. Crear o reutilizar un usuario sin privilegios (`www-data`).
3. Dar permisos de escritura solo a las carpetas necesarias (`uploads`, logs y PID de Apache).
4. Declarar `USER www-data` antes de `CMD`.
5. Cambiar el mapeo de `docker-compose.yml` de `"8080:80"` a `"8080:8080"`.
6. Ajustar `docker-entrypoint.sh`: el `chown` inicial solo puede ejecutarse como root; si el contenedor arranca como `www-data`, hay que recrear el volumen de `uploads` con el propietario correcto o usar un paso de inicialización con `gosu`/`su-exec`.

**Ejemplo de Dockerfile:**

```dockerfile
FROM php:8.2-apache

# ... instalación de dependencias y extensiones ...

RUN a2enmod rewrite \
    && sed -ri 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
    && sed -ri 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' \
        /etc/apache2/sites-available/000-default.conf \
    && chown -R www-data:www-data \
        /var/www/html \
        /var/run/apache2 \
        /var/log/apache2

USER www-data
EXPOSE 8080
CMD ["apache2-foreground"]
```

**Nota:** al cambiar el usuario hay que revisar el `ENTRYPOINT` y el volumen `uploads_data`; un volumen ya creado conserva el propietario anterior. Documentar el procedimiento de migración antes de aplicarlo.

---

## 3. Bugs (2)

| Regla | Severidad | Ubicación | Cambio |
|:---|:---|:---|:---|
| `php:S2003` | Minor | `backend/probe_media.php:2` | `require` → `require_once`. |
| `php:S2003` | Minor | `backend/probe_media.php:3` | `require` → `require_once`. |

**Recomendación adicional:** `probe_media.php` y `probe_originals.php` son scripts de diagnóstico que no deberían estar en la raíz web. Si se eliminan del árbol publicado (ver sección 5), estos dos bugs desaparecen y se reduce la superficie de exposición. Si se conservan para uso local, cambiar `require` por `require_once`.

---

## 4. Code smells (64)

### 4.1 Críticos

#### `php:S1192` — Literales de texto duplicados (13)

| Ubicación | Literal duplicado | Veces |
|:---|:---|:---:|
| `backend/cron-backup.php:41` | `"Y-m-d H:i:s"` | 5 |
| `backend/public/index.php:77` | `"Access-Control-Allow-Origin: "` | 3 |
| `backend/routes.php:44` | `"/colecciones/{id}"` | 3 |
| `backend/src/controllers/ColaborativoController.php:59` | `"La colección no existe."` | 3 |
| `backend/src/controllers/ColaborativoController.php:358` | `"/frontend-cliente/pages/colaborativo.html?token="` | 3 |
| `backend/src/controllers/ColaborativoController.php:398` | `"/frontend-cliente/pages/tuscoleccionescliente.html?invitacion="` | 3 |
| `backend/src/controllers/SistemaController.php:41` | `"Acceso restringido a la máquina local."` | 3 |
| `backend/src/helpers/MediaProcessor.php:166` | `"uploads/standard/"` | 5 |
| `backend/src/services/ColeccionService.php:135` | `"La colección no existe."` | 6 |
| `backend/src/services/MultimediaService.php:45` | `"La colección especificada no existe."` | 6 |
| `backend/src/services/MultimediaService.php:199` | `"El archivo multimedia no existe."` | 5 |
| `backend/src/services/MultimediaService.php:221` | `"Este archivo multimedia está pendiente de moderación."` | 3 |
| `backend/src/validators/ColeccionValidator.php:60` | `"Error de validación."` | 3 |

**Cambio:** definir constantes de clase o una clase central de mensajes. Ejemplo:

```php
final class Mensajes
{
    public const COLECCION_NO_EXISTE = 'La colección no existe.';
    public const ARCHIVO_NO_EXISTE = 'El archivo multimedia no existe.';
}
```

Para rutas y formatos, usar constantes en la clase que los utiliza:

```php
private const FORMATO_FECHA = 'Y-m-d H:i:s';
private const RUTA_STANDARD = 'uploads/standard/';
```

Evitar un archivo global con constantes de todos los módulos; cada clase debe declarar las que usa.

#### `php:S3776` — Complejidad cognitiva excesiva (12)

| Ubicación | Función | Complejidad actual | Límite |
|:---|:---|---:|---:|
| `backend/src/controllers/ColaborativoController.php:354` | `armarUrlColaborativo()` | 17 | 15 |
| `backend/src/controllers/ColaborativoController.php:394` | `armarUrlInvitacion()` | 17 | 15 |
| `backend/src/Core/Router.php:23` | `dispatch()` | 22 | 15 |
| `backend/src/helpers/Mailer.php:58` | `enviar()` | 29 | 15 |
| `backend/src/helpers/QrGenerator.php:298` | `construirMatrizConMascara()` | 22 | 15 |
| `backend/src/helpers/QrGenerator.php:431` | `colocarDatos()` | 36 | 15 |
| `backend/src/helpers/QrGenerator.php:571` | `penalidad()` | 64 | 15 |
| `backend/src/middlewares/AuthMiddleware.php:52` | `obtenerCabeceraAuth()` | 26 | 15 |
| `backend/src/middlewares/RateLimitMiddleware.php:64` | `handle()` | 17 | 15 |
| `backend/src/validators/AuthValidator.php:20` | `validateRegister()` | 17 | 15 |
| `backend/src/validators/ColeccionValidator.php:75` | `validateUpdate()` | 17 | 15 |
| `backend/src/validators/MultimediaValidator.php:117` | `validateUpdate()` | 17 | 15 |

**Cambio:** extraer métodos pequeños con nombres intencionados, usar retornos tempranos y separar validaciones por regla. En `QrGenerator`, dividir el cálculo de matriz, máscaras y penalización en clases independientes (esto también corrige `php:S1448`).

Ejemplo de extracción:

```php
public function validateUpdate(array $datos): array
{
    $errores = [];
    $this->validarTitulo($datos, $errores);
    $this->validarDescripcion($datos, $errores);
    $this->validarVisibilidad($datos, $errores);
    return $errores;
}
```

#### `php:S121` — Estructuras de control sin llaves (2)

| Ubicación | Función |
|:---|:---|
| `backend/src/repository/ColeccionRepository.php:201` | `sincronizarHashtags()` |
| `backend/src/services/BackupService.php:149` | `generarSqlDump()` |

**Cambio:** añadir llaves a todos los `if`, `else`, `for` y `foreach` anidados.

```php
if ($condicion) {
    $this->ejecutar();
}
```

### 4.2 Mayores

#### `php:S1142` — Demasiadas sentencias `return` (10)

| Ubicación | Función | Returns |
|:---|:---|---:|
| `backend/src/controllers/ColaborativoController.php:354` | `armarUrlColaborativo()` | 4 |
| `backend/src/controllers/ColaborativoController.php:394` | `armarUrlInvitacion()` | 4 |
| `backend/src/controllers/SistemaController.php:64` | `ipEnSubred()` | 5 |
| `backend/src/helpers/Jwt.php:51` | `decode()` | 5 |
| `backend/src/helpers/Mailer.php:58` | `enviar()` | 13 |
| `backend/src/helpers/MediaProcessor.php:156` | `generarBuenaCalidadImagen()` | 4 |
| `backend/src/helpers/QrGenerator.php:471` | `funcionMascara()` | 8 |
| `backend/src/helpers/RateLimiter.php:48` | `registrar()` | 4 |
| `backend/src/middlewares/AuthMiddleware.php:52` | `obtenerCabeceraAuth()` | 5 |
| `backend/src/validators/MultimediaValidator.php:32` | `checkUpload()` | 7 |

**Cambio:** agrupar guardas y devolver una variable de resultado al final. No se trata de eliminar retornos tempranos claros, sino de reducir la dispersión cuando la función mezcla validación, transformación y errores.

#### `php:S112` — Excepciones genéricas (3)

| Ubicación | Función | Excepción recomendada |
|:---|:---|:---|
| `backend/src/helpers/Mailer.php:192` | `leerLinea()` | `MailerException extends RuntimeException` |
| `backend/src/helpers/QrGenerator.php:192` | `elegirVersion()` | `QrGenerationException extends RuntimeException` |
| `backend/src/helpers/QrGenerator.php:209` | `construirBytesDatos()` | `QrGenerationException extends RuntimeException` |

**Cambio:** crear excepciones dedicadas y lanzarlas con un mensaje interno; el controlador decide qué responder al cliente.

#### `php:S1172` — Parámetros sin uso (2)

| Ubicación | Función | Parámetro |
|:---|:---|:---|
| `backend/src/services/MultimediaService.php:40` | `upload()` | `$mime` |
| `backend/src/services/MultimediaService.php:104` | `uploadMultiple()` | `$extensionesPorMime` |

**Cambio:** eliminar el parámetro y actualizar todas las llamadas. Si el dato se necesita para una validación futura, usarlo o documentar por qué se conserva.

#### `php:S127` — Contador de bucle modificado en el cuerpo (1)

| Ubicación | Función |
|:---|:---|
| `backend/src/helpers/QrGenerator.php:440` | `colocarDatos()` |

**Cambio:** no modificar `$col` dentro del `for`. Calcular la posición con una fórmula o usar un `while` explícito que documente el avance.

#### `php:S1448` — Clase con demasiados métodos (1)

| Ubicación | Clase | Métodos |
|:---|:---|---:|
| `backend/src/helpers/QrGenerator.php:13` | `QrGenerator` | 28 (máximo 20) |

**Cambio:** dividir en clases especializadas, por ejemplo:

- `QrMatrixBuilder` — construcción de la matriz.
- `QrMaskSelector` — evaluación de máscaras.
- `QrPenaltyCalculator` — penalizaciones.
- `QrRenderer` — salida PNG/SVG/HTML.

Esto también reduce la complejidad cognitiva de `php:S3776`.

#### `php:S1068` — Campo privado sin uso (1)

| Ubicación | Clase | Campo |
|:---|:---|:---|
| `backend/src/controllers/ColaborativoController.php:32` | `ColaborativoController` | `EXTENSION_POR_MIME` |

**Cambio:** eliminar el campo. Si se usa en el futuro, moverlo a la clase que corresponda.

### 4.3 Menores e informativos

#### `php:S113` — Falta salto de línea al final (14, Minor)

Añadir un salto de línea final a:

- `backend/probe_media.php`
- `backend/probe_originals.php`
- `backend/public/index.php`
- `backend/routes.php`
- `backend/src/controllers/AuthController.php`
- `backend/src/controllers/FavoritoController.php`
- `backend/src/controllers/HomeController.php`
- `backend/src/Core/Router.php`
- `backend/src/dtos/LoginDto.php`
- `backend/src/dtos/RegisterDto.php`
- `backend/src/helpers/Mailer.php`
- `backend/src/helpers/QrGenerator.php`
- `backend/src/services/AuthService.php`
- `backend/src/validators/AuthValidator.php`

**Cambio:** configurar el editor para insertar `EOF` newline y añadirlo a los archivos listados.

#### `php:S1135` — Comentarios `TODO` pendientes (3, Info)

| Ubicación | Acción |
|:---|:---|
| `backend/src/controllers/ColaborativoController.php:258` | Completar la tarea o convertirla en issue. |
| `backend/src/Core/Request.php:24` | Completar la tarea o convertirla en issue. |
| `backend/src/services/MultimediaService.php:142` | Completar la tarea o convertirla en issue. |

**Cambio:** resolver el `TODO` y eliminarlo, o registrar la deuda en el backlog y borrar el comentario del código.

#### `php:S1131` — Espacios en blanco al final de línea (1, Minor)

**Ubicación:** `backend/src/Core/Database.php:36`

**Cambio:** eliminar los espacios finales. Configurar `trim trailing whitespace` en el editor.

#### `docker:S7031` — Fusionar instrucciones `RUN` (1, Minor)

**Ubicación:** `backend/Dockerfile:5`

**Cambio:** unir las instrucciones `RUN` consecutivas con `&&` y una sola capa. Aprovechar para corregir la indentación de las líneas 20-36 del Dockerfile.

---

## 5. Riesgos críticos de despliegue (no detectados por Sonar)

SonarQube no detecta la configuración efectiva de Apache, los volúmenes de Docker ni la exposición de archivos excluidos del análisis. La revisión manual del 26/10/2026 confirmó que estos riesgos **siguen activos** en `http://localhost:8080`:

| ID | Severidad | Evidencia verificada | Cambio requerido |
|:---|:---|:---|:---|
| C-01 | **Crítica** | `GET /uploads/.jwt_secret` → `200` | Rotar el secreto JWT, eliminarlo de `uploads/`, definirlo por variable de entorno y bloquear `/uploads` en Apache. |
| C-02 | **Crítica** | `GET /probe_originals.php` → `200` (enumera los originales de `/uploads/originals/`) | Denegar `/uploads` en Apache, servir archivos solo por controladores con autorización y retirar los `probe_*` del árbol web. |
| C-03 | **Crítica** | Puerto `3306` abierto; credenciales por defecto `cipher_user` / `cipher_password` | Cerrar el puerto `3306`, rotar la contraseña, exigir `DB_PASS` y eliminar el fallback de `Database.php`. |
| H-01 | Alta | `GET /sistema/backups` → `200` sin autenticación | Exigir autenticación/rol administrativo o ejecutar solo por CLI; el filtro por IP no funciona detrás del NAT de Docker. |
| H-02 | Alta | `GET /.env`, `/docker-compose.yml`, `/database/schema.sql` → `200` | Cambiar `DocumentRoot` a `backend/public`, retirar archivos internos del árbol web y eliminar scripts de diagnóstico. |

El detalle completo, el impacto y los comandos de verificación están en `docs/SAST-Analisis-Manual-2026-10-26.md`.

---

## 6. Plan de corrección del backend

### P0 — Seguridad

1. Rotar `JWT_SECRET` y eliminar `backend/uploads/.jwt_secret` del volumen expuesto.
2. Bloquear `/uploads` en Apache y servir los archivos solo por los controladores con autorización.
3. Cerrar el puerto `3306`, rotar la contraseña de MySQL y eliminar `cipher_password` como fallback.
4. Deshabilitar `/sistema/*` por HTTP o exigir autenticación/rol administrativo.
5. Cambiar `DocumentRoot` a `backend/public` y retirar `.env`, `docker-compose.yml`, `database/`, documentación y `probe_*` del árbol web.
6. Corregir las 4 vulnerabilidades de Sonar: `php:S4790`, `php:S3330`, `php:S2092`, `docker:S6471`.

### P1 — Bugs

1. Cambiar `require` por `require_once` en `probe_media.php` o eliminar el script.

### P2 — Code smells críticos

1. Extraer constantes para los 13 literales duplicados (`php:S1192`).
2. Refactorizar las 12 funciones con complejidad cognitiva > 15 (`php:S3776`).
3. Añadir llaves en `ColeccionRepository::sincronizarHashtags()` y `BackupService::generarSqlDump()` (`php:S121`).

### P3 — Code smells mayores

1. Reducir los retornos dispersos en las 10 funciones de `php:S1142`.
2. Crear excepciones dedicadas para `Mailer` y `QrGenerator` (`php:S112`).
3. Eliminar los parámetros sin uso de `MultimediaService` (`php:S1172`).
4. Corregir el contador de bucle en `QrGenerator::colocarDatos()` (`php:S127`).
5. Dividir `QrGenerator` en clases más pequeñas (`php:S1448`).
6. Eliminar el campo privado `EXTENSION_POR_MIME` (`php:S1068`).

### P4 — Menores e informativos

1. Añadir salto de línea final a los 14 archivos (`php:S113`).
2. Resolver o registrar los 3 `TODO` (`php:S1135`).
3. Eliminar espacios finales en `Database.php:36` (`php:S1131`).
4. Fusionar los `RUN` del Dockerfile (`docker:S7031`).

### P5 — Quality Gate

1. Añadir pruebas automatizadas para el backend (PHPUnit) y generar `coverage.xml`.
2. Configurar `sonar.php.coverage.reportPaths=backend/coverage.xml`.
3. Reducir la duplicación global del código nuevo; el backend aporta literales y utilidades repetidas.
4. Volver a ejecutar el escaneo y verificar que el Quality Gate pasa.

---

## 7. Cómo verificar los cambios

### 7.1 Reejecutar SonarQube

```powershell
$token = Get-Content "$env:TEMP\sonar_token.txt" -Raw
& "C:\Sonar-Scanner\sonar-scanner\bin\sonar-scanner.bat" `
  "-Dsonar.host.url=http://localhost:9000" `
  "-Dsonar.token=$token"
```

Dashboard: <http://localhost:9000/dashboard?id=cipher-forge>  
Hallazgos: <http://localhost:9000/project/issues?id=cipher-forge&resolved=false>

### 7.2 Verificar los riesgos de despliegue

```powershell
# Deben responder 403/404 después de la corrección
curl.exe -i http://localhost:8080/uploads/.jwt_secret
curl.exe -i http://localhost:8080/.env
curl.exe -i http://localhost:8080/docker-compose.yml
curl.exe -i http://localhost:8080/database/schema.sql
curl.exe -i http://localhost:8080/probe_originals.php
curl.exe -i http://localhost:8080/sistema/backups

# El puerto 3306 debe estar cerrado desde el host
Test-NetConnection localhost -Port 3306
```

### 7.3 Verificar sintaxis y contenedor

```powershell
# Comprobar sintaxis de los archivos PHP modificados
docker exec cipher_forge_app php -l /var/www/html/src/helpers/RateLimiter.php

# Tras cambiar el Dockerfile
docker compose build app worker
docker compose up -d

# El proceso no debe ejecutarse como root (uid 0)
docker exec cipher_forge_app id
```

---

## 8. Notas

- **Falsos positivos:** `php:S4790` es un caso discutible porque SHA-1 solo genera nombres de archivo de contadores, no protege credenciales. Aun así, cambiar a SHA-256 elimina la alerta sin coste funcional.
- **Cookies PHP:** la aplicación no usa `session_start()`; las reglas `php:S3330` y `php:S2092` se refieren a la configuración nativa de PHP. La cookie JWT de `CookieAuth` ya es `HttpOnly` y `SameSite=Strict`.
- **Docker root:** el cambio a usuario no root requiere ajustar el entrypoint, los permisos del volumen `uploads_data` y el puerto interno de Apache. No aplicarlo en producción sin probar el arranque y las subidas.
- **SAST vs. despliegue:** SonarQube no detecta los hallazgos C-01, C-02, C-03, H-01 y H-02 porque son configuración de infraestructura y archivos excluidos. Están documentados en `docs/SAST-Analisis-Manual-2026-10-26.md` y deben tratarse como P0.
- **Líneas:** las ubicaciones corresponden al commit `0aca934`; si se modifica el código, los números de línea pueden desplazarse. Verificar siempre contra el archivo actual.

---

*Documento del backend generado el 26/10/2026 a partir del análisis SonarQube `cipher-forge` (commit `0aca934`) y de la verificación manual del stack local.*
