# SAST — Hallazgos a corregir (Cipher Forge)

> **Documento consolidado de referencia.** Los hallazgos están divididos por área en [`backend.md`](backend.md) y [`frontend.md`](frontend.md). Este archivo se conserva para consulta conjunta.

**Fecha del análisis:** 26/10/2026, 13:18 (UTC-3)  
**Herramienta:** SonarQube Community Build 26.8.0.126808 + SonarScanner CLI 8.1.0.6389  
**Proyecto:** `cipher-forge` — `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias`  
**Commit analizado:** `0aca934dfe4662c406da22d5ac4cd9f84b951013`  
**Dashboard:** <http://localhost:9000/dashboard?id=cipher-forge>  
**Quality Gate:** **ERROR**

> Este documento enumera los cambios necesarios para eliminar los hallazgos del último análisis SAST y mejorar el Quality Gate. Los archivos `backend/backups/**`, `backend/uploads/**` y `.git/**` quedan excluidos del escaneo según `sonar-project.properties`.
>
> En SonarQube, `Critical`, `Major`, `Minor` e `Info` son severidades de mantenibilidad. Solo la sección de **vulnerabilidades** tiene impacto directo de seguridad.

---

## 1. Resumen

### 1.1 Hallazgos por área

| Área | Vulnerabilidades | Bugs | Code smells | Total |
|:---|:---:|:---:|:---:|:---:|
| Backend | 4 | 2 | 64 | **70** |
| Frontend | 0 | 3 | 49 | **52** |
| **Total** | **4** | **5** | **113** | **122** |

### 1.2 Métricas generales

| Métrica | Valor |
|:---|:---:|
| Archivos analizados | 122 |
| Líneas de código (NCLOC) | 12 528 |
| Vulnerabilidades | 4 |
| Bugs | 5 |
| Code smells | 113 |
| Security Hotspots | 0 |
| Cobertura | 0.0 % |
| Duplicación | 7.3 % |
| Rating de seguridad | E (4.0) |
| Rating de fiabilidad | C (3.0) |
| Rating de mantenibilidad | A (1.0) |

### 1.3 Quality Gate

| Condición | Valor real | Umbral | Estado |
|:---|:---:|:---:|:---:|
| Cobertura del código nuevo | 0.0 % | ≥ 80 % | ERROR |
| Duplicación del código nuevo | 10.03 % | ≤ 3 % | ERROR |
| Violaciones nuevas | 95 | 0 | ERROR |

**Estado global: ERROR.** El Quality Gate no se corregirá solo eliminando code smells: también hay que aportar pruebas automatizadas y reducir la duplicación del código nuevo.

### 1.4 Prioridad de trabajo

| Prioridad | Qué corregir |
|:---|:---|
| **P0 — Seguridad** | Las 4 vulnerabilidades de Sonar y los riesgos críticos de despliegue (secreto JWT, `uploads/`, MySQL, `/sistema/*`, `DocumentRoot`). |
| **P1 — Bugs** | Los 5 bugs: 3 inputs sin etiqueta y 2 `require` duplicables. |
| **P2 — Code smells críticos** | Literales duplicados, complejidad cognitiva, llaves ausentes y complejidad del JS de subida. |
| **P3 — Accesibilidad y CSS** | Roles ARIA reemplazables por HTML nativo, selectores CSS duplicados, contraste y zoom. |
| **P4 — Menores** | Saltos de línea finales, `TODO`, espacios, excepciones genéricas, etc. |
| **P5 — Quality Gate** | Pruebas automatizadas, cobertura y reducción de duplicación. |

---

# 2. Backend

## 2.1 Vulnerabilidades (4)

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

## 2.2 Bugs (2)

| Regla | Severidad | Ubicación | Cambio |
|:---|:---|:---|:---|
| `php:S2003` | Minor | `backend/probe_media.php:2` | `require` → `require_once`. |
| `php:S2003` | Minor | `backend/probe_media.php:3` | `require` → `require_once`. |

**Recomendación adicional:** `probe_media.php` y `probe_originals.php` son scripts de diagnóstico que no deberían estar en la raíz web. Si se eliminan del árbol publicado (ver sección 2.4), estos dos bugs desaparecen y se reduce la superficie de exposición. Si se conservan para uso local, cambiar `require` por `require_once`.

---

## 2.3 Code smells (64)

### 2.3.1 Críticos

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

### 2.3.2 Mayores

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

### 2.3.3 Menores e informativos

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

## 2.4 Riesgos críticos de despliegue (no detectados por Sonar)

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

# 3. Frontend

## 3.1 Bugs (3)

| Regla | Severidad | Ubicación | Cambio |
|:---|:---|:---|:---|
| `Web:InputWithoutLabelCheck` | Major | `frontend-cliente/pages/panelcliente.html:47` | Asociar un `<label>` al input `#tagBusqueda`. |
| `Web:InputWithoutLabelCheck` | Major | `frontend-fotografo/pages/SubirImagenes.html:47` | Asociar un `<label>` al input `#tagInput`. |
| `Web:InputWithoutLabelCheck` | Major | `frontend-fotografo/pages/SubirImagenes.html:129` | Asociar un `<label>` al input de archivos `#selectorArchivos`. |

**Ejemplo:**

```html
<label class="VisualmenteOculto" for="tagBusqueda">Buscar por etiqueta</label>
<input id="tagBusqueda" type="text" placeholder="Escribe un tag" list="sugerenciasHashtags" />
```

Añadir la clase `VisualmenteOculto` a `base.css` si no existe:

```css
.VisualmenteOculto {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0 0 0 0);
    white-space: nowrap;
    border: 0;
}
```

Para el input de archivos oculto, asociar el botón visible con el input:

```html
<label class="BotonSubir" for="selectorArchivos">Seleccionar archivos</label>
<input type="file" id="selectorArchivos" hidden />
```

## 3.2 Code smells (49)

### 3.2.1 Crítico

#### `javascript:S3776` — Complejidad cognitiva excesiva (1)

| Ubicación | Función | Complejidad actual | Límite |
|:---|:---|---:|---:|
| `frontend-fotografo/dom/colecciones/subirimagenes.js:301` | `subirArchivos()` | 17 | 15 |

**Cambio:** extraer la subida de un archivo a una función `subirUnArchivo(archivo)` y separar el manejo de errores/progreso. El bucle principal debe limitarse a recorrer la lista y acumular resultados.

### 3.2.2 Mayores

#### `Web:S6819` — Preferir HTML nativo sobre roles ARIA (16)

**a) `role="status"` → `<output>` (12)**

| Archivo | Línea |
|:---|:---:|
| `frontend-cliente/pages/login.html` | 59 |
| `frontend-cliente/pages/registro.html` | 106 |
| `frontend-cliente/pages/verificaremail.html` | 69 |
| `frontend-fotografo/pages/crearcoleccion.html` | 46 |
| `frontend-fotografo/pages/editarperfil.html` | 63 |
| `frontend-fotografo/pages/login.html` | 60 |
| `frontend-fotografo/pages/moderacion.html` | 86 |
| `frontend-fotografo/pages/panel.html` | 48 |
| `frontend-fotografo/pages/panel.html` | 187 |
| `frontend-fotografo/pages/registro.html` | 106 |
| `frontend-fotografo/pages/SubirImagenes.html` | 138 |
| `frontend-fotografo/pages/verificaremail.html` | 69 |

**Cambio:** reemplazar el elemento con `role="status"` por `<output>`. Ejemplo:

```html
<output id="mensajeEstado" class="MensajeEstado"></output>
```

`<output>` ya tiene el rol implícito `status`; no hace falta añadir `role`. Revisar el CSS si el selector dependía de `p` o `div`.

**b) `role="textbox"` → `<input>` o `<textarea>` (2)**

| Archivo | Línea | Elemento actual |
|:---|:---:|---|
| `frontend-fotografo/pages/SubirImagenes.html` | 15 | `<h2 contenteditable role="textbox">` |
| `frontend-fotografo/pages/SubirImagenes.html` | 25 | `<p contenteditable role="textbox">` |

**Cambio:** usar controles nativos:

```html
<input id="nombreColeccion" type="text" class="CampoEditable" aria-label="Título de la colección" />
<textarea id="descripcionColeccionTexto" class="CampoEditable" aria-label="Descripción de la colección"></textarea>
```

Actualizar `subirimagenes.js` para leer/escribir `.value` en lugar de `textContent`. Si se mantiene `contenteditable` por diseño, documentar la excepción y justificarla; Sonar seguirá marcándola.

**c) `role="dialog"` → `<dialog>` (2)**

| Archivo | Línea |
|:---|:---:|
| `frontend-fotografo/pages/SubirImagenes.html` | 161 |
| `frontend-fotografo/pages/SubirImagenes.html` | 201 |

**Cambio:** usar el elemento nativo:

```html
<dialog class="ModalQr" id="modalQrColaborativo" aria-labelledby="tituloQrColaborativo">
    <div class="ModalQrContenido">...</div>
</dialog>
```

Abrir con `dialog.showModal()` y cerrar con `dialog.close()`. Ajustar `::backdrop` en CSS. Eliminar `role="dialog"` y `aria-modal="true"` cuando se use `<dialog>`.

#### `css:S4666` — Selectores CSS duplicados (5)

| Archivo | Línea | Selector | Primera aparición |
|:---|:---:|---|:---:|
| `frontend-cliente/css/panelcliente.css` | 339 | `.FlechaVisor` | 254 |
| `frontend-fotografo/css/subirimagenes.css` | 495 | `.ZonaCarga` | 288 |
| `frontend-fotografo/css/subirimagenes.css` | 500 | `.ZonaCarga .Formatos` | 320 |
| `frontend-fotografo/css/subirimagenes.css` | 535 | `.ModalQrContenido` | 341 |
| `frontend-fotografo/css/tuscolecciones.css` | 442 | `.TarjetaMedia` | 406 |

**Cambio:** consolidar las declaraciones en una sola regla por selector. Si la segunda regla existe para un estado o contexto distinto, usar una clase modificadora (`.ZonaCarga--activa`) en lugar de repetir el selector.

#### `css:S7924` — Contraste insuficiente (3)

| Archivo | Línea | Ajuste sugerido |
|:---|:---:|---|
| `frontend-fotografo/css/tuscolecciones.css` | 194 | Texto blanco sobre `#2bb58a`: oscurecer el fondo (por ejemplo `#167a5b`) hasta alcanzar 4.5:1. |
| `frontend-fotografo/css/tuscolecciones.css` | 428 | Texto blanco sobre `rgba(255,255,255,0.85)`: usar un color de texto oscuro o un fondo sólido oscuro. |
| `frontend-fotografo/css/tuscolecciones.css` | 497 | Texto blanco sobre `#e74c3c`: oscurecer a `#b42318` o similar y verificar 4.5:1. |

**Cambio:** validar cada combinación con una herramienta de contraste WCAG. Para texto normal el mínimo es **4.5:1**; para texto grande, **3:1**. No cambiar solo el color del texto sin comprobar el fondo real (incluidos estados `hover` y `focus`).

#### `Web:S6850` — Encabezados sin contenido accesible (2)

| Archivo | Línea | Elemento |
|:---|:---:|---|
| `frontend-cliente/pages/colaborativo.html` | 26 | `<h1 id="nombreEvento"></h1>` |
| `frontend-cliente/pages/tuscoleccionescliente.html` | 44 | `<h2 id="tituloInvitacion"></h2>` |

**Cambio:** añadir un texto inicial accesible (aunque luego se reemplace por JS) o mantener el encabezado oculto hasta que tenga contenido:

```html
<h1 id="nombreEvento">Evento colaborativo</h1>
```

Si el encabezado se rellena de forma asíncrona, mostrar un texto de carga y actualizarlo con `textContent`; no dejar el nodo vacío.

#### `Web:S6842` — Elemento no interactivo con rol interactivo (1)

**Ubicación:** `frontend-fotografo/pages/SubirImagenes.html:15`  
**Elemento:** `<h2 contenteditable="true" role="textbox">`

**Cambio:** el mismo de `Web:S6819` apartado b): reemplazar por `<input>` o `<textarea>`. Si se conserva `contenteditable`, eliminar `role="textbox"` no es una opción accesible; en ese caso documentar la excepción.

#### `javascript:S7768` — Usar `.before()` en lugar de `insertBefore()` (1)

**Ubicación:** `frontend-fotografo/dom/colecciones/subirimagenes.js:269`

**Código actual:**

```js
galeria.insertBefore(tarjeta, botonAgregar);
```

**Cambio:**

```js
botonAgregar.before(tarjeta);
```

#### `Web:S7926` — Viewport deshabilita el zoom (1)

**Ubicación:** `frontend-cliente/pages/colaborativo.html:5`

**Código actual:**

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
```

**Cambio:**

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
```

No impedir el zoom: es un requisito de accesibilidad (WCAG 1.4.4).

### 3.2.3 Menores

#### `javascript:S2486` — Excepciones capturadas e ignoradas (12)

| Archivo | Líneas |
|:---|:---|
| `frontend-cliente/dom/colecciones/panelcliente.js` | 152 |
| `frontend-cliente/dom/colecciones/tuscoleccionescliente.js` | 28, 145 |
| `frontend-cliente/dom/favoritos/favoritos.js` | 18 |
| `frontend-cliente/dom/multimedia/multimedia.js` | 13, 36 |
| `frontend-fotografo/dom/colecciones/qr.js` | 78 |
| `frontend-fotografo/dom/colecciones/subirimagenes.js` | 309 |
| `frontend-fotografo/dom/colecciones/tags.js` | 91 |
| `frontend-fotografo/dom/comun/almacenamiento.js` | 20 |
| `frontend-fotografo/dom/multimedia/multimedia.js` | 13, 36 |

**Cambio:** no dejar un `catch` vacío ni solo con un comentario. Opciones:

- Mostrar un mensaje al usuario con `mostrarToast` o un estado de error.
- Registrar el detalle con `console.error`/`console.warn` y aplicar un valor de respaldo.
- Eliminar el `try/catch` si la excepción debe propagarse.

Ejemplo:

```js
} catch (error) {
    console.warn("No se pudo cargar la portada de la colección.", error);
    elemento.classList.add("VistaNoDisponible");
}
```

#### `javascript:S6582` — Preferir optional chaining (4)

| Archivo | Línea |
|:---|:---:|
| `frontend-cliente/dom/colecciones/tarjetas.js` | 2 |
| `frontend-fotografo/dom/colecciones/subirimagenes.js` | 390 |
| `frontend-fotografo/services/multimedia/multimediaService.js` | 6 |
| `frontend-fotografo/services/multimedia/multimediaService.js` | 7 |

**Cambio:** reemplazar comprobaciones manuales por `?.`. Ejemplo:

```js
const mostrarFotografo = opciones?.mostrarFotografo !== false;
```

Verificar que el comportamiento con `undefined`/`null` sea el mismo que antes.

#### `javascript:S6353` — Clase de caracteres redundante (1)

**Ubicación:** `frontend-fotografo/dom/perfil/editarperfil.js:11`

**Código actual:**

```js
String(valor || "").replace(/[^0-9]/g, "")
```

**Cambio:**

```js
String(valor || "").replace(/\D/g, "")
```

#### `javascript:S7776` — Usar `Set` para comprobar existencia (1)

**Ubicación:** `frontend-cliente/dom/colecciones/panelcliente.js:33`

**Código actual:**

```js
const tags = (coleccion.hashtags || []).map(normalizarTag);
// ...
if (tags.includes(tagsSeleccionados[i])) return i;
```

**Cambio:**

```js
const tags = new Set((coleccion.hashtags || []).map(normalizarTag));
// ...
if (tags.has(tagsSeleccionados[i])) return i;
```

#### `javascript:S1874` — `document.execCommand` obsoleto (1)

**Ubicación:** `frontend-fotografo/dom/colecciones/subirimagenes.js:211`

**Código actual:**

```js
document.execCommand("insertText", false, texto);
```

**Cambio:** insertar el texto con la API de selección:

```js
const seleccion = window.getSelection();
if (seleccion && seleccion.rangeCount > 0) {
    const rango = seleccion.getRangeAt(0);
    rango.deleteContents();
    rango.insertNode(document.createTextNode(texto));
    rango.collapse(false);
    seleccion.removeAllRanges();
    seleccion.addRange(rango);
}
```

Si se necesita compatibilidad con navegadores antiguos, mantener `execCommand` como fallback y documentarlo, pero la ruta principal debe usar la API estándar.

---

# 4. Plan de corrección sugerido

## P0 — Seguridad (primero)

1. Rotar `JWT_SECRET` y eliminar `backend/uploads/.jwt_secret` del volumen expuesto.
2. Bloquear `/uploads` en Apache y servir los archivos solo por los controladores con autorización.
3. Cerrar el puerto `3306`, rotar la contraseña de MySQL y eliminar `cipher_password` como fallback.
4. Deshabilitar `/sistema/*` por HTTP o exigir autenticación/rol administrativo.
5. Cambiar `DocumentRoot` a `backend/public` y retirar `.env`, `docker-compose.yml`, `database/`, documentación y `probe_*` del árbol web.
6. Corregir las 4 vulnerabilidades de Sonar: `php:S4790`, `php:S3330`, `php:S2092`, `docker:S6471`.

## P1 — Bugs

1. Añadir etiquetas a los 3 inputs (`panelcliente.html:47`, `SubirImagenes.html:47`, `SubirImagenes.html:129`).
2. Cambiar `require` por `require_once` en `probe_media.php` o eliminar el script.

## P2 — Code smells críticos

1. Extraer constantes para los 13 literales duplicados.
2. Refactorizar las 12 funciones PHP con complejidad cognitiva > 15.
3. Añadir llaves en `ColeccionRepository::sincronizarHashtags()` y `BackupService::generarSqlDump()`.
4. Refactorizar `subirArchivos()` en `subirimagenes.js`.

## P3 — Accesibilidad y CSS

1. Reemplazar roles ARIA por HTML nativo (`<output>`, `<dialog>`, `<input>`, `<textarea>`).
2. Consolidar los 5 selectores CSS duplicados.
3. Ajustar los 3 contrastes de `tuscolecciones.css`.
4. Corregir los encabezados vacíos y el viewport de `colaborativo.html`.
5. Aplicar `.before()`, `Set`, `\D` y la API de selección.

## P4 — Menores

1. Añadir salto de línea final a los 14 archivos.
2. Resolver o registrar los 3 `TODO`.
3. Eliminar espacios finales y fusionar los `RUN` del Dockerfile.
4. Eliminar el campo privado sin uso y los parámetros sin uso.
5. Crear excepciones dedicadas.

## P5 — Quality Gate

1. Añadir pruebas automatizadas para el backend (PHPUnit) y el frontend (Vitest/Jest o pruebas de integración).
2. Configurar los reportes de cobertura:
   - `sonar.php.coverage.reportPaths=backend/coverage.xml`
   - `sonar.javascript.lcov.reportPaths=frontend-*/coverage/lcov.info`
3. Reducir la duplicación del código nuevo (10.03 % actual) extrayendo utilidades compartidas entre los dos frontends.
4. Volver a ejecutar el escaneo y verificar que el Quality Gate pasa.

---

# 5. Cómo verificar los cambios

## 5.1 Reejecutar SonarQube

```powershell
$token = Get-Content "$env:TEMP\sonar_token.txt" -Raw
& "C:\Sonar-Scanner\sonar-scanner\bin\sonar-scanner.bat" `
  "-Dsonar.host.url=http://localhost:9000" `
  "-Dsonar.token=$token"
```

Dashboard: <http://localhost:9000/dashboard?id=cipher-forge>  
Hallazgos: <http://localhost:9000/project/issues?id=cipher-forge&resolved=false>

## 5.2 Verificar los riesgos de despliegue

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

## 5.3 Verificar accesibilidad

- Navegar con teclado: todos los inputs deben recibir foco y tener etiqueta.
- Probar el zoom del navegador al 200 % en `colaborativo.html`.
- Ejecutar Lighthouse o axe DevTools en las páginas de login, panel y subida.
- Verificar que los diálogos se abren/cierran con `Esc` y devuelven el foco al botón que los abrió.

---

# 6. Notas

- **Falsos positivos:** `php:S4790` es un caso discutible porque SHA-1 solo genera nombres de archivo de contadores, no protege credenciales. Aun así, cambiar a SHA-256 elimina la alerta sin coste funcional.
- **Cookies PHP:** la aplicación no usa `session_start()`; las reglas `php:S3330` y `php:S2092` se refieren a la configuración nativa de PHP. La cookie JWT de `CookieAuth` ya es `HttpOnly` y `SameSite=Strict`.
- **Docker root:** el cambio a usuario no root requiere ajustar el entrypoint, los permisos del volumen `uploads_data` y el puerto interno de Apache. No aplicarlo en producción sin probar el arranque y las subidas.
- **SAST vs. despliegue:** SonarQube no detecta los hallazgos C-01, C-02, C-03, H-01 y H-02 porque son configuración de infraestructura y archivos excluidos. Están documentados en `docs/SAST-Analisis-Manual-2026-10-26.md` y deben tratarse como P0.
- **Cobertura:** el proyecto no tiene pruebas automatizadas ni reportes de cobertura; el 0 % es real, no un fallo de configuración del escáner.
- **Líneas:** las ubicaciones corresponden al commit `0aca934`; si se modifica el código, los números de línea pueden desplazarse. Verificar siempre contra el archivo actual.

---

*Documento generado el 26/10/2026 a partir del análisis SonarQube `cipher-forge` (commit `0aca934`) y de la verificación manual del stack local.*
