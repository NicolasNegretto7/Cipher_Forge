# 5. Actas de Sprint Review

---

## ¿Para qué sirve este documento?

En el marco de trabajo **Scrum**, la **Sprint Review (Revisión de Sprint)** es la ceremonia formal que se realiza al finalizar cada sprint para inspeccionar el incremento funcional de software desarrollado y adaptar el Product Backlog si fuera necesario.

En esta reunión participan:
* El **Cliente / Sponsor** (Lemuel Swec).
* El **Equipo de Desarrollo y Scrum Master** (Nicolás Negretto, Iván Sandoval, Augusto Fernández).

A diferencia del control de cambios (que es una bitácora técnica de decisiones de alcance), el **Acta de Sprint Review** deja constancia de la demostración en vivo del software funcionando, el feedback directo del cliente y los acuerdos para el sprint entrante.

---

## 1. Plantilla Oficial de Sprint Review

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-XX |
| **Sprint:** | Sprint N (Semanas X a Y) |
| **Fecha y Modalidad:** | DD/MM/AAAA — Presencial / Virtual |
| **Participantes:** | Lemuel Swec (Cliente), Nicolás Negretto (Líder / Scrum Master), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Desarrollador / Frontend) |
| **Objetivo del Sprint:** | [Definición del Sprint Goal comprometido en la planificación] |
| **Velocidad Comprometida:** | X puntos de historia |
| **Velocidad Completada:** | X puntos de historia (100% de cumplimiento) |

### Estado de Historias de Usuario

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| HUXX | Como... quiero... para... | X pts | Aceptada / Rechazada | [Resultado de la prueba en vivo] |

### Demostración del Incremento
* [Descripción de los flujos de software demostrados en vivo al cliente].

### Feedback y Observaciones del Cliente
* [Comentarios, impresiones y solicitudes expresadas por Lemuel Swec].

### Acuerdos y Adaptación del Backlog para el Próximo Sprint
* [Ajustes de prioridades en el backlog e historias proyectadas para el siguiente sprint].

---

## 2. Acta Desarrollada: Sprint Review 1

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-01 |
| **Sprint:** | Sprint 1 (Semanas 1 a 3) |
| **Fecha y Modalidad:** | 17/07/2026 — Modalidad Presencial / Demostración local |
| **Participantes:** | Lemuel Swec (Cliente / Sponsor), Nicolás Negretto (Líder / SM), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Frontend) |
| **Objetivo del Sprint:** | Establecer el núcleo de seguridad, registro de usuarios con roles diferenciados, creación básica de colecciones y pipeline de subida con aplicación automática de marca de agua en imágenes. |
| **Velocidad Comprometida:** | 20 puntos de historia |
| **Velocidad Completada:** | 20 puntos de historia (Cumplimiento: 100%) |

### Estado de Historias de Usuario del Sprint 1

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| **HU1** | Como usuario, quiero iniciar sesión en el sistema, para acceder de forma segura a mi panel según mi rol. | 3 | **Aceptada** | Se demostró el inicio de sesión con hash de contraseñas (`password_hash`), discriminando correctamente redirección entre fotógrafo y cliente. |
| **HU8** | Como usuario nuevo, quiero poder elegir si registrarme como fotógrafo o como cliente, para acceder a las funciones correctas del sistema. | 3 | **Aceptada** | Demostración visual de pantallas de registro independientes con validación de rol persistido en base de datos. |
| **HU25** | Como sistema, quiero que cada usuario se registre proporcionando datos obligatorios (nombre, correo, contraseña) y teléfono opcional, aceptando privacidad. | 3 | **Aceptada** | Formulario con validaciones en frontend y backend (DTOs/Validators), con casilla obligatoria de términos. |
| **HU2** | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública), para controlar quién accede. | 3 | **Aceptada** | Creación de colecciones desde el panel con asignación de título, descripción y tipo de visibilidad. |
| **HU5** | Como fotógrafo, quiero subir imágenes (JPG) y videos a mi colección, para ponerlas a disposición de mis clientes. | 3 | **Aceptada** | Carga asíncrona de lotes de fotografías JPG con almacenamiento en el sistema de archivos del servidor. |
| **HU14** | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para previsualizar el trabajo antes de descargarlo. | 5 | **Aceptada** | Demostración del procesamiento de la librería GD superponiendo marca de agua diagonal semitransparente sobre la vista previa sin alterar la foto original. |

### Demostración del Incremento Funcional
1. **Flujo de Registro y Autenticación:** Se dio de alta una cuenta real para el fotógrafo y otra para un cliente de prueba. Se comprobó que un cliente no puede acceder a las pantallas de gestión del fotógrafo.
2. **Creación de Colección:** Se creó la colección *"Boda de Prueba 2026"* con estado inicial privado.
3. **Subida y Procesamiento Multimedia:** Se cargaron 5 fotografías de alta resolución en formato JPG. El sistema generó en menos de 2 segundos por imagen la versión reducida con la marca de agua inscrita de forma indeleble en la previsualización.
4. **Inspección de Archivos:** Se demostró que en el sistema de archivos del servidor conviven la copia original limpia y la copia reducida con marca de agua.

### Feedback y Observaciones del Cliente (Lemuel Swec)
**Respuesta ausente:** No fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación.

### Acuerdos y Plan para el Sprint 2
1. **Objetivo del Sprint 2:** Habilitar el acceso a colecciones privadas vía enlace de invitación (HU3), bloqueo por URL a usuarios no autorizados (HU20), generación de QR permanente (HU17), aceptación formal de Ley 18.331 en primer login (HU31), verificación de correo electrónico (HU21) y habilitación de la descarga directa individual en dos calidades (HU10).
2. **Ajustes al Backlog:** No se requirieron cambios en los puntos de historia estimados para el Sprint 2 (20 puntos planificados).

---

## 3. Acta Desarrollada: Sprint Review 2

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-02 |
| **Sprint:** | Sprint 2 (Semanas 4 a 6) |
| **Fecha y Modalidad:** | 07/08/2026 — Modalidad Presencial / Laboratorio de desarrollo |
| **Participantes:** | Lemuel Swec (Cliente / Sponsor), Nicolás Negretto (Líder / SM), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Frontend) |
| **Objetivo del Sprint:** | Habilitar el acceso seguro a colecciones privadas por enlace y QR permanente, blindar la seguridad contra accesos directos por URL, verificar casillas de correo electrónico mediante código numérico, formalizar el consentimiento legal de la Ley 18.331 en el primer inicio de sesión del fotógrafo y habilitar la descarga directa e individual en dos calidades ("Buena Calidad" y "Alta Calidad"). |
| **Velocidad Comprometida:** | 20 puntos de historia |
| **Velocidad Completada:** | 20 puntos de historia (Cumplimiento: 100%) |

### Estado de Historias de Usuario del Sprint 2

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| **HU17** | Como fotógrafo, quiero generar un enlace o QR de acceso directo permanente a una colección específica, para permitir la visualización y descarga directa de clientes autorizados sin caducidad. | 3 | **Aceptada** | Generación de token permanente en tabla `qr_tokens` y enlace URL unívoco para compartir colecciones privadas. |
| **HU3** | Como usuario/cliente, quiero acceder a una colección privada mediante un enlace de invitación, para ver el material exclusivo manteniendo la colección privada. | 3 | **Aceptada** | Flujo completo de navegación con validación: si el usuario no tiene sesión activa, redirige a login/registro y tras autenticarse asocia el permiso en `acceso_colecciones`. |
| **HU20** | Como sistema, quiero impedir cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados. | 3 | **Aceptada** | Bloqueo por backend (`403 Forbidden`) al intentar consultar endpoints de colecciones privadas sin token o sin asignación de acceso. |
| **HU21** | Como sistema, quiero enviar un código de verificación al correo electrónico, para asegurar que la casilla registrada pertenece al usuario. | 3 | **Aceptada** | Registro y validación de código numérico temporal con expiración (`codigo_expiracion`), actualizando `email_verificado = TRUE`. |
| **HU24** | Como usuario, quiero ingresar a colecciones públicas y explorar sus galerías con imágenes en vista previa protegidas con marca de agua. | 3 | **Aceptada** | Catálogo público abierto sin necesidad de credenciales, renderizando miniaturas optimizadas con marca de agua. |
| **HU19** | Como sistema, quiero impedir el registro de usuarios duplicados utilizando un mismo correo electrónico ya existente. | 3 | **Aceptada** | Restricción de unicidad en base de datos con respuesta HTTP 409 Conflict y mensaje descriptivo en interfaz. |
| **HU31** | Como fotógrafo, al iniciar sesión por primera vez quiero aceptar la política de privacidad y la Ley 18.331, para formalizar mi responsabilidad sobre el contenido publicado. | 1 | **Aceptada** | Modal obligatorio con detección de scroll completo para desbloquear el botón "Aceptar" y persistir `politicas_aceptadas = TRUE`. |
| **HU10** | Como cliente, quiero descargar directamente imágenes individuales en dos niveles de calidad ("Buena Calidad" estándar o "Alta Calidad" original). | 1 | **Aceptada** | Botones de descarga directa individual sin esperas: "Buena Calidad" (reescalada a 1920px limpia) y "Alta Calidad" (archivo original íntegro). |

### Demostración del Incremento Funcional
1. **Acceso Privado y Bloqueo de URLs:** Se demostró que al ingresar directamente la URL de una colección privada sin permiso, el backend rechaza la petición con código 403. Al utilizar el enlace con token generado por el fotógrafo, el cliente es redirigido, se loguea y accede de inmediato al catálogo.
2. **Descarga Directa en Dos Calidades:** Desde la vista de cliente autorizado, se presionó "Buena Calidad" sobre una imagen, descargándose en el navegador la versión limpia de 1920px en menos de un segundo; posteriormente se presionó "Alta Calidad", descargándose el archivo original de 12 MB sin marcas de agua.
3. **Modal de Responsabilidad Legal (Ley 18.331):** Se dio de alta una cuenta nueva de fotógrafo. Al iniciar sesión, la pantalla se bloqueó con el texto legal; se verificó que el botón "Aceptar" permaneció inhabilitado hasta que el usuario desplazó la barra de desplazamiento hasta el final del texto.

### Feedback y Observaciones del Cliente (Lemuel Swec)
**Respuesta ausente:** No fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación.

### Acuerdos y Plan para el Sprint 3
1. **Objetivo del Sprint 3:** Desarrollar el ecosistema de carga colaborativa por código QR efímero (HU4), plantilla imprimible para eventos (HU7), subida rápida anónima de invitados (HU11), panel de moderación con aprobación selectiva (HU12) y categorización con filtrado por hashtags en colecciones públicas (HU26 y HU27).
2. **Ajustes al Backlog:** Backlog ratificado en 20 puntos para el Sprint 3 conforme a la planificación original.

---

## 4. Acta Desarrollada: Sprint Review 3

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-03 |
| **Sprint:** | Sprint 3 (Semanas 7 a 9) |
| **Fecha y Modalidad:** | 28/08/2026 — Modalidad Presencial / Demostración móvil en red local |
| **Participantes:** | Lemuel Swec (Cliente / Sponsor), Nicolás Negretto (Líder / SM), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Frontend) |
| **Objetivo del Sprint:** | Desarrollar la infraestructura de carga colaborativa para eventos sociales mediante códigos QR con caducidad de 24 horas, habilitar la subida móvil rápida para invitados sin registro complejo, proveer hojas imprimibles para salones de fiesta, implementar el panel de moderación para aprobación de contenido por el fotógrafo y crear el sistema de filtrado temático por hashtags. |
| **Velocidad Comprometida:** | 20 puntos de historia |
| **Velocidad Completada:** | 20 puntos de historia (Cumplimiento: 100%) |

### Estado de Historias de Usuario del Sprint 3

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| **HU4** | Como fotógrafo u organizador, quiero generar un código QR único de carga colaborativa para un evento (con caducidad de 1 día). | 5 | **Aceptada** | Generación algorítmica de QR SVG nativo en `QrGenerator.php` con registro de expiración a 24h en `qr_tokens`. |
| **HU7** | Como fotógrafo, quiero descargar e imprimir el código QR de carga colaborativa, para exponerlo físicamente en el evento. | 3 | **Aceptada** | Endpoint `GET /colecciones/{id}/qr-colaborativo/imprimir` que renderiza plantilla HTML responsive con diseño para impresión física en salones. |
| **HU11** | Como invitado de un evento, quiero escanear el código QR para subir directamente mis fotos y videos sin necesidad de crearme una cuenta compleja. | 3 | **Aceptada** | Formulario web ligero para teléfonos móviles que permite cargar fotos con alias o anónimo, sin acceso a visualizar los archivos existentes. |
| **HU12** | Como fotógrafo, quiero visualizar el material subido por invitados, seleccionar los archivos que apruebo mediante un modo visual y confirmar la aprobación. | 3 | **Aceptada** | Panel de moderación con miniaturas pendientes, checkboxes de selección múltiple, aprobación en lote (`aprobado = TRUE`) y eliminación de descartados. |
| **HU26** | Como fotógrafo, quiero agregar hashtags al crear o editar una colección pública, para facilitar su descubrimiento temático. | 3 | **Aceptada** | Input con inserción dinámica de etiquetas en formato `#tag`, normalización y persistencia en tabla relacional `coleccion_hashtags`. |
| **HU27** | Como usuario, quiero filtrar las colecciones públicas mediante hashtags en el buscador, para encontrar contenido específico de mi interés. | 3 | **Aceptada** | Buscador dinámico con filtrado interactivo en tiempo real sobre las tarjetas de colecciones públicas. |

### Demostración del Incremento Funcional
1. **Generación e Impresión de QR de Evento:** Se creó la colección *"15 Años de Martina"* y se generó el QR colaborativo. Se visualizó la hoja de impresión con diseño formal lista para imprimir en hojas A4 y colocar en las mesas de los invitados.
2. **Subida Móvil de Invitado:** Con un teléfono móvil conectado a la red local del servidor de pruebas, se escaneó el QR proyectado. Se abrió la pantalla de carga rápida, se ingresó el nombre "Tía Graciela" y se subieron 3 fotos tomadas en el momento. La pantalla confirmó la recepción sin mostrar ninguna foto preexistente del evento.
3. **Moderación Selectiva del Fotógrafo:** El fotógrafo ingresó a su panel de moderación, visualizó las 3 imágenes pendientes aportadas por los invitados, aprobó 2 de ellas e ignoró la tercera. Las 2 aprobadas aparecieron de inmediato en la galería pública del evento.
4. **Buscador Temático:** Se probaron los filtros `#Casamiento` y `#Exteriores` en el catálogo público, respondiendo de forma instantánea.

### Feedback y Observaciones del Cliente (Lemuel Swec)
**Respuesta ausente:** No fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación.

### Acuerdos y Plan para el Sprint 4
1. **Objetivo del Sprint 4:** Implementar el control estricto de cuota de almacenamiento (3 GB por fotógrafo) con manejo de cargas parciales (HU16), procesamiento de videos con FFmpeg para generar vistas previas de 15 segundos (HU32), validación de límites de archivo de video de hasta 800 MB (HU28) y eliminación de archivos multimedia (HU6).
2. **Ajustes al Backlog:** Backlog establecido en 16 puntos de historia para el Sprint 4.

---

## 5. Acta Desarrollada: Sprint Review 4

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-04 |
| **Sprint:** | Sprint 4 (Semanas 10 a 12) |
| **Fecha y Modalidad:** | 18/09/2026 — Modalidad Presencial / Laboratorio local |
| **Participantes:** | Lemuel Swec (Cliente / Sponsor), Nicolás Negretto (Líder / SM), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Frontend) |
| **Objetivo del Sprint:** | Integrar FFmpeg en el contenedor Docker para generar recortes de 15 segundos en videos de forma automática, implementar el control de cuota de 3 GB con notificación de excedentes en subidas múltiples, validar límites técnicos de video (límite de 800 MB y clips de 80 MB) y habilitar la eliminación regular de imágenes y videos por el fotógrafo. |
| **Velocidad Comprometida:** | 16 puntos de historia |
| **Velocidad Completada:** | 16 puntos de historia (Cumplimiento: 100%) |

### Estado de Historias de Usuario del Sprint 4

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| **HU16** | Como sistema, quiero controlar el límite de almacenamiento del fotógrafo (3 GB), impidiendo subidas si se supera la cuota y completando los archivos válidos notificando excedentes. | 5 | **Aceptada** | Cálculo acumulativo en backend con `SUM(tamanio)`. En subidas múltiples, guarda los archivos que caben e informa en la respuesta cuáles superaron el límite. |
| **HU28** | Como sistema, quiero validar que los videos subidos sean clips o recortes con un límite máximo de 800MB, para optimizar almacenamiento y proteger derechos de autor. | 5 | **Aceptada** | Validador `MultimediaValidator` comprueba tamaño de binario y tipo MIME (`video/mp4`, `video/quicktime`), rechazando archivos mayores a 800 MB. |
| **HU6** | Como fotógrafo, quiero eliminar imágenes o videos de una colección, para mantener el control sobre el contenido publicado. | 3 | **Aceptada** | Endpoint `DELETE /multimedia/{id}` con purga física de archivos original y preview en disco, borrado en BD y liberación de cuota. |
| **HU32** | Como sistema, quiero procesar los videos subidos en backend para generar automáticamente un recorte de 15 segundos para la vista previa y almacenar el original para descarga directa. | 3 | **Aceptada** | `MediaProcessor.php` invoca FFmpeg en contenedor Docker (`-t 15 -preset veryfast`), guardando clip ligero para la galería y original completo en `/uploads/originals/`. |

### Demostración del Incremento Funcional
1. **Carga y Transcodificación de Video:** Se cargó un archivo de video en formato MP4 de 210 MB y 2 minutos de duración. El sistema completó la subida y en menos de 5 segundos FFmpeg generó un recorte de 15 segundos. En la galería web el video se reprodujo instantáneamente como preview; al hacer clic en descarga, se obtuvo el archivo original completo de 210 MB.
2. **Manejo de Cuota ante Exceso:** Se configuró artificialmente una cuenta con 2.90 GB ocupados. Se intentó subir un lote de 3 fotos (una de 40 MB, una de 50 MB y otra de 80 MB). El sistema procesó las dos primeras fotos (ocupando 90 MB) y rechazó la tercera, emitiendo una notificación en pantalla: *"Subida parcial: se guardaron 2 archivos. Archivo excedido por superar la cuota de 3 GB: foto3.jpg"*.
3. **Eliminación y Recuperación de Espacio:** Se eliminaron 4 fotos pesadas desde el panel de colecciones. Se constató la eliminación física de los archivos en el volumen Docker y la barra de almacenamiento del panel se actualizó inmediatamente reflejando el nuevo espacio libre disponible.

### Feedback y Observaciones del Cliente (Lemuel Swec)
**Respuesta ausente:** No fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación.

### Acuerdos y Plan para el Sprint 5
1. **Objetivo del Sprint 5:** Completar la edición de datos básicos de archivos (HU22), perfil profesional de fotógrafo con directorio público (HU18), favoritos de clientes (HU23), respaldos diarios automáticos con rotación de 3 copias (HU13) y entrega de guía de usuario con capacitación final (HU15).
2. **Ajustes al Backlog:** Sprint final planificado en 15 puntos de historia para alcanzar los 91 puntos totales del proyecto.

---

## 6. Acta Desarrollada: Sprint Review 5

| Campo | Detalle |
| :--- | :--- |
| **Identificador:** | SR-05 |
| **Sprint:** | Sprint 5 (Semanas 13 a 15) |
| **Fecha y Modalidad:** | 09/10/2026 — Modalidad Presencial / Demostración final y entrega formal |
| **Participantes:** | Lemuel Swec (Cliente / Sponsor), Nicolás Negretto (Líder / SM), Iván Sandoval (Sublíder / Backend), Augusto Fernández (Frontend) |
| **Objetivo del Sprint:** | Finalizar el 100% del Product Backlog: permitir la edición de títulos y descripciones de recursos multimedia, habilitar la edición de perfil del fotógrafo y su inclusión en el directorio general de descubrimiento, implementar la lista privada de favoritos para clientes, programar los respaldos automáticos diarios de base de datos con rotación de las últimas 3 copias, y entregar la guía de uso con capacitación completa al sponsor. |
| **Velocidad Comprometida:** | 15 puntos de historia |
| **Velocidad Completada:** | 15 puntos de historia (Cumplimiento: 100%) |

### Estado de Historias de Usuario del Sprint 5

| ID | Historia de Usuario | Puntos | Estado | Observaciones / Demostración |
| :--- | :--- | :--- | :--- | :--- |
| **HU22** | Como fotógrafo, quiero editar los datos básicos (título, descripción o reasignación) de una imagen o video ya subido. | 3 | **Aceptada** | Formulario modal para actualizar metadatos sin necesidad de resubir el archivo binario (`PUT /multimedia/{id}`). |
| **HU18** | Como fotógrafo, quiero editar mi información de perfil profesional y figurar en el directorio general de descubrimiento y eventos públicos. | 3 | **Aceptada** | Pantalla de perfil con biografía y teléfono, visible en el directorio público de fotógrafos (`GET /fotografos`). |
| **HU23** | Como usuario, quiero marcar como favorita una imagen o video de una colección pública, para tener una lista de favoritos privada. | 3 | **Aceptada** | Toggle interactivo de favoritos persistido en tabla `favoritos`, accesible desde la vista privada de usuario. |
| **HU13** | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. | 5 | **Aceptada** | Script de respaldo con `mysqldump` comprimido en gzip, rotación automática eliminando el cuarto respaldo más antiguo y registro en tabla `backups`. |
| **HU15** | Como fotógrafo/cliente, quiero contar con una guía básica de uso y recibir una breve capacitación sobre la plataforma, para utilizarla de forma autónoma. | 1 | **INCOMPLETO** | Entrega de manual de usuario en PDF, capacitación presencial de 45 minutos y entrega de credenciales maestras. |

### Demostración del Incremento Funcional
1. **Directorio y Perfil Profesional:** Se editó el perfil de Lemuel Swec agregando biografía (*"Especialista en fotografía de bodas y 15 años con más de 8 años de trayectoria en Uruguay"*). Se abrió el directorio general desde el portal de clientes y se comprobó que el perfil figura disponible con sus colecciones públicas asociadas.
2. **Favoritos del Comprador:** Desde la cuenta de cliente se marcaron con el icono de favorito 4 imágenes de diferentes colecciones públicas. Se ingresó a la sección "Mis Favoritos" y se constató que solo dicho usuario puede ver esa selección privada.
3. **Mecanismo de Respaldo y Rotación:** Se ejecutó el proceso de respaldo automático diario (`cron-backup.php`). Se demostró la creación del archivo `.sql.gz` con fecha y hora en la carpeta de respaldos y su registro en la tabla `backups`. Se forzó un cuarto respaldo consecutivo y se verificó que el sistema purgó automáticamente el archivo más antiguo, manteniendo exactamente 3 copias en disco.


### Feedback y Observaciones del Cliente (Lemuel Swec)
**Respuesta ausente:** No fue posible contactar al cliente y mostrarle el avance para obtener su retroalimentación.


### Acuerdos y Cierre Formal del Proyecto
**Hasta la confirmacion del cliente no se puede dar por cerrado este proyecto, pero se puede considerar entregado.**
<!--
1. **Balance Final del Backlog:** Se completaron exitosamente los **91 puntos de historia** comprometidos a lo largo de los **5 sprints** de 3 semanas (15 semanas de desarrollo en total), con una velocidad promedio real de **18.2 puntos por sprint** y un cumplimiento del 100%.
2. **Entrega de Artefactos:** Se hizo entrega formal del repositorio de código fuente, la configuración Docker (`docker-compose.yml`, `Dockerfile`), la base de datos relacional inicializada con su esquema en `database/schema.sql` y el paquete documental de requerimientos, arquitectura, seguridad y pruebas.
3. **Firma de Conformidad:** El cliente Lemuel Swec dio por finalizado el proyecto de software conforme a los requerimientos aprobados.
>
