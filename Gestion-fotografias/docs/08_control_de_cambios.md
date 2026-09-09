# 6. Control de Cambios

## ¿Para qué sirve este documento?

En Scrum es normal y esperable que el alcance se ajuste durante el proyecto: el
Product Backlog es flexible por diseño. Pero que sea flexible no significa que los
cambios queden sin registro. El control de cambios es una bitácora que deja constancia
de **qué cambió, por qué, quién lo pidió o lo detectó, y qué impacto tuvo** en alcance,
tiempo, costo o backlog.

Este documento es distinto del [Sprint Review](05_sprint_review.md): el Sprint Review
es el acta de la reunión donde surge el cambio; el control de cambios es el registro
consolidado y trazable de todas las decisiones de cambio del proyecto, sin importar su
origen (una reunión, un hallazgo técnico, un pedido fuera de sprint).

---

## Plantilla

| ID | Fecha | Origen | Descripción del cambio | Impacto | Decisión | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| CC-01 | | | | | | |

Donde:
- **Origen:** de dónde surge (Sprint Review N, pedido directo del cliente, hallazgo
  técnico del equipo, restricción externa, etc.)
- **Impacto:** en alcance (historias agregadas/quitadas), tiempo, costo o prioridades.
- **Decisión:** qué resolvió el equipo (aceptar, rechazar, postergar, dividir en fases).
- **Estado:** Propuesto / Aceptado / Rechazado / Aplicado / Postergado.

---

## Registro de Cambios del Proyecto

| ID | Fecha | Origen | Descripción del cambio | Impacto | Decisión | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| CC-01 | Refinamiento inicial | Decisión del equipo / Restricción UTU | Se reemplaza el flujo de autorización de descarga con notificación al fotógrafo por descarga directa en dos niveles de calidad ("Buena Calidad" y "Alta Calidad"). El cobro real queda para una fase posterior por la restricción de minoría de edad y métodos de pago de UTU. | Alcance: Se eliminan del alcance las notificaciones de solicitud y aprobación de descarga. Backlog: Se retiran HU9 (3 pts), HU29 (3 pts) y HU30 (3 pts). El esfuerzo total del backlog se reduce en 9 puntos (de 100 a 91 pts). | Aceptado: Se ajusta a descarga directa e inmediata para la primera versión. | Aplicado |
| CC-02 | Refinamiento inicial | Decisión del equipo | Se descarta la selección múltiple comprimida en archivo .zip en la funcionalidad de descarga (RF10 y HU10). | Alcance: RF10 y HU10 se acotan exclusivamente a la descarga directa e individual por archivo. Se simplifica el backend eliminando el empaquetado dinámico en .zip. | Aceptado: La descarga se gestionará individualmente archivo por archivo. | Aplicado |
| CC-03 | Refinamiento inicial | Decisión del equipo | Se eliminan los requerimientos concatenados a notificaciones y permisos de descarga: RF12 (notificación al fotógrafo), RF22 (modo de selección visual para solicitud) y RF23 (notificación de resolución al usuario). Se desvincula la referencia a RF22 en RF15 (moderación colaborativa). | Alcance: Se depura la épica EP5 (Visualización y descargas), pasando de 18 a 9 puntos asociados. El Product Backlog priorizado se reorganiza de forma correlativa (orden 1 a 29) sin saltos. | Aceptado: Eliminar registros de notificaciones de descarga en requerimientos, épicas y backlog. | Aplicado |
| CC-04 | Refinamiento inicial | Revisión interna del equipo | Corrección de ambigüedad crítica en la cita de la Ley 18.331 (se redactaba erróneamente "contra la protección de datos"), discordancias gramaticales, términos informales ("sub-líder", "métodos de pagos", "Fotografo") y referencias residuales a descargas "autorizadas". | Calidad documental: Mayor rigurosidad conceptual, legal y técnica para la defensa ante el tribunal de UTU. Sin impacto en puntos de historia. | Aceptado: Se aplican correcciones de estilo, coherencia y ortografía en `01-requerimientos.md`. | Aplicado |
| CC-05 | 2026-09-08 | Decisión técnica del equipo | Se reformula la historia de usuario HU18 en `01-requerimientos.md` (sección 19). Se acota el enunciado de "Como fotógrafo, quiero editar mi información de perfil profesional y figurar en el directorio general de descubrimiento y eventos públicos, para que nuevos clientes puedan encontrarme y contactarme." a "Como fotógrafo, quiero editar mi información de perfil, para tener siempre mis datos actualizados.", en línea con la remoción técnica del campo `especialidad` de la tabla `fotografos`. | Alcance: HU18 conserva sus 3 puntos y su vinculación a RF19 y a la épica EP2 (Perfiles de fotógrafos y directorio). Sin impacto en tiempo ni costo. | Aceptado: La edición de perfil se mantiene operativa (nombre usuario y teléfono). | Aplicado |
| CC-06 | 2026-09-09 | Revisión Technical Writer / Project Manager (solo cambios pequeños) | Correcciones ortográficas y de redacción en `01-requerimientos.md` sin cambio de significado: RF16 `rederigira` → `redirigirá`; RF24 doble espacio `los  Términos` → `los Términos`; RF25 `restriccion/maxima` → `restricción/máxima`; criterios RF26 `-La cantidad maxima...sera` → `- La cantidad máxima...será`; EP2 `Modificacion` → `Modificación`; §17 `Se continua` → `Se continúa`; HU14 `(en la coleccion) o otros` → `(en la colección) u otros`; backlog HU22 `coleccion` → `colección`; backlog HU23 `pública` → `públicos` (concordancia de género). | Calidad documental: sin impacto en alcance, tiempo, costo ni puntos de historia. | Aceptado: cambios pequeños permitidos sin aprobación previa. | Aplicado |
| CC-07 | 2026-09-09 | Revisión Technical Writer / Project Manager (auditoría Scrum y trazabilidad) | PROPUESTO - pendiente de aprobación: (A) Ambigüedades RNF2/RNF3/RNF4/RF9/RF7/RF25-RF26; (B) Exceso de especificidad RF6/RF9/RF15/EP4/HU `Como sistema`; (C-D) Contradicciones/trazabilidad (visión cobro ágil, charter, RF12, SR-04/SR-05, backlog HU22, RF11 duplicado, velocidad, 05/06 vacíos, enlaces README/ética, Reviews sin cliente). | Si se acepta: reformulación RF/RNF/HU/épicas y actualización de secundarios. Sin cambio de código. | Decisión 2026-09-09 del Product Owner: se aprueba solo B completo + C-visión (ver CC-08). El resto (A y resto de D) queda validado y aceptado como está, sin modificación. | Aceptado parcial |
| CC-08 | 2026-09-09 | Aprobación Product Owner (B + C-visión) | Cambios GRANDES autorizados y aplicados en `01-requerimientos.md`: (B1) RF6: se elimina `mediante lógica de backend`; (B2) RF9: se elimina `mediante una librería especializada`; (B3) RF15: se generaliza (se eliminan `modo de selección visual`, detalle en base de datos, texto literal del aviso y `tarea automática programada`, se conserva regla aprobar + eliminar tras 24h); (B4) EP4: se eliminan `FFmpeg (Docker)`, `Filesystem` y `15 segundos` (detalle en `02-modelado.md`/`infraestructura.md`); (B5) HU reformuladas a valor de usuario Scrum/INVEST: HU13/HU16/HU20/HU28 a `Como fotógrafo`, HU19/HU21/HU25 a `Como usuario nuevo`, HU32 a `Como usuario`, HU15 a `Como cliente` (sin `Lemuel Swec`); (C1) Visión §8: `cobro ágil... (Esto último...)` → `(El cobro ágil queda pospuesto a fase posterior por restricción UTU —menores sin pagos reales—, ver Decisiones técnicas)`. | Calidad/metodología Scrum: requerimientos en nivel general (QUÉ, no CÓMO), HU con actor de valor. Sin impacto en puntos (91 pts), tiempo ni código. | Aceptado y aplicado según autorización. Resto de CC-07 validado sin cambios. | Aplicado |
| CC-09 | 2026-09-09 | Pedido Product Owner (cambio pequeño) | Ajuste de redacción en `01-requerimientos.md` §8 Visión: `(El cobro ágil queda pospuesto a una fase posterior...)` → `(El cobro ágil queda pospuesto a una versión posterior...)`. | Calidad documental: sin impacto en alcance, tiempo, costo ni puntos. | Aceptado: cambio pequeño autorizado. | Aplicado |

> **Nota:** todo cambio con impacto en alcance, tiempo o costo debe quedar
> registrado aquí, aunque el equipo lo haya "resuelto" verbalmente en una reunión. Esto
> evita discusiones futuras sobre qué se acordó y por qué, y es evidencia concreta del
> trabajo de gestión del proyecto para la defensa final.
