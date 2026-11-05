# Pruebas de carga diferida (Vanilla LazyLoad)

Estas pruebas verifican la integración de Lazy Loading del `frontend-cliente`.
**npm se usa únicamente como herramienta de pruebas**: la aplicación sigue
ejecutándose como JavaScript vanilla con módulos ES nativos, sin bundler ni
dependencias en tiempo de ejecución.

## Arquitectura que cubren

- Una **única instancia** de Vanilla LazyLoad 19.1.3
  (`dom/multimedia/lazyload.js`).
- Patrón oficial **"lazy functions"**: `unobserve_entered: true` +
  `callback_enter`.
- La ruta real se declara en `data-src`. La instancia se configura con
  `data_src: "lazy-src"` para que la librería **no** copie esa ruta a `src`
  (sería una petición sin credenciales); `callback_enter` la consume.
- El binario se descarga con `fetch` autenticado (cookie y, si existe, token
  Bearer) y se aplica como URL `blob:`.
- La librería gestiona las clases `MediaCargando`, `MediaCargada`,
  `MediaError` y `MediaVisible`, y su estado interno `data-ll-status`.
- No hay registro propio de tareas ni `WeakMap`: el despacho lo hace
  `callback_enter`.

## Requisitos

- Node.js 20 o superior.
- `npm install` dentro de `frontend-cliente` (instala `jsdom` y `playwright-core`).
- Para la prueba E2E:
  - Backend de Cipher Photo activo en la URL de `services/config.js`
    (`http://127.0.0.1:8080`).
  - Microsoft Edge instalado. También se puede indicar la ruta con la variable
    de entorno `EDGE_PATH`.

## Comandos

```bash
cd Gestion-fotografias/frontend-cliente
npm install
npm test          # pruebas funcionales con jsdom (sin navegador ni backend)
npm run test:e2e  # pruebas E2E con Edge real contra el backend
```

## Qué comprueba cada prueba

### `tests/lazyload.unit.mjs` (jsdom)

1. Antes de entrar en el viewport no hay petición ni `src`; `data-src` declara la ruta.
2. Al entrar se descarga una sola vez, se asigna la URL `blob:` y la librería
   aplica su clase y estado.
3. Los elementos lejanos no se descargan.
4. Cada portada declara su ruta (`vista-previa` o `poster`) y se carga al ser visible.
5. Un error de red hace que la librería aplique `MediaError` y
   `data-ll-status="error"`, sin dejar un `src` roto.
6. Una galería vacía no lanza errores.
7. `callback_enter` descarga una sola vez por elemento.

### `tests/lazyload.e2e.mjs` (Edge headless)

- **A.** Arnés con hasta 30 imágenes públicas reales: sólo una parte se descarga
  al inicio y todas al desplazarse; la librería marca todas como `MediaCargada`
  sin `MediaError`.
- **B.** `pages/coleccion.html` real: imágenes y videos usan `data-src`, reciben
  su `src` blob, la librería los marca como cargados y no hay excepciones de
  JavaScript.
- **C.** `pages/panelcliente.html` real: las portadas se marcan como diferidas,
  sólo se descargan las cercanas al viewport y la librería las marca como
  cargadas.

## Notas

- La prueba E2E inyecta una sesión de cliente en `localStorage` porque la sesión
  real vive en una cookie HttpOnly. Por eso la llamada a `/favoritos` responde
  `401`; es un error de red esperado y no una excepción de JavaScript.
- Las capturas de la prueba A se guardan en la carpeta temporal del sistema
  (`cipher-lazyload-top.png` y `cipher-lazyload-bottom.png`).
- Códigos de salida: `0` todo aprobado, `1` alguna prueba falló, `2` no se pudo
  ejecutar (falta una dependencia, el backend o el navegador).
