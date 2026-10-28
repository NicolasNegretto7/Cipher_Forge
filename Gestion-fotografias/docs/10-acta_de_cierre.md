# Documento de Cierre de Proyecto (Acta de Cierre)

## ¿Para qué sirve este documento?

El acta de cierre formaliza que el proyecto terminó: qué se entregó, qué requerimientos
se cumplieron, qué quedó pendiente, qué se aprendió y que el cliente/referente aceptó
la entrega. Es el último documento del proyecto y es especialmente importante para la
defensa final: resume en un solo lugar todo el recorrido del equipo.

---

**Nombre del proyecto: Cipher Photo** \
**Fecha de cierre: 15/10/2026** \
**Fecha de inicio: 26/06/2026** (ver [project_charter.md](project_charter.md)) \
**Duración total: 15 semanas — 5 sprints de 3 semanas — 91 puntos de historia** \
**Equipo: Iván Sandoval (sublíder / backend), Nicolás Negretto (líder / Frontend), Augusto Fernández (Frontend)** \
**Cliente: Lemuel Swec** \
**Metodología: Scrum** (revisión con el cliente al cierre de cada sprint)

---

## Resumen de sprints

| Sprint | Objetivo | Incremento entregado | Resultado |
| --- | --- | --- | --- |
| **Sprint 1** (semanas 1–3) · SR-01 · 17/07/2026 | Núcleo de seguridad y de la plataforma: registro con roles diferenciados, creación de colecciones y pipeline de subida con marca de agua automática. | HU1, HU8, HU25, HU2, HU5, HU14 — inicio de sesión con hash de contraseñas y redirección por rol, registro de fotógrafo/cliente con validaciones y términos, creación de colecciones públicas/privadas, carga de JPG y generación de vista previa con marca de agua (librería GD). | **20/20 pts (100%)**. Sin feedback del cliente: no fue posible contactarlo (SR-01). |
| **Sprint 2** (semanas 4–6) · SR-02 · 07/08/2026 | Acceso seguro a colecciones privadas, blindaje contra acceso directo por URL, verificación de correo, consentimiento de Ley 18.331 y descarga en dos calidades. | HU17, HU3, HU20, HU21, HU24, HU19, HU31, HU10 — tokens permanentes en `qr_tokens`, bloqueo 403 en endpoints privados, código de verificación por correo con expiración, unicidad de correo (409), modal obligatorio de Ley 18.331 con scroll, descarga directa en "Buena Calidad"/"Alta Calidad". | **20/20 pts (100%)**. Sin feedback del cliente (SR-02). |
| **Sprint 3** (semanas 7–9) · SR-03 · 28/08/2026 | Ecosistema de carga colaborativa por QR efímero y categorización temática. | HU4, HU7, HU11, HU12, HU26, HU27 — generación nativa de QR SVG con caducidad de 24 h, plantilla imprimible para salones, subida anónima móvil de invitados, panel de moderación con aprobación en lote, hashtags y filtrado en tiempo real. | **20/20 pts (100%)**. Sin feedback del cliente (SR-03). |
| **Sprint 4** (semanas 10–12) · SR-04 · 18/09/2026 | Control de almacenamiento y procesamiento de video. | HU16, HU28, HU6, HU32 — cuota de 3 GB con subida parcial y notificación de excedentes, validación de límites (imagen 30 MB / video 800 MB), eliminación de archivos con liberación de cuota, recortes de 15 s con FFmpeg conservando el original. | **16/16 pts (100%)**. Sin feedback del cliente (SR-04). |
| **Sprint 5** (semanas 13–15) · SR-05 · 09/10/2026 | Cierre del 100% del Product Backlog y entrega formal. | HU22, HU18, HU23, HU13, HU15 — edición de datos de archivos, edición de perfil, favoritos por colección pública, respaldo automático diario con rotación de 3 copias y guía/capacitación. | **15/15 pts (100%)**, con **HU15 marcada como INCOMPLETO** en SR-05 (ver *Pendientes*). Sin feedback del cliente (SR-05). |

**Balance de esfuerzo:** 91 de 91 puntos del backlog inicial entregados (20 + 20 + 20 + 16 + 15), velocidad promedio real de **18,2 puntos por sprint** sobre una estimación planificada de ~20 pts/sprint ([`01-requerimientos.md`, sección 14 — Estimación de esfuerzo](01-requerimientos.md#14-estimación-de-esfuerzo-plazo-y-costo) y [`04_sprint_review.md`](04_sprint_review.md)).

**Actividades de cierre realizadas:**
1. Entrega de guía básica de uso. *(parcial: ver Pendientes — HU15 figura INCOMPLETO en SR-05)*
2. Escalabilidad a producción. *(solo a nivel de infraestructura Docker local; despliegue en producción excluido por restricción institucional UTU)*
3. Último testing. *(`06-testing.md` y `SAST-SonarQube-Reporte.md`)*
4. Registro de lecciones aprendidas. *(sección siguiente)*
5. Cierre formal del proyecto y firma de aceptación. *(pendiente de firma del cliente: ver Aceptación)*
6. Validación de los requerimientos cumplidos frente al backlog inicial. *(tabla siguiente)*

---

## Requerimientos cumplidos al cierre

Fuente: `01-requerimientos.md`; evidencia en `04_sprint_review.md`, `06-testing.md` y `08_control_de_cambios.md`.

### Requerimientos funcionales

| Área / requerimiento | Estado | Evidencia |
| --- | --- | --- |
| **RF1** — Registro de usuarios (nombre, correo, contraseña, teléfono opcional) | Cumplido | SR-01 (HU8, HU25) |
| **RF2** — Impedir registro duplicado por correo | Cumplido | SR-02 (HU19, HTTP 409) |
| **RF3** — Pantalla de inicio de sesión segura | Cumplido | SR-01 (HU1, hash de contraseñas) |
| **RF4** — Colecciones públicas/privadas con hashtags | Cumplido | SR-01 (HU2) + SR-03 (HU26) |
| **RF5** — Privacidad permanente de colecciones privadas vía enlace de invitación | Cumplido | SR-02 (HU3, `acceso_colecciones`) |
| **RF6** — Bloqueo de acceso directo por URL a colecciones privadas | Cumplido | SR-02 (HU20, 403 Forbidden) |
| **RF7** — Subida de imágenes JPG y videos MP4 con límite por archivo | Cumplido | SR-01 (HU5) + CC-27 (límite imagen 30 MB) + CC-16 (transporte PHP 900M/1G) |
| **RF8** — Versión optimizada y ligera para la vista previa | Cumplido | SR-01 (demo: <2 s por imagen) |
| **RF9** — Marca de agua automática en la vista previa de imágenes JPG | Cumplido | SR-01 (HU14, librería GD) |
| **RF10** — Descarga directa individual en dos niveles de calidad | Cumplido | SR-02 (HU10) + `06-testing.md` (CC-24/CC-30/CC-32/CC-31) |
| **RF11** — Visualización pública, descarga en dos calidades y filtrado por hashtags | Cumplido | SR-02 (HU24) + SR-03 (HU27) |
| **RF12** — *Notificación al fotógrafo de solicitud de descarga* | No aplica | Eliminada por **CC-03 / CCT-03** (reemplazada por descarga directa, CC-01) |
| **RF13** — QR de carga colaborativa con caducidad de 1 día | Cumplido | SR-03 (HU4, `qr_tokens` 24 h) |
| **RF14** — Invitados suben sin registro, sin ver ni descargar contenido | Cumplido | SR-03 (HU11, demo móvil "Tía Graciela") |
| **RF15** — Moderación con aprobación selectiva y purga a las 24 h | Cumplido | SR-03 (HU12) + CC-11 (worker automatizado) |
| **RF16** — Enlace permanente (sin caducidad) a una colección | Cumplido | SR-02 (HU17, token permanente) |
| **RF17** — Control de cuota de 3 GB con subida parcial notificando excedentes | Cumplido | SR-04 (HU16, demo con subida parcial) |
| **RF18** — Código de verificación al correo electrónico | Cumplido | SR-02 (HU21, `email_verificado`) |
| **RF19** — Crear y editar información de perfil de fotógrafos | Cumplido | SR-05 (HU18, directorio `GET /fotografos`) |
| **RF20** — Editar datos básicos o eliminar archivos subidos | Cumplido | SR-04 (HU6) + SR-05 (HU22) |
| **RF21** — Favoritos sobre colecciones públicas completas (privados para otros usuarios) | Cumplido | SR-05 (HU23) + `06-testing.md` (CC-15: 10 verificaciones OK) |
| **RF22** — *Selección visual para solicitud de descarga* | No aplica | Eliminada por **CC-03 / CCT-03** |
| **RF23** — *Notificación de resolución al usuario* | No aplica | Eliminada por **CC-03 / CCT-03** |
| **RF24** — Modal obligatorio de Términos y Política / Ley 18.331 en el primer login del fotógrafo | Cumplido | SR-02 (HU31, bloqueo hasta finalizar scroll) |
| **RF25** — Videos gestionados como clips/recortes con límite máximo por video | Cumplido | SR-04 (HU28, `MultimediaValidator` 800 MB) |
| **RF26** — Recorte automático de vista previa de video y conservación del original | Cumplido | SR-04 (HU32, FFmpeg `-t 15`) — criterios: 15 s, 800 MB/video, 30 MB/imagen (CC-27) |

### Requerimientos no funcionales

| Área / requerimiento | Estado | Evidencia |
| --- | --- | --- |
| **RNF1** — Interfaz adaptable a escritorio y dispositivos móviles | Cumplido con observación | Demos en red local desde móvil (SR-03); no existe prueba formal de responsive en `06-testing.md` |
| **RNF2** — Tiempo de respuesta menor a 3 s | Cumplido con observación | Evidencia parcial en demos: <2 s por imagen (SR-01), <1 s en descarga (SR-02); sin medición formal documentada |
| **RNF3** — Interfaz simple, rápida y formal | Cumplido | Evaluación cualitativa de las demos de SR-01 a SR-05 (sin métrica formal) |
| **RNF4** — Estabilidad del sistema durante el uso en entorno local | Cumplido con observación | 15 semanas de uso y pruebas E2E sin caídas; *observación:* Quality Gate de SonarQube en **ERROR** (`SAST-SonarQube-Reporte.md`) |
| **RNF5** — Respaldo automático diario de la base de datos | Cumplido | SR-05 (HU13, `cron-backup.php`) |
| **RNF6** — Rotación automática de las últimas 3 copias | Cumplido | SR-05 (HU13, demo de purga del respaldo más antiguo) |
| **RNF7** — Registro de fecha y hora de cada respaldo | Cumplido | SR-05 (HU13, tabla `backups`) |
| **RNF8** — Cumplimiento de la Ley 18.331 | Cumplido con observación | Modal HU31 + `03-seguridad.md` (Términos, PSI); *observación:* el consentimiento de clientes e invitados fue revertido por **CC-13 / CCT-13** — solo queda el del fotógrafo |
| **RNF9** — Términos y Condiciones y Política de Privacidad | Cumplido | `03-seguridad.md` (Términos y Condiciones + Políticas de Seguridad de la Información) |

**Resumen:** de 23 requerimientos funcionales, **23 cumplidos** (RF12, RF22 y RF23 fueron eliminados del alcance por CC-03 y no aplican); de 9 requerimientos no funcionales, **9 cumplidos**, 4 de ellos con observaciones menores detalladas arriba.

---

## Alcance excluido / pendiente para etapas futuras

### Excluido desde el inicio (primer versión) — `01-requerimientos.md` y `project_charter.md`

1. App móvil nativa.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Perfil público con acceso libre a todo el contenido privado del fotógrafo.
4. Métodos de pago reales con pasarelas bancarias (cobro ágil) — *restricción institucional UTU: equipo menor de edad*.
5. Hosting y dominio en producción (despliegue local para la evaluación de UTU).
6. Subida de videos directa a S3/Cloudflare con URLs firmadas y colas asíncronas.
7. Descarga masiva de archivos comprimidos (.zip) y selección múltiple (CC-02 / CCT-02).
8. Flujo de solicitudes y notificaciones de autorización de descarga entre cliente y fotógrafo (CC-01 / CCT-01).

### Postergado o pendiente durante el proyecto

- **Protección de los endpoints de administración `/sistema/*`** (`/sistema/backup`, `/sistema/backups`, `/sistema/limpiar-colaborativos`): actualmente públicos. Cambio a futuro documentado en [`03-seguridad.md`, sección 4.1 — Protección de endpoints de administración](03-seguridad.md#4-cambios-a-futuro-pendientes) (CC-14 / CF-08): exigir clave maestra `SISTEMA_API_KEY` o rol `admin` **antes de exponer el servicio**.
- **Defensa en profundidad en el frontend para colecciones privadas** (validación client-side y página de "acceso denegado"): [`implementaciones-futuras.md`, sección 1 — Protección de colecciones privadas](implementaciones-futuras.md#1-protección-de-colecciones-privadas-depende-exclusivamente-del-backend) (RF5/RF6, severidad baja).
- **Validación de formato por magic bytes en la capa moderna del frontend**: [`implementaciones-futuras.md`, sección 2 — Validación de formato por magic bytes](implementaciones-futuras.md#2-validación-de-formato-de-archivo-por-magic-bytes-en-el-frontend) (RF7/RF25; la capa legacy ya lo implementa como referencia).
- **HU15 — Capacitación final y entrega completa de la guía de uso**: registrada como **INCOMPLETO** en SR-05 (queda pendiente la entrega definitiva del manual y la capacitación al sponsor).
- **Aceptación formal del cliente**: aún no firmada (ver sección *Aceptación del cliente/sponsor*).
- **Deuda de calidad del análisis SAST**: 4 vulnerabilidades activas (CORS excesivamente permisivo, cookie de sesión sin `HttpOnly`, cookie sin `flag secure`, imagen Docker como usuario privilegiado), 6 bugs y cobertura de código nueva en 0% (Quality Gate en ERROR) — `SAST-SonarQube-Reporte.md`.
- **`05-planificacion.md`**: documento reservado y vacío (la planificación efectiva quedó registrada en [`01-requerimientos.md`, sección 20 — Product Backlog inicial](01-requerimientos.md#20-product-backlog-inicial) y `04_sprint_review.md`).

---

## Lecciones aprendidas (retrospectiva general)

| Lección | Explicación |
| --- | --- |
| La ausencia del cliente en las revisiones invalida la validación de alcance | En las cinco Sprint Reviews (SR-01 a SR-05) consta "Respuesta ausente: no fue posible contactar al cliente". El equipo demostró el incremento, pero nunca obtuvo feedback ni aceptación formal; el cierre quedó "entregado" y no "aceptado". Acción correctiva: agendar las cinco revisiones con el cliente al inicio del plan. |
| Las restricciones institucionales deben salir a la superficie en el charter | La restricción de UTU (equipo menor de edad: sin hosting ni pagos reales) postergó el eje "cobro ágil", que era la prioridad #1 del cliente. Se documentó tarde y obligó a reformular la visión del producto (CC-08). |
| Registrar los cambios de alcance en el momento, no al final | La bitácora llegó a 41 entradas (CC-01 a CC-41) más 35 cambios técnicos (CCT-01 a CCT-35), varias de ellas correcciones hechas días después de tomada la decisión. Lo que no se registra el mismo día se reconstruye con esfuerzo y queda expuesto en la defensa. |
| Estimar con margen sobre la velocidad real | Se planificó a 20 pts/sprint y se terminó a 18,2 pts/sprint: el plan original de 5 sprints de 20 pts era inalcanzable. La estimación por épicas y la redistribución en sprints de 16 y 15 pts salvaron el cronograma. |
| La configuración por defecto del entorno rompe la funcionalidad validada | `php.ini` rechazaba archivos >2 MB (CC-16) y `localStorage` explotaba con fotos >2 MB (CC-19) pese a que el backend ya admitía 30 MB/800 MB. Lección: auditar límites del runtime y del navegador antes de estimar una historia. |
| Las API de frontend no heredan la autorización del backend | Los `<img>/<video>` no envían el header `Authorization`, lo que rompió galerías y moderación en colecciones privadas (CC-21, CC-25). Cualquier recurso multimedia protegido debe descargarse vía `fetch` con token. |
| Verificar contra un estándar externo, no contra el propio código | El motor QR propio parecía correcto pero sus codewords Reed-Solomon no cumplían el estándar (CC-17): solo lo descubrió la comparación con un decodificador independiente (`jsqr`) y un generador de referencia. |
| La documentación interna se desvía del código si no se audita | `AUDITORIA_ENDPOINTS.md` citaba límites y formatos que el backend nunca aceptó (CC-28, CC-29). Una auditoría de documentación periódica evita contradicciones en la defensa. |
| Integrar el análisis estático desde el inicio | El SAST se corrió cerca del cierre y quedó con Quality Gate en ERROR (cobertura nueva 0%, duplicación 12,87%). Ejecutarlo por sprint habría permitido corregir vulnerabilidades con tiempo. |
| Documentar las reuniones es parte del trabajo, no un extra | `07-actas_de_reuniones.md` reconoce que "varias actas anteriores no fueron documentadas debido al descuido del equipo". Las decisiones que no quedan escritas no existen para el tribunal. |
| El uso de IA debe declararse y revisarse | `etica_uso_de_ia.md` deja constancia de las buenas prácticas y la transparencia en el uso de herramientas asistidas por IA durante el proyecto. |

---

## Aceptación del cliente/sponsor

> **Estado al cierre: ENTREGADO, SIN ACEPTACIÓN FORMAL FIRMADA.**
>
> **SR-05 (09/10/2026), Acuerdos y Cierre Formal del Proyecto:** *"Hasta la confirmación del cliente no se puede dar por cerrado este proyecto, pero se puede considerar entregado."*
>
> **[`01-requerimientos.md`, sección 17 — Aprobación del cliente](01-requerimientos.md#17-aprobación-del-cliente):** *"Pendiente de confirmación formal por parte del cliente. Se continúa con los sprints debido a que es un proyecto de egreso y esperar una respuesta atrasa las entregas formales de carpetas."*
>
> En las cinco Sprint Reviews (SR-01 a SR-05) consta la misma nota: *"Respuesta ausente: no fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación."*
>
> Criterio de éxito acordado con el cliente (entrevista / `project_charter.md`): *"Con que el fotógrafo pueda subir sus fotos sin problema, la página funcione y el cobro opere. El resto de las funciones puede irse sumando después."* — Para esta primera versión (sin cobro por restricción UTU) el criterio queda cumplido: subida, visualización, marca de agua y descarga operan en entorno local.

**Pendiente para cerrar formalmente:** firma o confirmación expresa de Lemuel Swec sobre la entrega realizada el 09/10/2026 (SR-05).

---

## Firmas / aprobación

| Rol | Nombre | Firma | Fecha |
| --- | --- | --- | --- |
| Cliente | Lemuel Swec | | |
| Líder / Frontend | Nicolás Negretto | | |
| Sublíder / Backend | Iván Sandoval | | |
| Frontend | Augusto Fernández | | |

---

## Documentos de respaldo (trazabilidad de este acta)

Todo lo afirmado en este documento se respalda con los archivos de `docs/`:

| Documento | Qué respalda en este acta |
| --- | --- |
| `README.md` | Índice y alcance de la documentación del proyecto |
| `project_charter.md` | Fecha de inicio, equipo, sponsor, alcance incluido/excluido, criterios de éxito, riesgos |
| `01-requerimientos.md` | RF/RNF ([sección 11 — Requerimientos funcionales](01-requerimientos.md#11-requerimientos-funcionales), [sección 12 — Requerimientos no funcionales](01-requerimientos.md#12-requerimientos-no-funcionales)), alcance excluido ([sección 10 — Alcance excluido](01-requerimientos.md#10-alcance-excluido-para-esta-primera-versión)), estimación de 91 pts y 5 sprints ([secciones 14–15](01-requerimientos.md#14-estimación-de-esfuerzo-plazo-y-costo)), backlog por sprint ([sección 20 — Product Backlog inicial](01-requerimientos.md#20-product-backlog-inicial)), aprobación pendiente del cliente ([sección 17 — Aprobación del cliente](01-requerimientos.md#17-aprobación-del-cliente)) |
| `02-modelado.md` | Arquitectura, modelo de datos y flujos que soportan los incrementos entregados |
| `03-seguridad.md` | RNF8/RNF9 (Ley 18.331, Términos y Condiciones, PSI) y el pendiente de protección de endpoints `/sistema/*` ([sección 4.1 — Protección de endpoints de administración](03-seguridad.md#4-cambios-a-futuro-pendientes)) |
| `04_sprint_review.md` | Resumen de sprints (SR-01 a SR-05), objetivos, puntos comprometidos/entregados, evidencia por HU y estado de aceptación del cliente |
| `05-planificacion.md` | Documento reservado, vacío (planificación efectiva en [sección 20 — Product Backlog inicial](01-requerimientos.md#20-product-backlog-inicial) de `01-requerimientos.md` y `04_sprint_review.md`) |
| `06-testing.md` | Evidencias de prueba de QR, favoritos, subida >2 MB, galerías privadas, calidades de descarga, moderación y respaldos |
| `07-actas_de_reuniones.md` | Acuerdos operativos del equipo (R-01 a R-03) y lección sobre la falta de actas |
| `08_control_de_cambios.md` | Decisiones de alcance CC-01 a CC-41 (eliminación de RF12/RF22/RF23, favoritos por colección, límites, formatos) |
| `09_control_de_cambios_tecnicos.md` | Cambios de implementación CCT-01 a CCT-35 (infraestructura, backend y frontend) |
| `infraestructura.md` | Stack Docker de 4 contenedores (app, worker, mailpit, db) entregado para escalabilidad |
| `guia_reconstruccion.md` | Procedimiento de reconstrucción y verificación del entorno (entrega técnica al cierre) |
| `implementaciones-futuras.md` | Pendientes de etapas futuras (defensa client-side, magic bytes) |
| `SAST-SonarQube-Reporte.md` | Último testing de calidad/seguridad y deuda de calidad remanente |
| `etica_uso_de_ia.md` | Declaración de uso ético y transparente de IA en el proyecto |
