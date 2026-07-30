# Documento de Análisis de Ambigüedades, Contradicciones y Preguntas Clave para el Project Manager

**Proyecto:** Plataforma Web para Fotógrafos y Compradores de Material Fotográfico  
**Documentos de Origen Analizados:** `01-requerimientos (4).md`, Transcripciones de Entrevista Parte 1 y Parte 2 (`Screen Recording 2026-07-10 112551.txt` / TurboScribe transcripts)  
**Objetivo:** Identificar todas las ambigüedades, declaraciones contradictorias, vacíos de definición y restricciones técnicas no resueltas presentes en la documentación del cliente para unificarlas en decisiones concretas de desarrollo antes de la validación final.

---

## Resumen Ejecutivo

Durante el análisis exhaustivo de la entrevista realizada al cliente (Lemuel Swec) y la documentación de requerimientos generada (`01-requerimientos (4).md`), se detectaron múltiples inconsistencias lógicas, contradicciones directas entre lo expresado verbalmente y lo documentado, así como compromisos de diseño técnico que presentan alta ambigüedad o imposibilidad de implementación web estándar.

Este documento consolida cada uno de estos hallazgos en formato de **Preguntas de Mitigación**, acompañadas de sus citas directas de origen, la inconsistencia identificada y una **Propuesta de Unificación** para que el Project Manager (PM) determine el camino técnico definitivo.

---

## 1. Visibilidad de la Plataforma: ¿Red Social vs. Vínculo Privado? +++

### Citas de Origen
* **Entrevista (Cliente):** *"Lo que yo estoy buscando no es como si fuese una red social en el que yo entre y pueda ver mi perfil... sino que sea un contacto directo de vendedor a consumidor... si querés entrar a la página y buscarme a mí, no lo vas a encontrar."*
* **Entrevista (Cliente) y Doc. Sec. 5:** *"Sí le parece bien que exista una página general donde aparezcan perfiles y eventos de fotógrafos para que la gente se contacte, pero sin exponer todo el contenido."*
* **Doc. Alcance Excluido #3:** *"Perfil público con acceso libre a todo el material del fotógrafo."*
* **Doc. RF4, RF11:** *"El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como públicas o privadas."*

### Conflicto / Ambigüedad
Existe una contradicción entre la afirmación de que el sistema **no debe permitir encontrar ni buscar al fotógrafo en la plataforma** (acceso 100% privado por enlace/QR directo) y la solicitud simultánea de una **página principal con un catálogo general de perfiles de fotógrafos y eventos**. Si existe un catálogo/directorio general accesible, el sistema adquiere dinámicas públicas tipo directorio/red profesional.

### Preguntas para el PM
1. ¿La plataforma tendrá un catálogo/directorio público en la Home donde cualquier visitante pueda buscar e ingresar a los perfiles de fotógrafos y ver eventos/colecciones públicas?
2. Si el perfil es público, ¿qué datos exactos del fotógrafo y qué miniaturas de colecciones se muestran abiertamente sin requerir autorización o código QR?
3. **Propuesta de Unificación Sugerida:** Mantener el sistema orientado a galerías privadas por QR/enlace. La página principal (*Landing Page*) solo incluirá una sección informativa general y un buscador directo por *Código de Evento/PIN*, sin indexar perfiles ni colecciones en un directorio público global para esta primera versión.

---

## 2. Flujo de Descarga: ¿Compra Directa Inmediata vs. Notificación y Aprobación Manual? +++

### Citas de Origen
* **Entrevista (Cliente):** *"Quiero que sea algo más descentralizado... compré, ¡pum!, descargué. No se hace un pedido de tiempo... Compré y automáticamente pude bajar las cosas."*
* **Doc. RF11 y RF12:** *"El sistema debe enviar una notificación al fotógrafo cuando un usuario solicite la descarga en alta calidad... permitiendo al fotógrafo autorizar o denegar dicha solicitud."*
* **Doc. Alcance Incluido #8:** *"Visualización de imágenes... y solicitud de descarga en alta calidad mediante notificación al fotógrafo."*

### Conflicto / Ambigüedad
El cliente exige por un lado una experiencia inmediata e instantánea (pago/solicitud -> descarga directa al instante), pero en los Requerimientos Funcionales (RF11, RF12) se definió un flujo asincrónico donde el cliente debe "solicitar" y el fotógrafo debe entrar al sistema a "aprobar o rechazar manualmente" la descarga. Esto arruina la inmediatez deseada por el cliente y genera incertidumbre sobre cómo opera la simulación de pago.

### Preguntas para el PM
1. ¿La descarga de alta calidad se libera automáticamente en el momento en que se completa la simulación de cobro/autorización, o depende obligatoriamente de la intervención humana del fotógrafo aprobando la notificación?
2. En las colecciones privadas donde un cliente ya fue autorizado previamente por el fotógrafo, ¿la descarga es 100% directa sin requerir confirmación por cada foto?
3. **Propuesta de Unificación Sugerida:** Si una foto/colección está autorizada (o pagada en el simulador), el botón de descarga en alta calidad habilita el archivo `.zip`/JPG de forma inmediata. La "notificación al fotógrafo" será únicamente un registro histórico en su panel (*log* de descargas realizadas) y no un freno manual de aprobación.

---

## 3. Calidad de Archivos, Formato RAW y Niveles de Calidad de Descarga +++

### Citas de Origen
* **Entrevista (Equipo a Cliente):** *"¿En qué calidad debería subirse? ¿Hace falta RAW?"* -> **Cliente:** *"No hace falta RAW; JPG está bien... pero con una calidad bastante mejor que la de WhatsApp."*
* **Entrevista (Parte 2):** **Equipo:** *"Pensamos que pueda subir el RAW..."* -> **Cliente:** *"Sí, está perfecto eso... No en RAW igual, en JPG está bien."*
* **Entrevista (Cliente):** *"Que se pueda bajar de dos maneras: buena calidad o calidad óptima/superior/excelente... Podés ponerle 3, 4, 10, la que vos quieras... Lo que digo es que haya al menos dos."*
* **Doc. RF7, RF8:** *"El sistema debe permitir al fotógrafo subir imágenes (JPG)... generar automáticamente una versión optimizada y más ligera para vista previa."*

### Conflicto / Ambigüedad
El diálogo con el cliente osciló entre rechazar el formato RAW, aceptarlo y volver a descartarlo. Asimismo, el cliente solicitó que el comprador pueda elegir descargar en al menos "dos calidades distintas" (ej. Calidad Web/Media vs. Alta Calidad Original/Impresión), mientras que los requerimientos solo contemplan una vista previa optimizada y una única descarga autorizada en alta calidad.

### Preguntas para el PM
1. ¿Se descarta definitivamente la subida/almacenamiento de archivos RAW (.CR2, .NEF, .ARW) manteniendo únicamente JPG/PNG para evitar costos y sobrecarga del servidor?
2. ¿El sistema debe generar y ofrecer obligatoriamente **dos opciones de descarga** (ej. *Calidad Web - 1080p* y *Calidad Original/Impresión*) para una misma foto autorizada, o basta con la descarga del archivo original en alta resolución?
3. **Propuesta de Unificación Sugerida:** Restringir subidas strictly a JPG/PNG. Al autorizar la descarga, el usuario dispondrá de dos botones de descarga: "Calidad Web (Redes)" e "Hi-Res (Impresión)", generadas automáticamente durante el procesamiento del servidor.

---

## 4. Restricción Anti-Captura de Pantalla (*Screenshots*) en Entorno Web ---

### Citas de Origen
* **Entrevista (Cliente):** *"Con marca de agua y restricciones para descargar o hacer captura de pantalla... WhatsApp te manda la foto para ver una sola vez y no podés sacar screenshot, o páginas que lo tienen deshabilitado... No sé cómo funciona eso para ustedes, capaz sea un desafío."*
* **Doc. RF9:** *"El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en vista previa, y una protección equivalente sobre los videos... para proteger la propiedad intelectual."*

### Conflicto / Ambigüedad / Imposibilidad Técnica
El cliente asume que la plataforma web puede bloquear técnicamente las capturas de pantalla (*screenshots* o *screen recordings*) como lo hacen las aplicaciones móviles nativas (ej. mediante APIs Android/iOS como `FLAG_SECURE`). En navegadores web estándar (Chrome, Firefox, Safari), **es técnicamente imposible evitar que un sistema operativo o dispositivo tome una captura de pantalla del monitor o pantalla móvil**.

### Preguntas para el PM
1. ¿Se ha aclarado formalmente al cliente que en un sitio web no se pueden bloquear los *screenshots* del sistema operativo y que la única protección real frente a esto es la marca de agua visible e indeleble sobre la vista previa?
2. ¿Qué medidas disuasorias adicionales en Frontend se implementarán (ej. deshabilitar clic derecho `contextmenu`, deshabilitar arrastrar imagen `dragstart`)?
3. **Propuesta de Unificación Sugerida:** Documentar explícitamente como alcance que la protección anti-copia en la web se basa en la **marca de agua superpuesta de alta densidad** sobre la versión ligera de previsualización y el bloqueo de eventos de clic derecho/guardar como. Aclarar al cliente que el bloqueo de *screenshots* a nivel de sistema operativo requiere una App Móvil nativa (excluida del proyecto).

---

## 5. Modelo de Negocio y Monetización (Comisión vs. Suscripción vs. Venta por Espacio) ---

### Citas de Origen
* **Entrevista (Cliente):** *"No quiero depender de intermediarios que retengan la plata... en Lumepic te cobran 20% y el fotógrafo cobra tarde. Prefiero un cobro más directo."*
* **Entrevista (Cliente - más adelante):** *"Piensen en esto: cómo poder lograr, o por foto, sacar un porcentaje para la página... o si no, directamente cobrar una suscripción... o por espacio de almacenamiento como Gmail o Pixieset... Hay que manejarlo."*
* **Doc. Sec. 6 (Restricción UTU):** *"Por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales... El sistema correrá en entorno local."*

### Conflicto / Ambigüedad
El cliente presenta tres modelos de negocio totalmente contradictorios durante la entrevista:
1. Rechaza las comisiones por foto vendida (crítica a Lumepic).
2. Sugiere cobrar un porcentaje por foto o suscripción mensual.
3. Sugiere vender planes por gigabytes de almacenamiento (modelo SaaS / Gmail).

A esto se le suma la restricción institucional de UTU que prohíbe el uso de pasarelas de pago reales.

### Preguntas para el PM
1. ¿Cuál es el modelo de negocio conceptual que simulará la plataforma? (¿Cuota de almacenamiento tipo SaaS donde los fotógrafos pagan suscripción, o comisión por venta?).
2. ¿Cómo debe representarse el flujo financiero en el prototipo para que satisfaga la evaluación del proyecto sin integrar pasarelas de pago reales?
3. **Propuesta de Unificación Sugerida:** Adoptar formalmente el **modelo de suscripción por cuota de almacenamiento (SaaS)**. El fotógrafo dispone de un plan gratuito (ej. 2 GB) y el sistema simula un flujo de actualización (*upgrade*) de plan a almacenamiento superior (ej. 50 GB / 100 GB). Se simula un Checkout de prueba (*Sandbox/Mock*) que aprueba las transacciones instantáneamente.

---

## 6. Carga Colaborativa por QR en Eventos: Seguridad y Moderación +++

### Citas de Origen
* **Entrevista (Cliente):** *"Crear un QR para el evento y que los propios invitados... lo escaneen y suban ahí mismo sus fotos y videos, sin necesidad de un registro complejo."*
* **Doc. RF14:** *"Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo."*
* **Doc. RF15, HU12:** *"El fotógrafo debe poder visualizar y gestionar (eliminar) todo el material multimedia colaborativo subido por los invitados."*

### Conflicto / Ambigüedad
Permitir que personas anónimas (invitados sin cuenta registrada) suban archivos de forma directa mediante un código QR presenta un grave riesgo de seguridad y almacenamiento:
* Inyección de archivos maliciosos, ejecutables o malware disfrazados de imágenes.
* Carga masiva de spam o archivos basura que agoten la cuota de almacenamiento del fotógrafo.
* Subida de contenido explícito u ofensivo.

### Preguntas para el PM
1. ¿Qué nivel de validación anónima se solicitará al invitado antes de permitir la subida vía QR (ej. solicitar únicamente un nombre/alias temporal o captcha para evitar bots)?
2. ¿El contenido subido por los invitados mediante el QR se publica inmediatamente en la galería del evento o requiere una "Bandeja de Moderación / Aprobación Previa" donde el fotógrafo deba revisar los archivos antes de hacerlos visibles?
3. **Propuesta de Unificación Sugerida:** Todo archivo subido mediante el QR de invitado anónimo ingresará a un estado **"Pendiente de Revisión"** en el panel del fotógrafo. El fotógrafo podrá aprobarlos con un clic para publicarlos o descartarlos, evitando así que contenido no deseado afecte la galería del evento o la cuota sin control.

---

## 7. Manejo y Procesamiento de Videos +++

### Citas de Origen
* **Entrevista (Cliente):** *"Una plataforma con capacidad para alojar material gráfico... fotos y videos de eventos... subida y bajada de imágenes y videos."*
* **Doc. RF7, RF9:** *"Subir imágenes (JPG) y videos a su colección... aplicar automáticamente una marca de agua sobre las imágenes en su vista previa, y una protección equivalente sobre los videos (marca de agua superpuesta o restricción de descarga)."*

### Conflicto / Ambigüedad
El tratamiento de video difiere drásticamente del de las imágenes estáticas. La documentación habla de "marca de agua superpuesta o protección equivalente", pero no define límites de peso de archivo de video, formatos soportados (MP4, MOV, WebM), ni el motor de procesamiento para videos (ej. transcodificación con FFmpeg).

### Preguntas para el PM
1. ¿Cuál será el límite máximo de tamaño por archivo de video (ej. 50 MB, 100 MB) considerando que el sistema se ejecutará en un entorno local de prueba?
2. ¿Cómo se aplicará la "protección equivalente" en videos para previsualización? (¿Una marca de agua gráfica fija superpuesta mediante reproductor de video HTML5 o restricción de reproducción a una vista previa cortada de X segundos?).
3. **Propuesta de Unificación Sugerida:** Limitar el tamaño de subida de video a un máximo de **100 MB por archivo en formato MP4**. La previsualización de video en el Frontend utilizará un reproductor HTML5 personalizado que inhabilita el menú contextual, deshabilita la descarga directa y renderiza una capa superpuesta (*overlay*) transparente con la marca de agua del fotógrafo.

---

## 8. Registro de Usuarios, Datos Requeridos y Verificación ===

### Citas de Origen
* **Entrevista (Cliente):** *"Que sea un usuario certificado, que tenga cédula, nombre, dirección... un número de celular vinculado a un correo electrónico... verificación para que no sea un bot."*
* **Doc. Sección 6 y Notas del Equipo:** *"Exclusión de 'Cédula' y 'Dirección' en tabla Seguridad porque está fuera de nuestro alcance y es una página 100% virtual... Se modificó a: Nombre completo, correo electrónico, contraseña y teléfono opcional."*
* **Doc. RF1, RF18, HU21:** *"El sistema debe enviar un código de verificación al correo o teléfono (si fue proporcionado) para asegurar que realmente pertenezca a esa persona."*

### Conflicto / Ambigüedad
Aunque el equipo excluyó acertadamente la Cédula de Identidad y la Dirección por complejidad, el requerimiento RF18 contempla enviar códigos de verificación tanto a correo electrónico como a teléfono celular. Enviar SMS/WhatsApp requiere la integración de servicios de pago de terceros (ej. Twilio), lo cual choca con la restricción de presupuesto $0 y ejecución local.

### Preguntas para el PM
1. ¿Se limitará la verificación de cuenta únicamente al envío de un correo electrónico con código o enlace de activación (*Token SMTP*)?
2. ¿Confirmamos que el campo teléfono es 100% opcional e informativo, sin validación por código SMS?
3. **Propuesta de Unificación Sugerida:** La verificación de registro se realizará exclusivamente vía **correo electrónico** mediante la generación de un código/link de verificación en entorno de desarrollo. Se elimina formalmente cualquier intento de verificación por SMS.

---

## 9. Definición Explícita de Cuotas de Almacenamiento ===

### Citas de Origen
* **Entrevista (Cliente):** *"Con una cuota gratuita chica (menciona 2 o 3 GB, tomando como referencia Pixieset) y la posibilidad de pagar por más espacio."*
* **Doc. RF17 y Alcance Incluido #10:** *"Control de espacio de almacenamiento por usuario (la cantidad será propuesta por el cliente más adelante)."*

### Conflicto / Ambigüedad
El requerimiento RF17 deja la cantidad de almacenamiento como "a ser propuesta más adelante". Dejar variables numéricas abiertas en la documentación de requerimientos genera incertidumbre en las pruebas y en la lógica del sistema (*backend enforcement*).

### Preguntas para el PM
1. ¿Cuáles serán los valores por defecto configurados en la base de datos para la cuota de almacenamiento?
2. ¿Qué sucede cuando el fotógrafo alcanza el 100% de su capacidad? (¿Se bloquean únicamente las subidas o también la generación de nuevas colecciones?).
3. **Propuesta de Unificación Sugerida:** Fijar formalmente en el sistema:
   * **Plan Gratuito (*Default*):** 3 GB de almacenamiento.
   * **Plan Profesional (Simulado):** 50 GB.
   Cuando la cuota alcance el 100%, el backend rechazará nuevas subidas devolviendo el mensaje: *"Cuota de almacenamiento excedida. Actualice su plan para continuar subiendo archivos."* El fotógrafo mantendrá acceso para editar metadatos y permitir descargas a los compradores.

---

## 10. Inconsistencias de Alcance: Plantillas visuales y Redes Sociales ---

### Citas de Origen
* **Entrevista (Cliente):** *"Que cada uno tenga la vinculación directa o se le pueda presentar una plantilla directamente para que lo puedan exponer en las redes sociales (WhatsApp, Instagram, Snapchat)... o plantillas ya predeterminadas como Pixieset."*
* **Doc. Alcance Excluido #2:** *"Plantillas predeterminadas para exposición/publicación de fotos."*
* **Doc. Propuesta presentada al cliente #11:** *"Exclusiones: plantillas predeterminadas para exposición/publicación de fotos."*

### Conflicto / Ambigüedad
El cliente insiste durante la entrevista en contar con plantillas prediseñadas y herramientas para compartir automáticamente en redes sociales. El equipo colocó este punto en la lista de **Alcance Excluido**, pero el cliente dejó en la sección 12 la frase: *"Pendiente de confirmación formal por parte del cliente"*.

### Preguntas para el PM
1. ¿Está totalmente firmado y respaldado que las plantillas estéticas y la integración directa con APIs de redes sociales quedan **FUERA** de la versión 1 del proyecto de egreso?
2. En caso de que el cliente insista en "compartir en redes", ¿es suficiente con un botón de "Copiar enlace al portapapeles / WhatsApp Web share"?
3. **Propuesta de Unificación Sugerida:** Reconfirmar la exclusión de plantillas visuales personalizables. Para la difusión, el sistema proveerá únicamente un botón estándar de *"Copiar Enlace de Colección"* y *"Compartir en WhatsApp"* mediante la API genérica `https://wa.me/?text=...`.

---

## 11. Nombre Oficial del Producto / Plataforma (Marca) ===

### Citas de Origen
* **Doc. Sección 7:** *"Nombre propuesto del producto: ???"*
* **Doc. Sección 8:** *"Para fotógrafos y videógrafos... ??? es una plataforma web..."*
* **Doc. Sección 11:** *"Producto: ???, sistema web para fotógrafos."*

### Conflicto / Ambigüedad
El documento oficial entregado utiliza tres signos de interrogación (`???`) en el nombre oficial del sistema, lo que refleja falta de identidad comercial o falta de acuerdo con el cliente.

### Preguntas para el PM
1. ¿Qué nombre provisional o comercial se asignará al proyecto para reemplazar las marcas de agua de marcadores de posición (`???`) en el código, interfaz y documentación?
2. **Propuesta de Unificación Sugerida:** Utilizar el nombre en clave **"Photorium Web"** o **"Cipher Forge"** de forma provisional en el código y en la interfaz gráfica hasta que el cliente defina una marca comercial oficial.

---

## 12. Flujo de Selección de Fotos vs. Favoritos (Edición post-evento) +++@

### Citas de Origen
* **Entrevista (Cliente):** *"Vos me contrataste para que yo te dé 100 fotos. Bueno, yo ahí tengo 1000 fotos, vos elegís la foto que querés. Entonces, vos ahí elegís 100 fotos... querés que te la edite o querés bajarla así."*
* **Documentación (RF21 / HU23):** *"El sistema debe permitir al cliente marcar y desmarcar como favorita cualquier imagen... para tener una lista de favoritos."*

### Conflicto / Ambigüedad
El cliente describe un flujo de trabajo fotográfico real donde el comprador selecciona un cupo de fotos (ej. 100 de 1000) para que el fotógrafo las edite antes de la descarga final. En los requerimientos (RF21, HU23) solo se implementó "marcar como favorita" de forma privada. No queda claro si los "Favoritos" son un simple marcador personal o si el fotógrafo recibe la lista elegida para proceder a editar/liberar.

### Preguntas para el PM
1. ¿El botón de "Favoritos" es solo un guardado personal del cliente o es una lista de selección que se envía al fotógrafo para que proceda a editar/entregar?
2. En caso de ser un pedido de selección (ej. 100 fotos contratadas), ¿el sistema debe bloquear al cliente cuando intenta seleccionar más del cupo acordado?
3. **Propuesta de Unificación Sugerida:** Mantener "Favoritos" en V1 solo como marcador personal visual del cliente. La funcionalidad de "Selección de paquete para retoque/edición" se declara formalmente fuera de alcance para la V1.

---

## 13. Permisos y Alcance del Código QR para Invitados: ¿Visualización + Descarga o Solo Subida? ===

### Citas de Origen
* **Entrevista (Cliente):** *"Le pide a todos los invitados que le hagan el favor de los videos que hacen de la fiesta, que los suban ahí... Y de repente lo que hago es que me creo un QR y lo pongo en diferentes lugares... la gente escanea y ahí los videos que van haciendo... los manda a eso."*
* **Documentación (RF13, RF14, HU4, HU17):**
  * **RF14:** *"Cualquier invitado... debe poder escanear el código QR... para subir fotos y videos directamente... sin necesidad de un registro complejo."*
  * **HU17:** *"Generar un código QR único... para permitir la visualización y descarga de las imágenes... sin necesidad de buscar mi perfil."*

### Conflicto / Ambigüedad
Existe una confusión entre dos tipos de QR o los permisos de un mismo QR:
1. ¿El QR que se imprime en un evento es exclusivamente una vía de entrada para subir contenido anónimo sin ver lo que subieron otros?  
2. ¿O el QR otorga acceso total para que cualquier invitado vea y descargue gratis las fotos subidas por los demás invitados y el fotógrafo?  

### Preguntas para el PM
1. ¿Existirán dos códigos QR distintos por colección (uno "QR de Carga Colaborativa" y otro "QR de Galería/Descarga") o un único QR con permisos globales? 
2. Si un invitado escanea el QR de carga, ¿puede ver o descargar el material subido por otros invitados, o su pantalla solo le muestra un botón de "Adjuntar/Subir archivo"?
3. **Propuesta de Unificación Sugerida:** Separar conceptualmente ambos flujos:
   * **QR de Carga Colaborativa (Evento):** Solo muestra una interfaz simple de subida (*Upload Zone*) sin dar acceso a la galería ni a descargas.
   * **QR/Enlace de Galería:** Solo permite previsualizar la colección (con marca de agua) y requiere autorización o código PIN para descargar. 

---

## 14. Mecanismo Real de Notificaciones al Fotógrafo ===

### Citas de Origen
* **Entrevista (Cliente):** *"Compré y automáticamente pude bajar las cosas."*
* **Documentación (RF12 / HU9):** *"El sistema debe enviar una notificación al fotógrafo cuando un usuario solicite la descarga en alta calidad... permitiendo al fotógrafo autorizar o denegar dicha solicitud."*

### Conflicto / Ambigüedad
En la arquitectura de un sistema web local (sin servidor SMTP externo de producción ni servicios WebSocket o Push en la nube configurados por la restricción de egreso UTU), la palabra "Notificación" es ambigua. ¿Se refiere a un correo electrónico en tiempo real, una notificación Push en el navegador, o un simple módulo/tab de "Solicitudes Pendientes" dentro del panel del fotógrafo?

### Preguntas para el PM
1. Ante la imposibilidad de contratar servidores de correo masivo o SMS (Twilio/SendGrid), ¿cómo se entregará técnicamente la notificación al fotógrafo?
2. **Propuesta de Unificación Sugerida:** La notificación consistirá en un indicador numérico/Badge en el panel interno del fotógrafo (sección "Solicitudes de Descarga"). Cuando el fotógrafo inicie sesión, verá la lista de solicitudes pendientes con botones de "Aprobar" o "Rechazar".

---

## 15. Política de Limpieza, Expiración y Retención de Almacenamiento +++@

### Citas de Origen
* **Entrevista (Cliente):** *"Si vos de repente tenés un espacio gratuito que te dan 2, 3 gigas para trabajar, entonces vos bajás, subís, bajás, subís, bajás, subís material toda la semana, bien."*
* **Documentación (RF17 / HU16):** *"El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada... permitiendo igualmente la descarga del contenido ya existente."*

### Conflicto / Ambigüedad
El cliente asume un flujo rotativo ("subes, descargas y borras toda la semana"). La documentación especifica que al llegar al 100% de la cuota se bloquean las subidas. Sin embargo, no hay ninguna regla de negocio definida sobre si las colecciones antiguas expiran o se eliminan automáticamente tras X días de inactividad para liberar espacio en el servidor de pruebas.

### Preguntas para el PM
1. ¿El sistema eliminará o archivará automáticamente las colecciones inactivas después de un período (ej. 30 días) para liberar cuota en cuentas gratuitas, o el borrado es 100% manual por el fotógrafo?
2. **Propuesta de Unificación Sugerida:** El borrado de imágenes y colecciones será 100% manual por parte del fotógrafo desde su panel de control. No habrá procesos automáticos de eliminación por tiempo en la V1 para evitar pérdida accidental de datos.

---

## 16. Simulación del Proceso de Pago / Cobro en Entorno Local (UTU) ---

### Citas de Origen
* **Entrevista (Cliente):** *"Al menos con lo más básico... Brou o Prex... hace una transferencia... o pago por Redpagos o Abitab o tarjeta... que la persona compre y automáticamente pueda bajar las cosas."*
* **Documentación (Sección 6 / Alcance Excluido #4):** *"Por tratarse de un equipo de estudiantes... no es posible procesar pagos reales... Exclusión: Métodos de pago."*

### Conflicto / Ambigüedad
Mientras que el Alcance Excluido quita formalmente los "Métodos de Pago", la solicitud del cliente de probar el flujo "Compré -> Pagué -> Descargué" requiere que el prototipo demuestre la experiencia del usuario. Si no hay métodos de pago, el usuario no entiende cómo pasa la foto de "Vista previa con marca de agua" a "Descargable sin marca de agua".

### Preguntas para el PM
1. ¿Qué interfaz exacta se mostrará al cliente cuando presione "Comprar / Solicitar Descarga"?
2. **Propuesta de Unificación Sugerida:** Diseñar un Simulador de Pasarela de Pago (*Mock/Sandbox*). Al hacer clic en "Pagar", se despliega un modal con la opción ficticia "Transferencia / Tarjeta de Prueba". Al presionar "Confirmar Pago Simulado", el sistema cambia el estado del pedido a "Aprobado" y libera automáticamente la descarga en alta calidad.

---

## Matriz de Resumen para el Project Manager

| ID | Área Temática | Conflicto / Ambigüedad Principal | Decisión / Propuesta Unificada Sugerida |
| :--- | :--- | :--- | :--- |
| **M1** | Visibilidad del Sistema | ¿Directorio público de fotógrafos o acceso 100% privado por enlace/QR? | **Acceso por enlace/QR.** Sin directorio público global en V1; buscador por PIN en Landing. |
| **M2** | Flujo de Descargas | ¿Compra e inmediatez directa vs. aprobación manual del fotógrafo por notificación? | **Descarga inmediata** tras simulación de autorización/pago. Notificación funciona como *log* posterior. |
| **M3** | Formato y Calidades | ¿Subida RAW permitida? ¿Cuántas calidades de descarga se generan? | **Solo JPG/PNG.** Se generan 2 opciones de descarga: Calidad Web (1080p) e Hi-Res Original. |
| **M4** | Anti-Captura de Pantalla | Cliente pide evitar *screenshots* en la web (imposible técnicamente). | **Marca de agua densa** en previsualización + bloqueo de clic derecho. Aclarar restricción web al cliente. |
| **M5** | Modelo de Negocio | ¿Comisión por foto, suscripción o venta de espacio? | **Modelo SaaS por cuota de espacio (GB).** Simulación de *upgrade* de plan con pasarela *Mock*. |
| **M6** | QR Colaborativo | Subida anónima de invitados expone a spam o contenido inadecuado. | **Bandeja de Moderación:** Subidas por QR quedan "Pendientes" hasta aprobación del fotógrafo. |
| **M7** | Soporte de Video | No se definen límites de tamaño ni mecanismo de protección de video. | **Límite de 100 MB (MP4).** Reproductor HTML5 sin botón de descarga y con *overlay* de marca de agua. |
| **M8** | Verificación Usuarios | Cliente pide SMS/Cédula; UTU restringe pagos/servicios externos. | **Verificación exclusiva por Correo (SMTP).** Teléfono queda opcional y sin validación SMS. |
| **M9** | Cuotas Espacio | El límite en GB está indefinido en la tabla de RF17. | **Fijar 3 GB Gratis** y 50 GB Pro. Bloqueo de subidas al 100% permitiendo administración y descargas. |
| **M10**| Scope de Redes | Cliente pide plantillas y difusión; alcance documentado las excluye. | **Plantillas Excluidas.** Solo botón genérico de "Copiar enlace" y "Enviar por WhatsApp". |
| **M11**| Marca / Nombre | La documentación tiene `???` como nombre del producto. | Adopción del nombre provisional **"Photorium Web" / "Cipher Forge"** para interfaz y prototipo. |
| **M12**| Selección vs. Favoritos | ¿"Favoritos" es solo un guardado personal o un pedido de selección para edición? | **Favoritos es solo marcador personal.** La selección de paquetes para retoque/edición queda fuera del MVP. |
| **M13**| Permisos QR Invitados | ¿QR da acceso a ver/descargar todo o solo es una zona de subida? | **Separar en 2 QR:** "QR Carga Colaborativa" (solo subida) y "QR/Enlace de Galería" (previsualización con PIN/autorización). |
| **M14**| Mecanismo Notificaciones | ¿Cómo notificar al fotógrafo en sistema local sin servicios en la nube? | **Badge/Indicador interno.** Notificaciones mediante alertas numéricas en el panel de control. |
| **M15**| Retención Almacenamiento | ¿Las colecciones expiran o se eliminan automáticamente tras X días? | **Borrado 100% manual.** No se aplicarán políticas de borrado automático por expiración en V1. |
| **M16**| Simulación de Pagos | ¿Cómo probar el flujo "Compré -> Pagué -> Descargué" si no hay pagos reales? | **Pasarela Mock/Sandbox.** Modal con opciones ficticias que aprueban el estado a "Aprobado" y liberan descarga. |

---

*Fin del documento de análisis de ambigüedades. Este material queda listo para la reunión de alineación estratégica con el Project Manager.*