## 1. Información obtenida en la entrevista

| Categoría           | Información relevada                                                                    |
| ------------------- | --------------------------------------------------------------------------------------- |
| Problema principal  | Dificultad de entrega inmediata de material fotografico y baja calidad de imagen.       |
| Objetivo de negocio | Plataforma donde fotografos puedan subir su contenido con imagenes de buena calidad     |
| Alcance inicial     | Subida y bajada de imagenes, marca de agua.                                             |
| Plazo esperado      | 4 meses.                                                                        |
| Presupuesto         | Proyecto de UTU sin presupuesto.                                                        |
| Usuarios            | Fotografos, compradores.                                                                |
| Infraestructura     | Servidor en la nube, alta disponilibidad, almacenamineto cambiable por usuario.         |
| Seguridad           | Cedula, nombre, correo electronico y politicas de privacidad                            |
| Riesgo operativo    | Caida del servidor, problemas con metodos de pago y material con riesgo legal.           
| Restricción técnica | Imágenes descargables deben contar con marca de agua.                                                 |

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
10. Control de espacio de almacenamiento por usuario.
11. Políticas de privacidad y protección de datos.
12. Invitacion a material privado mediante código QR.

---

## 5. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:
 
1. Una version App.
3. Plantillas predeterminadas para exposición/publicación de fotos.
4. Integración con redes sociales.
5. Perfil público con acceso libre a todo el material del fotógrafo.
6. Apartado para las Políticas de privacidad y protección de datos.
7. Control de espacio de almacenamiento por usuario.
8. Restricción de descarga y captura de pantalla en el contenido no adquirido.


## 6. Requerimientos funcionales

| Código | Requerimiento funcional                                                                                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF1    | El sistema debe permitir el registro obligatorio de usuarios (fotógrafos y clientes) solicitando Nombre completo, Cédula, Correo Electrónico y numero de telefono.                                                                                                    |
| RF2    | El sistema debe impedir el registro de usuarios duplicados utilizando una misma Cédula de Identidad o un mismo Correo Electrónico ya existente en la base de datos.                                                                                                    |
| RF3    | El sistema debe proveer una pantalla de inicio de sesión (Login) segura.                                   |
| RF4    | El sistema debe permitir al fotógrafo crear colecciones de imágenes y clasificarlas manualmente como Públicas o Privadas.                         |
| RF5    | Las colecciones marcadas como Privadas deben permanecer en ese estado de forma permanente y solo ser visibles para los clientes que el fotógrafo asigne de manera explícita.                                                                       |
| RF6    | El sistema debe bloquear mediante lógica de backend cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados.                                                                                           |
| RF7    | El sistema debe permitir al fotógrafo subir imágenes en formato JPG.                                                                                                  |
| RF8    | Al subir una imagen, el backend debe generar automáticamente una versión optimizada y más ligera para su visualización fluida en la galería del cliente (vista previa).                                                                                                 |
| RF9    | El sistema debe aplicar automáticamente una marca de agua sobre las imágenes en su vista previa para proteger la propiedad intelectual del fotógrafo antes de que autorice su descarga.  |
| RF10   | El sistema debe permitir al cliente descargar las imágenes autorizadas de forma individual o masiva (comprimiendo la selección en un archivo .zip).                                                                                    |
| RF11   | El sistema debe ofrecer al cliente dos opciones de descarga según los permisos otorgados por el fotógrafo, buena calidad: versión ligera y optimizada Excelente calidad: El archivo original sin pérdida de resolución subido por el fotógrafo (este requerimiento fue adaptado a la restriccion de no realizar metodos de pago el cual fue la idea del cliente).                                                                                     |
| RF12   | El sistema debe permitir al fotógrafo activar o desactivar manualmente el permiso de descarga en "Excelente Calidad" para clientes específicos dentro de una colección privada. |
| RF13   | El sistema debe permitir al fotógrafo generar un código QR único vinculado a una colección específica de un evento.                                                                                                   |
| RF14   | Cualquier invitado del evento debe poder escanear el código QR con su celular para subir fotos y videos directamente a esa colección, sin necesidad de completar un registro de cuenta complejo.                                                                                                |
| RF15   | El fotógrafo debe poder visualizar y gestionar (aprobar, ocultar o descargar) todo el material multimedia colaborativo subido por los invitados mediante el QR.

---

## 7. Requerimientos no funcionales

| Código | Requerimiento no funcional                                                                                                  |
| ------ | --------------------------------------------------------------------------------------------------------------------------- |
| RNF1   | La interfaz de usuario debe ser completamente adaptable (Responsive) para asegurar una experiencia de usuario óptima tanto en computadoras de escritorio como en dispositivos móviles (smartphones y tablets).                                      |
| RNF2   | Las páginas del portal de clientes y las galerías deben cargar en un tiempo prudencial (idealmente bajo estándares web aceptables de menos de 3 segundos bajo conexiones normales).                                         |
| RNF3   | La interfaz de la pagina web debe ser simple, rapida y formal.                              |
| RNF4   | El sistema debe asegurar la estabilidad de la pagina para soportar el uso constante de esta misma (la pagina tendra horario 24/7)                           |
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
| EP6    | Carga colaborativa por QR         | Generación de códigos QR para eventos, subida rápida de fotos por invitados y aprobación por parte del fotógrafo..                |
| EP7    | Mantenimiento técnico y respaldo     | Configuración de respaldos automáticos diarios, rotación de las últimas tres copias y registro de auditoría.               |
| EP8    | Capacitación y cierre           | Entrega de la guía básica de uso, capacitación a usuarios y cierre formal del proyecto de UTU.               |

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
| **Total** |                                 | **49 puntos**        |


---
