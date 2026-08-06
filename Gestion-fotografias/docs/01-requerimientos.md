# Proyecto de Egreso UTU – Enfoque Scrum: Plataforma web para fotógrafos y compradores de material fotográfico

---

# Parte 1: Concepción del proyecto

## 1. Situación inicial del cliente

**Nombre del emprendimiento/estudio:** No especificado (el cliente no menciona una marca propia).\
**Cliente:** Lemuel Swec.\
**Rubro:** Fotografía y videografía de eventos (bodas/casamientos, fiestas de 15 años y similares).\
**Ubicación:** No especificado para una única ubicación.\
**Tamaño:** Fotógrafo/a independiente; el sistema se concibe como una plataforma multi-fotógrafo (varios vendedores).\
**Producción:** Fotografías (JPG, sin necesidad de RAW) y videos de eventos, destinados a la venta directa a compradores.\
**Nivel tecnológico actual:** Medio; el cliente mencionó herramientas como Pixieset o Lumepic para publicar/entregar material, pero ninguna resuelve la protección del contenido y cobro ágil.\
**Registro actual:** Entrega por WhatsApp (con pérdida notoria de calidad y sin protección del contenido) o por plataformas de terceros que cobran comisión y demoran la liquidación al fotógrafo.

> Debido a que el cliente no proporcionó una respuesta exacta y tampoco el equipo de desarrollo tiene una respuesta de su parte; el equipo decidió dedicar esta página web para Uruguay implementando la ley 18.331 contra la protección de datos. Y se le informará al cliente de dicha decisión cuando concuerde la fecha de la próxima entrevista.

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
| Seguridad y privacidad | ¿Qué datos personales se solicitan al registrarse? ¿Qué políticas de privacidad aplican? |
| Colaboración en eventos | ¿Cómo participan los invitados a un evento sin ser clientes registrados? |

---

# Parte 2: Entrevista con el cliente

## 4. Participantes de la entrevista

| Rol | Participante | Responsabilidad |
| --- | --- | --- |
| Cliente (solicita el sistema) | Lemuel Swec | Describe el problema, valida alcance y prioridades, aprueba decisiones sobre roles y visibilidad de colecciones |
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

**Cliente:** No hace falta RAW; JPG está bien, pero con una calidad bastante mejor que la que deja WhatsApp. Le pareció bien la idea de vincular una versión liviana para la vista previa con el archivo original para la descarga autorizada, y pidió que hubiera al menos dos niveles de calidad de descarga: una buena calidad (calidad estándar/media) y otra superior, alta calidad (resolución original).

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

> Algunas respuestas del cliente fueron resumidas por el equipo de desarrollo para no hacer tan extenso el documento. Todo lo redundante está en la transcripción original.

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

> **Restricción institucional (UTU):** Por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en entorno local para esta entrega, y se recomendará al cliente, una vez el equipo se gradúe, migrar el sistema de un servidor local a uno en la nube, adquiriendo hosting y dominio propio, y habilitando en ese momento un método de pago real.

> **Roles y Organizadores de Eventos:** El rol "Administrador" propuesto por Polo se implementará bajo el alias comercial propuesto por el cliente como "Fotógrafo" y el rol "Cliente" abarcará a los compradores. Aquel organizador de evento que no contrató fotógrafo profesional utilizará la plataforma registrándose bajo el rol "Fotógrafo" para habilitar la carga colaborativa por QR. Los invitados podrán acceder a subir contenido sin necesidad de ser un "Cliente" registrado, mediante el código QR de carga colaborativa provisto por el "Fotógrafo" / organizador.

> **Decisión sobre visibilidad:** La propuesta por Polo que se repitió en reiteradas ocasiones queda omitida. La propuesta dice que si una colección con cero clientes asignados se volverá una colección pública, pero el cliente dijo lo contrario: el rol "Fotógrafo" decide si una colección es privada o pública, independientemente de si hay clientes asignados o no. Por tanto, decidimos marcar esta decisión del cliente entrevistado como prioritaria y obligatoria por encima de la propuesta por Polo.

> **Exclusión de "dirección" y "cédula":** Se excluyen la dirección física y el número de cédula de identidad en las tablas de usuarios y seguridad porque es una plataforma 100% virtual y no son necesarios para la operativa del sistema, simplificando el registro y la protección de datos personales.

---

# Parte 3: Alcance inicial del proyecto

## 7. Nombre propuesto del producto

**[Nombre de la página web]**

Sistema web para fotógrafos y compradores que permite subir material fotográfico para ser comprado.

---

## 8. Visión del producto

Para fotógrafos y videógrafos que tienen dificultad para entregar su material de forma inmediata, profesional y sin perder calidad, [Nombre de la página web] es una plataforma web que permitirá a fotógrafos subir, organizar y comercializar su material fotográfico, protegido con marca de agua, y a sus compradores visualizar, comprar y descargar ese contenido en dos niveles de calidad (buena calidad y alta calidad). A diferencia de WhatsApp o plataformas como Pixieset y Lumepic, nuestro producto combina protección del contenido, alta calidad de imagen y cobro ágil, sin demoras causadas por intermediarios que retienen el dinero. (Esto último se podrá implementar en un futuro por restricción de edad del equipo).

La primera versión será de subida y bajada de imágenes y videos, y marca de agua.

---

## 9. Alcance incluido

El proyecto incluirá:

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

---

## 10. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:

1. Una versión de app móvil nativa.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Perfil público con acceso libre a todo el contenido privado del fotógrafo.
4. Métodos de pago reales con pasarelas bancarias.
5. Hosting/dominio en producción (despliegue local para evaluación de UTU).
6. Subida de videos directa a S3/Cloudflare con URLs firmadas con colas asíncronas.


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
| RF9 | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes JPG en su vista previa mediante una librería especializada. Para videos, se requerirá que sean videoclips o recortes conforme a las condiciones de responsabilidad establecidas en el RF25. |
| RF10 | El sistema debe permitir al cliente descargar las imágenes o videoclips autorizados en dos niveles de calidad ("Buena Calidad" estándar o "Alta Calidad" superior/original), de forma individual o masiva (comprimiendo la selección en un archivo .zip). |
| RF11 | El sistema debe permitir a los usuarios visualizar las colecciones públicas con imágenes/videos en vista previa (en el caso de imágenes con marca de agua), disponer de una opción para solicitar la descarga en el nivel de calidad deseado (buena o alta calidad) y filtrar las colecciones públicas por hashtags. |
| RF12 | El sistema debe enviar una notificación al fotógrafo en el menú lateral izquierdo cuando un usuario solicite la descarga en buena o alta calidad de uno o varios contenidos, permitiendo al fotógrafo autorizar o denegar dicha solicitud. |
| RF13 | El sistema debe permitir al fotógrafo generar un código QR de carga colaborativa exclusivo para un evento (imprimible y con fecha de caducidad de 1 día a partir de su creación), para permitir a los invitados subir fotos y videos directamente a esa colección durante el evento. |
| RF14 | Cualquier invitado del evento debe poder escanear el código QR de carga colaborativa con su celular para subir fotos (JPG) y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo. |
| RF15 | El fotógrafo debe poder visualizar y gestionar (eliminar) todo el material multimedia colaborativo subido por los invitados mediante el QR. |
| RF16 | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo permanente (sin caducidad) a una colección específica, distinto del QR de carga colaborativa, para facilitar la visualización y descarga directa a clientes autorizados. |
| RF17 | El sistema debe controlar la cuota de almacenamiento del fotógrafo (3GB), impidiendo la subida si se supera el límite; en subidas múltiples, debe completar la subida de los archivos válidos y mostrar un mensaje de notificación únicamente para los archivos que excedan la cuota restante. |
| RF18 | El sistema debe enviar un código de verificación al correo electrónico del usuario para asegurar que la casilla registrada realmente existe. |
| RF19 | El sistema debe permitir crear y editar la información de perfil profesional de los fotógrafos. |
| RF20 | El sistema debe permitir al fotógrafo modificar los datos básicos (título, descripción) o eliminar cualquier imagen o recortes de video previamente subido a sus colecciones. |
| RF21 | El sistema debe permitir al usuario marcar y desmarcar como favorita cualquier imagen o video perteneciente a una colección pública, visualizándose estas en un apartado de favoritos; esta información no se expone a otros usuarios. |
| RF22 | El sistema debe proporcionar un modo de selección visual (símbolo redondo o cuadrado en el lateral izquierdo) dentro de la vista ampliada de una imagen o video; al activarse, un clic sobre otro archivo lo selecciona automáticamente y se habilita un botón "Enviar confirmación" para solicitar la descarga en la calidad deseada de la selección. |
| RF23 | Una vez que el fotógrafo autoriza la descarga, el sistema debe notificar al usuario mediante el apartado de notificaciones con el mensaje "El fotógrafo ha aceptado la descarga" (indicando la calidad concedida) o en su defecto "El fotógrafo no ha aceptado la descarga", ofreciendo las opciones "Aceptar descargar archivos" y "Quizás más tarde". |
| RF24 | Al primer inicio de sesión como fotógrafo, el sistema debe mostrar un modal obligatorio con la política de privacidad y la Ley 18.331 sobre protección de datos personales e intimidad, estableciendo que el fotógrafo asume la responsabilidad legal por el contenido que publica y que la plataforma no se hace responsable ante demandas por publicación no autorizada. |
| RF25 | El sistema debe validar que los videos subidos (por fotógrafo o invitado) sean clips o recortes del video original con un límite máximo de 80MB por video; si el video subido es el original (límite máximo de 800MB) completo, la responsabilidad recae exclusivamente sobre quien lo subió. |
| RF26 | El sistema deberá generar automáticamente un recorte de vista previa de cada video subido y almacenar el archivo original completo para su posterior descarga autorizada. |

**RF26 – Criterios de aceptación:**
- El recorte de vista previa tendrá una duración máxima de 15 segundos.
- El recorte se mostrará en la colección como representación del video.
- El video original completo quedará disponible para la descarga autorizada.
- El proceso de recorte se realizará de forma automática sin intervención del usuario.

---

## 12. Requerimientos no funcionales

| Código | Requerimiento no funcional |
| --- | --- |
| RNF1 | La interfaz de usuario debe ser completamente adaptable (Responsive) para asegurar una experiencia de usuario óptima tanto en computadoras de escritorio como en dispositivos móviles (smartphones y tablets). |
| RNF2 | Las páginas del portal de clientes y las galerías deben cargar en un tiempo óptimo (tiempo de respuesta menor a 2 segundos bajo condiciones normales de red local). |
| RNF3 | La interfaz de la página web debe ser simple, rápida y formal. |
| RNF4 | El sistema debe asegurar la estabilidad de la página para soportar el uso constante durante las pruebas en entorno local y estar preparado para un despliegue futuro en producción. |
| RNF5 | El sistema debe realizar respaldos automáticos diarios de la base de datos (propuesta del equipo de desarrollo para mitigar riesgos de pérdida de información). |
| RNF6 | El sistema debe eliminar de manera automática el respaldo más antiguo si ya hay tres a disposición (rotación automática de las últimas 3 copias). |
| RNF7 | El sistema debe registrar fecha y hora para cada respaldo diario. |
| RNF8 | El sistema debe cumplir con la Ley 18.331 de Protección de Datos Personales de Uruguay en el tratamiento, almacenamiento y exhibición de la información de fotógrafos y clientes. |

---

# Parte 5: Épicas del proyecto

## 13. Definición de épicas

Una épica es una funcionalidad grande o área de trabajo que debe dividirse en historias de usuario más pequeñas. En este proyecto, las épicas organizan el alcance principal antes de pasar al Product Backlog.

> **Nota sobre Requerimientos No Funcionales (RNF):** Los requerimientos RNF1, RNF2, RNF3, RNF4 y RNF8 son restricciones transversales de calidad, rendimiento, diseño y cumplimiento legal que aplican de manera global a todo el desarrollo del sistema y a todas las épicas. RNF5, RNF6 y RNF7 son requerimientos técnicos específicos contemplados en la épica EP7.

| Código | Épica | Descripción | Requerimientos vinculados |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles, verificación de cuenta y políticas de privacidad con Ley 18.331. | RF1, RF2, RF3, RF18, RF24 |
| EP2 | Perfiles de fotógrafos y directorio | Creación, edición y administración de perfiles profesionales de fotógrafos, e inclusión en el directorio general de descubrimiento y eventos. | RF19 |
| EP3 | Gestión de colecciones y accesos | Creación, categorización (públicas/privadas), hashtags, filtrado público, asignación de clientes, control de acceso por URL y generación de QR/enlace de acceso permanente. | RF4, RF5, RF6, RF11, RF16 |
| EP4 | Carga y procesamiento multimedia | Subida de imágenes JPG y videos, procesamiento en backend con FFmpeg (Docker) para recortes de 15 segundos, guardado en Filesystem, generación de vistas previas optimizadas, marca de agua, edición/eliminación de archivos y control de cuotas. | RF7, RF8, RF9, RF17, RF20, RF25, RF26 |
| EP5 | Visualización, selección y descargas | Galería de previsualización para clientes, modo de selección visual, solicitudes de descarga en dos niveles de calidad con notificación al fotógrafo, notificación de aceptación al usuario y bajada de imágenes (individual o en .zip). | RF10, RF11, RF12, RF21, RF22, RF23 |
| EP6 | Carga colaborativa por QR | Generación de código QR temporal de evento (caducidad 1 día), subida rápida por invitados sin registro complejo, validación de clips y moderación del material por el fotógrafo. | RF13, RF14, RF15, RF25 |
| EP7 | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría. | RNF5, RNF6, RNF7 |
| EP8 | Capacitación y cierre | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU. | — (actividad de entrega/capacitación) |

---

# Parte 6: Estimación, planificación y backlog

## 14. Estimación de esfuerzo, plazo y costo

## Criterio didáctico de estimación

Para simplificar la explicación, vamos a utilizar una estimación basada en puntos de historia (story points).

En este ejemplo:
- 1 punto representa una tarea simple pero con cierta lógica.
- 3 puntos representan una tarea media.
- 5 puntos representan una tarea compleja.
- 8 puntos representan una tarea grande o riesgosa.

Se asumirá una velocidad promedio del equipo de **20 puntos por sprint** (promedio real: 20.0 puntos).
Cada sprint tendrá una duración de **3 semanas**.
El proyecto tendrá **5 sprints**, por lo tanto, la duración total estimada será de **15 semanas** para completar un backlog consolidado de **100 puntos de historia**.

---

## 15. Estimación por épica

A continuación se detalla la suma exacta de puntos de historia correspondientes a las Historias de Usuario asignadas a cada épica:

| Código | Épica | Estimación en puntos | Historias asociadas |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | 16 | HU1 , HU8 , HU19 , HU21 , HU25 , HU31  |
| EP2 | Perfiles de fotógrafos y directorio | 3 | HU18  |
| EP3 | Gestión de colecciones y accesos | 21 | HU2 , HU3 , HU17 , HU20 , HU24 , HU26 , HU27  |
| EP4 | Carga y procesamiento multimedia | 22 | HU5 , HU6 , HU16 , HU22 , HU28 , HU32  |
| EP5 | Visualización, selección y descargas | 18 | HU9 , HU10 , HU14 , HU23 , HU29 , HU30  |
| EP6 | Carga colaborativa por QR | 14 | HU4 , HU7 , HU11 , HU12  |
| EP7 | Mantenimiento técnico y respaldo | 5 | HU13  |
| EP8 | Capacitación y cierre | 1 | HU15 |
| **Total** | | **100 puntos** | 

---

## 16. Propuesta presentada al cliente

El equipo presenta la siguiente propuesta:

| Elemento | Propuesta |
| --- | --- |
| Producto | [Nombre de la página web], sistema web para fotógrafos y compradores. |
| Duración | 15 semanas (100 puntos de historia totales). |
| Metodología | Scrum, con 5 sprints de 3 semanas (velocidad promedio: ~20 pts/sprint). |
| Entregas | Incremento funcional al final de cada sprint. |
| Presupuesto | Proyecto de Egreso de UTU (sin presupuesto financiero asignado). |
| Forma de trabajo | Revisión con el cliente al cierre de cada sprint. |
| Primera versión | Subida y bajada de imágenes/videos en dos calidades, marca de agua, selección visual, directorio de fotógrafos, QR colaborativo y de acceso directo, hashtags y políticas de privacidad conforme a Ley 18.331. |
| Exclusiones | Aplicación móvil nativa, plantillas de exposición, perfil público con acceso libre a colecciones privadas, pasarelas de pago reales, hosting/dominio en producción. |

---

## 17. Aprobación del cliente

Luego de revisar la propuesta, el cliente responde:

> “Pendiente de confirmación formal por parte del cliente. Se espera su respuesta en los próximos días para proceder con el detalle de sprints.”

---

## 18. Formato de historia de usuario

Se utilizará el siguiente formato:

> Como **[tipo de usuario]**, quiero **[acción o necesidad]**, para **[beneficio o resultado esperado]**.

---

## 19. Historias de usuario

| ID | Historia de usuario | Puntos | Prioridad |
| --- | --- | --- | --- |
| HU1 | Como usuario, quiero iniciar sesión en el sistema, para acceder de forma segura a mi panel según mi rol. | 3 | Alta |
| HU2 | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública), para controlar quién puede acceder a cada una. | 3 | Alta |
| HU3 | Como fotógrafo, quiero autorizar de forma explícita a un cliente mediante sus datos principales para que acceda a una colección privada. | 3 | Alta |
| HU4 | Como fotógrafo u organizador, quiero generar un código QR único de carga colaborativa para un evento (con caducidad de 1 día), para permitir a los invitados subir fotos o videos directamente durante la jornada. | 5 | Media |
| HU5 | Como fotógrafo, quiero subir imágenes (JPG) y videos (clips/recortes) a mi colección, para ponerlas a disposición de mis clientes. | 3 | Alta |
| HU6 | Como fotógrafo, quiero eliminar imágenes o videos de una colección, para mantener el control sobre el contenido publicado. | 3 | Alta |
| HU7 | Como fotógrafo, quiero descargar e imprimir el código QR de carga colaborativa (con caducidad de 1 día), para exponerlo físicamente en el evento. | 3 | Media |
| HU8 | Como usuario nuevo, quiero poder elegir si registrarme como fotógrafo o como cliente, para acceder a las funciones correctas del sistema. | 3 | Alta |
| HU9 | Como usuario/cliente, quiero solicitar la descarga en buena calidad o alta calidad de una o varias imágenes o videos desde la vista previa (con marca de agua en imágenes), para que al fotógrafo le llegue una notificación y autorice la descarga. | 3 | Alta |
| HU10 | Como cliente autorizado, quiero descargar mis fotos autorizadas de forma individual o en un archivo comprimido (.zip) según el nivel de calidad aprobado, para obtener mi material de manera ágil. | 1 | Media |
| HU11 | Como invitado de un evento, quiero escanear el código QR de carga colaborativa para subir directamente mis fotos y videos (clips) a la colección (pudiendo ingresar un nombre opcional o de forma anónima) sin necesidad de crearme una cuenta compleja. | 3 | Media |
| HU12 | Como fotógrafo, quiero visualizar y gestionar (eliminar o modificar) el material subido por invitados para tener control total sobre la colección. | 3 | Media |
| HU13 | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. | 5 | Media |
| HU14 | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para poder previsualizar el trabajo antes de solicitar la descarga autorizada. | 5 | Alta |
| HU15 | Como fotógrafo/cliente, quiero contar con una guía básica de uso y recibir una breve capacitación sobre la plataforma, para poder utilizarla de forma autónoma una vez finalizado el proyecto. | 1 | Media |
| HU16 | Como sistema, quiero controlar el límite de almacenamiento del fotógrafo (3GB), impidiendo subidas si se supera la cuota y, en subidas múltiples, completar los archivos válidos notificando únicamente los que excedan la cuota restante. | 5 | Media |
| HU17 | Como fotógrafo, quiero generar un enlace o QR de acceso directo permanente a una colección específica, para permitir la visualización y descarga directa de los clientes autorizados sin caducidad. | 3 | Media |
| HU18 | Como fotógrafo, quiero editar mi información de perfil profesional y figurar en el directorio general de descubrimiento y eventos públicos, para que nuevos clientes puedan encontrarme y contactarme. | 3 | Media |
| HU19 | Como sistema, quiero impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente, para que exista una única cuenta por correo. | 3 | Media |
| HU20 | Como sistema, quiero impedir cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados, para mantener la privacidad del contenido. | 3 | Media |
| HU21 | Como sistema, quiero enviar un código de verificación al correo electrónico, para asegurar que la casilla registrada pertenece al usuario. | 3 | Media |
| HU22 | Como fotógrafo, quiero editar los datos básicos (título, descripción o reasignación de colección) de una imagen o video ya subido, para mantener organizada la galería. | 3 | Media |
| HU23 | Como usuario, quiero marcar como favorita una imagen o video de una colección pública, para tener una lista de favoritos privada. | 3 | Baja |
| HU24 | Como usuario, quiero ingresar a colecciones públicas y explorar sus galerías con imágenes o videos en vista previa protegidos con marca de agua, para conocer el catálogo disponible. | 3 | Media |
| HU25 | Como sistema, quiero que cada usuario (Fotógrafo o Cliente) se registre proporcionando su nombre completo, correo electrónico, contraseña de forma obligatoria y teléfono opcional, aceptando los términos de privacidad. | 3 | Media |
| HU26 | Como fotógrafo, quiero agregar hashtags al crear o editar una colección pública, para facilitar su descubrimiento por temática en el buscador. | 3 | Media |
| HU27 | Como usuario, quiero filtrar las colecciones públicas mediante hashtags en el buscador, para encontrar contenido específico de mi interés. | 3 | Media |
| HU28 | Como sistema, quiero validar que los videos subidos sean clips o recortes con un límite máximo de 800MB, para optimizar el almacenamiento y proteger derechos de autor. | 5 | Alta |
| HU29 | Como usuario, quiero disponer de un modo de selección visual en la galería para elegir múltiples archivos y enviar una solicitud de descarga indicando la calidad deseada mediante el botón "Enviar confirmación". | 3 | Baja |
| HU30 | Como sistema, quiero notificar al usuario cuando el fotógrafo apruebe su solicitud de descarga, ofreciendo las opciones "Aceptar descargar archivos" y "Quizás más tarde". | 3 | Baja |
| HU31 | Como fotógrafo, al iniciar sesión por primera vez quiero aceptar la política de privacidad y la Ley 18.331, para formalizar mi responsabilidad sobre el contenido publicado. | 1 | Alta |
| HU32 | Como sistema, quiero procesar los videos subidos en el backend para generar automáticamente un recorte de 15 segundos para la vista previa en la colección y almacenar el video completo para la descarga autorizada, para garantizar la visualización ligera y reservar el archivo original. | 3 | Media |

> **Nota de consolidación:** La antigua HU29 (Manejo de subida múltiple ante exceso de cuota) fue unificada con la HU16 para eliminar la duplicación de concepto en el backlog, consolidando 5 puntos en una única historia de usuario integral. A partir de dicha unificación, las historias posteriores fueron renumeradas secuencialmente (HU28 a HU32) para mantener la continuidad del backlog. Asimismo, por recomendación docente, el RF26 fue redactado como requerimiento funcional orientado al resultado esperado del sistema, asociándose de forma directa a la HU32 dentro de la Épica EP4.

---

## 20. Product Backlog inicial

### Backlog priorizado y balanceado por Sprints (100 puntos de historia totales)

El backlog ha sido distribuido equitativamente manteniendo un ritmo de trabajo sostenido de aproximadamente **20 puntos por sprint**:

| Orden | ID | Historia de usuario | Puntos | Sprint estimado |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU1 | Inicio de sesión básico (acceso a paneles) | 3 | Sprint 1 |
| 2 | HU8 | Registro con selección de rol (Fotógrafo / Cliente) | 3 | Sprint 1 |
| 3 | HU25 | Registro obligatorio de campos (Nombre, correo, contraseña y teléfono opcional) | 3 | Sprint 1 |
| 4 | HU19 | Impedir el registro de usuarios duplicados por correo | 3 | Sprint 1 |
| 5 | HU2 | Creación de colecciones y clasificación de visibilidad | 3 | Sprint 1 |
| 6 | HU5 | Subida de imágenes o videos a colecciones | 3 | Sprint 1 |
| 7 | HU31 | Aceptación de política de privacidad y Ley 18.331 en primer login | 1 | Sprint 1 |
| 8 | HU10 | Descarga individual o comprimida (.zip) | 1 | Sprint 1 |
| 9 | HU14 | Visualización con marca de agua automática | 5 | Sprint 2 |
| 10 | HU3 | Autorización manual de clientes a colecciones privadas | 3 | Sprint 2 |
| 11 | HU21 | Envío de código de verificación al correo | 3 | Sprint 2 |
| 12 | HU20 | Bloqueo de acceso directo por URL a colecciones privadas | 3 | Sprint 2 |
| 13 | HU24 | Acceso y visualización de galerías en colecciones públicas | 3 | Sprint 2 |
| 14 | HU26 | Agregar hashtags a colecciones públicas | 3 | Sprint 2 |
| 15 | HU4 | Generación de QR de carga colaborativa de evento (caducidad 1 día) | 5 | Sprint 3 |
| 16 | HU7 | Descarga e impresión física del QR colaborativo | 3 | Sprint 3 |
| 17 | HU11 | Carga de archivos vía QR por invitados (sin registro complejo) | 3 | Sprint 3 |
| 18 | HU12 | Moderación de material de invitados por el fotógrafo | 3 | Sprint 3 |
| 19 | HU17 | Generación de QR / enlace permanente de acceso directo | 3 | Sprint 3 |
| 20 | HU27 | Filtrado de colecciones públicas por hashtags | 3 | Sprint 3 |
| 21 | HU9 | Solicitud y notificación/aprobación de descarga (buena/alta calidad) | 3 | Sprint 4 |
| 22 | HU16 | Control de cuota (3GB) y manejo de subida parcial notificando excedentes | 5 | Sprint 4 |
| 23 | HU28 | Validación de videos (clips/recortes y límite de 800MB) | 5 | Sprint 4 |
| 24 | HU6 | Eliminación regular de imágenes o videos por el fotógrafo | 3 | Sprint 4 |
| 25 | HU32 | Procesamiento automático de recortes de video (15s) y almacenamiento del original | 3 | Sprint 4 |
| 26 | HU22 | Edición de datos básicos (título, descripción o reasignación) | 3 | Sprint 5 |
| 27 | HU18 | Edición de perfil de fotógrafo y presencia en directorio público | 3 | Sprint 5 |
| 28 | HU23 | Marcar como favorita una imagen o video pública | 3 | Sprint 5 |
| 29 | HU29 | Modo de selección visual y botón "Enviar confirmación" | 3 | Sprint 5 |
| 30 | HU30 | Notificación al usuario de aceptación con opciones de descarga | 3 | Sprint 5 |
| 31 | HU13 | Respaldo automático diario de base de datos (3 copias) | 5 | Sprint 5 |
| 32 | HU15 | Entrega de guía de uso, capacitación y cierre | 1 | Sprint 5 |

---

