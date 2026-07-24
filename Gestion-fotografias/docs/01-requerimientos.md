## 1. Información obtenida en la entrevista

| Categoría | Información relevada |
| --- | --- |
| Problema principal | Dificultad de entrega inmediata de material fotográfico y baja calidad de imagen. |
| Objetivo de negocio | Vínculo comercial comprador-vendedor y el cobro ágil sin intermediarios que retengan el dinero. |
| Alcance inicial | Subida y bajada de imágenes, métodos de pago, marca de agua. |
| Plazo esperado | |
| Presupuesto | Proyecto de UTU sin presupuesto. |
| Usuarios | Fotógrafos, clientes. |
| Infraestructura | Nube, alta disponibilidad, almacenamiento variable. |
| Seguridad | Cédula, nombre, teléfono, dirección, correo electrónico y políticas de privacidad. |
| Riesgo operativo | Caída del servidor, material de riesgo real y métodos de pago (esto mismo se tendrá en cuenta a futuro). |
| Restricción técnica | Las imágenes en vista previa deben tener marca de agua; la descarga autorizada no. |

> Información obtenida de la transcripción de la entrevista realizada con el cliente. Parte 1 de la entrevista: "https://turboscribe.ai/es/transcript/share/5521413143271206535/BAQ_YceRsNbt_qSbib6HglsceYdjERFhVwK3hj63kII/screen-recording-2026-07-10-112551", parte 2: "https://turboscribe.ai/es/transcript/share/5845672316447232238/SpD0uFbmbpp-LPeTqhBtjAwON_rYso_hrBSaekkgC_w/lv-0-20260710161346". Esta información se validó con la grabación de la entrevista, ya que la IA que transcribió la entrevista a veces confunde palabras y es necesario reescuchar el audio. Por tanto, se puede decir que esta información es válida, fiel y se puede utilizar para nuestro proyecto.

---

> “Restricción institucional (UTU): por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en entorno local para esta entrega, y se recomendará al cliente, una vez el equipo se gradúe, migrar el sistema de un servidor local a uno en la nube, adquiriendo hosting y dominio propio, y habilitando en ese momento un método de pago real.”

> “El rol "Administrador" de la propuesta por Polo se implementará bajo el alias comercial propuesto por el cliente como "Fotógrafo" y el rol "Cliente" abarcará a los compradores. Los invitados podrán acceder a la colección sin necesidad de ser un "Cliente" mediante el código QR dado por el "Fotógrafo".”

> “La propuesta por Polo que se repitió en reiteradas ocasiones en dicha propuesta queda omitida. La propuesta dice que si una colección con cero clientes asignados se volverá una colección pública, pero el cliente dijo lo contrario: el rol "Fotógrafo" decide si una colección es privada o pública, independientemente de si hay clientes asignados o no. Por tanto, decidimos marcar esta decisión del cliente entrevistado como prioritaria y obligatoria por encima de la propuesta por Polo.”

> “Exclusión de "dirección" en tabla Seguridad porque es una página 100% virtual y no es necesaria la dirección del usuario.”

---

## 2. Nombre propuesto del producto

**???**

Sistema web para fotógrafos y compradores que permite subir material fotográfico para ser comprado.

---

## 3. Visión del producto

Para fotógrafos y videógrafos que tienen dificultad para entregar su material de forma inmediata, profesional y sin perder calidad, ??? es una plataforma web que permitirá a fotógrafos subir, organizar y comercializar su material fotográfico, protegido con marca de agua, y a sus compradores visualizar, comprar y descargar ese contenido en buena calidad. A diferencia de WhatsApp o plataformas como Pixieset y Lumipick, nuestro producto combina protección del contenido, alta calidad de imagen y cobro ágil, sin demoras causadas por intermediarios que retienen el dinero. (Esto último se podrá implementar en un futuro por restricción de edad del equipo).

La primera versión será de subida y bajada de imágenes y videos, y marca de agua.

---

## 4. Alcance incluido

El proyecto incluirá:

1. Gestión de usuarios y roles.
2. Registro y verificación de usuarios.
3. Creación de perfiles de fotógrafo.
4. Creación de colecciones (públicas o privadas).
5. Subida de imágenes y videos en alta calidad.
6. Aplicación de marca de agua en la vista previa de las imágenes.
7. Restricción de descarga en el contenido no autorizado.
8. Visualización de imágenes en al menos dos niveles de calidad (alta calidad y calidad normal).
9. Descarga inmediata de imágenes.
10. Control de espacio de almacenamiento por usuario (la cantidad será propuesta por el cliente más adelante).
11. Políticas de privacidad y protección de datos.
12. Generación de un enlace o QR de acceso directo a una colección privada puntual, para que un comprador vea su sesión sin necesidad de buscar el perfil del fotógrafo.

---

## 5. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:

1. Una versión de app.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Integración con redes sociales.
4. Perfil público con acceso libre a todo el material del fotógrafo.
5. Métodos de pago.
6. Hosting/dominio.

---

## 6. Requerimientos funcionales

| Código | Requerimiento funcional |
| --- | --- |
| RF1 | El sistema debe permitir el registro obligatorio de usuarios (fotógrafos y clientes) solicitando nombre completo, cédula, correo electrónico y número de teléfono. |
| RF2 | El sistema debe impedir el registro de usuarios duplicados utilizando una misma cédula de identidad o un mismo correo electrónico ya existentes en la base de datos. |
| RF3 | El sistema debe proveer una pantalla de inicio de sesión (Login) segura. |
| RF4 | El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como públicas o privadas. |
| RF5 | Las colecciones marcadas como privadas no cambian por sí solas por la cantidad de clientes asignados y solo son visibles para los clientes que el fotógrafo asigne de manera explícita. |
| RF6 | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados. |
| RF7 | El sistema debe permitir al fotógrafo subir imágenes (JPG) y videos a su colección. |
| RF8 | Al subir una imagen, el sistema debe generar automáticamente una versión optimizada y más ligera para su visualización fluida en la galería del cliente (vista previa). |
| RF9 | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en su vista previa, y una protección equivalente sobre los videos (marca de agua superpuesta o restricción de descarga), para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga (protección en video: alcance a confirmar con el cliente). Se evaluó una restricción de captura de pantalla (mencionada por el cliente); se descarta por inviabilidad técnica en entorno web y se refuerza con marca de agua. |
| RF10 | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip). |
| RF11 | El sistema debe ofrecer al cliente dos opciones de descarga según los permisos otorgados por el fotógrafo: calidad normal (versión ligera y optimizada) y alta calidad (el archivo original sin pérdida de resolución subido por el fotógrafo). Este requerimiento fue adaptado a la restricción de no realizar métodos de pago, la cual fue una restricción de la UTU. |
| RF12 | El sistema debe permitir al fotógrafo activar o desactivar manualmente el permiso de descarga en "alta calidad" para clientes específicos dentro de una colección privada. |
| RF13 | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica de un evento, para que los invitados puedan subir contenido de forma colaborativa durante el evento. |
| RF14 | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo. |
| RF15 | El fotógrafo debe poder visualizar y gestionar (ocultar o eliminar) todo el material multimedia colaborativo subido por los invitados mediante el QR. |
| RF16 | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo a una colección privada específica, distinto del QR de carga colaborativa. |
| RF17 | El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada (la cantidad será propuesta por el cliente más adelante), permitiendo igualmente la descarga del contenido ya existente. |
| RF18 | El sistema debe enviar un código de verificación al correo o teléfono para asegurar que realmente exista. |
| RF19 | El sistema debe permitir editar la información de perfil de los fotógrafos. |
| RF20 | El sistema debe permitir al fotógrafo modificar los datos básicos de una imagen o video ya subido (título, descripción o colección) sin necesidad de volver a subir el archivo. |
| RF21 | El sistema debe permitir al cliente marcar y desmarcar como favorita cualquier imagen perteneciente a una colección a la que tenga acceso autorizado, sin exponer esta información a otros usuarios. |
| RF22 | El sistema debe registrar cada descarga (usuario, imagen o colección, fecha/hora, cantidad de archivos), permitiendo al cliente consultar su propio historial y al fotógrafo consultar estadísticas agregadas de sus colecciones. |

---

## 7. Requerimientos no funcionales

| Código | Requerimiento no funcional |
| --- | --- |
| RNF1 | La interfaz de usuario debe ser completamente adaptable (Responsive) para asegurar una experiencia de usuario óptima tanto en computadoras de escritorio como en dispositivos móviles (smartphones y tablets). |
| RNF2 | Las páginas del portal de clientes y las galerías deben cargar en un tiempo óptimo. |
| RNF3 | La interfaz de la página web debe ser simple, rápida y formal. |
| RNF4 | El sistema debe asegurar la estabilidad de la página para soportar el uso constante de esta misma mientras se ejecuta en entornos de pruebas en el entorno local (pensar en estabilidad para un posible hosting en un futuro). |
| RNF5 | El sistema debe realizar respaldos automáticos diarios (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |
| RNF6 | El sistema debe eliminar de manera automática el respaldo más antiguo si ya hay tres a disposición (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |
| RNF7 | El sistema debe registrar fecha y hora para cada respaldo diario (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |

---

## 8. Épicas del proyecto

| Código | Épica | Descripción |
| --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles y políticas de privacidad. |
| EP2 | Perfiles de fotógrafos | Creación, edición y administración de los perfiles profesionales de los fotógrafos. |
| EP3 | Gestión de colecciones | Creación, categorización (públicas/privadas) y control de acceso por URL a colecciones de fotos. |
| EP4 | Carga y procesamiento multimedia | Subida de imágenes de alta calidad, generación de vistas previas optimizadas y aplicación de marcas de agua. |
| EP5 | Visualización y descargas | Galería de previsualización para clientes, control de calidad de descarga y bajada de imágenes (individual o en .zip). |
| EP6 | Carga colaborativa por QR | Generación de códigos QR para eventos, subida rápida de fotos por invitados y moderación/gestión posterior del material por parte del fotógrafo (ocultar o eliminar). |
| EP7 | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría. |
| EP8 | Capacitación y cierre | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU. |

---

## 9. Estimación de esfuerzo, plazo y costo

## Criterio didáctico de estimación

Para simplificar la explicación, vamos a utilizar una estimación basada en puntos de historia (story points).

En este ejemplo:

- 1 punto representa una tarea muy pequeña.
- 3 puntos representan una tarea simple pero con cierta lógica.
- 5 puntos representan una tarea media.
- 8 puntos representan una tarea compleja.
- 13 puntos representan una tarea grande o riesgosa.

Se asumirá una velocidad promedio del equipo de **29 puntos por sprint**.
Cada sprint tendrá una duración de **3 semanas**.
El proyecto tendrá **5 sprints**, por lo tanto, la duración total estimada será de **15 semanas**.

---

## 10. Estimación por épica

| Código | Épica | Estimación en puntos | Historias asociadas |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | 25 | HU1, HU8, HU19, HU21, HU25 |
| EP2 | Perfiles de fotógrafos | 5 | HU18 |
| EP3 | Gestión de colecciones | 18 | HU2, HU3, HU20 |
| EP4 | Carga y procesamiento multimedia | 31 | HU5, HU6, HU14, HU16, HU23 |
| EP5 | Visualización y descarga | 18 | HU9, HU10, HU22, HU24 |
| EP6 | Carga colaborativa por QR | 28 | HU4, HU7, HU11, HU12, HU17 |
| EP7 | Mantenimiento técnico y respaldo | 8 | HU13 |
| EP8 | Capacitación y cierre | 3 | HU15 |
| **Total** | | **136 puntos** | |

---

## 11. Propuesta presentada al cliente

El equipo presenta la siguiente propuesta:

| Elemento | Propuesta |
| --- | --- |
| Producto | ???, sistema web para fotógrafos. |
| Duración | 15 semanas. |
| Metodología | Scrum, con 5 sprints de 3 semanas. |
| Entregas | Incremento funcional al final de cada sprint. |
| Presupuesto | Proyecto de Egreso, por lo tanto no habrá presupuesto asignado. |
| Forma de trabajo | Revisión con el cliente al cierre de cada sprint. |
| Primera versión | Subida y bajada de imágenes/videos, marca de agua. |
| Exclusiones | App móvil nativa, integración con redes sociales, perfil público con acceso libre a todo el material del fotógrafo, métodos de pago, hosting/dominio. |

---

## 12. Aprobación del cliente

Luego de revisar la propuesta, el cliente responde:

> “Pendiente de confirmación formal por parte del cliente. Se espera su respuesta en los próximos días para proceder con el detalle de sprints.”

---

## 13. Formato de historia de usuario

Se utilizará el siguiente formato:

> Como **[tipo de usuario]**, quiero **[acción o necesidad]**, para **[beneficio o resultado esperado]**.

---

## 14. Historias de usuario iniciales

| ID | Historia de usuario | Puntos | Prioridad |
| --- | --- | --- | --- |
| HU1 | Como usuario, quiero iniciar sesión en el sistema, para acceder de forma segura a mi panel según mi rol. | 5 | Alta |
| HU2 | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública), para controlar quién puede acceder a cada una. | 5 | Alta |
| HU3 | Como fotógrafo, quiero autorizar de forma explícita a un cliente mediante sus datos principales para que acceda a una colección privada. | 5 | Alta |
| HU4 | Como fotógrafo, quiero generar un código QR único para una colección permitiendo a todos los que accedan mediante este código QR permiso para subir imágenes o videos, para utilizarlo de manera presencial en mis eventos laborales. | 8 | Media |
| HU5 | Como fotógrafo, quiero subir imágenes (JPG) y videos a mi colección, para ponerlas a disposición de mis clientes. | 5 | Alta |
| HU6 | Como fotógrafo, quiero eliminar imágenes o videos de una colección, para mantener el control sobre el contenido publicado. | 5 | Alta |
| HU7 | Como fotógrafo, quiero descargar el código QR generado para poder imprimirlo físicamente y exponerlo en el evento. | 5 | Media |
| HU8 | Como usuario nuevo, quiero poder elegir si registrarme como fotógrafo o como cliente, para acceder a las funciones correctas del sistema. | 5 | Alta |
| HU9 | Como fotógrafo, quiero habilitar o deshabilitar manualmente el permiso de descarga en "alta calidad" para un cliente específico, para controlar la entrega final del material. | 5 | Alta |
| HU10 | Como cliente autorizado, quiero descargar mis fotos de forma individual o en un archivo comprimido (.zip), para obtener mi material de manera ágil. | 3 | Media |
| HU11 | Como invitado de un evento, quiero escanear el código QR para subir directamente mis fotos y videos a la colección sin necesidad de crearme una cuenta compleja. | 5 | Media |
| HU12 | Como fotógrafo, quiero visualizar y gestionar (ocultar o eliminar) el material subido por invitados para tener un control sobre la colección. | 5 | Media |
| HU13 | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. | 8 | Media |
| HU14 | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para poder previsualizar el trabajo antes de descargarlo en alta calidad. | 8 | Alta |
| HU15 | Como fotógrafo/cliente, quiero contar con una guía básica de uso y recibir una breve capacitación sobre la plataforma, para poder utilizarla de forma autónoma una vez finalizado el proyecto. | 3 | Media |
| HU16 | Como sistema, quiero impedir al fotógrafo subir imágenes o videos si supera la cuota de almacenamiento, para no sobrecargar el espacio en el sistema de archivos. | 8 | Media |
| HU17 | Como fotógrafo, quiero generar un código QR único de una colección, para permitir la visualización y descarga de las imágenes (según los permisos habilitados) de la colección, sin necesidad de buscar mi perfil. | 5 | Media |
| HU18 | Como fotógrafo, quiero editar mi información de perfil y contacto comercial, para que los clientes me reconozcan. | 5 | Media |
| HU19 | Como sistema, quiero impedir el registro de usuarios duplicados utilizando una misma cédula de identidad o un mismo correo electrónico ya existentes, para que exista solo una única cuenta. | 5 | Media |
| HU20 | Como sistema, quiero impedir cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados, para mantener el orden. | 8 | Media |
| HU21 | Como sistema, quiero enviar un código de verificación al correo o teléfono, para asegurar si ese correo o teléfono realmente pertenece a esa persona. | 5 | Media |
| HU22 | Como fotógrafo, quiero consultar estadísticas de descargas de mis colecciones, incluyendo las imágenes más descargadas, para entender qué contenido le interesa más a mis clientes. | 5 | Media |
| HU23 | Como fotógrafo, quiero editar los datos básicos (título, descripción) de una imagen o video ya subido, para no tener que subirlo de nuevo para cambiar los datos básicos. | 5 | Media |
| HU24 | Como usuario, quiero marcar como favorita una imagen o video de una colección a la que tenga autorización, para tener una lista de favoritos. | 5 | Media |
| HU25 | Como sistema, quiero que cada usuario, independientemente de si es Fotógrafo o Cliente, tenga que registrarse con su nombre completo, cédula, correo electrónico y número de teléfono, para identificar quién es. | 5 | Media |

---

## 15. Product Backlog inicial

## Backlog priorizado, balanceado y enfocado en MVP

| Orden | ID | Historia | Puntos | Sprint estimado |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU1 | Inicio de sesión básico (acceso a paneles) | 5 | Sprint 1 |
| 2 | HU2 | Creación de colecciones y clasificación de visibilidad | 5 | Sprint 1 |
| 3 | HU5 | Subida de imágenes o videos a colecciones | 5 | Sprint 1 |
| 4 | HU10 | Descarga individual o comprimida (.zip) | 3 | Sprint 1 |
| 5 | HU14 | Visualización con marca de agua automática | 8 | Sprint 1 |
| 6 | HU3 | Autorización manual de clientes a colecciones | 5 | Sprint 2 |
| 7 | HU8 | Registro con selección de rol (Fotógrafo / Cliente) | 5 | Sprint 2 |
| 8 | HU25 | Registro obligatorio de campos y datos básicos | 5 | Sprint 2 |
| 9 | HU19 | Impedir el registro de usuarios duplicados | 5 | Sprint 2 |
| 10 | HU21 | Envío de código de verificación al correo/teléfono | 5 | Sprint 2 |
| 11 | HU18 | Edición de información del perfil del fotógrafo | 5 | Sprint 2 |
| 12 | HU20 | Bloqueo de acceso directo por URL a privadas | 8 | Sprint 3 |
| 13 | HU17 | Código QR único para visualización/descarga directa | 5 | Sprint 3 |
| 14 | HU4 | Código QR único para subida (Eventos) | 8 | Sprint 3 |
| 15 | HU7 | Descarga e impresión física del código QR | 5 | Sprint 3 |
| 16 | HU23 | Edición de datos básicos de un archivo ya subido | 5 | Sprint 3 |
| 17 | HU11 | Carga de archivos vía QR por invitados (sin cuenta) | 5 | Sprint 4 |
| 18 | HU12 | Moderación de material de invitados (ocultar/eliminar) | 5 | Sprint 4 |
| 19 | HU6 | Eliminación regular de imágenes o videos | 5 | Sprint 4 |
| 20 | HU9 | Habilitación manual del permiso de "alta calidad" | 5 | Sprint 4 |
| 21 | HU16 | Restricción por superación de la cuota de espacio | 8 | Sprint 4 |
| 22 | HU24 | Marcar como favorita una imagen o video | 5 | Sprint 5 |
| 23 | HU22 | Consultar estadísticas agregadas de descargas (Fotógrafo) | 5 | Sprint 5 |
| 24 | HU13 | Respaldo automático diario de base de datos (3 copias) | 8 | Sprint 5 |
| 25 | HU15 | Entrega de guía de uso, capacitación y cierre | 3 | Sprint 5 |                                                      
