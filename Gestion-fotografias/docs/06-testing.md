# 6. Pruebas

## ¿Para qué sirve este documento?

Registra las estrategias y evidencias de prueba del proyecto. Documenta qué se
verificó, cómo se verificó y con qué resultados, de modo que cualquier integrante
pueda reproducir la prueba y auditar que el sistema cumple los requerimientos.

---

## Motor de códigos QR (F1)

### Contexto

El QR de acceso a colecciones se genera con `backend/src/helpers/QrGenerator.php`
(`QrGenerator::svg()` y `QrGenerator::renderPrintableHtml()`), para símbolos ISO
18004 versiones 1 a 7, nivel de corrección **L**, en modo byte. La matriz se
construye de cero (patrones fijos, formato, versión, datos y corrección
Reed-Solomon sobre GF(256) con polinomio primitivo `0x11D`).

### Cómo probar el escaneo físico (aceptación en campo)

1. Levantar el backend (ver `docs/infraestructura.md`) y generar el HTML imprimible
   de una colección; por ejemplo, abrir la tarjeta de una colección pública y elegir
   "Mostrar / imprimir QR".
2. Verificar que el encabezado del HTML muestra el evento, la URL de acceso y la
   fecha de expiración (o el aviso "Enlace de acceso exclusivo").
3. Imprimir o mostrar la tarjeta y escanearla con una cámara de teléfono (aplicación
   de cámara nativa o lector como Google Lens / ZXing).
4. **Criterio de aceptación:** el escáner abre la URL correcta de la colección.

### Verificación automatizada (evidencia)

Prueba off-line validando el símbolo generado contra un decodificador independiente
(`jsqr`) y contra un generador de referencia estricto (`qrcode`, soldair):

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `php -l backend/src/helpers/QrGenerator.php` (sintaxis) | OK |
| 2 | Dimensiones según versión: v1/v2 → 25×25, v3 → 29×29, v7 → 45×45 | OK |
| 3 | Tres patrones de búsqueda correctos en cada símbolo | OK |
| 4 | Info de formato (BCH, nivel L, máscara) en ambas copias | OK |
| 5 | Info de versión para v7 (`0x07C94`) | OK |
| 6 | Juego de codewords (modo + longitud + datos + terminador + relleno `0xEC`/`0x11`) idéntico al estándar | OK |
| 7 | Codewords Reed-Solomon idénticos al estándar y a `qrcode` (soldair) | OK |
| 8 | Matriz final celda a celda idéntica a un generador de referencia con la misma máscara (payload versiones 1/2/7) | 0 diferencias |
| 9 | Decodificación con `jsqr` de los símbolos generados (v1, v2, v3 y v7) | Decodifica la URL correcta |
| 10 | `QrGenerator::svg()` y `renderPrintableHtml()` generan salida no vacía y bien formada | OK |

### Corrección aplicada (2026-09-10)

Durante la verificación automatizada se detectó que los lectores independientes no
podían decodificar los símbolos: los bytes de datos y el patrón de la matriz eran
correctos, pero los **codewords Reed-Solomon no coincidían con el estándar**. La
causa raíz estaba en la división sintética de `codigoReedSolomon()`: el bucle que
multiplica el polinomio generador (grado n) por el coeficiente de cada paso omitía
el **término principal** (iteraba `j < n` en vez de `j < n+1`), con lo que el
resto (ECC) resultaba incorrecto y la corrección de errores no validaba el símbolo.

Se corrigió iterando sobre todos los coeficientes del generador
(`$j < count($gen)`). Tras el cambio:

- los codewords ECC coinciden byte a byte con el estándar y con `qrcode` (soldair);
- todos los símbolos de prueba decodifican correctamente con `jsqr`;
- para payloads con una única segmentación obligada (byte), la matriz final coincide
  celda a celda con `qrcode` forzando la misma versión y máscara (0 diferencias).

**Funciones afectadas:** `QrGenerator::codigoReedSolomon()` (y el paso de
intercalado que la usa). No cambió la interfaz pública de `QrGenerator` ni el resto
del backend.

### Cómo reproducir la verificación automática

Con PHP y Node disponibles, generar SVG para los payloads de prueba y:
1. reconstruir la matriz desde los `<rect>` del SVG y comprobar dimensión y buscadores;
2. decodificar esa misma matriz con `jsqr` (render a imagen en memoria) y comparar
   contra la URL original;
3. comparar juego de codewords y matriz final contra `qrcode` con versión/máscara
   forzadas.

Los cuatro payloads de referencia usados en esta iteración:
- `https://cf.local/x` (16 caracteres → versión 2)
- `https://cf.local/xa` (18 caracteres → versión 2)
- `https://cipherforge.local/e/INV-7F3K` (36 caracteres → versión 3)
- `https://cipherforge.local/colecciones/o/abc123def?utm_source=qr&utm_medium=cartel&utm_campaign=` + 53×`z` (148 caracteres → versión 7)

> Nota: para payloads con caracteres que habilitan segmentación en otros modos
> (numérico / alfanumérico), `qrcode` (soldair) puede elegir segmentación mixta
> mientras `QrGenerator` usa siempre modo byte; ambos son válidos y decodifican la
> misma URL. La verificación de igualdad celda a celda se hace solo sobre payloads
> de modo byte forzado.

---

## Favoritos por colección (F2 / CC-15)

### Contexto

Tras la decisión CC-15, los favoritos dejan de ser por archivo multimedia y pasan
a ser por **colección pública completa** (RF21): la tabla `favoritos.favorito_id`
ahora referencia `colecciones.id` en vez de `multimedia.id_multimedia`. Se aplicó
la migración incremental (`backend/database/migration.sql`) en la BD en ejecución
y se alinearon el controlador, el repositorio y el frontend de cliente.

### Verificación automatizada (evidencia, 2026-09-10)

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `php -l` de `FavoritoController.php`, `ColeccionRepository.php` y `routes.php` | OK |
| 2 | `node --check` de `api.js`, `panelcliente.js`, `gallery.js`, `favoritoscliente.js` | OK |
| 3 | Migración `favoritos.favorito_id` FK → `colecciones(id)` ON DELETE CASCADE (SHOW CREATE TABLE) | OK |
| 4 | La migración es idempotente: re-ejecutada sin errores ni cambios (código de salida 0) | OK |
| 5 | `POST /favoritos/59` (colección pública) con token de cliente | 201, `es_favorito: true` |
| 6 | `GET /favoritos` devuelve una fila por colección (`id_coleccion`, `portada_id_multimedia`, `total_archivos`) | OK |
| 7 | `POST /favoritos/99999` (colección inexistente) | 404 |
| 8 | `POST /favoritos/64` (colección privada) | 403 (RF21) |
| 9 | `GET /favoritos` sin token | 401 |
| 10 | `DELETE /favoritos/59` y `GET /favoritos` posterior queda vacío | 200 → 0 filas |

> La re-ejecución de la migración que elimina los favoritos previos (por archivo)
> se hizo tras confirmar que la tabla estaba vacía (0 registros) en la BD en ejecución.

## Subida de archivos >2 MB en el panel del fotógrafo (CC-19)

### Contexto

El backend admite imágenes de hasta 20 MB y videos de hasta 800 MB
(`MultimediaValidator`) y el transporte del contenedor acepta hasta 900M/1G (CC-16);
sin embargo, el frontend del fotógrafo guardaba el archivo completo como **dataURL en
`localStorage`** (límite real del navegador ~5 MB): una foto de cámara >2 MB lanzaba
`QuotaExceededError` sin controlar y el archivo "no aparecía". Se corrigió
persistiendo los bytes originales en **IndexedDB** (nuevo `binarios.js`) y guardando
en `localStorage` solo una miniatura reencodificada, con `guardarColeccion()`
protegido contra agotamiento de cuota y restauración de vistas al recargar.

### Verificación (evidencia, 2026-09-10)

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `node --check` de `subirimagenes.js` y `binarios.js` | OK |
| 2 | `binarios.js` incluido en `SubirImagenes.html` antes de `subirimagenes.js` | OK |
| 3 | Imagen JPEG real de 2.15 MB: `POST /colecciones/{id}/multimedia` con `archivos[]` + `titulo`/`descripcion` | 201, `vista_previa` generada |
| 4 | Mismo flujo con dos `archivos[]` en una petición | 201, todos en `subidos` |
| 5 | Video MP4 (ffmpeg, 35 KB): misma subida | 201, `tipo: video`, `vista_previa` .mp4 generada |
| 6 | Datos de prueba (usuarios `ups_%`/`up_test_%`, colecciones, multimedia y ficheros en volumen) limpiados al terminar | OK |
| 7 | Clic en una miniatura del borrador (`SubirImagenes.html`) abre el visor `#visor.Abierto` con la previsualización | OK (manual) |
| 8 | Videos en el visor: se cargan con `src` del archivo original recuperado (objectURL) y se reproducen (póster solo si los bytes no están disponibles) | OK (manual) |
| 9 | `node --check` de `subirimagenes.js` tras cablear el visor | OK |
| 10 | `POST /colecciones` con título de 65 caracteres responde `400` con `errores: ["El título no puede superar los 60 caracteres."]` (reproducido) | OK |
| 11 | `POST /colecciones` con descripción de 95 caracteres responde `400` con detalle en `errores` (reproducido) | OK |
| 12 | `POST /colecciones/{id}/multimedia` con un PNG responde `400` con `errores: ["Formato no permitido. Solo se aceptan imágenes JPG y videos MP4."]` (reproducido) | OK |
| 13 | `api.js` propaga `error.errores` y `publicarColeccion` muestra el detalle (viñetas) en el alert; validación previa (nombre ≤60, descripción ≤90, JPG/MP4) antes de llamar al backend | OK (`node --check` en `api.js` y `subirimagenes.js`) |
| 14 | `comprobarFormatoReal` detecta por cabecera JPG, PNG, WebP, GIF, BMP, TIFF, JP2, JXL, HEIC, AVIF, MOV, MKV, AVI, WebM aunque el nombre/la extensión digan `.jpg`; la validación previa SIEMPRE lee los bytes (ya no confía en el MIME del navegador, que usa la extensión) | OK (`node --check`) |
| 15 | `mime_content_type` del servidor (probe en contenedor): JPEG real→`image/jpeg` (acepta); PNG/WebP/JP2→otros MIME (rechaza con "Formato no permitido") | OK |

### Despliegue

Cambios solo en `frontend-fotografo/` (JS + HTML). No requiere reconstrucción de
imágenes ni migración de BD; los borradores previos de `localStorage` se conservan.

## Galería de una colección privada abierta por QR/invitación (CC-21)

### Contexto

La galería del cliente (`frontend-cliente/js/gallery.js:crearVista`) ponía la vista
previa como `src` directo de un `<img>/<video>` (`urlVistaPrevia(id)`). Un navegador
no adjunta `Authorization: Bearer` a un recurso cargado por un elemento HTML; para
colecciones **privadas** el backend exige sesión (`rutaServible` → 401) y las
miniaturas/visor acababan en icono de imagen rota. Las públicas funcionaban.

Corrección: `window.api.obtenerVistaPrevia(id)` en `frontend-cliente/js/api.js`, que
hace `fetch` de `vista-previa` con el header Bearer y devuelve un objectURL (mismo
patrón que `descargarMultimedia`); `gallery.js` la usa para miniaturas y visor, con
liberación de objectURLs al re-renderizar la galería.

### Verificación (evidencia, 2026-09-11)

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `node --check` de `frontend-cliente/js/api.js` y `frontend-cliente/js/gallery.js` | OK |
| 2 | `GET /multimedia/101/vista-previa` de colección privada (78) **sin** Bearer | 401 (causa del icono roto) |
| 3 | Flujo invitado completo: registrar cliente, verificar código, login, `GET /invitaciones/{token}` → `GET/POST /invitaciones/{token}/canjear` | 200, `acceso_concedido: true`, `tipo_visibilidad: privada` |
| 4 | `GET /multimedia/101/vista-previa` con Bearer del invitado (tras canje) | 200, 208 977 B, firma `FF D8 FF E0` (JPEG) |
| 5 | Usuarios de prueba, `acceso_colecciones` y ficheros temporales limpiados | OK |

### Despliegue

Cambios solo en `frontend-cliente/` (JS). No requiere reconstrucción de imágenes ni
migración de BD; las colecciones privadas ya publicadas se ven al recargar con
Ctrl+F5.

## Archivos nuevos en una colección ya publicada (CC-22)

### Contexto

En el panel del fotógrafo los archivos se añaden primero al borrador local
(`localStorage`/IndexedDB) y solo se suben al backend al pulsar «Publicar colección».
Para una colección **ya publicada** eso obligaba a re-publicar para que el enlace
permanente/QR mostrase los archivos nuevos. Corrección: `subirNuevosSiColeccionPublicada()`
en `subirimagenes.js` sube de inmediato los pendientes cuando la colección está
publicada (al seleccionar archivos y al cargar la página).

### Verificación (evidencia, 2026-09-11)

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `node --check` de `frontend-fotografo/js/subirimagenes.js` | OK |
| 2 | Fotógrafo de prueba crea colección **privada** y genera QR de acceso; cliente invitado canjea el QR (`acceso_concedido: true`) | OK |
| 3 | `GET /colecciones/{id}/multimedia` como invitado (estado inicial) | 0 archivos |
| 4 | Fotógrafo sube 2 archivos nuevos (JPEG 64×64 real + MP4 ffmpeg) a la colección ya publicada | 201, `subidos` con id 104 (imagen) y 105 (video), `aprobado: true` |
| 5 | Mismo `GET /colecciones/{id}/multimedia` como invitado **sin re-publicar** | 2 archivos (los ve al refrescar) |
| 6 | `GET /multimedia/{id}/vista-previa` del archivo nuevo con token del invitado | 200 (mp4, 2246 B) |
| 7 | `publicarColeccion` conserva su validación previa (nombre ≤60, descripción ≤90, JPG/MP4 reales, extraído a `archivosConFormatoInvalido`) | OK (`node --check`) |
| 8 | Datos de prueba eliminados: colección, multimedia, QR, accesos, usuarios y ficheros de vista previa en el volumen | OK, sin residuos |

### Despliegue

Cambios solo en `frontend-fotografo/js/subirimagenes.js`. No requiere migración de BD;
los borradores previos se conservan. Los pendientes heredados de antes del fix se
suben solos al abrir la colección.

## Miniaturas verdes por perfil ICC y calidad de descarga (CC-23)

### Contexto

Las miniaturas del borrador reencodan la imagen en un `<canvas>` (`generarMiniaturaImagen`)
y el póster de video hace lo propio (`generarPosterVideo`). Cuando el JPEG trae metadatos
de perfil de color (ICC) inconsistentes —típico en archivos descargados y re-subeidos—
Chrome/Edge pintan todo el canvas en verde; el `<img>` directo y el visor (bytes
originales) se ven bien. Corrección: `dibujarEnLienzo()` decodifica con
`createImageBitmap({ colorSpaceConversion: "none", imageOrientation: "from-image" })`
(ignora el perfil corrupto y respeta EXIF), con fallback al `drawImage` clásico.

La descarga en dos calidades usa `MediaProcessor::generarBuenaCalidadImagen()`: desde CC-24 la "buena" es una copia limpia sin marca de agua con calidad baja (JPEG 30) y resolución máxima Full HD (1920 px, se reescala solo si el original supera ese ancho); la "alta" es el original íntegro. (Semántica previa CC-12: máx 1920 px + JPEG 80.)

### Verificación (evidencia, 2026-09-11)

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `node --check` de `frontend-fotografo/js/subirimagenes.js` (helper `dibujarEnLienzo`) | OK |
| 2 | `createImageBitmap` disponible en Chrome/Edge/Firefox; `colorSpaceConversion: "none"` evita la conversión del perfil ICC roto (referencia: WHATWG ImageBitmap / MDN) | OK (documentación) |
| 3 | Fallback: si `createImageBitmap` no está o falla, se dibuja la imagen tal cual (comportamiento anterior) | OK (try/catch) |
| 4 | Descarga `?calidad=alta` de un JPG 6000×4000 de prueba | 200, 2 283 322 B (original íntegro) |
| 5 | Descarga `?calidad=buena` del mismo archivo (CC-24) | 200, 1920×1280, 133 003 B (-94%), SHA-256 distinto |
| 6 | Descarga `?calidad=buena` de un JPG 1920×1280 de prueba | 200, 1920×1280, 134 137 B (-59%); se genera `uploads/standard/*.jpg` (máx 1920 px, JPEG 30) en el volumen |
| 7 | `php -l` de `MediaProcessor.php` y `MultimediaService.php` tras el cambio CC-24 | OK |
| 8 | Sin regresión en la subida: `POST /colecciones/{id}/multimedia` multiauto (imagen + video) | 201, `subidos` con `aprobado: true` |
| 9 | Datos de prueba (usuarios `qual_%`/`qual2_%`, colecciones, multimedia, ficheros de prueba en volumen) limpiados | OK, sin residuos (los originales reales del usuario quedan intactos) |

### Despliegue

Cambios solo en `frontend-fotografo/js/subirimagenes.js`. No requiere migración de BD.

---

### Vista previa y moderación de aportes colaborativos (CC-25)

El panel "Moderar aportes" (`frontend-fotografo/js/moderation.js`) cargaba las miniaturas con `<img src=.../vista-previa>` sin cabecera `Authorization`; como las colecciones colaborativas son privadas, el backend responde 401 y las imágenes quedaban ocultas (se podían seleccionar sin verlas). Corrección: `window.api.obtenerVistaPrevia(id)` en `frontend-fotografo/js/api.js` descarga con `fetch` + Bearer y devuelve un objectURL; `renderizarPendientes` la usa, revoca los objectURLs al re-renderizar y el clic en la miniatura abre la vista previa completa en nueva pestaña (CC-25).

| # | Verificación | Resultado |
| --- | --- | --- |
| 1 | `node --check` de `frontend-fotografo/js/api.js` y `frontend-fotografo/js/moderation.js` | OK |
| 2 | Carga de una colección publicada con aportes pendientes en "Moderar aportes" | Pendiente de confirmar en navegador (Ctrl+F5) |

### Despliegue (CC-25)

Cambios solo en `frontend-fotografo/js/api.js` y `frontend-fotografo/js/moderation.js`. No requiere migración de BD.