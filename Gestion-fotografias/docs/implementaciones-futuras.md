# Implementaciones futuras y observaciones pendientes

Este documento registra hallazgos, riesgos y oportunidades de mejora identificados durante la revisión de código del frontend, que no requieren acción inmediata pero deben considerarse en futuras iteraciones.

---

## 1. Protección de colecciones privadas depende exclusivamente del backend

**Fecha de identificación:** 2026-09-14
**Requisitos relacionados:** RF5, RF6
**Severidad:** Baja (observación de arquitectura)

### Contexto

- **RF5** establece que las colecciones privadas deben conservar su privacidad de forma permanente, sin cambiar su estado por el tiempo ni por la cantidad de usuarios vinculados.
- **RF6** establece que el sistema debe bloquear cualquier intento de acceso directo mediante URL a colecciones privadas por parte de usuarios no autorizados.

### Observación

El frontend gestiona el acceso a colecciones privadas a través de un sistema de invitaciones (tokens). Sin embargo, **no implementa ninguna barrera de protección adicional** más allá de no mostrar las colecciones privadas en la lista pública de colecciones.

La protección real contra acceso directo por URL depende enteramente del backend: cada endpoint que sirve contenido de una colección privada debe verificar que el usuario solicitante tenga una invitación válida o sea el propietario de la colección.

### Riesgo

Si el backend tiene un bug de autorización (por ejemplo, un endpoint que no verifica permisos antes de devolver contenido), el frontend no tiene protección compensatoria. Un usuario podría acceder a contenido privado manipulando la URL directamente.

### Recomendación para futuras iteraciones

Considerar agregar validación client-side como capa defensiva adicional:
1. Al cargar una colección, verificar la respuesta del backend para detectar errores de autorización (403) y mostrar un mensaje claro.
2. En la página de visualización de colección, si la colección es privada y el usuario no tiene invitación válida, redirigir antes de cargar el contenido.
3. Implementar una página de "acceso denegado" consistente en lugar de depender exclusivamente de los mensajes de error del backend.

Estas son mejoras de UX y defensa en profundidad, no reemplazan la validación server-side que es la protección principal.

### Archivos relevantes

- `frontend-cliente/js/tuscoleccionescliente.js` (flujo de invitaciones)
- `frontend-cliente/js/gallery.js` (visualización de colecciones)

---

## 2. Validación de formato de archivo por magic bytes en la capa moderna

**Fecha de identificación:** 2026-09-14
**Requisitos relacionados:** RF7, RF25
**Severidad:** Baja (mejora de UX)

### Contexto

- **RF7** establece que el sistema debe permitir subir imágenes en formato JPG y videos MP4.
- **RF25** establece que los videos subidos deben ser clips o recortes con un límite máximo por video original.

### Observación

La capa legacy del frontend (`js/subirimagenes.js:223-258`) implementa una función llamada `comprobarFormatoReal()` que verifica los **magic bytes** (los primeros bytes de un archivo) para confirmar que el contenido real del archivo es JPEG o MP4, independientemente de la extensión del archivo.

**¿Qué son los magic bytes?** Son los primeros bytes de un archivo que identifican su formato real. Por ejemplo:
- Todo archivo JPEG real empieza con los bytes `FF D8 FF`
- Todo archivo MP4 real contiene la cadena `ftyp` en sus primeros 8 bytes

La capa moderna (`dom/colecciones/subirimagenes.js`) **no implementa esta validación**. Simplemente envía el archivo seleccionado al backend sin verificar su contenido real.

### Ejemplo del problema

Un usuario podría renombrar un archivo `.png` o `.webp` a `.jpg`. El frontend moderno lo aceptaría y lo enviaría al backend. Si el backend rechaza el archivo, el usuario recibiría un error sin entender por qué. Si el backend lo acepta, podría haber problemas de procesamiento (marca de agua, vista previa, etc.).

### Recomendación para futuras iteraciones

Agregar validación de magic bytes en la capa moderna antes de subir archivos. La implementación de la capa legacy ya existe como referencia y puede reutilizarse. Esto mejoraría la experiencia de usuario al detectar archivos con extensión incorrecta antes de iniciar la subida.

### Archivos relevantes

- `frontend-fotografo/js/subirimagenes.js:223-258` (implementación legacy de referencia)
- `frontend-fotografo/dom/colecciones/subirimagenes.js:112-138` (capa moderna sin validación)

---

*Este documento se actualizará a medida que se identifiquen nuevas observaciones pendientes.*
