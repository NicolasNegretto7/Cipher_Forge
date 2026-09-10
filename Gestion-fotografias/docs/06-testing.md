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

### Despliegue

Cambios solo en `frontend-fotografo/` (JS + HTML). No requiere reconstrucción de
imágenes ni migración de BD; los borradores previos de `localStorage` se conservan.