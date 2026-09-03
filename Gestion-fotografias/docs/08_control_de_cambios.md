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

> **Nota:** todo cambio con impacto en alcance, tiempo o costo debe quedar
> registrado aquí, aunque el equipo lo haya "resuelto" verbalmente en una reunión. Esto
> evita discusiones futuras sobre qué se acordó y por qué, y es evidencia concreta del
> trabajo de gestión del proyecto para la defensa final.
