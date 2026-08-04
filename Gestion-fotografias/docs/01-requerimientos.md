# Proyecto de Egreso UTU – Enfoque Scrum: Plataforma web para fotógrafos y compradores de material fotográfico

---

# Parte 1: Concepción del proyecto

## 1. Situación inicial del cliente

**Nombre del emprendimiento/estudio:** no especificado (el cliente no menciona una marca propia).\
**Cliente:** Lemuel Swec\
**Rubro:** Fotografía y videografía de eventos (bodas/casamientos, fiestas de 15 años y similares)\
**Ubicación:** No especificado para una única ubicación, se toma en cuenta que es una aplicación web con alcance para cualquier parte del mundo.\
**Tamaño:** fotógrafo/a independiente; el sistema se concibe como una plataforma multi-fotógrafo (varios vendedores), no solo para uso del entrevistado\
**Producción:** fotografías (JPG, sin necesidad de RAW) y videos de eventos, destinados a la venta directa a compradores\
**Nivel tecnológico actual:** medio; el cliente mencionó herramientas como Pixieset o Lumepic para publicar/entregar material, pero ninguna resuelve a la vez calidad de imagen, protección del contenido y cobro ágil\
**Registro actual:** entrega por WhatsApp (con pérdida notoria de calidad y sin protección del contenido) o por plataformas de terceros que cobran comisión y demoran la liquidación al fotógrafo.

> Debido a que el cliente no proporciono una respuesta exacta y tampoco el equipo de desarrollo tiene una respuesta de su parte; el equipo decidio dedicar esta pagina web para Uruguay implementando la ley 18.331 contra la proteccion de datos. Y se le informara al cliente de dicha decision cuando concuerde la fecha de la proxima entrevista.

---

## 2. Necesidad puntual presentada por el cliente

El cliente plantea la necesidad al equipo de desarrollo desde el inicio de la entrevista. *(Síntesis basada en el contenido real de la transcripción.)*

> "La idea de este proyecto es crear un vínculo entre el consumidor y el vendedor: una plataforma con capacidad para alojar material gráfico. El problema es que hoy se entrega mucho por WhatsApp, y WhatsApp te salva la vida, pero no es una forma profesional de hacerlo; además, pixela demasiado la imagen. Y una vez que la persona ya tiene la copia, el fotógrafo pierde toda forma de exigir que le paguen lo justo. Quiero que haya una interacción real entre comprador y vendedor, como una librería del material, con marca de agua y restricciones para descargar o hacer captura de pantalla, y que a la vez se pueda comercializar sin depender de intermediarios que retengan la plata, como pasa en otras plataformas."

El cliente agrega que no hace falta que la primera versión resuelva todo: pide priorizar, como mínimo, la subida y bajada de imágenes y videos, la marca de agua, y el tema del cobro.

---

## 3. Primer análisis del equipo de desarrollo

Antes de entrevistar al cliente, el equipo identifica que la solicitud contiene varias áreas que deben aclararse:

| Área a aclarar | Preguntas iniciales del equipo |
| --- | --- |
| Usuarios y roles | ¿Quiénes usarán el sistema? ¿Cómo se diferencian fotógrafos, compradores e invitados a un evento? |
| Colecciones | ¿Qué es una "colección" para el cliente? ¿Quién decide si es pública o privada? |
| Contenido multimedia | ¿Qué tipo de archivos se suben (fotos, videos)? ¿En qué calidad? |
| Almacenamiento | ¿Existe un límite de espacio por usuario? ¿Qué ocurre si se supera? |
| Seguridad y privacidad | ¿Qué datos personales se solicitan al registrarse? ¿Qué políticas de privacidad aplican? |
| Colaboración en eventos | ¿Cómo participan los invitados a un evento sin ser clientes registrados? |
| Restricciones institucionales | ¿Existen limitaciones por tratarse de un proyecto de egreso de UTU (presupuesto, hosting, pagos reales)? |
| Plazo | ¿Cuándo se espera contar con una primera versión funcionando? |

---

# Parte 2: Entrevista con el cliente

## 4. Participantes de la entrevista

| Rol | Participante | Responsabilidad |
| --- | --- | --- |
| Cliente (fotógrafo/videógrafo que solicita el sistema) | Lemuel Swec | Describe el problema, valida alcance y prioridades, aprueba decisiones sobre roles y visibilidad de colecciones |
| Equipo de desarrollo | Nicolás Negretto (Líder), Iván Sandoval (sub-líder), Augusto Fernández (desarrollador) | Releva necesidades, transcribe y valida la entrevista, transforma la información en backlog |

---

## 5. Entrevista

### Inicio de la entrevista

**Equipo:** ¿Cuál es la idea del proyecto? ¿Qué problema busca resolver y cuál es el objetivo principal?

**Cliente:** La idea es crear un vínculo entre el consumidor y el vendedor de material gráfico: una plataforma con capacidad para subir fotos y videos. El problema es que hoy, para entregar ese material, se usa mucho WhatsApp: "salva la vida", pero no es una forma profesional de trabajar, porque pixela mucho la imagen. Y una vez que la persona ya tiene la copia, el fotógrafo pierde toda forma de exigir que le paguen lo justo.

---

**Equipo:** ¿Y a nivel comercial, qué buscan lograr?

**Cliente:** Que haya una interacción real entre comprador y vendedor, como una especie de galería del material, con marca de agua y restricciones para descargar o hacer captura de pantalla, y que a la vez se pueda comercializar. No quiero depender de intermediarios que retengan la plata: en plataformas como Lumepic, por cada foto vendida se cobra una comisión (el cliente menciona un 20%) y el fotógrafo cobra tarde. Prefiero un cobro más directo, parecido a comprar un libro digital: pagás y accedés al toque.

---

**Equipo:** ¿En qué calidad debería subirse el material? ¿Hace falta RAW?

**Cliente:** No hace falta RAW; JPG está bien, pero con una calidad bastante mejor que la que deja WhatsApp. Le pareció bien la idea de vincular una versión liviana para la vista previa con el archivo original para la descarga autorizada, y pidió que hubiera al menos dos niveles de calidad de descarga: una buena calidad, y otra superior, alta calidad.

---

**Equipo:** ¿Debería funcionar como una red social, con perfiles públicos y todo el material visible?

**Cliente:** No busca que sea una red social. Prefiere un contacto directo vendedor-comprador: se comparte un QR o enlace puntual a una colección, y quien no tenga ese acceso no debería poder encontrar ni ver el material. Sí le parece bien que exista una página general donde aparezcan perfiles y eventos de fotógrafos para que la gente se contacte, pero sin exponer todo el contenido — el acceso a las fotos lo autoriza cada fotógrafo.

---

**Equipo:** Sobre las colecciones privadas: si una colección no tiene ningún cliente asignado, ¿debería volverse pública después de un tiempo?

**Cliente:** No, tiene que quedar privada. Cada fotógrafo tiene que tener la libertad de decidir si su colección es pública o privada, tenga o no clientes asignados; eso no depende de la cantidad de gente asignada. Es una decisión del fotógrafo, entre otras cosas porque es él quien queda expuesto legalmente si publica una foto de alguien sin su autorización.

---

**Equipo:** ¿Qué datos deberían pedirse al registrarse, y qué cuidados de seguridad hay que tener?

**Cliente:** Un registro básico, con verificación por celular o correo para confirmar que la cuenta es real, y que no se pueda registrar dos veces con el mismo correo. Le preocupa el manejo de los datos — que no se vendan ni se filtren, porque un hackeo no solo cuesta plata sino también tiempo de trabajo y respaldo perdido —, y pide políticas de privacidad claras, aunque reconoce que en su mayoría pueden ser estándares del rubro.

---

**Equipo:** ¿Cómo debería manejarse el espacio de almacenamiento?

**Cliente:** Con una cuota gratuita chica (menciona 2 o 3 GB, tomando como referencia lo que ofrece Pixieset) y la posibilidad de pagar por más espacio, de forma parecida a como funciona Gmail.

---

**Equipo:** Nos contaste una idea sobre carga colaborativa en eventos. ¿Nos la podés explicar?

**Cliente:** Pensando en alguien que organiza un evento y no contrató fotógrafo ni videógrafo: la idea es crear un perfil, generar un QR para el evento, y que los propios invitados —que casi siempre andan con el celular— lo escaneen y suban ahí mismo sus fotos y videos, sin necesidad de un registro complejo. Así el organizador termina con una cobertura visual armada por los propios invitados, y se le puede cobrar por el espacio de almacenamiento que use.

---

**Equipo:** Si tuvieran que priorizar, ¿qué debería estar sí o sí en la primera versión?

**Cliente:** Subida y bajada de imágenes y videos, la marca de agua, y el tema del cobro, aunque para el cobro no pide integrar todos los bancos y tarjetas, sino algo básico y accesible en Uruguay (menciona Brou o Prex como ejemplo). El resto, como las plantillas o el envío automático de fotos por mail que tiene Pixieset, lo considera secundario frente a lo esencial: que se pueda subir, bajar y cobrar sin que el sistema se caiga.

---

**Equipo:** ¿Cómo van a saber que el proyecto está terminado y que cumple con lo que necesitan?

**Cliente:** Con que el fotógrafo pueda subir sus fotos sin problema, que la página y que el cobro funcione. El resto de las funciones puede irse sumando después.

---

> Algunas respuestas del cliente fueron resumidas por el equipo de desarrollo para no hacer tan extenso el documento. Todo lo relevante está en la transcripción original.

## 6. Información obtenida en la entrevista

| Categoría | Información relevada |
| --- | --- |
| Problema principal | Dificultad de entrega inmediata de material fotográfico y baja calidad de imagen. |
| Objetivo de negocio | Vínculo comercial comprador-vendedor y el cobro ágil sin intermediarios que retengan el dinero. |
| Alcance inicial | Subida y bajada de imágenes, métodos de pago, marca de agua. |
| Plazo esperado | Plazo no acordado con el cliente. |
| Presupuesto | Proyecto de UTU sin presupuesto. |
| Usuarios | Fotógrafos, clientes, invitados. |
| Infraestructura | Nube, alta disponibilidad, almacenamiento variable. |
| Seguridad | Nombre completo, correo electrónico, contraseña, número de teléfono (opcional) y políticas de privacidad. |
| Riesgo operativo | Caída del servidor, material de riesgo real y métodos de pago (esto mismo se tendrá en cuenta a futuro). |
| Restricción técnica | Las imágenes en vista previa deben tener marca de agua; la descarga autorizada no. |

> Información obtenida de la transcripción de la entrevista realizada con el cliente. Parte 1 de la entrevista: "https://turboscribe.ai/es/transcript/share/5521413143271206535/BAQ_YceRsNbt_qSbib6HglsceYdjERFhVwK3hj63kII/screen-recording-2026-07-10-112551", parte 2: "https://turboscribe.ai/es/transcript/share/5845672316447232238/SpD0uFbmbpp-LPeTqhBtjAwON_rYso_hrBSaekkgC_w/lv-0-20260710161346". Esta información se validó con la grabación de la entrevista, ya que la IA que transcribió la entrevista a veces confunde palabras y es necesario reescuchar el audio. Por tanto, se puede decir que esta información es válida, fiel y se puede utilizar para nuestro proyecto.

> **Restricción institucional (UTU):** por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en entorno local para esta entrega, y se recomendará al cliente, una vez el equipo se gradúe, migrar el sistema de un servidor local a uno en la nube, adquiriendo hosting y dominio propio, y habilitando en ese momento un método de pago real.

> **Roles:** El rol "Administrador" propuesto por Polo se implementará bajo el alias comercial propuesto por el cliente como "Fotógrafo" y el rol "Cliente" abarcará a los compradores. Los invitados podrán acceder a la colección sin necesidad de ser un "Cliente" mediante el código QR dado por el "Fotógrafo".

> **Decisión sobre visibilidad:** La propuesta por Polo que se repitió en reiteradas ocasiones queda omitida. La propuesta dice que si una colección con cero clientes asignados se volverá una colección pública, pero el cliente dijo lo contrario: el rol "Fotógrafo" decide si una colección es privada o pública, independientemente de si hay clientes asignados o no. Por tanto, decidimos marcar esta decisión del cliente entrevistado como prioritaria y obligatoria por encima de la propuesta por Polo.

> **Exclusión de "dirección" en tabla Seguridad** porque es una página 100% virtual y no es necesaria la dirección del usuario.

---

# Parte 3: Alcance inicial del proyecto

## 7. Nombre propuesto del producto

**???**

Sistema web para fotógrafos y compradores que permite subir material fotográfico para ser comprado.

---

## 8. Visión del producto

Para fotógrafos y videógrafos que tienen dificultad para entregar su material de forma inmediata, profesional y sin perder calidad, ??? es una plataforma web que permitirá a fotógrafos subir, organizar y comercializar su material fotográfico, protegido con marca de agua, y a sus compradores visualizar, comprar y descargar ese contenido en buena calidad. A diferencia de WhatsApp o plataformas como Pixieset y Lumepic, nuestro producto combina protección del contenido, alta calidad de imagen y cobro ágil, sin demoras causadas por intermediarios que retienen el dinero. (Esto último se podrá implementar en un futuro por restricción de edad del equipo).

La primera versión será de subida y bajada de imágenes y videos, y marca de agua.

---

## 9. Alcance incluido

El proyecto incluirá:

1. Gestión de usuarios y roles.
2. Registro y verificación de usuarios.
3. Creación de perfiles de fotógrafo.
4. Creación de colecciones (públicas o privadas) con soporte de hashtags para las públicas.
5. Subida de imágenes (JPG) y videos (clips/recortes) en alta calidad, con marca de agua automática y límite de MB.
6. Aplicación de marca de agua en la vista previa de las imágenes mediante librería especializada.
7. Restricción de descarga en el contenido no autorizado.
8. Visualización de imágenes en colecciones públicas/privadas y solicitud de descarga en alta calidad mediante notificación al fotógrafo, con modo de selección múltiple visual.
9. Descarga inmediata de imágenes autorizadas (individual o en .zip) con notificación de aceptación al usuario.
10. Control de espacio de almacenamiento por usuario con manejo de subidas parciales ante exceso de cuota (cantidad propuesta 3 GB).
11. Políticas de privacidad, protección de datos y Ley 18.331 para fotógrafos.
12. Generación de un enlace o QR de acceso directo a una colección puntual.
13. Sistema de favoritos sobre colecciones públicas.
14. Filtrado de colecciones públicas por hashtags.

---

## 10. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:

1. Una versión de app.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Perfil público con acceso libre a todo el material del fotógrafo.
4. Métodos de pago reales.
5. Hosting/dominio en producción.

---

# Parte 4: Requerimientos del sistema

## 11. Requerimientos funcionales

| Código | Requerimiento funcional |
| --- | --- |
| RF1 | El sistema debe permitir el registro de usuarios (fotógrafos y clientes) solicitando nombre completo, correo electrónico, contraseña y, de forma opcional, número de teléfono. |
| RF2 | El sistema debe impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente en la base de datos. |
| RF3 | El sistema debe proveer una pantalla de inicio de sesión (Login) segura. |
| RF4 | El sistema debe permitir al fotógrafo crear colecciones de imágenes, clasificarlas manualmente como públicas o privadas y, en caso de ser públicas, agregar hashtags para su posterior filtrado. |
| RF5 | Las colecciones marcadas como privadas no cambian por sí solas por la cantidad de clientes asignados y solo son visibles para los clientes que el fotógrafo asigne de manera explícita. |
| RF6 | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados. |
| RF7 | El sistema debe permitir al fotógrafo subir imágenes en formato JPG y videos (clips o recortes) a su colección, aplicando un límite máximo de 800MB por archivo de video. |
| RF8 | Al subir una imagen, el sistema debe generar automáticamente una versión optimizada y más ligera para su visualización fluida en la galería del cliente (vista previa). |
| RF9 | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes JPG en su vista previa mediante una librería especializada, y sobre los videos tiene que ser un videoclip o un recorte del video original (esto mismo porque no se encuentra una manera de colocar una marca de agua al video), si el video no es un recorte y es el original es culpa del que lo suba que vean el contenido completo del video, para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga. |
| RF10 | El sistema debe permitir al cliente descargar las imágenes o videoclips autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip). |
| RF11 | El sistema debe permitir a los usuarios visualizar las colecciones públicas con imágenes/videos en vista previa (en el caso de imagenes con marca de agua), disponer de una opción para solicitar la descarga en alta calidad y filtrar las colecciones públicas por hashtags. |
| RF12 | El sistema debe enviar una notificación al fotógrafo en el menú lateral izquierdo cuando un usuario solicite la descarga en alta calidad de uno o varios contenidos, permitiendo al fotógrafo autorizar o denegar dicha solicitud. |
| RF13 | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica (este mismo podrá imprimirse y tendrá fecha de caducidad de un día a partir de su creación), para permitir el acceso directo, la descarga o la carga colaborativa de contenido durante un evento. |
| RF14 | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos (JPG) y videos (clips/recortes) directamente a esa colección, sin necesidad de completar un registro de cuenta complejo. |
| RF15 | El fotógrafo debe poder visualizar y gestionar (eliminar) todo el material multimedia colaborativo subido por los invitados mediante el QR. |
| RF16 | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo a una colección privada específica, distinto del QR de carga colaborativa. |
| RF17 | El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada (3GB); en subidas múltiples, debe completar la subida de los archivos válidos y mostrar un mensaje de error solo para los archivos que excedan la cuota restante. |
| RF18 | El sistema debe enviar un código de verificación al correo electrónico del usuario para asegurar que realmente exista. |
| RF19 | El sistema debe permitir editar la información de perfil de los fotógrafos. |
| RF20 | El sistema debe permitir al fotógrafo modificar los datos básicos de una imagen o video ya subido (título, descripción o colección) sin necesidad de volver a subir el archivo. |
| RF21 | El sistema debe permitir al usuario marcar y desmarcar como favorita cualquier imagen o video perteneciente a una colección pública, visualizándose estas en un apartado de favoritos; esta información no se expone a otros usuarios. |
| RF22 | El sistema debe proporcionar un modo de selección visual (símbolo redondo o cuadrado en el lateral izquierdo) dentro de la vista ampliada de una imagen o video; al activarse, un clic sobre otro archivo lo selecciona automáticamente y se habilita un botón "Enviar confirmación" para solicitar la descarga en alta calidad de la selección. |
| RF23 | Una vez que el fotógrafo autoriza la descarga en alta calidad, el sistema debe notificar al usuario mediante el apartado de notificaciones con el mensaje "El fotógrafo ha aceptado la descarga en alta calidad" en caso contrario "El fotógrafo no ha aceptado la descarga en alta calidad", ofreciendo las opciones "Aceptar descargar archivos" y "Quizás más tarde". |
| RF24 | Al primer inicio de sesión como fotógrafo, el sistema debe mostrar un modal obligatorio con la política de privacidad y la Ley 18.331 sobre protección de datos personales e intimidad, estableciendo que el fotógrafo asume la responsabilidad legal por el contenido que publica y que la plataforma no se hace responsable ante demandas por publicación no autorizada. |
| RF25 | El sistema debe validar que los videos subidos (por fotógrafo o invitado) sean clips o recortes del video original, aplicando un límite máximo de 800MB por video; si el video subido es el original completo, la responsabilidad recae exclusivamente sobre quien lo subió. |

> **Exclusión de "Cédula" en RF1** porque está fuera de nuestro alcance y supera por mucho la complejidad de lo propuesto por el cliente. En cambio se propuso un cambio, solo mantener nombre completo, contraseña, número de celular y correo electrónico.

---

## 12. Requerimientos no funcionales

| Código | Requerimiento no funcional |
| --- | --- |
| RNF1 | La interfaz de usuario debe ser completamente adaptable (Responsive) para asegurar una experiencia de usuario óptima tanto en computadoras de escritorio como en dispositivos móviles (smartphones y tablets). |
| RNF2 | Las páginas del portal de clientes y las galerías deben cargar en un tiempo óptimo. |
| RNF3 | La interfaz de la página web debe ser simple, rápida y formal. |
| RNF4 | El sistema debe asegurar la estabilidad de la página para soportar el uso constante de esta misma mientras se ejecuta en entornos de pruebas en el entorno local (pensar en estabilidad para un posible hosting en un futuro). |
| RNF5 | El sistema debe realizar respaldos automáticos diarios (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |
| RNF6 | El sistema debe eliminar de manera automática el respaldo más antiguo si ya hay tres a disposición (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |
| RNF7 | El sistema debe registrar fecha y hora para cada respaldo diario (propuesta del equipo de desarrollo por preocupación del cliente ante la pérdida de información en un hackeo). |
| RNF8 | El sistema debe cumplir con la Ley 18.331 de protección de datos personales de Uruguay en el tratamiento, almacenamiento y exhibición de la información de fotógrafos y clientes. |

---

# Parte 5: Épicas del proyecto

## 13. Definición de épicas

Una épica es una funcionalidad grande o área de trabajo que debe dividirse en historias de usuario más pequeñas. En este proyecto, las épicas organizan el alcance principal antes de pasar al Product Backlog.

| Código | Épica | Descripción | Requerimientos vinculados |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles, verificación de cuenta y políticas de privacidad con Ley 18.331. | RF1, RF2, RF3, RF18, RF24 |
| EP2 | Perfiles de fotógrafos | Creación, edición y administración de los perfiles profesionales de los fotógrafos. | RF19 |
| EP3 | Gestión de colecciones | Creación, categorización (públicas/privadas), hashtags, filtrado público, visualización pública y control de acceso por URL a colecciones de fotos. | RF4, RF5, RF6, RF11 |
| EP4 | Carga y procesamiento multimedia | Subida de imágenes JPG y videos (clips), generación de vistas previas optimizadas, aplicación automática de marcas de agua y control de cuotas. | RF7, RF8, RF9, RF17, RF20, RF25 |
| EP5 | Visualización, selección y descargas | Galería de previsualización para clientes, modo de selección visual, solicitudes de descarga en alta calidad con notificación al fotógrafo, notificación de aceptación al usuario y bajada de imágenes (individual o en .zip). | RF10, RF11, RF12, RF21, RF22, RF23 |
| EP6 | Carga colaborativa por QR | Generación de códigos QR para eventos, subida rápida de fotos y videos por invitados, validación de clips y moderación/gestión posterior del material por parte del fotógrafo. | RF13, RF14, RF15, RF16, RF25 |
| EP7 | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría. | RNF5, RNF6, RNF7 |
| EP8 | Capacitación y cierre | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU. | — (actividad de entrega/capacitación; no corresponde a una función del sistema) |

---

# Parte 6: Estimación, planificación y backlog

## 9. Estimación de esfuerzo, plazo y costo

## Criterio didáctico de estimación

Para simplificar la explicación, vamos a utilizar una estimación basada en puntos de historia (story points).

En este ejemplo:

- 1 punto representa una tarea simple pero con cierta lógica.
- 3 puntos representan una tarea media.
- 5 puntos representan una tarea compleja.
- 8 puntos representan una tarea grande o riesgosa.

Se asumirá una velocidad promedio del equipo de **21 puntos por sprint**.
Cada sprint tendrá una duración de **3 semanas**.
El proyecto tendrá **5 sprints**, por lo tanto, la duración total estimada será de **15 semanas**.

---

## 10. Estimación por épica

| Código | Épica | Estimación en puntos | Historias asociadas |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | 16 | HU1, HU8, HU19, HU21, HU25, HU32 |
| EP2 | Perfiles de fotógrafos | 3 | HU18 |
| EP3 | Gestión de colecciones | 17 | HU2, HU3, HU20, HU24, HU26, HU27 |
| EP4 | Carga y procesamiento multimedia | 24 | HU5, HU6, HU14, HU16, HU22, HU28, HU29 |
| EP5 | Visualización, selección y descargas | 20 | HU9, HU10, HU23, HU30, HU31 |
| EP6 | Carga colaborativa por QR | 19 | HU4, HU7, HU11, HU12, HU17 |
| EP7 | Mantenimiento técnico y respaldo | 5 | HU13 |
| EP8 | Capacitación y cierre | 1 | HU15 |
| **Total** | | **105 puntos** | |

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
| Primera versión | Subida y bajada de imágenes/videos, marca de agua, selección visual, hashtags y políticas de privacidad. |
| Exclusiones | Una versión de app, plantillas predeterminadas para exposición/publicación de fotos, perfil público con acceso libre a todo el material del fotógrafo, métodos de pago, hosting/dominio. |

---

## 12. Aprobación del cliente

Luego de revisar la propuesta, el cliente responde:

> “Pendiente de confirmación formal por parte del cliente. Se espera su respuesta en los próximos días para proceder con el detalle de sprints.”

---

## 13. Formato de historia de usuario

Se utilizará el siguiente formato:

> Como **[tipo de usuario]**, quiero **[acción o necesidad]**, para **[beneficio o resultado esperado]**.

---

## 14. Historias de usuario

| ID | Historia de usuario | Puntos | Prioridad |
| --- | --- | --- | --- |
| HU1 | Como usuario, quiero iniciar sesión en el sistema, para acceder de forma segura a mi panel según mi rol. | 3 | Alta |
| HU2 | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública), para controlar quién puede acceder a cada una. | 3 | Alta |
| HU3 | Como fotógrafo, quiero autorizar de forma explícita a un cliente mediante sus datos principales para que acceda a una colección privada. | 3 | Alta |
| HU4 | Como fotógrafo, quiero generar un código QR único para una colección permitiendo a todos los que accedan mediante este código QR permiso para subir imágenes o videos, para utilizarlo de manera presencial en mis eventos laborales. | 5 | Media |
| HU5 | Como fotógrafo, quiero subir imágenes (JPG) y videos (clips/recortes) a mi colección, para ponerlas a disposición de mis clientes. | 3 | Alta |
| HU6 | Como fotógrafo, quiero eliminar imágenes o videos de una colección, para mantener el control sobre el contenido publicado. | 3 | Alta |
| HU7 | Como fotógrafo, quiero descargar el código QR generado para poder imprimirlo físicamente y exponerlo en el evento (este mismo QR tendra fecha de caducidad, debido a que el cliente no especificó, se tomara como fecha de caducidad 1 dia a partir de su creacion). | 3 | Media |
| HU8 | Como usuario nuevo, quiero poder elegir si registrarme como fotógrafo o como cliente, para acceder a las funciones correctas del sistema. | 3 | Alta |
| HU9 | Como usuario/cliente, quiero solicitar la descarga en alta calidad de una o varias imágenes o videos desde la vista previa (con marca de agua en el caso de las imagenes), para que al fotógrafo le llegue una notificación y pueda autorizar mi descarga en alta calidad. | 3 | Alta |
| HU10 | Como cliente autorizado, quiero descargar mis fotos de forma individual o en un archivo comprimido (.zip), para obtener mi material de manera ágil. | 1 | Media |
| HU11 | Como invitado de un evento, quiero escanear el código QR para subir directamente mis fotos y videos (clips) a la colección sin necesidad de crearme una cuenta compleja. | 3 | Media |
| HU12 | Como fotógrafo, quiero visualizar y gestionar (eliminar) el material subido por invitados para tener un control sobre la colección. | 3 | Media |
| HU13 | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. | 5 | Media |
| HU14 | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para poder previsualizar el trabajo antes de descargarlo en alta calidad. | 5 | Alta |
| HU15 | Como fotógrafo/cliente, quiero contar con una guía básica de uso y recibir una breve capacitación sobre la plataforma, para poder utilizarla de forma autónoma una vez finalizado el proyecto. | 1 | Media |
| HU16 | Como sistema, quiero impedir al fotógrafo subir imágenes o videos si supera la cuota de almacenamiento, permitiendo en subidas múltiples completar las válidas y notificar solo los rechazados. | 5 | Media |
| HU17 | Como fotógrafo, quiero generar un código QR único de una colección, para permitir la visualización y descarga de las imágenes (según los permisos habilitados) de la colección, sin necesidad de buscar mi perfil. | 3 | Media |
| HU18 | Como fotógrafo, quiero editar mi información de perfil y contacto comercial, para que los clientes me reconozcan. | 3 | Media |
| HU19 | Como sistema, quiero impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente, para que exista solo una única cuenta por correo. | 3 | Media |
| HU20 | Como sistema, quiero impedir cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados, para mantener el orden. | 5 | Media |
| HU21 | Como sistema, quiero enviar un código de verificación al correo electrónico, para asegurar si realmente pertenece a esa persona. | 3 | Media |
| HU22 | Como fotógrafo, quiero editar los datos básicos (título, descripción) de una imagen o video ya subido, para no tener que subirlo de nuevo para cambiar los datos básicos. | 3 | Media |
| HU23 | Como usuario, quiero marcar como favorita una imagen o video de una colección pública, para tener una lista de favoritos privada. | 3 | Baja |
| HU24 | Como usuario, quiero ingresar a colecciones públicas y explorar sus galerías con imágenes o videos en vista previa protegidos con marca de agua (en el caso de las imagenes), para conocer el catálogo disponible. | 3 | Media |
| HU25 | Como sistema, quiero que cada usuario, independientemente de si es Fotógrafo o Cliente, se registre proporcionando su nombre completo, correo electrónico y contraseña de forma obligatoria, dejando el número de teléfono como opcional, para la preferencia del usuario en cuestion. | 3 | Media |
| HU26 | Como fotógrafo, quiero agregar hashtags al crear o editar una colección pública, para facilitar su descubrimiento por temática en el buscador. | 3 | Media |
| HU27 | Como usuario, quiero filtrar las colecciones públicas mediante hashtags en el buscador, para encontrar contenido específico de mi interés. | 3 | Media |
| HU28 | Como sistema, quiero validar que los videos subidos sean clips o recortes con un límite máximo de 800MB, para optimizar almacenamiento y proteger derechos de autor. | 5 | Alta |
| HU29 | Como sistema, durante una subida múltiple quiero completar las subidas de archivos válidos y notificar únicamente los errores por exceso de cuota, para no perder el trabajo ya realizado por el usuario. | 5 | Alta |
| HU30 | Como usuario, quiero disponer de un modo de selección visual en la galería para elegir múltiples archivos y enviar una solicitud de descarga mediante un botón "Enviar confirmación". | 3 | Baja |
| HU31 | Como sistema, quiero notificar al usuario cuando el fotógrafo apruebe su solicitud, ofreciendo las opciones "Aceptar descargar archivos" y "Quizás más tarde". | 3 | Baja |
| HU32 | Como fotógrafo, al iniciar sesión por primera vez quiero aceptar la política de privacidad y la Ley 18.331, para formalizar mi responsabilidad sobre el contenido publicado. | 1 | Alta |

---

## 15. Product Backlog inicial

## Backlog priorizado

| Orden | ID | Historia | Puntos | Sprint estimado |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU1 | Inicio de sesión básico (acceso a paneles) | 3 | Sprint 1 |
| 2 | HU2 | Creación de colecciones y clasificación de visibilidad | 3 | Sprint 1 |
| 3 | HU5 | Subida de imágenes o videos a colecciones | 3 | Sprint 1 |
| 4 | HU10 | Descarga individual o comprimida (.zip) | 1 | Sprint 1 |
| 5 | HU14 | Visualización con marca de agua automática | 5 | Sprint 1 |
| 6 | HU25 | Registro obligatorio de campos (Nombre, correo, contraseña y teléfono opcional) | 3 | Sprint 1 |
| 7 | HU19 | Impedir el registro de usuarios duplicados por correo | 3 | Sprint 1 |
| 8 | HU3 | Autorización manual de clientes a colecciones privadas | 3 | Sprint 2 |
| 9 | HU8 | Registro con selección de rol (Fotógrafo / Cliente) | 3 | Sprint 2 |
| 10 | HU21 | Envío de código de verificación al correo | 3 | Sprint 2 |
| 11 | HU20 | Bloqueo de acceso directo por URL a colecciones privadas | 5 | Sprint 2 |
| 12 | HU24 | Acceso y visualización de galerías en colecciones públicas | 3 | Sprint 2 |
| 13 | HU26 | Agregar hashtags a colecciones públicas | 3 | Sprint 2 |
| 14 | HU4, HU17 | Generación de códigos QR de colección (Acceso directo, descarga y subida colaborativa) | 8 | Sprint 3 |
| 15 | HU7 | Descarga e impresión física del código QR | 3 | Sprint 3 |
| 16 | HU11 | Carga de archivos vía QR por invitados (sin cuenta) | 3 | Sprint 3 |
| 17 | HU12 | Moderación de material de invitados (ocultar/eliminar) | 3 | Sprint 3 |
| 18 | HU32 | Aceptación de política de privacidad y Ley 18.331 en primer login de fotógrafo | 1 | Sprint 3 |
| 19 | HU9 | Solicitud y notificación/aprobación de descarga en alta calidad | 3 | Sprint 4 |
| 20 | HU16 | Restricción por superación de la cuota de espacio (con manejo parcial) | 5 | Sprint 4 |
| 21 | HU28 | Validación de videos (clips/recortes y límite de MB) | 5 | Sprint 4 |
| 22 | HU29 | Manejo de subida múltiple ante exceso de cuota | 5 | Sprint 4 |
| 23 | HU6 | Eliminación regular de imágenes o videos | 3 | Sprint 4 |
| 24 | HU23 | Marcar como favorita una imagen o video | 3 | Sprint 5 |
| 25 | HU18 | Edición de información del perfil del fotógrafo | 3 | Sprint 5 |
| 26 | HU22 | Edición de datos básicos de un archivo ya subido | 3 | Sprint 5 |
| 27 | HU30 | Modo de selección visual y botón "Enviar confirmación" | 3 | Sprint 5 |
| 28 | HU31 | Notificación al usuario de aceptación con opciones de descarga | 3 | Sprint 5 |
| 29 | HU27 | Filtrado de colecciones públicas por hashtags | 3 | Sprint 5 |
| 30 | HU13 | Respaldo automático diario de base de datos (3 copias) | 5 | Sprint 5 |
| 31 | HU15 | Entrega de guía de uso, capacitación y cierre | 1 | Sprint 5 |


