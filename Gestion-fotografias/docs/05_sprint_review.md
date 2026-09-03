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
* **Aprobación de Calidad Visual:** El cliente expresó conformidad con la nitidez de la vista previa con marca de agua: destacó que supera ampliamente la calidad de compresión destructiva de WhatsApp.
* **Comentarios sobre el Flujo:** Preguntó cómo compartirá la colección privada con sus clientes sin exponerla en la web general. El equipo explicó que ese módulo corresponde al Sprint 2 mediante enlaces de invitación y tokens de acceso directo (HU3 y HU17).
* **Definición de Pagos/Descargas:** El cliente reiteró su conformidad con que la descarga sea directa en dos niveles de calidad (Buena y Alta) sin trabas de notificaciones, ajustándose a la restricción de pagos de UTU acordada previamente.

### Acuerdos y Plan para el Sprint 2
1. **Objetivo del Sprint 2:** Habilitar el acceso a colecciones privadas vía enlace de invitación (HU3), bloqueo por URL a usuarios no autorizados (HU20), generación de QR permanente (HU17), aceptación formal de Ley 18.331 en primer login (HU31), verificación de correo electrónico (HU21) y habilitación de la descarga directa individual en dos calidades (HU10).
2. **Ajustes al Backlog:** No se requirieron cambios en los puntos de historia estimados para el Sprint 2 (20 puntos planificados).
