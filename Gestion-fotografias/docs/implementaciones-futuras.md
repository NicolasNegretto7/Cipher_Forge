# Implementaciones futuras y observaciones pendientes

Este documento registra hallazgos, riesgos y oportunidades de mejora identificados durante la revisión de código del frontend, que no requieren acción inmediata pero deben considerarse en futuras iteraciones.

---

## 1. Protección de colecciones privadas depende exclusivamente del backend

**Fecha de identificación:** 2026-09-14
**Requisitos relacionados:** RF5, RF6
**Severidad:** Baja (observación de arquitectura)

### Contexto

- **RF5** establece que las colecciones privadas deben conservar su privacidad de forma permanente, sin cambiar su estado por el tiempo ni por la cantidad de usuarios vinculados.
- **RF6** establece que el sistema debe bloquear cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados.

### Observación

El frontend gestiona el acceso a colecciones privadas a través de un sistema de invitaciones (tokens). Sin embargo, **no implementa ninguna barrera de protección adicional** más allá de no mostrar las colecciones privadas en la lista pública de colecciones.

La protección real contra acceso directo por URL depende enteramente del backend: cada endpoint que sirve contenido de una colección privada debe verificar que el usuario solicitante tenga una invitación válida o sea el propietario de la colección.

### Riesgo

Si el backend tiene un bug de autorización (por ejemplo, un endpoint que no verifica permisos antes de devolver contenido), el frontend no tiene protección compensatoria. Un usuario podría acceder a contenido privado manipulando la URL directamente.

### Recomendación para futuras iteraciones

Considerar agregar validación client-side como capa defensiva adicional:
1. Al cargar una colección, verificar la respuesta del backend para detectar errores de autorización (403) y mostrar un mensaje claro.
2. En la página de visualización de colección, si la colección es privada y el usuario no tiene invitación válida, redirigir antes de cargar el contenido.
3. Implementar una página de "acceso denegado" consistente en lugar de depender exclusivamente de los mensajes de error del backend.

Estas son mejoras de UX y defensa en profundidad, no reemplazan la validación server-side que es la protección principal.

### Archivos relevantes

- `frontend-cliente/dom/colecciones/tuscoleccionescliente.js` (flujo de invitaciones)
- `frontend-cliente/services/invitaciones/invitacionesService.js` (validación y canje del token)
- `frontend-cliente/dom/colecciones/coleccion.js` (visualización de colecciones)
- `frontend-cliente/dom/multimedia/multimedia.js` (carga de contenido con sesión)

---

## 2. Validación de formato de archivo por magic bytes en el frontend

**Fecha de identificación:** 2026-09-14
**Requisitos relacionados:** RF7, RF25
**Severidad:** Baja (mejora de UX)

### Contexto

- **RF7** establece que el sistema debe permitir subir imágenes en formato JPG y videos MP4.
- **RF25** establece que los videos subidos deben ser clips o recortes con un límite máximo por video original.

### Observación

El frontend del fotógrafo (`frontend-fotografo/dom/colecciones/subirimagenes.js`) valida el **tamaño** de cada archivo (`validarTamanoArchivo`), pero **no verifica el contenido real** antes de enviarlo al backend. El `input` de subida solo restringe por extensión (`.jpg,.jpeg,.mp4`) y el navegador reporta el MIME a partir de esa extensión, por lo que no hay una comprobación de los **magic bytes** (los primeros bytes de un archivo) que confirme que el contenido real es JPEG o MP4.

**¿Qué son los magic bytes?** Son los primeros bytes de un archivo que identifican su formato real. Por ejemplo:
- Todo archivo JPEG real empieza con los bytes `FF D8 FF`
- Todo archivo MP4 real contiene la cadena `ftyp` en sus primeros 8 bytes

En consecuencia, el archivo se envía al backend sin comprobar su contenido real más allá del `accept` del input y del MIME reportado por el navegador.

### Ejemplo del problema

Un usuario podría renombrar un archivo `.png` o `.webp` a `.jpg`. El frontend lo aceptaría y lo enviaría al backend. Si el backend rechaza el archivo, el usuario recibiría un error sin entender por qué. Si el backend lo acepta, podría haber problemas de procesamiento (marca de agua, vista previa, etc.).

### Recomendación para futuras iteraciones

Agregar validación de magic bytes en el frontend antes de subir archivos. Como referencia sigue existiendo la validación de MIME que el backend sí aplica (`backend/src/validators/MultimediaValidator.php`). Esto mejoraría la experiencia de usuario al detectar archivos con extensión incorrecta antes de iniciar la subida.

### Archivos relevantes

- `frontend-fotografo/dom/colecciones/subirimagenes.js` (validación actual: solo tamaño, no magic bytes)
- `backend/src/validators/MultimediaValidator.php` (validación real de MIME en el servidor)

---

*Este documento se actualizará a medida que se identifiquen nuevas observaciones pendientes.

## 3. Mailpit solo para entorno de desarrollo

**Fecha de identificación:** 2026-10-21
**Referencia:** [infraestructura.md, Sección 5.6](infraestructura.md#56-dependencias-y-ejecución), [Sección 6, B6](infraestructura.md#6-riesgos-restricciones-y-decisiones-pendientes)

### Contexto

El servicio Mailpit (`axllent/mailpit:latest`) se usa exclusivamente como buzón de desarrollo y laboratorio. Cumple el requisito RF18 de envío de códigos de verificación por correo durante el desarrollo y las pruebas del proyecto UTU.

### Estado actual

- **LOCAL Windows:** Mailpit está activo en los puertos `8025` (UI) y `1025` (SMTP), publicados por Docker Compose. Permite capturar y revisar los correos de verificación enviados por la aplicación durante el desarrollo.
- **SERVIDOR UBUNTU (Server Ubuntu Lab):** Mailpit corre en el mismo stack, pero escucha solo en `127.0.0.1:8025/1025`. Se consulta por túnel SSH (`ssh -p 2222 -L 8025:127.0.0.1:8025 sysadmin@127.0.0.1`) y no está expuesto a la LAN.
- **PRODUCCIÓN:** no está implementado. Para un entorno de producción se requiere contratar un servicio de correo externo (SendGrid, Mailgun, Amazon SES, etc.) o integrar una API de envío de correos. El uso continuado de Mailpit en producción no está recomendado ni soportado.

### Recomendación

- Mantener Mailpit como parte del stack de desarrollo local (`docker-compose.yml`).
- Para despliegues reales, configurar credenciales y endpoints SMTP apropiados a través de variables de entorno (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`) y proveedor de servicio externo.
- Documentar en la guía de despliegue la transición de Mailpit a un servicio de producción.

### Archivos relevantes

- `Gestion-fotografias/backend/docker-compose.yml` (configuración actual de Mailpit)
- `Gestion-fotografias/docs/infraestructura.md` (notas de producción)
- `Gestion-fotografias/backend/.env` (plantilla de variables de entorno)*

---

## 4. Rate limiting global para todas las rutas

**Fecha de identificación:** 2026-10-21
**Estado:** Parcialmente implementado (endpoints sensibles) — el alcance global queda documentado aquí como mejora futura
**Requisitos relacionados:** RF18 (verificación de correo), seguridad de autenticación, RNF de robustez

### Contexto

El backend no tenía ninguna limitación de tasa de peticiones: los endpoints de autenticación podían recibir fuerza bruta sin freno y cada reenvío de código disparaba un correo real. Se implementó (2026-10-21) un rate limiter **solo para los endpoints sensibles**, dejando documentado en este apartado el diseño para extenderlo a **todas las rutas**.

### Estado actual (implementado)

- **Núcleo:** `backend/src/helpers/RateLimiter.php` — ventana fija, estado en archivos con `flock()` bajo `sys_get_temp_dir()/cipher_forge_rate_limit`, purga automática a las 24 h, y *fail open* si el almacenamiento no está disponible (la disponibilidad pesa más que un rechazo puntual).
- **Reglas:** `backend/src/middlewares/RateLimitMiddleware.php`, invocado desde `backend/public/index.php` **antes** del despacho del Router (un 429 no toca BD ni controladores). Cupos actuales:

| Ruta | Regla | Cupo |
|---|---|---|
| `POST /auth/login` | IP + email | 5 / 5 min |
| `POST /auth/login` | IP | 20 / 5 min |
| `POST /auth/register` | IP | 10 / 1 h |
| `POST /auth/verificar-email` | IP + email | 6 / 10 min |
| `POST /auth/reenviar-codigo` | IP + email | 3 / 15 min |
| `POST /auth/reenviar-codigo` | IP | 10 / 1 h |

- **Respuesta:** HTTP 429 con el JSON estándar del proyecto más `Retry-After` y cabeceras `X-RateLimit-Limit/Remaining/Reset`. Las respuestas permitidas también informan su cupo restante.
- **Kill switch:** `RATE_LIMIT_ENABLED=0` desactiva todo el mecanismo sin redeploy (emergencias operativas o suites E2E).

### Diseño propuesto para el alcance global

1. **Ubicación del hook:** mantener la evaluación en `public/index.php` (antes del Router), ampliando `RateLimitMiddleware::REGLAS` con una regla *catch-all* por categoría en lugar de enumerar cada ruta. Ventaja: un 429 global sigue sin tocar la BD ni instanciar controladores.
2. **Presupuestos por categoría (propuesta):**

| Categoría | Rutas | Cupo propuesto |
|---|---|---|
| Lectura pública | `GET /colecciones/publicas`, `GET /fotografos`, `GET /qr/{token}/svg` | 120 / min por IP |
| Lectura autenticada | `GET` con middleware `auth`/`optional` | 240 / min por usuario + IP |
| Escritura autenticada | `POST/PUT/DELETE` con `auth` | 60 / min por usuario |
| Uploads pesados | `POST /colecciones/{id}/multimedia`, `POST /colaborativo/{token}/subir` | 20 / min por usuario (además de los límites de tamaño ya existentes) |
| Ya protegidos | `/sistema/*` (guard por IP), CLI de `cron-backup.php` | Exentos del catch-all |

3. **Algoritmo:** migrar de ventana fija a **ventana deslizante** (registro de marcas de tiempo por clave) o *token bucket* para evitar el "borde de ventana" donde caben el doble de peticiones. La interfaz de `RateLimiter::registrar()` no cambia; solo su implementación interna.
4. **Almacenamiento por escala:**
   - **1 instancia (actual):** archivos con `flock()` — ya probado, cero dependencias.
   - **Varias workers / más carga:** APCu (requiere compilar la extensión en el `Dockerfile`).
   - **Varias instancias o backend horizontal:** Redis o una tabla MySQL `rate_limit_hits` (clave, ventana, conteo) con limpieza periódica desde el worker de `cron-backup.php`.
5. **Identidad del cliente:** hoy se usa exclusivamente `REMOTE_ADDR` (igual que `SistemaController::restringirALocal`), coherente con el stack actual (Apache directo detrás del puerto de Docker). Si en producción se introduce un proxy/load balancer, confiar en `X-Forwarded-For` **solo** desde rangos de proxies de confianza, configurable por env (p. ej. `TRUSTED_PROXIES`); nunca de forma abierta, porque es falsificable.
6. **Experiencia de cliente:** exponer `X-RateLimit-*` y `Retry-After` en `Access-Control-Expose-Headers` (línea de CORS de `public/index.php`) para que el frontend pueda mostrar "espera N segundos" en lugar de un error genérico. **Requiere aprobación del responsable del proyecto.**
7. **Plan de rollout:** (a) reglas *catch-all* detrás de `RATE_LIMIT_GLOBAL_ENABLED=0` por defecto; (b) medir en desarrollo con las suites E2E existentes (`probe_e2e.ps1`) buscando falsos positivos; (c) activar en staging; (d) ajustar cupos con métricas reales antes de producción.
8. **Pruebas:** el patrón ya existe en el proyecto: generar bombarderos controlados (login/registro inválido), verificar 429 + `Retry-After`, verificar aislamiento por clave (una cuenta bloqueada no afecta a otras) y verificar recuperación tras limpiar contadores.

### Archivos relevantes

- `Gestion-fotografias/backend/src/helpers/RateLimiter.php` (núcleo implementado)
- `Gestion-fotografias/backend/src/middlewares/RateLimitMiddleware.php` (reglas de endpoints sensibles)
- `Gestion-fotografias/backend/public/index.php` (hook previo al Router y cabeceras CORS)
- `Gestion-fotografias/backend/src/middlewares/AuthMiddleware.php` (referencia de patrón de middleware)
- `Gestion-fotografias/backend/src/controllers/SistemaController.php` (guard por IP existente, exento del catch-all)
