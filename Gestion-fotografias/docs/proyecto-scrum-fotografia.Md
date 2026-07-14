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
9. Compra y descarga inmediata de imágenes.
10. Control de espacio de almacenamiento por usuario.
11. Políticas de privacidad y protección de datos.

---

## 5. Alcance excluido para esta primera versión

Quedarán fuera de la primera versión:

1. Una version App.
2. Invitacion a material privado mediante código QR.
3. Plantillas predeterminadas para exposición/publicación de fotos.
4. Integración con redes sociales.
5. Perfil público con acceso libre a todo el material del fotógrafo.
6. Apartado para las Políticas de privacidad y protección de datos.
7. Control de espacio de almacenamiento por usuario.
8. Restricción de descarga y captura de pantalla en el contenido no adquirido.


## 6. Requerimientos funcionales

| Código | Requerimiento funcional                                                                                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF1    | El sistema debe permitir iniciar sesión con usuario y cédula.                                                                                                       |
| RF2    | El sistema debe permitir gestionar usuarios con diferentes roles.                                                                                                       |
| RF3    | El sistema debe permitir registrar Usuarios, cédula, correo electrónico y cuenta de administración.                                    |
| RF4    | El sistema debe permitir modificar el estado de una vaca: en producción, secado, tratamiento o baja.                                                                    |
| RF5    | El sistema debe permitir registrar ordeñes indicando fecha, turno, responsable y tanque asociado.                                                                       |
| RF6    | El sistema debe permitir seleccionar las vacas participantes en cada ordeñe.                                                                                            |
| RF7    | El sistema debe permitir excluir vacas de un ordeñe indicando motivo.                                                                                                   |
| RF8    | El sistema debe permitir crear lotes de leche a partir de un ordeñe.                                                                                                    |
| RF9    | El sistema debe permitir registrar propiedades del lote: litros estimados, temperatura, grasa, proteína, células somáticas, resultado de antibióticos y observaciones.  |
| RF10   | El sistema debe permitir completar propiedades de calidad después de creado el lote.                                                                                    |
| RF11   | El sistema debe permitir cerrar un lote para evitar modificaciones no autorizadas.                                                                                      |
| RF12   | El sistema debe permitir consultar la trazabilidad de un lote, mostrando fecha, turno, tanque, responsable, vacas incluidas, vacas excluidas y propiedades registradas. |
| RF13   | El sistema debe permitir buscar vacas por caravana, nombre o estado.                                                                                                    |
| RF14   | El sistema debe permitir generar reportes exportables en PDF o planilla.                                                                                                |
| RF15   | El sistema debe registrar un historial de cambios sobre lotes cerrados o datos críticos.                                                                                |

