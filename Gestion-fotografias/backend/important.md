# Hallazgos importantes

> Registro de los hallazgos de auditoría **aprobados** por el responsable del proyecto.
> Mantener la **misma estructura de hallazgo** para cada entrada. No borrar entradas.

---

## Aprobados (ya solucionados)

### H01 — Seguridad del respaldo (Riesgo Alto)

- **Categoría:** Seguridad
- **Requisito relacionado:** RNF8 / Ley 18.331 (protección de datos personales)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/backups/` (sin `.htaccess`), `backend/.htaccess`, `backend/backups/*.sql`
- **Evidencia:** `GET /backups/backup_cipher_forge_….sql` respondía **HTTP 200** con el dump completo de MySQL (~90 KB, `INSERT INTO` / `CREATE TABLE`). A diferencia de `uploads/` (que sí tiene `.htaccess` con `Require all denied`), `backups/` no estaba protegido y Apache servía los archivos reales directamente.
- **Problema:** el respaldo completo de la base de datos (usuarios, emails, contraseñas bcrypt, material colaborativo sin aprobar, tokens) era descargable por URL estática predecible sin autenticación.
- **Impacto:** fuga total de datos personales; compromete RNF8 y la Ley 18.331.
- **Dependencias:** ninguna; la corrección no altera el flujo de respaldos.
- **Cambio propuesto:** crear `backend/backups/.htaccess` con `Require all denied` (idéntico al de `uploads/`).
- **Riesgo:** **Alto**
- **¿Requiere aprobación?:** **Sí** — aprobado por el responsable (2026-09-11).
- **Estado:** **Solucionado** (2026-09-11) — se creó `backend/backups/.htaccess`; verificado e2e: el acceso directo al respaldo ahora responde `HTTP 403`.

---

### H11 — Documentación interna de formatos aceptados (Riesgo Bajo, mantenibilidad)

- **Categoría:** Mantenibilidad
- **Requisito relacionado:** RF7 / CF-03 (solo JPG y MP4)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/AUDITORIA_ENDPOINTS.md`
- **Evidencia:** las secciones del endpoint de subida citaban formatos que la validación nunca aceptó: "(JPG/PNG o video)", "imagen JPG/PNG | video MP4/MOV/WEBM/AVI" y "fotos (JPG/PNG) y videos (clips)". `MultimediaValidator::MIMES_IMAGEN`/`MIMES_VIDEO` solo admiten `image/jpeg` → `jpg` y `video/mp4` → `mp4`, y el invitado colaborativo usa el mismo mapa (`ColaborativoController::EXTENSION_POR_MIME`).
- **Problema:** la documentación interna anunciaba formatos que el backend rechaza (400), induciendo a error a quien mantenga el código o la suite.
- **Impacto:** desviación documental sin efecto funcional; confusión en tareas de mantenimiento y auditoría.
- **Dependencias:** ninguna.
- **Cambio propuesto:** reescribir las menciones a los formatos realmente aceptados (JPG y MP4).
- **Riesgo:** **Bajo**
- **¿Requiere aprobación?:** **Sí** — aprobado por el responsable (2026-09-11).
- **Estado:** **Solucionado** (2026-09-11) — corregidas las menciones en `AUDITORIA_ENDPOINTS.md` (resúmenes de `POST /colecciones/{id}/multimedia`, detalle MIME y `POST /colaborativo/{token}/subir`); registrado CC-29.

---

### H09 — Falta `GET /colecciones/mias` (escalabilidad/producción, Riesgo Bajo)

- **Categoría:** Funcionalidad / escalabilidad
- **Requisito relacionado:** panel "Mis colecciones" del fotógrafo (HU5 y relacionadas)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/routes.php` (solo existían `GET /colecciones/publicas` y `GET /colecciones/{id}`), `ColeccionController`, `frontend-fotografo/js/panel.js:6` (lista leída solo de `localStorage`)
- **Evidencia:** el panel "Mis colecciones" (`panel.js:6`) pintaba únicamente `localStorage["colecciones"]`; el backend no ofrecía endpoint que liste las colecciones del fotógrafo autenticado. Por eso la lista desaparecía al cambiar de navegador/dispositivo o limpiar el almacenamiento, aunque las colecciones existan en MySQL.
- **Problema:** la lista de colecciones propias no escala ni persiste entre dispositivos (depende del navegador).
- **Impacto:** en producción, con muchos fotógrafos/colecciones, el panel no escala y el usuario pierde la vista de sus colecciones al cambiar de equipo.
- **Dependencias:** ninguna.
- **Cambio propuesto:** `GET /colecciones/mias` con `'auth'` → lista las colecciones del fotógrafo autenticado desde el servidor; el panel la carga fusionada con los borradores locales sin publicar.
- **Riesgo:** **Bajo**
- **¿Requiere aprobación?:** **Sí** — aprobado por el responsable (2026-09-11).
- **Estado:** **Solucionado** (2026-09-11) — `GET /colecciones/mias` implementado (`ColeccionRepository::listarMiasConPortada`, `ColeccionService::listarMias`, `ColeccionController::listarMias`, ruta ANTES de `/colecciones/{id}`); `api.js` expone `listarMisColecciones()` y `panel.js` sincroniza el panel con el servidor (conserva borradores locales, descarta publicadas ya inexistentes en el servidor, miniaturas autenticadas vía `obtenerVistaPrevia`). Registrado CC-33.

---

## Pendientes de aprobación (sin resolver)

### H02 — Endpoints administrativos `/sistema/*` sin control de acceso (Riesgo Medio)

- **Categoría:** Seguridad (control de acceso administrativo)
- **Requisito relacionado:** HU13 / RNF5, RNF6, RNF7 / RF15
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/routes.php:85-87`, `backend/src/controllers/SistemaController.php`
- **Evidencia:** `POST /sistema/backup`, `GET /sistema/backups` y `POST /sistema/limpiar-colaborativos` se registran **sin middleware** (no llevan `'auth'`), por lo que responden sin token.
- **Problema:** operaciones administrativas (crear respaldo, listar respaldos, purgar material colaborativo) expuestas a cualquier llamador HTTP.
- **Impacto:** cualquiera puede disparar respaldos/purgas o leer el historial de respaldos; `limpiar-colaborativos` elimina material.
- **Dependencias:** ninguna.
- **Cambio propuesto:** restringir esos 3 endpoints al **host local** (`Require local` en Apache / chequeo de `REMOTE_ADDR` en `index.php`). El cron del contenedor sigue funcionando por correr en la misma red local. Sin introducir roles.
- **Riesgo:** **Medio**
- **¿Requiere aprobación?:** **Sí** — **aprobación pendiente** (2026-09-11).
- **Estado:** **Pendiente de aprobación.**

---

### H03 — Verificación de email eludible (Riesgo Medio)

- **Categoría:** Seguridad
- **Requisito relacionado:** RF18 / HU21 (código al correo para asegurar que la casilla existe y pertenece al usuario)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/src/services/AuthService.php`, `backend/src/controllers/AuthController.php`
- **Evidencia (e2e):** `POST /auth/register` → 201 con `codigo_verificacion` incluido en la respuesta JSON. Documentado como decisión "solo desarrollo" en `backend/EMAIL_CONFIG.md`.
- **Problema:** cualquiera que se registre con un correo ajeno puede verificar la cuenta sin acceder al correo; la verificación pierde su propósito. El requisito no restringe esto a desarrollo.
- **Impacto:** verificación de email eludible; cuentas falsas con correo ajeno.
- **Dependencias:** el frontend usa el código devuelto para el flujo de verificación en desarrollo; el cambio debe coordinarse.
- **Cambio propuesto:** dejar de exponer `codigo_verificacion` (y `email_enviado`) en las respuestas; verificar en dev leyendo el correo de Mailpit (`:8025`).
- **Riesgo:** **Medio**
- **¿Requiere aprobación?:** **Sí** — **aprobación pendiente** (2026-09-11).
- **Estado:** **Pendiente de aprobación.**

---

### H04 — Material de invitados pendiente servible por URL directa (Riesgo Medio)

- **Categoría:** Seguridad / Bug (caso límite de permisos)
- **Requisito relacionado:** RF14-RF15 (los invitados solo suben; el material se modera antes de exponerse)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/src/services/MultimediaService.php` (`rutaServible`/`obtenerVistaPrevia`, `obtenerOriginal`, `obtenerDescarga` no filtran `aprobado`)
- **Evidencia (e2e):** material subido como invitado (201, `aprobado = 0`, id 133). `GET /multimedia/133/vista-previa` con token del dueño → 200, y con token de un cliente autorizado → 200, ambos ANTES de aprobar. Tras aprobar → sigue 200.
- **Problema:** el material de invitados pendiente de aprobación es servible por URL directa (IDs secuenciales) a quien tenga acceso a la colección, exponiéndolo antes de la moderación del fotógrafo.
- **Impacto:** fuga de material no autorizado (privacidad del evento, Ley 18.331).
- **Dependencias:** el endpoint `/colaborativo/pendientes` sigue siendo el canal del dueño.
- **Cambio propuesto:** en vista-previa, original y descargar, responder **403** si `es_invitado = 1` y `aprobado = 0`.
- **Riesgo:** **Medio**
- **¿Requiere aprobación?:** **Sí** — **aprobación pendiente** (2026-09-11).
- **Estado:** **Pendiente de aprobación.**

---

### H10 — Hoja imprimible de QR sin verificar propietario (Riesgo Bajo, aceptado por diseño)

- **Categoría:** Caso límite (aceptado por diseño)
- **Requisito relacionado:** HU7 / CF-06 (hoja imprimible sin sesión)
- **Ruta del archivo de requisito:** `Gestion-fotografias/docs/01-requerimientos.md`
- **Archivo(s) afectado(s):** `backend/routes.php:65`, `backend/src/controllers/ColaborativoController.php` (`imprimir`, línea 125)
- **Evidencia (e2e):** `GET /colecciones/{id}/qr-colaborativo/imprimir` → 200 sin token; genera/muestra QR del evento sin verificar propietario.
- **Problema:** un tercero que conozca el ID puede generar el token colaborativo de una colección ajena (solo habilita subidas de invitados, sin visibilidad).
- **Impacto:** acotado por diseño de RF14 (sin acceso a material); bajo.
- **Dependencias:** el evento requiere el QR imprimible sin sesión (CF-06).
- **Cambio propuesto:** documentar la aceptación del riesgo o, si se prefiere, verificar propietario cuando se imprime con sesión iniciada.
- **Riesgo:** **Bajo**
- **¿Requiere aprobación?:** **Sí** — **aprobación pendiente** (2026-09-11).
- **Estado:** **Pendiente de aprobación.**