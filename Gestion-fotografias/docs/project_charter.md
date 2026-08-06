## Project Charter (Acta de Constitución del Proyecto)

**Nombre del proyecto:** [Nombre de la página web] — Plataforma web para fotógrafos y compradores de material fotográfico

**Cliente / patrocinador (sponsor):** Lemuel Swec

**Director del proyecto / Scrum Master:** Nicolás Negretto

**Equipo:** Nicolás Negretto (Líder / Scrum Master), Iván Sandoval (sub-líder), Augusto Fernández (desarrollador)

**Fecha de inicio:** 26/6/2026

**Duración estimada:** 15 semanas (5 sprints de 3 semanas, velocidad promedio: ~20 pts/sprint, 100 puntos de historia totales)

---

**Situación inicial del cliente:**
Fotógrafo/videógrafo independiente de eventos (bodas, fiestas de 15 años y similares). Actualmente entrega material por WhatsApp con pérdida notoria de calidad y sin protección del contenido, o por plataformas de terceros (Pixieset, Lumepic) que cobran comisión (aprox. 20%) y demoran la liquidación al fotógrafo. No cuenta con una solución que combine protección del contenido, alta calidad de imagen y cobro ágil sin intermediarios.

**Necesidad planteada por el cliente:**
> "La idea de este proyecto es crear un vínculo entre el consumidor y el vendedor: una plataforma con capacidad para alojar material gráfico. El problema es que hoy se entrega mucho por WhatsApp, y WhatsApp te salva la vida, pero no es una forma profesional de hacerlo; además, pixela demasiado la imagen. Y una vez que la persona ya tiene la copia, el fotógrafo pierde toda forma de exigir que le paguen lo justo. Quiero que haya una interacción real entre comprador y vendedor, como una librería del material, con marca de agua y restricciones para descargar o hacer captura de pantalla, y que a la vez se pueda comercializar sin depender de intermediarios que retengan la plata, como pasa en otras plataformas."

El cliente agrega que no hace falta que la primera versión resuelva todo: pide priorizar, como mínimo, la subida y bajada de imágenes y videos, la marca de agua, y el tema del cobro.

**Objetivo del proyecto:**
Desarrollar una plataforma web que permita a fotógrafos subir, organizar y proteger su material fotográfico con marca de agua, y a sus compradores visualizar, solicitar descarga y obtener ese contenido en dos niveles de calidad (buena calidad y alta calidad), integrando carga colaborativa por QR para eventos y directorio de fotógrafos para descubrimiento.

**Justificación del proyecto:**
Los fotógrafos uruguayos carecen de una herramienta que combine tres necesidades simultáneas: entrega profesional sin pérdida de calidad, protección efectiva del contenido (marca de agua, restricción de descarga) y vínculo comercial directo comprador-vendedor sin intermediarios que retengan comisiones. WhatsApp degrada la calidad y elimina el control; Pixieset/Lumepic cobran comisión y demoran la liquidación.

**Visión del producto:**
Para fotógrafos y videógrafos que tienen dificultad para entregar su material de forma inmediata, profesional y sin perder calidad, [Nombre de la página web] es una plataforma web que permitirá a fotógrafos subir, organizar y comercializar su material fotográfico, protegido con marca de agua, y a sus compradores visualizar, comprar y descargar ese contenido en dos niveles de calidad (buena calidad y alta calidad). A diferencia de WhatsApp o plataformas como Pixieset y Lumepic, nuestro producto combina protección del contenido, alta calidad de imagen y cobro ágil, sin demoras causadas por intermediarios que retienen el dinero. (Esto último se podrá implementar en un futuro por restricción de edad del equipo).

La primera versión será de subida y bajada de imágenes y videos, y marca de agua.

---

**Alcance incluido:**
1. Gestión de usuarios y roles (Fotógrafo y Cliente), con registro e inicio de sesión seguro.
2. Verificación de correo electrónico y aceptación obligatoria de políticas de privacidad / Ley 18.331.
3. Creación y edición de perfiles profesionales de fotógrafo, con inclusión en un directorio general de descubrimiento y eventos.
4. Creación de colecciones (públicas o privadas) con soporte de hashtags para las públicas.
5. Subida de imágenes (JPG) y videos con procesamiento en backend mediante FFmpeg (Docker) para generar un recorte de 15 segundos en la vista previa y almacenar el archivo completo en Filesystem (límite de 800MB por video original), marca de agua automática en imágenes y control de cuotas.
6. Aplicación de marca de agua en la vista previa de las imágenes mediante librería especializada.
7. Restricción de descarga en el contenido no autorizado.
8. Visualización de imágenes en colecciones públicas/privadas y solicitud de descarga en dos niveles de calidad (buena calidad y alta calidad) mediante notificación al fotógrafo, con modo de selección múltiple visual.
9. Descarga inmediata de imágenes autorizadas (individual o en .zip) con notificación de aceptación al usuario.
10. Control de espacio de almacenamiento por usuario (cuota inicial de 3 GB) con manejo de subidas parciales ante exceso de cuota.
11. Generación de un código QR de carga colaborativa para eventos con caducidad de 1 día, permitiendo a invitados subir contenido sin registro complejo, pudiendo ingresar de forma anónima.
12. Generación de un enlace o QR de acceso directo permanente a una colección específica para visualización y descarga de clientes.
13. Moderación y gestión (modificación de datos, reasignación o eliminación) por parte del fotógrafo sobre el contenido de sus colecciones y el material aportado por invitados.
14. Sistema de favoritos sobre colecciones públicas y filtrado de colecciones públicas por hashtags.
15. Respaldos automáticos diarios de la base de datos con rotación de las últimas tres copias.

**Alcance excluido de esta primera versión:**
1. Una versión de app móvil nativa.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Perfil público con acceso libre a todo el contenido privado del fotógrafo.
4. Métodos de pago reales con pasarelas bancarias.
5. Hosting/dominio en producción (despliegue local para evaluación de UTU).
6. Subida de videos directa a S3/Cloudflare con URLs firmadas con colas asíncronas.

---

**Stakeholders principales:**

| Rol | Persona / referente | Responsabilidad |
| --- | --- | --- |
| Cliente | Lemuel Swec | Describe el problema, valida alcance y prioridades, aprueba decisiones sobre roles y visibilidad de colecciones |
| Líder / Desarrollador | Nicolás Negretto | Desarrollo frontend, valida la documentación |
| Sub-líder / Desarrollador | Iván Sandoval | Desarrollo backend, transcripción y documentación de la entrevista |
| Desarrollador | Augusto Fernández | Desarrollo frontend, documentación de la entrevista, protecciones de seguridad |

**Riesgos iniciales:**

| Riesgo | Impacto posible |
| --- | --- |
| Falta de experiencia del equipo en PHP, JavaScript y FFmpeg | Retraso en la implementación de módulos complejos (marca de agua, procesamiento de video, QR) |
| Restricción institucional (UTU): equipo menor de edad | Imposibilidad de contratar hosting, dominio o pasarela de pago real; sistema limitado a entorno local |
| Caída del servidor durante pruebas o evaluación | Pérdida de datos de prueba y tiempo de trabajo; mitigado con respaldos automáticos|
| Material de riesgo legal (fotos sin autorización) | Responsabilidad legal del fotógrafo; mitigado con política de privacidad obligatoria y Ley 18.331 |
| Pérdida de respaldos o archivos multimedia | Pérdida irrecuperable de material del fotógrafo; mitigado con rotación de 3 copias en la base de datos |

**Plazo y metodología:**
Scrum, 5 sprints de 3 semanas (15 semanas totales), velocidad promedio de ~20 puntos por sprint, con revisión del incremento junto al cliente al final de cada sprint.

**Presupuesto / esfuerzo estimado:**
No hay presupuesto financiero por tratarse de un Proyecto de Egreso de UTU. Esfuerzo estimado: 100 puntos de historia distribuidos en 5 sprints.

**Criterios de éxito:**
> "Con que el fotógrafo pueda subir sus fotos sin problema, que la página y que el cobro funcione. El resto de las funciones puede irse sumando después."
>
> — Lemuel Swec (entrevista con el cliente)

Para la primera versión (sin cobro por restricción UTU): que el fotógrafo pueda subir material protegido con marca de agua, que el cliente pueda visualizar y solicitar descargas, y que la plataforma sea estable durante las pruebas en entorno local.
