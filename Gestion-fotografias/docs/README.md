# Documentación del Proyecto Cipher_Forge

Índice central de la documentación técnica, de gestión y de arquitectura para la plataforma web de gestión y comercialización fotográfica (**Proyecto de Egreso UTU**).

---

## Estructura Documental

| Documento | Descripción y Alcance |
| :--- | :--- |
| [01-requerimientos.md](01-requerimientos.md) | **Análisis de requerimientos:** Relevamiento inicial, transcripción de entrevista con el cliente (Lemuel Swec), alcance, requerimientos funcionales (RF) y no funcionales (RNF), épicas y Product Backlog priorizado. |
| [02-modelado.md](02-modelado.md) | **Arquitectura propuesta y Justificación tecnológica:** Diagrama de arquitectura en capas (Layered), estado de implementación por entorno y diagrama de despliegue (LOCAL Windows / Server Ubuntu / PRODUCCIÓN), diagramas de secuencia de subida y descarga directa, diagrama entidad-relación (DER/ERD) y matriz de justificación tecnológica. |
| [03-seguridad.md](03-seguridad.md) | **Seguridad y Modelado de Amenazas:** Análisis STRIDE, vectores de ataque OWASP Top 10, políticas de protección de datos personales (Ley 18.331) y controles implementados. |
| [04_sprint_review.md](04_sprint_review.md) | **Actas de Sprint Review:** Marco metodológico Scrum, plantilla oficial para revisiones con el cliente y actas desarrolladas SR-01 a SR-05. |
| [05-planificacion.md](05-planificacion.md) | **Planificación:** Documento reservado para planificación de sprints (actualmente vacío). |
| [06-testing.md](06-testing.md) | **Pruebas y Verificación:** Verificación del motor QR nativo, favoritos por colección, subida de archivos >2 MB, galería de colecciones privadas, moderación colaborativa, calidad de descarga en dos niveles, "Mis colecciones" persistente y posters de video. |
| [07-actas_de_reuniones.md](07-actas_de_reuniones.md) | **Actas de Reuniones Generales:** Registro de minutas internas de equipo y acuerdos operativos (R-01, R-02, etc.). |
| [08_control_de_cambios.md](08_control_de_cambios.md) | **Control de Cambios:** Bitácora formal de modificaciones de alcance, impacto en backlog y decisiones de equipo (CC-01 a CC-41). |
| [09_control_de_cambios_tecnicos.md](09_control_de_cambios_tecnicos.md) | **Control de Cambios Técnicos:** Registro de cambios tecnológicos, de implementación e infraestructura realizados durante el desarrollo (CCT-01 a CCT-35). |
| [10-acta_de_cierre.md](10-acta_de_cierre.md) | **Acta de Cierre:** Documento de cierre del proyecto: resumen de sprints, requerimientos cumplidos y no aplicables, pendientes, lecciones aprendidas y aceptación del cliente. |
| [infraestructura.md](infraestructura.md) | **Documentación de Infraestructura:** Análisis técnico del `Dockerfile`, `docker-compose.yml` (LOCAL Windows y Server Ubuntu), esquemas SQL y mecanismos de respaldo. |
| [guia_reconstruccion.md](guia_reconstruccion.md) | **Guía de Reconstrucción:** Manual descriptivo paso a paso para levantar y reconstruir el entorno completo de contenedores desde cero. Incluye el entorno local Windows, la preparación de producción y la reconstrucción en Server Ubuntu. |
| [manual-migracion-serverubuntu.md](manual-migracion-serverubuntu.md) | **Manual de migración a Server Ubuntu:** Runbook completo para mover el stack desde Windows + Docker Desktop a Ubuntu Server, conservar base de datos, fotos y respaldos, configurar Nginx/VirtualBox NAT y validar el QR desde el celular. |
| [manual-de-usuario.md](manual-de-usuario.md) | **Manual de usuario:** Guía para levantar los servidores y desplegar la página web en internet, desde el `.zip` del proyecto hasta la funcionalidad completa del sitio. *(Documento en preparación).* |
| [project_charter.md](project_charter.md) | **Project Charter:** Acta de constitución del proyecto, justificación de negocio, sponsors, riesgos preliminares y visión. |
| [etica_uso_de_ia.md](etica_uso_de_ia.md) | **Ética y Uso de IA:** Declaración de buenas prácticas y transparencia en el uso de herramientas asistidas por inteligencia artificial. |
| [SAST-SonarQube-Reporte.md](SAST-SonarQube-Reporte.md) | **Reporte SAST (SonarQube):** Análisis estático de seguridad y calidad de código: vulnerabilidades, bugs, code smells y deuda técnica remanente. |
| [implementaciones-futuras.md](implementaciones-futuras.md) | **Implementaciones Futuras:** Hallazgos, riesgos y oportunidades de mejora identificados para futuras iteraciones. |
