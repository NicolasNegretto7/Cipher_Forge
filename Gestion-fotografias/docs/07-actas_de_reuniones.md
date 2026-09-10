## Plantilla

| ID | Fecha | Modalidad | Asistentes | Temas tratados | Temas pendientes | Acuerdos | Desacuerdos |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R-01 | | Presencial / Virtual | | | | | |

Donde:
- **Modalidad:** presencial, virtual o mixta.
- **Asistentes:** integrantes del equipo presentes y, si corresponde, referente/cliente
  o docente.
- **Temas tratados:** puntos discutidos en la reunión.
- **Temas pendientes:** puntos que quedaron sin resolver y deben retomarse en una
  próxima reunión.
- **Acuerdos:** decisiones tomadas en conjunto.
- **Desacuerdos:** puntos donde no hubo consenso, dejando registro de las distintas
  posturas (no es necesario resolverlos en el acta, pero sí registrarlos).

---

## Desarrollo

| ID | Fecha | Modalidad | Asistentes | Temas tratados | Temas pendientes | Acuerdos | Desacuerdos |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R-01 | Inicio de proyecto | Presencial | Equipo completo | Relevamiento de la idea inicial del cliente y primeras preguntas para la entrevista. | Confirmar fecha de entrevista con el cliente. | Se define agenda de entrevista y roles del equipo. | — |
| R-02 | Post-entrevista | Presencial | Equipo completo | Puesta en común de lo relevado en la entrevista con el sponsor. | Redacción del Project Charter. | Se define alcance inicial y prioridades del cliente. | No se coincidían requerimientos en el grupo por la falta de información del cliente, se resolvió descartando ideas del cliente que no eran necesarias o por permisos fuera de alcance para realizarlos|
| R-03 | 2026-08-30 | Presencial | Equipo completo | Reversión de consentimiento Ley 18.331 (CF-15), ajuste de límites de subida PHP (CF-NUEVO), redefinición de favoritos a colecciones (CC-15) y seguridad de endpoints del sistema (CF-08). | Definir e implementar el mecanismo de autenticación con clave maestra (`SISTEMA_API_KEY`) para endpoints de sistema. | 1. Se revierte íntegramente el consentimiento en registro de clientes y fotos colaborativas (mantiene solo modal HU31 de fotógrafos).<br>2. Se amplían los límites de subida en `php.ini` a 900M/1G para fotos y videos.<br>3. Se acota la funcionalidad de favoritos exclusivamente a colecciones públicas completas (se actualizan requerimientos, backlog y modelo).<br>4. Se posterga la seguridad en endpoints del sistema (`/sistema/backup`), documentándolo como cambio a futuro. | — |