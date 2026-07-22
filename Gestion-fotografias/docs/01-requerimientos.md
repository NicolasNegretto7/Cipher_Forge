# Documentación de Requerimientos: Sistema de Gestión y Distribución de Material Fotográfico

## 1. Información obtenida en la entrevista

| Categoría | Información relevada |
| :--- | :--- |
| **Problema principal** | Dificultad de entrega inmediata de material fotográfico y baja calidad de imagen. |
| **Objetivo de negocio** | Vínculo comercial comprador-vendedor y el cobro ágil sin intermediarios que retengan el dinero. |
| **Alcance inicial** | Subida y bajada de imágenes, métodos de pago y marca de agua. |
| **Plazo esperado** | 15 semanas (5 sprints de 3 semanas). |
| **Presupuesto** | Proyecto de egreso de UTU (sin presupuesto). |
| **Usuarios** | Fotógrafos y clientes (compradores / invitados). |
| **Infraestructura** | Entorno local para el MVP; arquitectura orientada a la nube para despliegue futuro. |
| **Seguridad** | Cédula de identidad, nombre completo, teléfono, correo electrónico y políticas de privacidad. |
| **Riesgo operativo** | Caída del servidor, gestión de contenido sensible/riesgoso y métodos de pago (estos últimos se considerarán a futuro). |
| **Restricción técnica** | Las imágenes en vista previa deben incluir marca de agua; la descarga autorizada no. |

> **Información de origen:** Información obtenida de la transcripción de la entrevista realizada con el cliente ([Parte 1](https://turboscribe.ai/es/transcript/share/5521413143271206535/BAQ_YceRsNbt_qSbib6HglsceYdjERFhVwK3hj63kII/screen-recording-2026-07-10-112551) y [Parte 2](https://turboscribe.ai/es/transcript/share/5845672316447232238/SpD0uFbmbpp-LPeTqhBtjAwON_rYso_hrBSaekkgC_w/lv-0-20260710161346)). Esta información se validó minuciosamente con la grabación de la entrevista para corregir imprecisiones de la IA de transcripción. Por lo tanto, se confirma que la información es válida, fiel y utilizable para el proyecto.

---

> **Restricción institucional (UTU):** Por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en un entorno local para esta entrega, y se recomendará al cliente, una vez que el equipo se gradúe, migrar el sistema a un servidor en la nube con hosting y dominio propios, habilitando en ese momento un método de pago real.

> **Definición de roles:** El rol "Administrador" de la propuesta inicial de Polo se implementará bajo el alias comercial propuesto por el cliente como "Fotógrafo", mientras que el rol "Cliente" abarcará a los compradores. Los invitados a un evento podrán acceder a una colección específica sin necesidad de registrarse como "Cliente", utilizando el código QR proporcionado por el "Fotógrafo".

> **Aclaración sobre visibilidad de colecciones:** La regla de la propuesta inicial de Polo que indicaba que una colección con cero clientes asignados se convertiría automáticamente en pública queda omitida. Durante la entrevista, el cliente especificó que el "Fotógrafo" decide si una colección es privada o pública independientemente de si tiene clientes asignados o no. Se prioriza esta decisión directa del cliente por sobre la propuesta inicial.

> **Exclusión de campo de dirección:** Se excluye el campo "Dirección" en el módulo de seguridad/registro, ya que la plataforma es 100% digital y no requiere la dirección física del usuario.

---

## 2. Nombre propuesto del producto

**[Nombre del Producto]**  
*Sistema web para fotógrafos y compradores que permite gestionar, proteger, visualizar y comercializar material fotográfico.*

---

## 3. Visión del producto

Para fotógrafos y videógrafos que enfrentan dificultades para entregar su material de forma inmediata, profesional y sin pérdida de calidad, **[Nombre del Producto]** es una plataforma web que permite a los fotógrafos subir, organizar y comercializar su material multimedia —protegido con marca de agua— y a sus compradores previsualizar, seleccionar y descargar dicho contenido en alta resolución.

A diferencia de enviar archivos por WhatsApp (que reduce fuertemente la calidad) o plataformas como Pixyset y Lumipick, nuestro producto combina la protección eficiente del contenido, múltiples niveles de resolución y una gestión de cobro ágil sin retenciones prolongadas de dinero por intermediarios (esta última función se habilitará en una versión futura debido a las restricciones de edad del equipo).

La primera versión estará enfocada en la subida, previsualización protegida con marca de agua y descarga controlada de imágenes y videos.

---

## 4. Alcance incluido

El proyecto incluirá las siguientes funcionalidades:

1. **Gestión de usuarios y roles:** Registro diferenciado y control de acceso.
2. **Registro y verificación de usuarios:** Validación básica de datos.
3. **Perfiles de fotógrafo:** Creación y edición de perfil comercial y de contacto.
4. **Gestión de colecciones:** Creación y clasificación explícita como públicas o privadas.
5. **Carga multimedia:** Subida de imágenes y videos en alta calidad.
6. **Marca de agua:** Aplicación automática sobre las previsualizaciones de las imágenes.
7. **Control de descargas:** Restricción de descarga para contenido no autorizado.
8. **Niveles de calidad:** Opción de visualización y descarga en al menos dos niveles (calidad optimizada/normal y calidad original/alta).
9. **Descarga masiva:** Descarga individual o de múltiples archivos comprimidos en formato `.zip`.
10. **Control de almacenamiento:** Control del límite de espacio por usuario (cuota a definir con el cliente).
11. **Seguridad y privacidad:** Políticas de privacidad y protección de datos personales.
12. **Acceso directo por QR:** Generación de enlaces o códigos QR para acceder directamente a una colección específica de un evento.

---

## 5. Alcance excluido para esta primera versión

Quedan fuera del alcance de la primera versión:

1. Aplicación móvil nativa (iOS/Android).
2. Plantillas predeterminadas de diseño para la exposición de fotos.
3. Integración directa con redes sociales.
4. Perfil público con acceso abierto a todo el catálogo histórico del fotógrafo.
5. Pasarela de pagos reales integradas.
6. Despliegue en hosting y dominio de producción.

---

## 6. Requerimientos funcionales

| Código | Requerimiento funcional |
| :--- | :--- |
| **RF1** | El sistema debe permitir el registro obligatorio de usuarios (fotógrafos y clientes), solicitando Nombre Completo, Cédula de Identidad, Correo Electrónico y Número de Teléfono. |
| **RF2** | El sistema debe impedir el registro de usuarios duplicados utilizando una misma Cédula de Identidad o Correo Electrónico ya existente en la base de datos. |
| **RF3** | El sistema debe proveer una pantalla de inicio de sesión (Login) segura con validación de credenciales. |
| **RF4** | El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como Públicas o Privadas. |
| **RF5** | Las colecciones marcadas como Privadas no cambiarán automáticamente su estado según la cantidad de clientes asignados y solo serán visibles para los clientes explícitamente autorizados por el fotógrafo. |
| **RF6** | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo por URL a colecciones privadas por parte de usuarios no autorizados. |
| **RF7** | El sistema debe permitir al fotógrafo subir imágenes (JPG) y videos a sus colecciones. |
| **RF8** | Al subir una imagen, el sistema debe generar automáticamente una versión optimizada y más ligera para su previsualización fluida en la galería del cliente. |
| **RF9** | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en vista previa y una protección equivalente sobre los videos (marca de agua superpuesta o restricción de descarga). *Nota: Se descartó el bloqueo de captura de pantalla por inviabilidad técnica en entornos web.* |
| **RF10** | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo `.zip`). |
| **RF11** | El sistema debe ofrecer al cliente dos opciones de descarga según los permisos otorgados por el fotógrafo: **Calidad Normal** (versión optimizada) y **Alta Calidad** (archivo original sin pérdida de resolución). |
| **RF12** | El sistema debe permitir al fotógrafo activar o desactivar manualmente el permiso de descarga en "Alta Calidad" para clientes específicos dentro de una colección privada. |
| **RF13** | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica de un evento, para que los invitados puedan subir contenido de forma colaborativa durante la actividad. |
| **RF14** | Cualquier invitado del evento debe poder escanear el código QR con su dispositivo móvil para subir fotos y videos directamente a esa colección, sin requerir un registro complejo de cuenta. |
| **RF15** | El fotógrafo debe poder visualizar y gestionar (ocultar o eliminar) todo el material multimedia colaborativo subido por los invitados a través del código QR. |
| **RF16** | El sistema debe permitir al fotógrafo generar un enlace o código QR de acceso directo para la visualización y descarga de una colección privada específica. |
| **RF17** | El sistema debe impedir que el fotógrafo suba nuevo contenido si supera su cuota de almacenamiento asignada, permitiendo igualmente la descarga del contenido previamente subido. |
| **RF18** | El sistema debe enviar un código de verificación al correo electrónico o teléfono para confirmar la autenticidad del medio de contacto registrado. |
| **RF19** | El sistema debe permitir al fotógrafo editar la información de su perfil y datos de contacto comercial. |
| **RF20** | El sistema debe permitir al fotógrafo modificar los datos básicos de una imagen o video ya subido (título, descripción o colección asociada) sin necesidad de volver a subir el archivo. |
| **RF21** | El sistema debe permitir al cliente marcar y desmarcar como favorita cualquier imagen perteneciente a una colección autorizada, sin exponer esta información a otros usuarios. |
| **RF22** | El sistema debe registrar cada descarga realizada (usuario, archivo/colección, fecha/hora, cantidad de archivos), permitiendo al cliente consultar su historial propio y al fotógrafo consultar estadísticas agregadas. |

---

## 7. Requerimientos no funcionales

| Código | Requerimiento no funcional |
| :--- | :--- |
| **RNF1** | La interfaz de usuario debe ser completamente adaptable (*Responsive Design*) para garantizar una experiencia de usuario óptima en computadoras de escritorio, tablets y dispositivos móviles. |
| **RNF2** | Las galerías y el portal del cliente deben cargar en un tiempo prudencial (menos de 3 segundos bajo conexiones normales). |
| **RNF3** | La interfaz gráfica debe ser simple, ágil, intuitiva y de aspecto profesional. |
| **RNF4** | El sistema debe garantizar la estabilidad del servicio durante las pruebas en entorno local y estar preparado para su futura migración a un hosting de producción. |
| **RNF5** | El sistema debe realizar respaldos automáticos diarios de la base de datos (propuesto por el equipo de desarrollo ante la preocupación del cliente sobre la pérdida de información). |
| **RNF6** | El sistema debe eliminar de manera automática el respaldo más antiguo al generar una nueva copia cuando existan tres respaldos almacenados. |
| **RNF7** | El sistema debe registrar la fecha y hora de cada respaldo automático generado. |

---

## 8. Épicas del proyecto

| Código | Épica | Descripción |
| :--- | :--- | :--- |
| **EP1** | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, gestión de roles y políticas de privacidad. |
| **EP2** | Perfiles de fotógrafo | Creación, edición y administración de los datos profesionales y de contacto del fotógrafo. |
| **EP3** | Gestión de colecciones | Creación, categorización (públicas/privadas) y control de acceso seguro a colecciones. |
| **EP4** | Carga y procesamiento multimedia | Subida de archivos, generación de vistas previas optimizadas y aplicación de marcas de agua. |
| **EP5** | Visualización y descargas | Galería de previsualización para clientes, descarga individual/masiva y selección de calidad. |
| **EP6** | Carga colaborativa por QR | Generación de códigos QR para eventos, carga rápida por invitados y moderación por parte del fotógrafo. |
| **EP7** | Mantenimiento técnico y respaldo | Configuración de respaldos automáticos diarios, rotación de copias y registro de auditoría. |
| **EP8** | Capacitación y cierre | Guía básica de uso, capacitación al cliente y entrega formal del proyecto. |

---

## 9. Estimación de esfuerzo, plazo y costo

### Criterio didáctico de estimación

Para la planificación del trabajo se utiliza una estimación basada en **Puntos de Historia (Story Points)**:

* **1 punto:** Tarea muy pequeña o trivial.
* **3 puntos:** Tarea simple con cierta lógica de negocio.
* **5 puntos:** Tarea de complejidad media.
* **8 puntos:** Tarea compleja con múltiples dependencias.
* **13 puntos:** Tarea grande, compleja o de alto riesgo.

**Parámetros del proyecto:**
* **Velocidad promedio estimada:** 29 puntos por sprint.
* **Duración de cada sprint:** 3 semanas.
* **Cantidad de sprints:** 5 sprints.
* **Duración total estimada:** 15 semanas.

---

## 10. Estimación por épica

| Código | Épica | Estimación (Puntos) | Historias asociadas |
| :--- | :--- | :---: | :--- |
| **EP1** | Gestión de usuarios y seguridad | 25 | HU1, HU8, HU19, HU21, HU25 |
| **EP2** | Perfiles de fotógrafo | 5 | HU18 |
| **EP3** | Gestión de colecciones | 18 | HU2, HU3, HU20 |
| **EP4** | Carga y procesamiento multimedia | 31 | HU5, HU6, HU14, HU16, HU23 |
| **EP5** | Visualización y descarga | 18 | HU9, HU10, HU22, HU24 |
| **EP6** | Carga colaborativa por QR | 28 | HU4, HU7, HU11, HU12, HU17 |
| **EP7** | Mantenimiento técnico y respaldo | 8 | HU13 |
| **EP8** | Capacitación y cierre | 3 | HU15 |
| **Total** | | **136 puntos** | |

---

## 11. Propuesta presentada al cliente

| Elemento | Detalle de la propuesta |
| :--- | :--- |
| **Producto** | Sistema web para fotógrafos y compradores. |
| **Duración** | 15 semanas (5 sprints de 3 semanas). |
| **Metodología** | Scrum con entregas incrementales al final de cada sprint. |
| **Presupuesto** | $0 (Proyecto de Egreso Académico UTU). |
| **Forma de trabajo** | Reuniones de revisión con el cliente al cierre de cada sprint. |
| **Primera versión (MVP)** | Subida/bajada de imágenes y videos, marca de agua y carga colaborativa por QR. |
| **Exclusiones** | App móvil nativa, pasarela de pagos reales, hosting/dominio comercial e integración con redes sociales. |

---

## 12. Aprobación del cliente

> *Pendiente de confirmación formal por parte del cliente. Se espera su respuesta en los próximos días para proceder con el detalle definitivo de los sprints.*

---

## 13. Formato de historias de usuario

Se utiliza la siguiente estructura estándar:

> Como **[tipo de usuario]**, quiero **[acción o necesidad]**, para **[beneficio o resultado esperado]**.

---

## 14. Historias de usuario iniciales

| ID | Historia de usuario | Puntos | Prioridad |
| :--- | :--- | :---: | :--- |
| **HU1** | Como usuario, quiero iniciar sesión en el sistema para acceder de forma segura a mi panel según mi rol. | 5 | Alta |
| **HU2** | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública) para controlar quién puede acceder a ellas. | 5 | Alta |
| **HU3** | Como fotógrafo, quiero autorizar de forma explícita a un cliente mediante sus datos para que acceda a una colección privada. | 5 | Alta |
| **HU4** | Como fotógrafo, quiero generar un código QR único para una colección de evento permitiendo a los asistentes subir imágenes o videos. | 8 | Media |
| **HU5** | Como fotógrafo, quiero subir imágenes (JPG) y videos a mi colección para ponerlos a disposición de mis clientes. | 5 | Alta |
| **HU6** | Como fotógrafo, quiero eliminar imágenes o videos de una colección para mantener el control sobre el contenido publicado. | 5 | Alta |
| **HU7** | Como fotógrafo, quiero descargar el código QR generado para poder imprimirlo físicamente y exponerlo durante el evento. | 5 | Media |
| **HU8** | Como usuario nuevo, quiero seleccionar si deseo registrarme como fotógrafo o como cliente para acceder a las funciones correspondientes. | 5 | Alta |
| **HU9** | Como fotógrafo, quiero habilitar o deshabilitar manualmente el permiso de descarga en "Alta Calidad" para un cliente específico. | 5 | Alta |
| **HU10** | Como cliente autorizado, quiero descargar mis fotos de forma individual o comprimidas en un archivo `.zip` de forma ágil. | 3 | Media |
| **HU11** | Como invitado de un evento, quiero escanear un código QR para subir fotos y videos a la colección sin necesidad de crear una cuenta compleja. | 5 | Media |
| **HU12** | Como fotógrafo, quiero visualizar y moderar (ocultar o eliminar) el material subido por invitados para mantener la calidad de la colección. | 5 | Media |
| **HU13** | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias para mitigar la pérdida de datos. | 8 | Media |
| **HU14** | Como cliente, quiero previsualizar las fotos con marca de agua automática para valorar el trabajo antes de descargarlo en alta calidad. | 8 | Alta |
| **HU15** | Como cliente/fotógrafo, quiero contar con una guía básica de uso y capacitación para operar la plataforma de forma autónoma. | 3 | Media |
| **HU16** | Como sistema, quiero impedir la subida de nuevos archivos si el fotógrafo supera su cuota de almacenamiento asignada. | 8 | Media |
| **HU17** | Como fotógrafo, quiero generar un código QR único para permitir la visualización y descarga directa de una colección específica. | 5 | Media |
| **HU18** | Como fotógrafo, quiero editar mi información de perfil y datos comerciales para que los clientes me reconozcan. | 5 | Media |
| **HU19** | Como sistema, quiero impedir el registro de usuarios duplicados utilizando una misma Cédula de Identidad o Correo Electrónico. | 5 | Media |
| **HU20** | Como sistema, quiero bloquear el acceso directo por URL a colecciones privadas a usuarios no autorizados. | 8 | Media |
| **HU21** | Como sistema, quiero enviar un código de verificación por correo o teléfono para validar la autenticidad del canal de contacto. | 5 | Media |
| **HU22** | Como fotógrafo, quiero consultar estadísticas de descargas de mis colecciones para identificar el contenido más popular. | 5 | Media |
| **HU23** | Como fotógrafo, quiero editar los datos básicos (título, descripción) de un archivo multimedia ya subido. | 5 | Media |
| **HU24** | Como usuario, quiero marcar o desmarcar como favorita una imagen de una colección autorizada para organizar mis elecciones. | 5 | Media |
| **HU25** | Como sistema, quiero requerir que todo usuario se registre obligatoriamente con nombre completo, cédula, correo y teléfono. | 5 | Media |

---

## 15. Product Backlog inicial (priorizado por Sprint)

| Orden | ID | Historia de Usuario | Puntos | Sprint |
| :---: | :--- | :--- | :---: | :---: |
| 1 | **HU1** | Inicio de sesión básico y autenticación por roles | 5 | Sprint 1 |
| 2 | **HU2** | Creación de colecciones y clasificación de visibilidad | 5 | Sprint 1 |
| 3 | **HU5** | Subida de imágenes y videos a colecciones | 5 | Sprint 1 |
| 4 | **HU10** | Descarga individual o comprimida (`.zip`) | 3 | Sprint 1 |
| 5 | **HU14** | Previsualización con marca de agua automática | 8 | Sprint 1 |
| 6 | **HU3** | Autorización manual de clientes a colecciones privadas | 5 | Sprint 2 |
| 7 | **HU8** | Registro con selección de rol (Fotógrafo / Cliente) | 5 | Sprint 2 |
| 8 | **HU25** | Registro obligatorio de campos y datos personales | 5 | Sprint 2 |
| 9 | **HU19** | Control de unicidad de cédula y correo electrónico | 5 | Sprint 2 |
| 10 | **HU21** | Envío de código de verificación por correo/teléfono | 5 | Sprint 2 |
| 11 | **HU18** | Edición de perfil comercial de fotógrafo | 5 | Sprint 2 |
| 12 | **HU20** | Bloqueo de seguridad de acceso por URL directa | 8 | Sprint 3 |
| 13 | **HU17** | Código QR de acceso/descarga directa a colecciones | 5 | Sprint 3 |
| 14 | **HU4** | Generación de código QR para eventos colaborativos | 8 | Sprint 3 |
| 15 | **HU7** | Descarga e impresión de códigos QR de eventos | 5 | Sprint 3 |
| 16 | **HU23** | Edición de metadatos básicos de archivos subidos | 5 | Sprint 3 |
| 17 | **HU11** | Carga de archivos vía QR por invitados (sin registro) | 5 | Sprint 4 |
| 18 | **HU12** | Moderación de contenido cargado por invitados | 5 | Sprint 4 |
| 19 | **HU6** | Eliminación de archivos multimedia por el fotógrafo | 5 | Sprint 4 |
| 20 | **HU9** | Permiso manual para descarga en "Alta Calidad" | 5 | Sprint 4 |
| 21 | **HU16** | Restricción por superación de cuota de almacenamiento | 8 | Sprint 4 |
| 22 | **HU24** | Sistema de marcado de imágenes favoritas | 5 | Sprint 5 |
| 23 | **HU22** | Consulta de estadísticas de descarga por fotógrafo | 5 | Sprint 5 |
| 24 | **HU13** | Respaldo diario automático y rotación de base de datos | 8 | Sprint 5 |
| 25 | **HU15** | Entrega de guía de usuario, capacitación y cierre | 3 | Sprint 5 |