# Proyecto de Egreso UTU – Enfoque Scrum: Plataforma web para fotógrafos y compradores de material fotográfico


---

# Parte 1: Concepción del proyecto

## 1. Situación inicial del cliente

**Nombre del emprendimiento/estudio:** no especificado (el cliente no menciona una marca propia).\
**Cliente:** Lemuel Swec\
**Rubro:** Fotografía y videografía de eventos (bodas/casamientos, fiestas de 15 años y similares)\
**Ubicación:** No especificado para un unica ubicacion, se toma en cuenta que es una aplicacion web con alcance para cualquier parte del mundo.\
**Tamaño:** fotógrafo/a independiente; el sistema se concibe como una plataforma multi-fotógrafo (varios vendedores), no solo para uso del entrevistado\
**Producción:** fotografías (JPG, sin necesidad de RAW) y videos de eventos, destinados a la venta directa a compradores\
**Nivel tecnológico actual:** medio; el cliente mencionó herramientas como Pixieset o Lumepic para publicar/entregar material, pero ninguna resuelve a la vez calidad de imagen, protección del contenido y cobro ágil\
**Registro actual:** entrega por WhatsApp (con pérdida notoria de calidad y sin protección del contenido) o por plataformas de terceros que cobran comisión y demoran la liquidación al fotógrafo.


---

## 2. Necesidad puntual presentada por el cliente

El cliente plantea la necesidad al equipo de desarrollo desde el inicio de la entrevista. *(Síntesis basada en el contenido real de la transcripción, no una cita literal — ver la sección 5 para el intercambio completo.)*

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

>Algunas respuestas del cliente fueron resumidas por el equipo de desarrollo para no hacer tan extenso el documento. Esto mismo aplica a las preguntas. Todo lo relevante está en la transcripción original.

## 6. Información obtenida en la entrevista

| Categoría | Información relevada |
| --- | --- |
| Problema principal | Dificultad de entrega inmediata de material fotográfico y baja calidad de imagen. |
| Objetivo de negocio | Vínculo comercial comprador-vendedor y el cobro ágil sin intermediarios que retengan el dinero. |
| Alcance inicial | Subida y bajada de imágenes, métodos de pago, marca de agua. |
| Plazo esperado | Plazo no acordado con el cliente. |
| Presupuesto | Proyecto de UTU sin presupuesto. |
| Usuarios | Fotógrafos, clientes. |
| Infraestructura | Nube, alta disponibilidad, almacenamiento variable. |
| Seguridad | Nombre completo, correo electrónico, contraseña, número de teléfono (opcional) y políticas de privacidad. |
| Riesgo operativo | Caída del servidor, material de riesgo real y métodos de pago (esto mismo se tendrá en cuenta a futuro). |
| Restricción técnica | Las imágenes en vista previa deben tener marca de agua; la descarga autorizada no. |

> Información obtenida de la transcripción de la entrevista realizada con el cliente. Parte 1 de la entrevista: "https://turboscribe.ai/es/transcript/share/5521413143271206535/BAQ_YceRsNbt_qSbib6HglsceYdjERFhVwK3hj63kII/screen-recording-2026-07-10-112551", parte 2: "https://turboscribe.ai/es/transcript/share/5845672316447232238/SpD0uFbmbpp-LPeTqhBtjAwON_rYso_hrBSaekkgC_w/lv-0-20260710161346". Esta información se validó con la grabación de la entrevista, ya que la IA que transcribió la entrevista a veces confunde palabras y es necesario reescuchar el audio. Por tanto, se puede decir que esta información es válida, fiel y se puede utilizar para nuestro proyecto.

---

> "Restricción institucional (UTU): por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en entorno local para esta entrega, y se recomendará al cliente, una vez el equipo se gradúe, migrar el sistema de un servidor local a uno en la nube, adquiriendo hosting y dominio propio, y habilitando en ese momento un método de pago real."

> "El rol "Administrador" de la propuesta por Polo se implementará bajo el alias comercial propuesto por el cliente como "Fotógrafo" y el rol "Cliente" abarcará a los compradores. Los invitados podrán acceder a la colección sin necesidad de ser un "Cliente" mediante el código QR dado por el "Fotógrafo"."

> "La propuesta por Polo que se repitió en reiteradas ocasiones en dicha propuesta queda omitida. La propuesta dice que si una colección con cero clientes asignados se volverá una colección pública, pero el cliente dijo lo contrario: el rol "Fotógrafo" decide si una colección es privada o pública, independientemente de si hay clientes asignados o no. Por tanto, decidimos marcar esta decisión del cliente entrevistado como prioritaria y obligatoria por encima de la propuesta por Polo."

> "Exclusión de "dirección" en tabla Seguridad porque es una página 100% virtual y no es necesaria la dirección del usuario."

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
4. Creación de colecciones (públicas o privadas).
5. Subida de imágenes y videos en alta calidad.
6. Aplicación de marca de agua en la vista previa de las imágenes.
7. Restricción de descarga en el contenido no autorizado.
8. Visualización de imágenes en colecciones públicas/privadas y solicitud de descarga en alta calidad mediante notificación al fotógrafo.
9. Descarga inmediata de imágenes autorizadas.
10. Control de espacio de almacenamiento por usuario (la cantidad será propuesta por el cliente más adelante).
11. Políticas de privacidad y protección de datos.
12. Generación de un enlace o QR de acceso directo a una colección puntual.
13. Etiquetado de colecciones públicas mediante hashtags y búsqueda/filtro por hashtag en el buscador de la página.
14. Selección múltiple de imágenes o videos (vista ampliada) y notificación de confirmación para la descarga en alta calidad.
15. Marcado de contenido como favorito y visualización posterior desde una sección dedicada del menú.
16. Aviso legal sobre la Ley N.º 18.331 de Protección de Datos Personales, mostrado al fotógrafo en su primer inicio de sesión.

---

## 10. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:

1. Una versión de app.
2. Plantillas predeterminadas para exposición/publicación de fotos.
3. Perfil público con acceso libre a todo el material del fotógrafo.
4. Métodos de pago.
5. Hosting/dominio.

---

# Parte 4: Requerimientos del sistema

## 11. Requerimientos funcionales

| Código | Requerimiento funcional |
| --- | --- |
| RF1 | El sistema debe permitir el registro de usuarios (fotógrafos y clientes) solicitando nombre completo, correo electrónico, contraseña y, de forma opcional, número de teléfono. |
| RF2 | El sistema debe impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente en la base de datos. |
| RF3 | El sistema debe proveer una pantalla de inicio de sesión (Login) segura. |
| RF4 | El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como públicas o privadas. |
| RF5 | Las colecciones marcadas como privadas no cambian por sí solas por la cantidad de clientes asignados y solo son visibles para los clientes que el fotógrafo asigne de manera explícita. |
| RF6 | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados. |
| RF7 | El sistema debe permitir al fotógrafo subir imágenes (JPG) y videos a su colección. |
| RF8 | Al subir una imagen, el sistema debe generar automáticamente una versión optimizada y más ligera para su visualización fluida en la galería del cliente (vista previa). |
| RF9 | El sistema debe aplicar automáticamente, mediante una librería de procesamiento de imágenes, una marca de agua sobre las imágenes en su vista previa, para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga. Dado que actualmente no existe una forma de aplicar marca de agua sobre videos, la protección equivalente para estos consiste en exigir que el archivo subido sea un recorte (videoclip) del original y no el video completo (ver RF24). |
| RF10 | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip). |
| RF11 | El sistema debe permitir a los usuarios visualizar las colecciones públicas con imágenes/videos en vista previa (con marca de agua) y disponer de una opción para solicitar la descarga en alta calidad. |
| RF12 | El sistema debe permitir al usuario seleccionar una o varias imágenes o videos de una colección y enviar, mediante un botón "Enviar confirmación" (parte superior derecha), una única solicitud de descarga en alta calidad para todo lo seleccionado. El fotógrafo debe recibir esta solicitud como una notificación en el apartado de menú lateral izquierdo, pudiendo autorizar o denegar dicha solicitud. |
| RF13 | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica para permitir el acceso directo, la descarga o la carga colaborativa de contenido durante un evento. |
| RF14 | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo. Estos archivos deben respetar las mismas restricciones de formato de imagen y de video definidas para el fotógrafo (ver RF7, RF24 y RF25). |
| RF15 | El fotógrafo debe poder visualizar y gestionar (eliminar) todo el material multimedia colaborativo subido por los invitados mediante el QR. |
| RF16 | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo a una colección privada específica, distinto del QR de carga colaborativa. |
| RF17 | El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada (la cantidad será propuesta por el cliente más adelante), permitiendo igualmente la descarga del contenido ya existente. Al subir varios archivos en una misma operación, el sistema debe cargar los que sí entren dentro de la cuota disponible y mostrar un mensaje de error únicamente para los que la superen, en lugar de cancelar la carga completa. |
| RF18 | El sistema debe enviar un código de verificación al correo o teléfono (en caso de haber sido proporcionado) para asegurar que realmente exista. |
| RF19 | El sistema debe permitir editar la información de perfil de los fotógrafos. |
| RF20 | El sistema debe permitir al fotógrafo modificar los datos básicos de una imagen o video ya subido (título, descripción o colección) sin necesidad de volver a subir el archivo. |
| RF21 | El sistema debe permitir al usuario marcar y desmarcar como favorita, mediante un ícono de estrella ubicado en la esquina inferior (derecha o izquierda) del contenido, cualquier imagen o video de una colección pública o de una colección privada a la que tenga acceso autorizado, sin exponer esta información a otros usuarios. |
| RF22 | El sistema debe permitir al fotógrafo asignar hashtags a cada colección pública al editar su información, agregando automáticamente el símbolo "#" a cada palabra clave ingresada. |
| RF23 | El sistema debe permitir a los usuarios filtrar y encontrar colecciones públicas por hashtag desde el buscador general de la página. |
| RF24 | El sistema debe exigir que los videos subidos, tanto por el fotógrafo como por un invitado mediante QR, sean un recorte (videoclip) del original y no el archivo completo. Si se sube el video original sin recortar, la plataforma no se responsabiliza por la exposición de su contenido completo; dicha responsabilidad recae exclusivamente en quien lo sube. |
| RF25 | El sistema debe limitar el tamaño máximo (en MB) de cada video subido, tanto por el fotógrafo como por un invitado mediante QR. |
| RF26 | Al hacer clic sobre una imagen o video dentro de una colección (pública o privada), el sistema debe mostrar una vista ampliada del archivo mediante un elemento superpuesto, oculto por defecto, con prioridad de visualización sobre el resto del contenido de la página. |
| RF27 | En la vista ampliada, el sistema debe mostrar en el lateral izquierdo un ícono de selección (circular o cuadrado) que permita marcar la imagen o video como seleccionado; mientras el modo selección esté activo, el usuario podrá seleccionar imágenes o videos adicionales haciendo clic directamente sobre ellas dentro de la colección. |
| RF28 | Cuando el fotógrafo confirme una solicitud de descarga en alta calidad, el sistema debe notificar al usuario con el mensaje "¡El fotógrafo ha aceptado la descarga en alta calidad!" junto con las opciones "Aceptar descargar archivos" y "Quizás más tarde". |
| RF29 | El sistema debe permitir al usuario visualizar, en una sección dedicada del menú ("Favoritos"), todas las imágenes y videos que haya marcado como favoritos. |
| RF30 | El sistema debe mostrar al fotógrafo, únicamente en su primer inicio de sesión, un aviso destacado sobre la política de privacidad y la Ley N.º 18.331 de Protección de Datos Personales, indicando que la responsabilidad legal por publicar imágenes de personas sin su autorización recae exclusivamente en el fotógrafo, y que la plataforma no asume responsabilidad ante reclamos o demandas derivadas de dicho uso. |

> "Exclusión de "Cédula" en RF1 porque esta fuera de nuestro alcance y supera por mucho la complejidad de lo propuesto por el cliente. En cambio se propuso un cambio, solo mantener nombre completo, contraseña, número de celular y correo electrónico."

> "Actualización a partir de las mejoras incorporadas (sd.txt): se agregaron los requerimientos RF22 a RF30 y se modificaron RF9, RF12, RF14, RF17 y RF21, cubriendo hashtags y búsqueda de colecciones públicas, selección múltiple con notificación de confirmación, restricciones de formato/tamaño de video, vista ampliada con modo de selección, sección de favoritos y aviso legal sobre la Ley 18.331 al fotógrafo."

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

---

# Parte 5: Épicas del proyecto

## 13. Definición de épicas

Una épica es una funcionalidad grande o área de trabajo que debe dividirse en historias de usuario más pequeñas. En este proyecto, las épicas organizan el alcance principal antes de pasar al Product Backlog.

| Código | Épica | Descripción | Requerimientos vinculados |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles, políticas de privacidad y aviso legal sobre protección de datos personales (Ley 18.331) al fotógrafo. | RF1, RF2, RF3, RF18, RF30 |
| EP2 | Perfiles de fotógrafos | Creación, edición y administración de los perfiles profesionales de los fotógrafos. | RF19 |
| EP3 | Gestión de colecciones | Creación, categorización (públicas/privadas), etiquetado con hashtags, búsqueda por hashtag, visualización pública y control de acceso por URL a colecciones de fotos. | RF4, RF5, RF6, RF22, RF23 |
| EP4 | Carga y procesamiento multimedia | Subida de imágenes y videos, generación de vistas previas optimizadas, aplicación de marca de agua mediante librería, restricciones de formato y tamaño de video, y control de cuota de almacenamiento. | RF7, RF8, RF9, RF17, RF20, RF24, RF25 |
| EP5 | Visualización y descargas | Galería de previsualización para clientes, vista ampliada con selección múltiple, solicitudes de descarga en alta calidad con notificación al fotógrafo, bajada de imágenes (individual o en .zip) y gestión de favoritos. | RF10, RF11, RF12, RF21, RF26, RF27, RF28, RF29 |
| EP6 | Carga colaborativa por QR | Generación de códigos QR para eventos, subida rápida de fotos y videos por invitados (sujeta a las mismas restricciones de formato y tamaño de video definidas en RF24 y RF25) y moderación/gestión posterior del material por parte del fotógrafo (ocultar o eliminar). | RF13, RF14, RF15, RF16 |
| EP7 | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría. | RNF5, RNF6, RNF7 |
| EP8 | Capacitación y cierre | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU. | — (actividad de entrega/capacitación; no corresponde a una función del sistema) |

---


## 9. Estimación de esfuerzo, plazo y costo

## Criterio didáctico de estimación

Para simplificar la explicación, vamos a utilizar una estimación basada en puntos de historia (story points).

En este ejemplo:

- 1 puntos representan una tarea simple pero con cierta lógica.
- 3 puntos representan una tarea media.
- 5 puntos representan una tarea compleja.
- 8 puntos representan una tarea grande o riesgosa.

> Actualización del criterio: al incorporar las mejoras de "sd.txt" el esfuerzo total del proyecto aumentaba. Para aligerar ese incremento, se decidió correr un lugar la escala de estimación (eliminando el nivel de 13 puntos y bajando un escalón la descripción de cada valor), de modo que las nuevas historias de usuario se estimaran de forma más liviana.

Se asumirá una velocidad promedio del equipo de **27 puntos por sprint**.
Cada sprint tendrá una duración de **3 semanas**.
El proyecto tendrá **5 sprints**, por lo tanto, la duración total estimada será de **15 semanas**.

---

## 10. Estimación por épica

| Código | Épica | Estimación en puntos | Historias asociadas |
| --- | --- | --- | --- |
| EP1 | Gestión de usuarios y seguridad | 26 | HU1, HU8, HU19, HU21, HU25, HU32 |
| EP2 | Perfiles de fotógrafos | 5 | HU18 |
| EP3 | Gestión de colecciones | 27 | HU2, HU3, HU20, HU24, HU26, HU27 |
| EP4 | Carga y procesamiento multimedia | 33 | HU5, HU6, HU14, HU16, HU22, HU28, HU29 |
| EP5 | Visualización y descarga | 19 | HU9, HU10, HU23, HU30, HU31 |
| EP6 | Carga colaborativa por QR | 28 | HU4, HU7, HU11, HU12, HU17 |
| EP7 | Mantenimiento técnico y respaldo | 8 | HU13 |
| EP8 | Capacitación y cierre | 3 | HU15 |
| **Total** | | **149 puntos** | |

> Nota: el total pasó de 136 a 149 puntos tras incorporar las historias derivadas de "sd.txt" (HU26 a HU32). Se mantiene la planificación original de 5 sprints a 27 puntos/sprint (135 puntos de capacidad nominal); el excedente se reparte entre sprints puntuales (ver Sprint 3 y Sprint 5 en la sección 15), tal como ya ocurría en la planificación original. Se recomienda revisarlo en el Sprint Planning real.

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
| HU9 | Como usuario/cliente, quiero seleccionar una o varias imágenes o videos de una colección y enviar una única solicitud mediante el botón "Enviar confirmación", para que al fotógrafo le llegue una notificación (en su menú lateral izquierdo) y pueda autorizar mi descarga en alta calidad. | 5 | Alta |
| HU10 | Como cliente autorizado, quiero descargar mis fotos de forma individual o en un archivo comprimido (.zip), para obtener mi material de manera ágil. | 3 | Media |
| HU11 | Como invitado de un evento, quiero escanear el código QR para subir directamente mis fotos (JPG) y videos (en formato de recorte/clip) a la colección, sin necesidad de crearme una cuenta compleja. | 5 | Media |
| HU12 | Como fotógrafo, quiero visualizar y gestionar (eliminar) el material subido por invitados para tener un control sobre la colección. | 5 | Media |
| HU13 | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. | 8 | Media |
| HU14 | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para poder previsualizar el trabajo antes de descargarlo en alta calidad. | 8 | Alta |
| HU15 | Como fotógrafo/cliente, quiero contar con una guía básica de uso y recibir una breve capacitación sobre la plataforma, para poder utilizarla de forma autónoma una vez finalizado el proyecto. | 3 | Media |
| HU16 | Como sistema, quiero impedir al fotógrafo subir imágenes o videos si supera la cuota de almacenamiento, cargando únicamente los archivos que sí entren en la cuota disponible y mostrando un error para los que la superen, para no sobrecargar el espacio en el sistema de archivos sin bloquear una carga completa por un solo archivo problemático. | 8 | Media |
| HU17 | Como fotógrafo, quiero generar un código QR único de una colección, para permitir la visualización y descarga de las imágenes (según los permisos habilitados) de la colección, sin necesidad de buscar mi perfil. | 5 | Media |
| HU18 | Como fotógrafo, quiero editar mi información de perfil y contacto comercial, para que los clientes me reconozcan. | 5 | Media |
| HU19 | Como sistema, quiero impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente, para que exista solo una única cuenta por correo. | 5 | Media |
| HU20 | Como sistema, quiero impedir cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados, para mantener el orden. | 8 | Media |
| HU21 | Como sistema, quiero enviar un código de verificación al correo o teléfono (si fue proporcionado), para asegurar si realmente pertenece a esa persona. | 5 | Media |
| HU22 | Como fotógrafo, quiero editar los datos básicos (título, descripción) de una imagen o video ya subido, para no tener que subirlo de nuevo para cambiar los datos básicos. | 5 | Media |
| HU23 | Como usuario, quiero marcar como favorita, mediante un ícono de estrella, una imagen o video de una colección pública o de una colección privada a la que tenga autorización, para poder encontrarla más tarde en una sección dedicada de "Favoritos" en el menú. | 5 | Baja |
| HU24 | Como usuario, quiero ingresar a colecciones públicas y explorar sus galerías con imágenes o videos en vista previa protegidos con marca de agua, para conocer el catálogo disponible. | 5 | Media |
| HU25 | Como sistema, quiero que cada usuario, independientemente de si es Fotógrafo o Cliente, se registre proporcionando su nombre completo, correo electrónico y contraseña de forma obligatoria, dejando el número de teléfono como opcional, para validar e identificar su identidad. | 5 | Media |
| HU26 | Como fotógrafo, quiero asignar hashtags a mis colecciones públicas al editar su información, para que los usuarios puedan encontrarlas más fácilmente en el buscador. | 1 | Media |
| HU27 | Como usuario, quiero filtrar colecciones públicas por hashtag desde el buscador de la página, para encontrar contenido de mi interés de forma más rápida. | 3 | Media |
| HU28 | Como sistema, quiero exigir que los videos subidos por el fotógrafo o por un invitado sean un recorte (videoclip) del original, para proteger el contenido en los casos donde no es posible aplicar marca de agua; si se sube el video completo, la responsabilidad es de quien lo sube. | 1 | Alta |
| HU29 | Como sistema, quiero limitar el tamaño máximo en MB de cada video subido, para controlar el uso de almacenamiento y mantener la estabilidad de la plataforma. | 1 | Alta |
| HU30 | Como usuario, quiero abrir una vista ampliada de una imagen o video de la colección y activar un modo de selección múltiple mediante un ícono circular o cuadrado, para elegir varios archivos antes de solicitar su descarga en alta calidad. | 5 | Baja |
| HU31 | Como usuario, quiero recibir una notificación con las opciones "Aceptar descargar archivos" y "Quizás más tarde" cuando el fotógrafo confirme mi solicitud, para decidir si descargo el contenido en ese momento o más tarde. | 1 | Baja |
| HU32 | Como fotógrafo, quiero ver, en mi primer inicio de sesión, un aviso sobre la política de privacidad y la Ley 18.331 de protección de datos personales, para conocer que la responsabilidad legal por el uso indebido de imágenes de terceros es exclusivamente mía. | 1 | Alta |

---

## 15. Product Backlog inicial

## Backlog priorizado

| Orden | ID | Historia | Puntos | Sprint estimado |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU1 | Inicio de sesión básico (acceso a paneles) | 5 | Sprint 1 |
| 2 | HU2 | Creación de colecciones y clasificación de visibilidad | 5 | Sprint 1 |
| 3 | HU5 | Subida de imágenes o videos a colecciones | 5 | Sprint 1 |
| 4 | HU10 | Descarga individual o comprimida (.zip) | 3 | Sprint 1 |
| 5 | HU14 | Visualización con marca de agua automática | 8 | Sprint 1 |
| 6 | HU28 | Restricción de video a recorte/clip (sin marca de agua) | 1 | Sprint 1 |
| 7 | HU29 | Límite de tamaño (MB) por video subido | 1 | Sprint 1 |
| 8 | HU3 | Autorización manual de clientes a colecciones privadas | 5 | Sprint 2 |
| 9 | HU8 | Registro con selección de rol (Fotógrafo / Cliente) | 5 | Sprint 2 |
| 10 | HU25 | Registro obligatorio de campos (Nombre, correo, contraseña y teléfono opcional) | 5 | Sprint 2 |
| 11 | HU19 | Impedir el registro de usuarios duplicados por correo | 5 | Sprint 2 |
| 12 | HU21 | Envío de código de verificación al correo/teléfono | 5 | Sprint 2 |
| 13 | HU32 | Aviso legal de privacidad y Ley 18.331 al fotógrafo | 1 | Sprint 2 |
| 14 | HU20 | Bloqueo de acceso directo por URL a colecciones privadas | 8 | Sprint 3 |
| 15 | HU4, HU17 | Generación de códigos QR de colección (Acceso directo, descarga y subida colaborativa) | 13 | Sprint 3 |
| 16 | HU7 | Descarga e impresión física del código QR | 5 | Sprint 3 |
| 17 | HU24 | Acceso y visualización de galerías en colecciones públicas | 5 | Sprint 3 |
| 18 | HU26 | Asignación de hashtags a colecciones públicas | 1 | Sprint 3 |
| 19 | HU27 | Búsqueda/filtro de colecciones públicas por hashtag | 3 | Sprint 3 |
| 20 | HU11 | Carga de archivos vía QR por invitados (JPG y recorte de video) | 5 | Sprint 4 |
| 21 | HU12 | Moderación de material de invitados (ocultar/eliminar) | 5 | Sprint 4 |
| 22 | HU6 | Eliminación regular de imágenes o videos | 5 | Sprint 4 |
| 23 | HU9 | Solicitud y notificación/aprobación de descarga en alta calidad (selección múltiple) | 5 | Sprint 4 |
| 24 | HU16 | Restricción por superación de la cuota de espacio (carga parcial con error puntual) | 8 | Sprint 4 |
| 25 | HU23 | Marcar como favorita una imagen o video (con sección dedicada) | 5 | Sprint 5 |
| 26 | HU18 | Edición de información del perfil del fotógrafo | 5 | Sprint 5 |
| 27 | HU22 | Edición de datos básicos de un archivo ya subido | 5 | Sprint 5 |
| 28 | HU13 | Respaldo automático diario de base de datos (3 copias) | 8 | Sprint 5 |
| 29 | HU15 | Entrega de guía de uso, capacitación y cierre | 3 | Sprint 5 |
| 30 | HU30 | Vista ampliada con selección múltiple de contenido | 5 | Sprint 5 |
| 31 | HU31 | Notificación de confirmación con opciones de descarga | 1 | Sprint 5 |

---

## Puntos por sprint (resumen)

| Sprint | Puntos totales |
| --- | --- |
| Sprint 1 | 28 |
| Sprint 2 | 26 |
| Sprint 3 | 35 |
| Sprint 4 | 28 |
| Sprint 5 | 32 |
| **Total** | **149** |