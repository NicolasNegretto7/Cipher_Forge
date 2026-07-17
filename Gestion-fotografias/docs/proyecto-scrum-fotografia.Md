## 1. Información obtenida en la entrevista

| Categoría           | Información relevada                                                                    |
| ------------------- | --------------------------------------------------------------------------------------- |
| Problema principal  | Dificultad de entrega inmediata de material fotografico y baja calidad de imagen.       |
| Objetivo de negocio | Plataforma donde fotografos puedan subir su contenido con imagenes de buena calidad     |
| Alcance inicial     | Subida y bajada de imagenes, marca de agua.                                             |
| Plazo esperado      |                                                                        |
| Presupuesto         | Proyecto de UTU sin presupuesto.                                                        |
| Usuarios            | Fotografos, compradores.                                                                |
| Infraestructura     | Nube, alta disponibilidad, almacenamiento variable.         |
| Seguridad           | Cedula, nombre, correo electronico y politicas de privacidad                            |
| Riesgo operativo    | Caida del servidor, problemas con metodos de pago y material con riesgo legal.           
| Restricción técnica | Imágenes descargables deben contar con marca de agua.                                                 |

> “Restricción institucional (UTU): por tratarse de un equipo de estudiantes menores de edad, no es posible contratar hosting ni procesar pagos reales para este proyecto. Esta restricción es ajena tanto al pedido del cliente como a una decisión técnica del equipo. El sistema correrá en entorno local para esta entrega, y se recomendará al cliente, una vez el equipo se gradúe, migrar el sistema de un servidor local a uno en la nube, adquiriendo hosting y dominio propio, y habilitando en ese momento un método de pago real.”


---

## 2. Nombre propuesto del producto

**???**

Sistema web para fotografos y compradores que permite subir material fotografico y ser comprado.

---

## 3. Visión del producto

Para fotógrafos y videógrafos que tienen dificultad para entregar su material de forma inmediata, profesional y sin perder calidad, ??? es una plataforma web que permitirá a fotógrafos subir, organizar y comercializar su material fotográfico, protegido con marca de agua, y a sus compradores visualizar, comprar y descargar ese contenido en buena calidad. A diferencia de WhatsApp o plataformas como Pixyset y Lumipick, nuestro producto combina protección del contenido y alta calidad de imagen y un cobro ágil sin intermediarios que retengan el dinero del fotógrafo. (Esto último se podrá en un futuro por restricción de edad del equipo)

La primera versión sera de subida y bajada de imagenes y videos, marca de agua.

---

## 4. Alcance incluido

El proyecto incluirá:

1. Gestión de usuarios y roles.
2. Registro y verificación de usuarios.
3. Creación de perfiles de fotógrafo.
4. Creación de colecciones (públicas o privadas).
5. Subida de imágenes y videos en alta calidad.
6. Aplicación de marca de agua en la vista previa de las imágenes.
7. Restricción de descarga y captura de pantalla en el contenido no adquirido.
8. Visualización de imágenes en al menos dos niveles de calidad (alta calidad y calidad normal).
9. Descarga inmediata de imágenes.
10. Control de espacio de almacenamiento por usuario (3GB).
11. Políticas de privacidad y protección de datos.
12. Generación de un enlace o QR de acceso directo a una colección privada puntual, para que un comprador vea su sesión sin necesidad de buscar el perfil del fotógrafo.

---

## 5. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:
 
1. Una version App.
3. Plantillas predeterminadas para exposición/publicación de fotos.
4. Integración con redes sociales.
5. Perfil público con acceso libre a todo el material del fotógrafo.
6. Metodos de pago.
7. Hosting/dominio.



## 6. Requerimientos funcionales

| Código | Requerimiento funcional                                                                                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF1    | El sistema debe permitir el registro obligatorio de usuarios (fotógrafos y clientes) solicitando Nombre completo, Cédula, Correo Electrónico y numero de telefono.                                                                                                    |
| RF2    | El sistema debe impedir el registro de usuarios duplicados utilizando una misma Cédula de Identidad o un mismo Correo Electrónico ya existente en la base de datos.                                                                                                    |
| RF3    | El sistema debe proveer una pantalla de inicio de sesión (Login) segura.                                   |
| RF4    | El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como Públicas o Privadas.                         |
| RF5    | Las colecciones marcadas como Privadas deben permanecer en ese estado de forma permanente y solo ser visibles para los clientes que el fotógrafo asigne de manera explícita.                                                                       |
| RF6    | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados.                                                                                           |
| RF7    | El sistema debe permitir al fotógrafo subir imágenes (JPG) y videos a su colección..                                                                                                  |
| RF8    | Al subir una imagen, el backend debe generar automáticamente una versión optimizada y más ligera para su visualización fluida en la galería del cliente (vista previa).                                                                                                 |
| RF9    | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en su vista previa para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga.  |
| RF10   | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip).                                                                                    |
| RF11   | El sistema debe ofrecer al cliente dos opciones de descarga según los permisos otorgados por el fotógrafo, calidad normal: versión ligera y optimizada alta calidad: El archivo original sin pérdida de resolución subido por el fotógrafo (este requerimiento fue adaptado a la restriccion de no realizar metodos de pago el cual fue restriccion de la UTU).                                                                                     |
| RF12   | El sistema debe permitir al fotógrafo activar o desactivar manualmente el permiso de descarga en "Excelente Calidad" para clientes específicos dentro de una colección privada. |
| RF13   | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica de un evento, para compartir con un comprador puntual.                                                                                                   |
| RF14   | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo.                                                                                                |
| RF15   | El fotógrafo debe poder visualizar y gestionar (aprobar, ocultar o descargar) todo el material multimedia colaborativo subido por los invitados mediante el QR.
| RF16   | El sistema debe permitir al fotógrafo generar un enlace o QR de acceso directo a una colección privada específica, distinto del QR de carga colaborativa

---

## 7. Requerimientos no funcionales

| Código | Requerimiento no funcional                                                                                                  |
| ------ | --------------------------------------------------------------------------------------------------------------------------- |
| RNF1   | La interfaz de usuario debe ser completamente adaptable (Responsive) para asegurar una experiencia de usuario óptima tanto en computadoras de escritorio como en dispositivos móviles (smartphones y tablets).                                      |
| RNF2   | Las páginas del portal de clientes y las galerías deben cargar en un tiempo prudencial (idealmente bajo estándares web aceptables de menos de 3 segundos bajo conexiones normales).                                         |
| RNF3   | La interfaz de la pagina web debe ser simple, rapida y formal.                              |
| RNF4   | El sistema debe asegurar la estabilidad de la pagina para soportar el uso constante de esta misma mientras se corre en entornos de pruebas en el entorno local (Pensar estabilidad para posible hosting en un futuro).                         |
| RNF5   | El sistema debe realizar respaldos automáticos diarios.                                         |
| RNF6   | El sistema debe eliminar de manera automatica el respaldo mas antiguo si ya hay tres en disposicion.                                                                    |
| RNF7   | El sistema debe registrar fecha y hora para cada respaldo diario.                                                        |


---                                                                                

# 8. Épicas del proyecto

| Código | Épica                           | Descripción                                                                         |
| ------ | ------------------------------- | ----------------------------------------------------------------------------------- |
| EP1    | Gestión de usuarios y seguridad | Registro de usuarios, inicio de sesión seguro, asignación de roles y políticas de privacidad.                   |
| EP2    | Perfiles de fotógrafos            | Creación, edición y administración de los perfiles profesionales de los fotógrafos.                      |
| EP3    | Gestión de colecciones             | Creación, categorización (públicas/privadas) y control de acceso por URL a colecciones de fotos. |
| EP4    | Carga y procesamiento multimedia       | Subida de imágenes de alta calidad, generación de vistas previas optimizadas y aplicación de marcas de agua.                             |
| EP5    | Visualización y descargas | Galería de previsualización para clientes, control de calidad de descarga y bajada de imágenes (individual o en .zip).                  |
| EP6    | Carga colaborativa por QR         | Generación de códigos QR para eventos, subida rápida de fotos por invitados y moderación/gestión posterior del material por parte del fotógrafo (ocultar o eliminar).                |
| EP7    | Mantenimiento técnico y respaldo     | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría.               |
| EP8    | Capacitación y cierre           | Entrega de la guía básica de uso, capacitación al cliente y cierre formal del proyecto de UTU.               |

---

# 9. Estimación de esfuerzo, plazo y costo

## Criterio didáctico de estimación

Para simplificar la explicación, vamos a utilizar una estimación basada en puntos de historia (storypoints).

En este ejemplo:

- 1 punto representa una tarea muy pequeña.
- 3 puntos representan una tarea simple pero con cierta lógica.
- 5 puntos representan una tarea media.
- 8 puntos representan una tarea compleja.
- 13 puntos representan una tarea grande o riesgosa.

Se asumirá una velocidad promedio del equipo de **20 puntos por sprint**.

Cada sprint tendrá una duración de **3 semanas**.

El proyecto tendrá **5 sprints**, por lo tanto la duración total estimada será de **15 semanas**.

---

## 10. Estimación por épica

| Código    | Épica                           | Estimación en puntos |
| --------- | ------------------------------- | -------------------- |
| EP1       | Gestión de usuarios y seguridad |           5         |
| EP2       | Perfiles de fotógrafos             |       5             |
| EP3       | Gestión de colecciones             |         5           |
| EP4       | Carga y procesamiento multimedia       |      8             |
| EP5       | Visualización y descarga |              5      |
| EP6       | Carga colaborativa por QR         |           8         |
| EP7       | Mantenimiento técnico y respaldo     |         5            |
| EP8       | Capacitación y cierre           |            3         |
| **Total** |                                 | **46 puntos**        |

La estimación no supera la cantidad inicial por tanto no es necesario un ajuste de alcance. 

---

## 11. Propuesta presentada al cliente

El equipo presenta la siguiente propuesta:

| Elemento         | Propuesta                                                                           |
| ---------------- | ----------------------------------------------------------------------------------- |
| Producto         | ???, sistema web para fotografos.                                    |
| Duración         | 15 semanas.                                                                          |
| Metodología      | Scrum, con 5 sprints de 3 semanas.                                                  |
| Entregas         | Incremento funcional al final de cada sprint.                                       |
| Presupuesto      | Proyecto de Egreso por tanto no habra presupuesto asignado.                                                                          |
| Forma de trabajo | Revisión con cliente al cierre de cada sprint.                                      |
| Primera versión  | Subida y bajada de imagenes/videos, marca de agua.   |
| Exclusiones      | App móvil nativa, integracion con redes sociales, Perfil público con acceso libre a todo el material del fotógrafo, metodos de pagos.|

---

## 12. Aprobación del cliente

Luego de revisar la propuesta, el cliente responde:

> “Pendiente de confirmación formal por parte del cliente. Se espera su respuesta en los próximos días para proceder con el detalle de sprints.”

Con esta aprobación, el equipo pasa de épicas a historias de usuario y construye el Product Backlog inicial.

---

# Historias de usuario

## 13. Formato de historia de usuario

Se utilizará el siguiente formato:

> Como **[tipo de usuario]**, quiero **[acción o necesidad]**, para **[beneficio o resultado esperado]**.

Cada historia incluirá criterios de aceptación para saber cuándo puede considerarse terminada.

---

## 14. Historias de usuario iniciales

| ID   | Historia de usuario                                                                                                                     | Puntos | Prioridad |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------- | ------ | --------- |
| HU1  | Como usuario, quiero iniciar sesión en el sistema, para acceder de forma segura a mi panel según mi rol.                                                  |       | Alta      |
| HU2  | Como fotógrafo, quiero crear colecciones y asignarles visibilidad (privada o pública), para controlar quién puede acceder a cada una.                                 |       | Alta      |
| HU3  | Como fotógrafo, quiero autorizar de forma explícita a un cliente mediante sus datos principales para que acceda a una colección privada.  |       | Alta      |
| HU4  | Como fotógrafo, quiero generar un código QR único para una colección, para utilizarlo de manera presencial en mis eventos laborales.                                               |       | Media      |
| HU5  | Como fotógrafo, quiero subir imágenes (JPG) a mi colección, para ponerlas a disposición de mis clientes.                   |       | Alta      |
| HU6  | Como fotógrafo, quiero eliminar imágenes o videos de una colección, para mantener el control sobre el contenido publicado.                 |       | Alta      |
| HU7  | Como fotógrafo, quiero descargar el código QR generado para poder imprimirlo físicamente y exponerlo en el evento.              |       | Media      |
| HU8  | Como usuario nuevo, quiero poder elegir si registrarme como fotógrafo o como cliente, para acceder a las funciones correctas del sistema.                         |       | Alta      |
| HU9  | Como fotógrafo, quiero habilitar o deshabilitar manualmente el permiso de descarga en "Excelente Calidad" para un cliente específico, para controlar la entrega final del material.                        |       | Alta      |
| HU10 | Como cliente autorizado, quiero descargar mis fotos de forma individual o en un archivo comprimido (.zip), para obtener mi material de manera ágil.                     |       | Media      |
| HU11 | Como invitado de un evento, quiero escanear el código QR para subir directamente mis fotos y videos a la colección sin necesidad de crearme una cuenta compleja.         |       | Media     |
| HU12 | Como fotógrafo, quiero visualizar y gestionar (ocultar o eliminar) el material subido por invitados                                                         |       | Media      |
| HU13 | Como sistema, quiero realizar un respaldo automático diario de la base de datos y rotar las últimas 3 copias, para mitigar el riesgo de pérdida de datos. |       | Media      |
| HU14 | Como cliente, quiero visualizar las fotos de mi evento con una marca de agua integrada automáticamente, para poder previsualizar el trabajo antes de descargarlo en máxima resolución.                   |       | Alta     |


---

# Product Backlog inicial

## 15. Backlog priorizado

| Orden | ID | Historia | Puntos | Sprint estimado |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU1 | Inicio de sesión | | Sprint 1 |
| 2 | HU8 | Selección de rol (Fotógrafo / Cliente) | | Sprint 1 |
| 3 | HU2 | Creación de colecciones y visibilidad | | Sprint 1 |
| 4 | HU5 | Subida de imágenes | | Sprint 1 |
| 5 | HU3 | Autorización de clientes a colecciones | | Sprint 2 |
| 6 | HU4 | Generación de código QR único | | Sprint 2 |
| 7 | HU7 | Descarga e impresión de código QR | | Sprint 2 |
| 8 | HU11 | Carga de archivos por QR (Invitados) | | Sprint 2 |
| 9 | HU9 | Habilitación manual de descarga "Excelente Calidad" | | Sprint 3 |
| 10 | HU10 | Descarga individual o comprimida (.zip) | | Sprint 3 |
| 11 | HU14 | Visualización con marca de agua automática | | Sprint 3 |
| 12 | HU12 | Moderación de material subido por invitados | | Sprint 3 |
| 13 | HU6 | Eliminación de imágenes o videos | | Sprint 4 |
| 14 | HU13 | Respaldo automático de base de datos | | Sprint 4 |

---