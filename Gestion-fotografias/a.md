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
| RF9 | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en su vista previa, y una protección equivalente sobre los videos (marca de agua superpuesta o restricción de descarga), para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga. |
| RF10 | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip). |
| RF11 | El sistema debe permitir a los usuarios visualizar las colecciones públicas con imágenes/videos en vista previa (con marca de agua) y disponer de una opción para solicitar la descarga en alta calidad. |
| RF12 | El sistema debe enviar una notificación al fotógrafo cuando un usuario solicite la descarga en alta calidad de un contenido, permitiendo al fotógrafo autorizar o denegar dicha solicitud. |
| RF13 | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica para permitir el acceso directo, la descarga o la carga colaborativa de contenido durante un evento. |
| RF14 | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo. |
| RF15 | El fotógrafo debe poder visualizar y gestionar (eliminar) todo el material multimedia colaborativo subido por los invitados mediante el QR. |
| RF16 | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo a una colección privada específica, distinto del QR de carga colaborativa. |
| RF17 | El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada (la cantidad será propuesta por el cliente más adelante), permitiendo igualmente la descarga del contenido ya existente. |
| RF18 | El sistema debe enviar un código de verificación al correo o teléfono (en caso de haber sido proporcionado) para asegurar que realmente exista. |
| RF19 | El sistema debe permitir editar la información de perfil de los fotógrafos. |
| RF20 | El sistema debe permitir al fotógrafo modificar los datos básicos de una imagen o video ya subido (título, descripción o colección) sin necesidad de volver a subir el archivo. |
| RF21 | El sistema debe permitir al cliente marcar y desmarcar como favorita cualquier imagen perteneciente a una colección a la que tenga acceso autorizado, sin exponer esta información a otros usuarios. |

> "Exclusión de "Cédula" en RF1 porque esta fuera de nuestro alcance y supera por mucho la complejidad de lo propuesto por el cliente. En cambio se propuso un cambio, solo mantener nombre completo, contraseña, número de celular y correo electrónico."

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
| EP1 | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles y políticas de privacidad. | RF1, RF2, RF3, RF18 |
| EP2 | Perfiles de fotógrafos | Creación, edición y administración de los perfiles profesionales de los fotógrafos. | RF19 |
| EP3 | Gestión de colecciones | Creación, categorización (públicas/privadas), visualización pública y control de acceso por URL a colecciones de fotos. | RF4, RF5, RF6 |
| EP4 | Carga y procesamiento multimedia | Subida de imágenes de alta calidad, generación de vistas previas optimizadas y aplicación de marcas de agua. | RF7, RF8, RF9, RF17, RF20 |
| EP5 | Visualización y descargas | Galería de previsualización para clientes, solicitudes de descarga en alta calidad con notificación al fotógrafo y bajada de imágenes (individual o en .zip). | RF10, RF11, RF12, RF21 |
| EP6 | Carga colaborativa por QR | Generación de códigos QR para eventos, subida rápida de fotos por invitados y moderación/gestión posterior del material por parte del fotógrafo (ocultar o eliminar). | RF13, RF14, RF15, RF16 |
| EP7 | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría. | RNF5, RNF6, RNF7 |
| EP8 | Capacitación y cierre | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU. | — (actividad de entrega/capacitación; no corresponde a una función del sistema) |

---
