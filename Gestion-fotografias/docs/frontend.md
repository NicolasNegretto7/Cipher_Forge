# SAST — Hallazgos del Frontend (Cipher Forge)

**Fecha del análisis:** 26/10/2026, 13:18 (UTC-3)  
**Herramienta:** SonarQube Community Build 26.8.0.126808 + SonarScanner CLI 8.1.0.6389  
**Proyecto:** `cipher-forge` — `C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias`  
**Commit analizado:** `0aca934dfe4662c406da22d5ac4cd9f84b951013`  
**Dashboard:** <http://localhost:9000/dashboard?id=cipher-forge>  
**Quality Gate global:** **ERROR**

> Este documento contiene únicamente los hallazgos de `frontend-cliente/` y `frontend-fotografo/`. Los hallazgos del backend están en [`backend.md`](backend.md).
>
> El frontend no tiene vulnerabilidades en este escaneo. Los hallazgos son bugs de accesibilidad y code smells de mantenibilidad; no son fallos de seguridad explotables por sí mismos.

---

## 1. Resumen del frontend

| Vulnerabilidades | Bugs | Code smells | Total |
|:---:|:---:|:---:|:---:|
| 0 | 3 | 49 | **52** |

### 1.1 Quality Gate global

El Quality Gate es del proyecto completo; se incluye aquí porque condiciona la entrega. Las métricas de cobertura y duplicación no se pueden atribuir solo al frontend.

| Condición | Valor real | Umbral | Estado |
|:---|:---:|:---:|:---:|
| Cobertura del código nuevo | 0.0 % | ≥ 80 % | ERROR |
| Duplicación del código nuevo | 10.03 % | ≤ 3 % | ERROR |
| Violaciones nuevas | 95 | 0 | ERROR |

**Estado global: ERROR.** Corregir los hallazgos de este documento reduce las violaciones, pero el Quality Gate también exige pruebas automatizadas y menos duplicación.

### 1.2 Prioridad del frontend

| Prioridad | Qué corregir | Cantidad |
|:---|:---|:---:|
| **P1 — Bugs** | Inputs sin etiqueta | 3 |
| **P2 — Code smell crítico** | `javascript:S3776` en `subirArchivos()` | 1 |
| **P3 — Code smells mayores** | `Web:S6819` (16), `css:S4666` (5), `css:S7924` (3), `Web:S6850` (2), `Web:S6842`, `javascript:S7768`, `Web:S7926` | 29 |
| **P4 — Code smells menores** | `javascript:S2486` (12), `javascript:S6582` (4), `javascript:S6353`, `javascript:S7776`, `javascript:S1874` | 19 |
| **P5 — Quality Gate** | Cobertura y duplicación globales | — |

---

## 2. Bugs (3)

| Regla | Severidad | Ubicación | Cambio |
|:---|:---|:---|:---|
| `Web:InputWithoutLabelCheck` | Major | `frontend-cliente/pages/panelcliente.html:47` | Asociar un `<label>` al input `#tagBusqueda`. |
| `Web:InputWithoutLabelCheck` | Major | `frontend-fotografo/pages/SubirImagenes.html:47` | Asociar un `<label>` al input `#tagInput`. |
| `Web:InputWithoutLabelCheck` | Major | `frontend-fotografo/pages/SubirImagenes.html:129` | Asociar un `<label>` al input de archivos `#selectorArchivos`. |

**Ejemplo:**

```html
<label class="VisualmenteOculto" for="tagBusqueda">Buscar por etiqueta</label>
<input id="tagBusqueda" type="text" placeholder="Escribe un tag" list="sugerenciasHashtags" />
```

Añadir la clase `VisualmenteOculto` a `base.css` si no existe:

```css
.VisualmenteOculto {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0 0 0 0);
    white-space: nowrap;
    border: 0;
}
```

Para el input de archivos oculto, asociar el botón visible con el input:

```html
<label class="BotonSubir" for="selectorArchivos">Seleccionar archivos</label>
<input type="file" id="selectorArchivos" hidden />
```

---

## 3. Code smells (49)

### 3.1 Crítico

#### `javascript:S3776` — Complejidad cognitiva excesiva (1)

| Ubicación | Función | Complejidad actual | Límite |
|:---|:---|---:|---:|
| `frontend-fotografo/dom/colecciones/subirimagenes.js:301` | `subirArchivos()` | 17 | 15 |

**Cambio:** extraer la subida de un archivo a una función `subirUnArchivo(archivo)` y separar el manejo de errores/progreso. El bucle principal debe limitarse a recorrer la lista y acumular resultados.

### 3.2 Mayores

#### `Web:S6819` — Preferir HTML nativo sobre roles ARIA (16)

**a) `role="status"` → `<output>` (12)**

| Archivo | Línea |
|:---|:---:|
| `frontend-cliente/pages/login.html` | 59 |
| `frontend-cliente/pages/registro.html` | 106 |
| `frontend-cliente/pages/verificaremail.html` | 69 |
| `frontend-fotografo/pages/crearcoleccion.html` | 46 |
| `frontend-fotografo/pages/editarperfil.html` | 63 |
| `frontend-fotografo/pages/login.html` | 60 |
| `frontend-fotografo/pages/moderacion.html` | 86 |
| `frontend-fotografo/pages/panel.html` | 48 |
| `frontend-fotografo/pages/panel.html` | 187 |
| `frontend-fotografo/pages/registro.html` | 106 |
| `frontend-fotografo/pages/SubirImagenes.html` | 138 |
| `frontend-fotografo/pages/verificaremail.html` | 69 |

**Cambio:** reemplazar el elemento con `role="status"` por `<output>`. Ejemplo:

```html
<output id="mensajeEstado" class="MensajeEstado"></output>
```

`<output>` ya tiene el rol implícito `status`; no hace falta añadir `role`. Revisar el CSS si el selector dependía de `p` o `div`.

**b) `role="textbox"` → `<input>` o `<textarea>` (2)**

| Archivo | Línea | Elemento actual |
|:---|:---:|---|
| `frontend-fotografo/pages/SubirImagenes.html` | 15 | `<h2 contenteditable role="textbox">` |
| `frontend-fotografo/pages/SubirImagenes.html` | 25 | `<p contenteditable role="textbox">` |

**Cambio:** usar controles nativos:

```html
<input id="nombreColeccion" type="text" class="CampoEditable" aria-label="Título de la colección" />
<textarea id="descripcionColeccionTexto" class="CampoEditable" aria-label="Descripción de la colección"></textarea>
```

Actualizar `subirimagenes.js` para leer/escribir `.value` en lugar de `textContent`. Si se mantiene `contenteditable` por diseño, documentar la excepción y justificarla; Sonar seguirá marcándola.

**c) `role="dialog"` → `<dialog>` (2)**

| Archivo | Línea |
|:---|:---:|
| `frontend-fotografo/pages/SubirImagenes.html` | 161 |
| `frontend-fotografo/pages/SubirImagenes.html` | 201 |

**Cambio:** usar el elemento nativo:

```html
<dialog class="ModalQr" id="modalQrColaborativo" aria-labelledby="tituloQrColaborativo">
    <div class="ModalQrContenido">...</div>
</dialog>
```

Abrir con `dialog.showModal()` y cerrar con `dialog.close()`. Ajustar `::backdrop` en CSS. Eliminar `role="dialog"` y `aria-modal="true"` cuando se use `<dialog>`.

#### `css:S4666` — Selectores CSS duplicados (5)

| Archivo | Línea | Selector | Primera aparición |
|:---|:---:|---|:---:|
| `frontend-cliente/css/panelcliente.css` | 339 | `.FlechaVisor` | 254 |
| `frontend-fotografo/css/subirimagenes.css` | 495 | `.ZonaCarga` | 288 |
| `frontend-fotografo/css/subirimagenes.css` | 500 | `.ZonaCarga .Formatos` | 320 |
| `frontend-fotografo/css/subirimagenes.css` | 535 | `.ModalQrContenido` | 341 |
| `frontend-fotografo/css/tuscolecciones.css` | 442 | `.TarjetaMedia` | 406 |

**Cambio:** consolidar las declaraciones en una sola regla por selector. Si la segunda regla existe para un estado o contexto distinto, usar una clase modificadora (`.ZonaCarga--activa`) en lugar de repetir el selector.

#### `css:S7924` — Contraste insuficiente (3)

| Archivo | Línea | Ajuste sugerido |
|:---|:---:|---|
| `frontend-fotografo/css/tuscolecciones.css` | 194 | Texto blanco sobre `#2bb58a`: oscurecer el fondo (por ejemplo `#167a5b`) hasta alcanzar 4.5:1. |
| `frontend-fotografo/css/tuscolecciones.css` | 428 | Texto blanco sobre `rgba(255,255,255,0.85)`: usar un color de texto oscuro o un fondo sólido oscuro. |
| `frontend-fotografo/css/tuscolecciones.css` | 497 | Texto blanco sobre `#e74c3c`: oscurecer a `#b42318` o similar y verificar 4.5:1. |

**Cambio:** validar cada combinación con una herramienta de contraste WCAG. Para texto normal el mínimo es **4.5:1**; para texto grande, **3:1**. No cambiar solo el color del texto sin comprobar el fondo real (incluidos estados `hover` y `focus`).

#### `Web:S6850` — Encabezados sin contenido accesible (2)

| Archivo | Línea | Elemento |
|:---|:---:|---|
| `frontend-cliente/pages/colaborativo.html` | 26 | `<h1 id="nombreEvento"></h1>` |
| `frontend-cliente/pages/tuscoleccionescliente.html` | 44 | `<h2 id="tituloInvitacion"></h2>` |

**Cambio:** añadir un texto inicial accesible (aunque luego se reemplace por JS) o mantener el encabezado oculto hasta que tenga contenido:

```html
<h1 id="nombreEvento">Evento colaborativo</h1>
```

Si el encabezado se rellena de forma asíncrona, mostrar un texto de carga y actualizarlo con `textContent`; no dejar el nodo vacío.

#### `Web:S6842` — Elemento no interactivo con rol interactivo (1)

**Ubicación:** `frontend-fotografo/pages/SubirImagenes.html:15`  
**Elemento:** `<h2 contenteditable="true" role="textbox">`

**Cambio:** el mismo de `Web:S6819` apartado b): reemplazar por `<input>` o `<textarea>`. Si se conserva `contenteditable`, eliminar `role="textbox"` no es una opción accesible; en ese caso documentar la excepción.

#### `javascript:S7768` — Usar `.before()` en lugar de `insertBefore()` (1)

**Ubicación:** `frontend-fotografo/dom/colecciones/subirimagenes.js:269`

**Código actual:**

```js
galeria.insertBefore(tarjeta, botonAgregar);
```

**Cambio:**

```js
botonAgregar.before(tarjeta);
```

#### `Web:S7926` — Viewport deshabilita el zoom (1)

**Ubicación:** `frontend-cliente/pages/colaborativo.html:5`

**Código actual:**

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
```

**Cambio:**

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
```

No impedir el zoom: es un requisito de accesibilidad (WCAG 1.4.4).

### 3.3 Menores

#### `javascript:S2486` — Excepciones capturadas e ignoradas (12)

| Archivo | Líneas |
|:---|:---|
| `frontend-cliente/dom/colecciones/panelcliente.js` | 152 |
| `frontend-cliente/dom/colecciones/tuscoleccionescliente.js` | 28, 145 |
| `frontend-cliente/dom/favoritos/favoritos.js` | 18 |
| `frontend-cliente/dom/multimedia/multimedia.js` | 13, 36 |
| `frontend-fotografo/dom/colecciones/qr.js` | 78 |
| `frontend-fotografo/dom/colecciones/subirimagenes.js` | 309 |
| `frontend-fotografo/dom/colecciones/tags.js` | 91 |
| `frontend-fotografo/dom/comun/almacenamiento.js` | 20 |
| `frontend-fotografo/dom/multimedia/multimedia.js` | 13, 36 |

**Cambio:** no dejar un `catch` vacío ni solo con un comentario. Opciones:

- Mostrar un mensaje al usuario con `mostrarToast` o un estado de error.
- Registrar el detalle con `console.error`/`console.warn` y aplicar un valor de respaldo.
- Eliminar el `try/catch` si la excepción debe propagarse.

Ejemplo:

```js
} catch (error) {
    console.warn("No se pudo cargar la portada de la colección.", error);
    elemento.classList.add("VistaNoDisponible");
}
```

#### `javascript:S6582` — Preferir optional chaining (4)

| Archivo | Línea |
|:---|:---:|
| `frontend-cliente/dom/colecciones/tarjetas.js` | 2 |
| `frontend-fotografo/dom/colecciones/subirimagenes.js` | 390 |
| `frontend-fotografo/services/multimedia/multimediaService.js` | 6 |
| `frontend-fotografo/services/multimedia/multimediaService.js` | 7 |

**Cambio:** reemplazar comprobaciones manuales por `?.`. Ejemplo:

```js
const mostrarFotografo = opciones?.mostrarFotografo !== false;
```

Verificar que el comportamiento con `undefined`/`null` sea el mismo que antes.

#### `javascript:S6353` — Clase de caracteres redundante (1)

**Ubicación:** `frontend-fotografo/dom/perfil/editarperfil.js:11`

**Código actual:**

```js
String(valor || "").replace(/[^0-9]/g, "")
```

**Cambio:**

```js
String(valor || "").replace(/\D/g, "")
```

#### `javascript:S7776` — Usar `Set` para comprobar existencia (1)

**Ubicación:** `frontend-cliente/dom/colecciones/panelcliente.js:33`

**Código actual:**

```js
const tags = (coleccion.hashtags || []).map(normalizarTag);
// ...
if (tags.includes(tagsSeleccionados[i])) return i;
```

**Cambio:**

```js
const tags = new Set((coleccion.hashtags || []).map(normalizarTag));
// ...
if (tags.has(tagsSeleccionados[i])) return i;
```

#### `javascript:S1874` — `document.execCommand` obsoleto (1)

**Ubicación:** `frontend-fotografo/dom/colecciones/subirimagenes.js:211`

**Código actual:**

```js
document.execCommand("insertText", false, texto);
```

**Cambio:** insertar el texto con la API de selección:

```js
const seleccion = window.getSelection();
if (seleccion && seleccion.rangeCount > 0) {
    const rango = seleccion.getRangeAt(0);
    rango.deleteContents();
    rango.insertNode(document.createTextNode(texto));
    rango.collapse(false);
    seleccion.removeAllRanges();
    seleccion.addRange(rango);
}
```

Si se necesita compatibilidad con navegadores antiguos, mantener `execCommand` como fallback y documentarlo, pero la ruta principal debe usar la API estándar.

---

## 4. Plan de corrección del frontend

### P1 — Bugs

1. Añadir etiquetas a los 3 inputs:
   - `frontend-cliente/pages/panelcliente.html:47`
   - `frontend-fotografo/pages/SubirImagenes.html:47`
   - `frontend-fotografo/pages/SubirImagenes.html:129`

### P2 — Code smell crítico

1. Refactorizar `subirArchivos()` en `frontend-fotografo/dom/colecciones/subirimagenes.js:301` y extraer la subida de un archivo.

### P3 — Accesibilidad y CSS

1. Reemplazar `role="status"` por `<output>` en las 12 ubicaciones.
2. Reemplazar `role="textbox"` por `<input>`/`<textarea>` en `SubirImagenes.html:15` y `:25`.
3. Reemplazar `role="dialog"` por `<dialog>` en `SubirImagenes.html:161` y `:201`.
4. Consolidar los 5 selectores CSS duplicados.
5. Ajustar los 3 contrastes de `tuscolecciones.css`.
6. Corregir los encabezados vacíos de `colaborativo.html:26` y `tuscoleccionescliente.html:44`.
7. Eliminar `user-scalable=no` del viewport de `colaborativo.html`.
8. Aplicar `.before()` en `subirimagenes.js:269`.

### P4 — Menores

1. Gestionar las 12 excepciones ignoradas (`javascript:S2486`).
2. Aplicar optional chaining en las 4 ubicaciones (`javascript:S6582`).
3. Usar `\D` en `editarperfil.js:11` (`javascript:S6353`).
4. Usar `Set` en `panelcliente.js:33` (`javascript:S7776`).
5. Sustituir `document.execCommand` por la API de selección (`javascript:S1874`).

### P5 — Quality Gate

1. Añadir pruebas de interfaz o unitarias para los flujos principales (login, panel, subida, moderación).
2. Generar reportes de cobertura y configurar `sonar.javascript.lcov.reportPaths`.
3. Reducir la duplicación entre `frontend-cliente` y `frontend-fotografo` extrayendo utilidades compartidas (HTTP, formato, validaciones).
4. Volver a ejecutar el escaneo y verificar que el Quality Gate pasa.

---

## 5. Cómo verificar los cambios

### 5.1 Reejecutar SonarQube

```powershell
$token = Get-Content "$env:TEMP\sonar_token.txt" -Raw
& "C:\Sonar-Scanner\sonar-scanner\bin\sonar-scanner.bat" `
  "-Dsonar.host.url=http://localhost:9000" `
  "-Dsonar.token=$token"
```

Dashboard: <http://localhost:9000/dashboard?id=cipher-forge>  
Hallazgos: <http://localhost:9000/project/issues?id=cipher-forge&resolved=false>

### 5.2 Verificar accesibilidad

- Navegar con teclado: todos los inputs deben recibir foco y tener etiqueta.
- Probar el zoom del navegador al 200 % en `colaborativo.html`.
- Ejecutar Lighthouse o axe DevTools en las páginas de login, panel y subida.
- Verificar que los diálogos se abren/cierran con `Esc` y devuelven el foco al botón que los abrió.
- Comprobar los mensajes de estado con un lector de pantalla (NVDA o VoiceOver).

### 5.3 Verificar los cambios visuales

- Revisar los 3 contrastes con una herramienta WCAG.
- Comprobar que los selectores CSS consolidados no alteran el layout en escritorio y móvil.
- Verificar que `<output>` y `<dialog>` mantienen el estilo y el comportamiento esperados.

---

## 6. Notas

- **Sin vulnerabilidades:** el frontend no presenta vulnerabilidades en este escaneo. Los 52 hallazgos son 3 bugs de accesibilidad y 49 code smells.
- **Roles ARIA:** reemplazar roles por HTML nativo puede afectar selectores CSS y JS. Hacerlo por partes y probar cada pantalla.
- **`contenteditable`:** el cambio de `h2`/`p` editables a `<input>`/`<textarea>` es el cambio más invasivo del frontend; requiere ajustar `subirimagenes.js` y los estilos.
- **Duplicación:** extraer utilidades compartidas entre ambos frontends ayuda al Quality Gate, pero no mezclar responsabilidades de cliente y fotógrafo solo para reducir líneas.
- **Líneas:** las ubicaciones corresponden al commit `0aca934`; si se modifica el código, los números de línea pueden desplazarse. Verificar siempre contra el archivo actual.

---

*Documento del frontend generado el 26/10/2026 a partir del análisis SonarQube `cipher-forge` (commit `0aca934`).*
