# Reporte de Análisis SAST — Cipher_Forge / Gestion-fotografias

**Herramienta:** SonarQube (Community Build) + SonarScanner CLI
**Tipo de verificación:** Static Application Security Testing (SAST) + análisis de calidad de código
**Proyecto:** `cipher-forge` — `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias`

---

## 1. Resumen ejecutivo

Se realizó un análisis SAST completo sobre el proyecto `Gestion-fotografias` (backend PHP/MySQL + frontends web JS/HTML/CSS + Docker) mediante SonarQube. Se detectaron **117 problemas activos**, de los cuales **4 son vulnerabilidades de seguridad**, **6 son bugs** y **107 son code smells**. El Quality Gate quedó en **ERROR** por cobertura nueva 0% (exigido ≥80%), duplicación nueva 12.87% (máx. 3%) y 88 incumplimientos nuevos.

No se encontraron **Security Hotspots** pendientes de revisión ni secretos expuestos (sensor de texto/secretos analizó 117 archivos sin hallazgos).

**Comparación con el análisis anterior:** las 3 vulnerabilidades `javascript:S2245` (PRNG `Math.random()`) fueron **corregidas** y pasaron a estado `CLOSED`. El proyecto fue reestructurado con directorios `dom/` y `services/` (115 archivos vs 82 antes). Las vulnerabilidades restantes (CORS, cookies de sesión, Docker root) siguen activas.

---

## 2. Información de la verificación

| Parámetro | Valor |
|:---|:---|
| Fecha del análisis | 2026-09-11 |
| SonarQube Server | `http://localhost:9000` (Community Build **26.8.0.126808**) |
| SonarScanner CLI | **8.1.0.6389** — Java 21.0.11 (Eclipse Adoptium) |
| Clave de proyecto | `cipher-forge` |
| Directorio base | `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias` |
| Dashboard | http://localhost:9000/dashboard?id=cipher-forge |
| Estado del análisis | `ANALYSIS SUCCESSFUL` (Compute Engine: `SUCCESS`) |

---

## 3. Alcance del análisis

### 3.1 Archivos escaneados (115 archivos de código fuente)

| Lenguaje | Archivos | Notas |
|:---|:---:|:---|
| JavaScript | 47 | `dom/` (lógica), `services/` (servicios HTTP) de ambos frontends |
| PHP | 37 | Backend `src/`, `public/`, scripts raíz |
| HTML | 18 | Páginas de ambos frontends |
| CSS | 11 | Hojas de estilo de ambos frontends |
| INI | 1 | `backend/php.ini` (config runtime) |
| Dockerfile | 1 | `backend/Dockerfile` |

### 3.2 Configuración del análisis (`sonar-project.properties`)

```properties
sonar.projectKey=cipher-forge
sonar.projectName=Cipher Forge - Gestion Fotografias
sonar.projectVersion=1.0
sonar.sources=backend,frontend-cliente,frontend-fotografo
sonar.sourceEncoding=UTF-8
sonar.exclusions=backend/backups/**,backend/uploads/**,**/.git/**
```

### 3.3 Comando de ejecución

```powershell
& C:\Sonar-Scanner\sonar-scanner\bin\sonar-scanner.bat --% `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=<SONAR_TOKEN>
```

### 3.4 Perfiles de calidad activados

`Sonar way` para los 6 lenguajes detectados: **css, docker, js, php, web, yaml**.

---

## 4. Métricas globales

| Métrica | Valor |
|:---|:---|
| Líneas de código (NCLOC) | 10 904 |
| Líneas totales | 13 912 |
| Sentencias | 3 725 |
| Funciones | 480 |
| Clases | 32 |
| Complejidad | 1 387 |
| Densidad de comentarios | 5.9% |
| **Problemas activos** | **117** |
| Vulnerabilidades | 4 |
| Bugs | 6 |
| Code Smells | 107 |
| Security Hotspots | 0 |
| Cobertura | 0.0% |
| Duplicación | 8.6% |
| Rating seguridad | **C (3.0)** |
| Rating fiabilidad | **C (3.0)** |
| Rating mantenibilidad | **A (1.0)** |

### 4.1 Distribución por severidad

| Severidad | Cantidad |
|:---|:---:|
| Blocker | 0 |
| Critical | 26 |
| Major | 51 |
| Minor | 37 |
| Info | 3 |
| **Total** | **117** |

### 4.2 Quality Gate

| Condición | Valor real | Umbral | Estado |
|:---|:---|:---|:---|
| Cobertura nueva | 0.0% | ≥ 80% | ❌ ERROR |
| Duplicación nueva | 12.87% | ≤ 3% | ❌ ERROR |
| Violaciones nuevas | 88 | = 0 | ❌ ERROR |

**Estado global: `ERROR`**

---

## 5. Vulnerabilidades de seguridad (4)

| # | Severidad | Regla | Archivo | Línea | CWE |
|:--|:--|:--|:--|:--:|:--|
| V1 | Minor | `php:S3330` Cookie sin HttpOnly | `backend/php.ini` | — | CWE-1004 |
| V2 | Minor | `php:S2092` Cookie sin `secure` | `backend/php.ini` | — | CWE-614 |
| V3 | Major | `php:S5122` CORS permisivo `*` | `backend/public/index.php` | 54 | CWE-942 |
| V4 | Minor | `docker:S6471` Contenedor como root | `backend/Dockerfile` | 3 | — |

### V1 — Cookie de sesión sin flag `HttpOnly` — `php:S3330`

**Regla:** *"Cookies should have the HttpOnly flag"* — CWE-1004 (Sensitive Cookie Without 'HttpOnly' Attribute).

**Justificación:** con `HttpOnly` desactivado, un script inyectado vía XSS puede leer `document.cookie` y robar el `PHPSESSID`, permitiendo secuestro de sesión.

**Código afectado (`backend/php.ini`):** no se define `session.cookie_httponly`. PHP 8.2-apache tiene `session.cookie_httponly=0` por defecto.

**Corrección:**
```ini
session.cookie_httponly = 1
```

### V2 — Cookie de sesión sin flag `secure` — `php:S2092`

**Regla:** *"Cookies should have the secure flag"* — CWE-614 (Sensitive Cookie in HTTPS Session Without 'Secure' Attribute).

**Justificación:** sin `secure`, la cookie de sesión se envía por HTTP plano y puede ser interceptada en un ataque MITM.

**Corrección:**
```ini
session.cookie_secure = 1
```
> ⚠️ `session.cookie_secure=1` descarta la cookie si la app se accede por HTTP sin TLS. En desarrollo (`localhost`) puede dejarse en 0.

### V3 — Política CORS excesivamente permisiva — `php:S5122`

**Regla:** *"Cross-Origin Resource Sharing (CORS) policy should be restricted to trusted origins"* — CWE-942.

**Código (`backend/public/index.php:54`):**
```php
header('Access-Control-Allow-Origin: *');
```

**Justificación:** `*` permite que **cualquier** sitio web lea las respuestas de la API, incluyendo datos sensibles con `Authorization`. Posibilidad de exfiltración de datos.

**Corrección:** restringir a una lista blanca:
```php
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$permitidos = ['https://dominio-fotografo.ejemplo'];
if (in_array($origin, $permitidos, true)) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Vary: Origin');
}
```

### V4 — Imagen Docker ejecutándose como root — `docker:S6471`

**Código (`backend/Dockerfile:3`):**
```dockerfile
FROM php:8.2-apache
```

**Justificación:** sin `USER`, el contenedor corre como `root`. Un atacante con acceso al contenedor obtiene privilegios máximos.

**Corrección:**
```dockerfile
FROM php:8.2-apache
RUN useradd --create-home --uid 1000 www-app
USER www-app
```

---

## 6. Bugs (6)

| # | Severidad | Regla | Archivo | Línea | Acción |
|:--|:--|:--|:--|:--:|:--|
| B1 | Major | `Web:InputWithoutLabelCheck` | `frontend-cliente/pages/panelcliente.html` | 51 | Añadir `<label>` |
| B2 | Major | `Web:InputWithoutLabelCheck` | `frontend-fotografo/pages/SubirImagenes.html` | 32 | Añadir `<label>` |
| B3 | Major | `Web:InputWithoutLabelCheck` | `frontend-fotografo/pages/SubirImagenes.html` | 100 | Añadir `<label>` |
| B4 | Major | `Web:InputWithoutLabelCheck` | `frontend-fotografo/pages/crearcoleccion.html` | 59 | Añadir `<label>` |
| B5 | Minor | `php:S2003` | `backend/probe_media.php` | 2 | `require` → `require_once` |
| B6 | Minor | `php:S2003` | `backend/probe_media.php` | 3 | `require` → `require_once` |

- **`Web:InputWithoutLabelCheck`** — Los campos `input` deben tener `<label>` asociada (WCAG 3.3.2 / 4.1.2). Sin etiquetas, la accesibilidad se degrada.
- **`php:S2003`** — `require`/`include` pueden incluir el archivo dos veces → definiciones duplicadas.

---

## 7. Code Smells (107)

Agrupados por regla, con archivos afectados:

| Regla | Cant. | Severidad | Descripción | Archivos afectados |
|:--|:--:|:--|:--|:--|
| `Web:S6819` | 15 | Major | Preferir etiqueta semántica nativa sobre rol ARIA | `index.html`×2, `SubirImagenes.html`×3, `crearcoleccion.html`, `panel.html`×2, `login.html`×2, `registro.html`×2, `verificaremail.html`×2, `editarperfil.html` |
| `php:S113` | 14 | Minor | Archivos sin salto de línea final | 14 archivos PHP (`FavoritoController`, `QrGenerator`, `Mailer`, `index.php`, `routes.php`, `Router.php`, probes, `AuthController`, `AuthService`, dtos, validators, `HomeController`) |
| `php:S1192` | 13 | Critical | Literales de texto duplicados → definir constantes | `ColaborativoController.php`×3, `MultimediaService.php`×3, `ColeccionService.php`, `MediaProcessor.php`, `AuthMiddleware.php`, `SistemaController.php`, `cron-backup.php`, `routes.php`, `ColeccionValidator.php` |
| `javascript:S2486` | 12 | Minor | Excepciones capturadas e ignoradas | `multimedia.js`×4, `tuscoleccionescliente.js`×2, `subirimagenes.js`, `panelcliente.js`, `favoritos.js`, `qr.js`, `tags.js`, `almacenamiento.js` |
| `php:S3776` | 10 | Critical | Complejidad cognitiva excesiva (refactorizar) | `QrGenerator.php`×3, `ColaborativoController.php`×2, `AuthMiddleware.php`, `Mailer.php`, `Router.php`, `ColeccionValidator.php`, `MultimediaValidator.php` |
| `php:S1142` | 9 | Major | Demasiadas sentencias `return` | `Mailer.php`, `QrGenerator.php`, `Jwt.php`, `AuthMiddleware.php`, `MultimediaValidator.php`, `ColaborativoController.php`×2, `SistemaController.php`, `MediaProcessor.php` |
| `css:S4666` | 6 | Major | Selectores CSS duplicados | `subirimagenes.css`×4, `panelcliente.css`, `tuscolecciones.css` |
| `php:S112` | 3 | Major | Excepciones genéricas (usar dedicadas) | `QrGenerator.php`×2, `Mailer.php` |
| `css:S7924` | 3 | Major | Contraste insuficiente texto/fondo | `tuscolecciones.css`×3 |
| `php:S1135` | 3 | Info | Comentarios TODO sin completar | `ColaborativoController.php`, `MultimediaService.php`, `Request.php` |
| `javascript:S6582` | 2 | Minor | Preferir optional chaining (`?.`) | `multimediaService.js`×2 |
| `Web:S6850` | 2 | Major | Encabezados sin contenido accesible | `tuscoleccionescliente.html`, `colaborativo.html` |
| `php:S1172` | 2 | Major | Parámetros de función sin uso | `MultimediaService.php`×2 |
| `php:S121` | 2 | Critical | Estructuras de control sin llaves `{}` | `ColeccionRepository.php`, `BackupService.php` |
| `Web:S6853` | 2 | Major | Labels sin asociar con controles | `crearcoleccion.html`×2 |
| `docker:S7031` | 1 | Minor | Fusionar instrucciones `RUN` | `Dockerfile` |
| `php:S1131` | 1 | Minor | Espacios en blanco al final de línea | `Database.php` |
| `Web:S7926` | 1 | Major | Meta viewport deshabilita zoom | `colaborativo.html` |
| `php:S127` | 1 | Major | Condición de parada de bucle no invariante | `QrGenerator.php` |
| `javascript:S7770` | 1 | Minor | Arrow function equivalente a `Boolean` | `crearcoleccion.js` |
| `php:S1068` | 1 | Major | Campo privado sin uso | `ColaborativoController.php` |
| `javascript:S3776` | 1 | Critical | Complejidad cognitiva excesiva (JS) | `subirimagenes.js` |
| `php:S1448` | 1 | Major | Clase con demasiados métodos (28 > 20) | `QrGenerator.php` |
| `javascript:S7776` | 1 | Minor | Arrays para existencia → usar `Set` | `panelcliente.js` |

---

## 8. Security Hotspots

**Resultado: 0 hotspots** pendientes de revisión.

---

## 9. Correlación CWE / OWASP

| Vulnerabilidad | CWE | Mitigación |
|:--|:--|:--|
| `S3330` (sin HttpOnly) | CWE-1004 | Mitigación de XSS / robo de cookies |
| `S2092` (sin secure) | CWE-614 | Prevenir sniffing de sesión (MITM) |
| `S5122` (CORS permisivo) | CWE-942 | OWASP API Security — lista blanca de orígenes |
| `S6471` (usuario root) | — | Principio de menor privilegio (CIS Docker Benchmark) |

---

## 10. Archivos escaneados (listado completo)

### Backend (40 archivos)
```
backend/cron-backup.php
backend/Dockerfile
backend/php.ini
backend/probe_media.php
backend/probe_originals.php
backend/public/index.php
backend/routes.php
backend/src/Core/Config.php
backend/src/Core/Database.php
backend/src/Core/Request.php
backend/src/Core/Response.php
backend/src/Core/Router.php
backend/src/controllers/AuthController.php
backend/src/controllers/ColaborativoController.php
backend/src/controllers/ColeccionController.php
backend/src/controllers/FavoritoController.php
backend/src/controllers/FotografoController.php
backend/src/controllers/HomeController.php
backend/src/controllers/MultimediaController.php
backend/src/controllers/SistemaController.php
backend/src/dtos/CreateColeccionDto.php
backend/src/dtos/LoginDto.php
backend/src/dtos/MultimediaDto.php
backend/src/dtos/RegisterDto.php
backend/src/helpers/Jwt.php
backend/src/helpers/Mailer.php
backend/src/helpers/MediaProcessor.php
backend/src/helpers/QrGenerator.php
backend/src/middlewares/AuthMiddleware.php
backend/src/repository/ColeccionRepository.php
backend/src/repository/MultimediaRepository.php
backend/src/repository/UserRepository.php
backend/src/services/AuthService.php
backend/src/services/BackupService.php
backend/src/services/ColeccionService.php
backend/src/services/MultimediaService.php
backend/src/validators/AuthValidator.php
backend/src/validators/ColeccionValidator.php
backend/src/validators/MultimediaValidator.php
```

### Frontend cliente (37 archivos)
```
frontend-cliente/css/base.css
frontend-cliente/css/colaborativo.css
frontend-cliente/css/estilos.css
frontend-cliente/css/estiloscliente.css
frontend-cliente/css/panelcliente.css
frontend-cliente/dom/auth/login.js
frontend-cliente/dom/auth/registro.js
frontend-cliente/dom/auth/verificaremail.js
frontend-cliente/dom/colaborativo/colaborativo.js
frontend-cliente/dom/colecciones/coleccion.js
frontend-cliente/dom/colecciones/panelcliente.js
frontend-cliente/dom/colecciones/tarjetas.js
frontend-cliente/dom/colecciones/tuscoleccionescliente.js
frontend-cliente/dom/comun/auth.js
frontend-cliente/dom/comun/interfaz.js
frontend-cliente/dom/comun/sesion.js
frontend-cliente/dom/favoritos/favoritos.js
frontend-cliente/dom/favoritos/favoritoscliente.js
frontend-cliente/dom/multimedia/descargas.js
frontend-cliente/dom/multimedia/multimedia.js
frontend-cliente/index.html
frontend-cliente/pages/colaborativo.html
frontend-cliente/pages/coleccion.html
frontend-cliente/pages/favoritoscliente.html
frontend-cliente/pages/login.html
frontend-cliente/pages/panelcliente.html
frontend-cliente/pages/registro.html
frontend-cliente/pages/tuscoleccionescliente.html
frontend-cliente/pages/verificaremail.html
frontend-cliente/services/auth/authService.js
frontend-cliente/services/colaborativo/colaborativoService.js
frontend-cliente/services/colecciones/coleccionesService.js
frontend-cliente/services/config.js
frontend-cliente/services/favoritos/favoritosService.js
frontend-cliente/services/http.js
frontend-cliente/services/invitaciones/invitacionesService.js
frontend-cliente/services/multimedia/multimediaService.js
frontend-cliente/services/sesion/sesionService.js
```

### Frontend fotógrafo (38 archivos)
```
frontend-fotografo/css/base.css
frontend-fotografo/css/estilos.css
frontend-fotografo/css/moderacion.css
frontend-fotografo/css/panel.css
frontend-fotografo/css/subirimagenes.css
frontend-fotografo/css/tuscolecciones.css
frontend-fotografo/dom/auth/login.js
frontend-fotografo/dom/auth/registro.js
frontend-fotografo/dom/auth/verificaremail.js
frontend-fotografo/dom/colecciones/crearcoleccion.js
frontend-fotografo/dom/colecciones/moderacion.js
frontend-fotografo/dom/colecciones/panel.js
frontend-fotografo/dom/colecciones/qr.js
frontend-fotografo/dom/colecciones/subirimagenes.js
frontend-fotografo/dom/colecciones/tags.js
frontend-fotografo/dom/comun/almacenamiento.js
frontend-fotografo/dom/comun/sesion.js
frontend-fotografo/dom/multimedia/multimedia.js
frontend-fotografo/dom/perfil/editarperfil.js
frontend-fotografo/dom/perfil/menu-perfil.js
frontend-fotografo/dom/perfil/privacidad.js
frontend-fotografo/index.html
frontend-fotografo/pages/crearcoleccion.html
frontend-fotografo/pages/editarperfil.html
frontend-fotografo/pages/login.html
frontend-fotografo/pages/moderacion.html
frontend-fotografo/pages/panel.html
frontend-fotografo/pages/registro.html
frontend-fotografo/pages/SubirImagenes.html
frontend-fotografo/pages/tuscolecciones.html
frontend-fotografo/pages/verificaremail.html
frontend-fotografo/services/auth/authService.js
frontend-fotografo/services/colaborativo/colaborativoService.js
frontend-fotografo/services/colecciones/coleccionesService.js
frontend-fotografo/services/config.js
frontend-fotografo/services/fotografo/fotografoService.js
frontend-fotografo/services/http.js
frontend-fotografo/services/multimedia/multimediaService.js
frontend-fotografo/services/sesion/sesionService.js
```

---

## 11. Comparación con análisis anteriores

| Métrica | Análisis 1 | Análisis 2 | **Análisis 3 (actual)** |
|:---|:---:|:---:|:---:|
| Archivos indexados | 100 | 82 | **115** |
| Vulnerabilidades | 7 | 7 | **4** |
| Bugs | 12 | 9 | **6** |
| Code Smells | 65 | 129 | **107** |
| Rating seguridad | C | C | **C** |
| Cobertura | 0% | 0% | **0%** |
| Duplicación | 3.4% | 4.3% | **8.6%** |

**Cambios positivos:**
- `javascript:S2245` (Math.random) → **corregidas** (3 vulnerabilidades cerradas)
- Estructura del proyecto reorganizada con `dom/` y `services/`
- Algunos smells cerrados por eliminación de archivos obsoletos

**Pendientes:**
- Las 4 vulnerabilidades restantes (CORS, cookies, Docker) siguen activas
- Duplicación subió a 8.6% (nuevos archivos CSS/JS)
- 10 code smells critical sin resolver (13 literales duplicados, 10 complejidad cognitiva)

---

## 12. Notas metodológicas

1. **SAST** detecta patrones estáticos sin ejecutar el código. No sustituye DAST ni revisión manual.
2. **Falsos positivos posibles:** `S2245` cerrado porque `Math.random()` solo generaba IDs locales, no tokens de sesión.
3. **Cobertura 0%:** no se proveyeron reportes de pruebas (PHPUnit/JS). Configurar `sonar.php.coverage.reportPaths` para medirla.
4. **SCA omitido:** no hay `composer.json` / `package.json` → no se analizan dependencias vulnerables.
5. El token del escáner debe revocarse al finalizar: `http://localhost:9000/account/security`.

---

## 13. Comandos de reproducción

```powershell
# Levantar SonarQube
Start-Process -FilePath "cmd.exe" -ArgumentList "/c",
  "C:\SonarQube\sonarqube\sonarqube-26.8.0.126808\bin\windows-x86-64\StartSonar.bat" -WindowStyle Hidden

# Esperar estado UP
Invoke-WebRequest http://localhost:9000/api/system/status

# Ejecutar análisis
& "C:\Sonar-Scanner\sonar-scanner\bin\sonar-scanner.bat" --% `
  -Dsonar.host.url=http://localhost:9000 -Dsonar.token=<SONAR_TOKEN>
```

---

*Reporte generado el 2026-09-11 a partir de los datos exportados de SonarQube Community Build 26.8.0.126808.*
