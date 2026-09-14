# Cipher Forge

Proyecto de gestión de fotografías para estudiantes. El frontend usa HTML, CSS y JavaScript del navegador, sin framework ni compilación. El backend existente usa PHP y MySQL.

## Ejecutar el proyecto

1. Abre Docker Desktop. Desde `Gestion-fotografias/backend`, ejecuta:

    ```sh
    docker compose up -d --build
    ```

2. Abre la carpeta `Cipher_Forge` con Live Server. Usa `127.0.0.1` y el puerto `5500`.

3. Abre el frontend que quieras usar:

    - Fotógrafo: [frontend-fotografo](http://127.0.0.1:5500/Gestion-fotografias/frontend-fotografo/index.html)
    - Cliente: [frontend-cliente](http://127.0.0.1:5500/Gestion-fotografias/frontend-cliente/index.html)

El backend escucha en `http://localhost:8081`. El correo de desarrollo llega a [Mailpit](http://localhost:8025), donde puedes leer el código de verificación.

Los enlaces QR del Docker Compose están configurados para esa dirección.

No abras los HTML con doble clic: los módulos `import/export` necesitan un servidor HTTP. Si cambias el puerto o el host, ajusta `FRONTEND_URL` en `backend/docker-compose.yml`. Cada frontend tiene su propio `services/config.js` para indicar la dirección del backend.

## Organización

```text
frontend-cliente/
    index.html              Entrada del cliente
    pages/                  Login, registro, colecciones e invitaciones
    dom/                    Cambios del DOM, eventos y renderización
        auth/               Pantallas de acceso y registro
        colecciones/        Listados y detalle de colecciones
        favoritos/          Interfaz de favoritos
        multimedia/         Vistas y descargas
        comun/              Sesión e interfaz reutilizable
    services/               Configuración HTTP y servicios agrupados por tema
    css/                    Todos los estilos del cliente
frontend-fotografo/
    index.html              Bienvenida
    pages/                  Login, registro, panel, subida y moderación
    dom/                    Cambios del DOM, eventos y renderización
        auth/               Pantallas de acceso y registro
        colecciones/        Panel, subida, QR y moderación
        multimedia/         Vistas de imágenes y videos
        perfil/             Perfil y privacidad
        comun/              Sesión y almacenamiento mostrado
    services/               Configuración HTTP y servicios agrupados por tema
    css/                    Todos los estilos del fotógrafo
backend/                    API PHP, base de datos y Docker
docs/                       Documentación del proyecto
```

En cada frontend, todos los HTML cargan primero su propio `css/base.css`. Ese archivo
define los colores, la tipografía, los controles, la navegación, las tarjetas y los
estados comunes. Después se carga, cuando hace falta, un CSS pequeño con los ajustes
de esa pantalla. Los elementos creados desde `dom/` reciben clases CSS y no escriben
estilos en línea.

## Cómo leer el código

Los dos frontends son aplicaciones independientes. No importan JavaScript o CSS del otro frontend, usan claves de sesión diferentes y cada uno ofrece sus propias pantallas de ingreso, registro y verificación.

Empieza por un HTML de `pages/`. Al final encontrarás un solo `<script type="module">` que apunta a `dom/`. Todo archivo dentro de `dom/` pertenece a la interfaz: obtiene o modifica elementos HTML, registra eventos, renderiza resultados y llama a los servicios.

Por ejemplo, `frontend-fotografo/dom/colecciones/crearcoleccion.js`:

1. Lee el nombre y la descripción del formulario.
2. Ejecuta `await crearColeccion(datos)`.
3. Abre la pantalla de subida usando el ID que devuelve el servidor.
4. Si falla, muestra el error y vuelve a habilitar el botón.

Los datos y la interfaz están separados así:

```js
// services/colecciones/coleccionesService.js: conoce el endpoint, no el HTML.
import { enviarJson } from "../http.js";

export async function listarMisColecciones() {
    return await enviarJson("/colecciones/mias", "GET");
}

// dom/colecciones/panel.js: modifica el DOM, no escribe fetch.
import { listarMisColecciones } from "../../services/colecciones/coleccionesService.js";

async function cargarColecciones() {
    try {
        const colecciones = await listarMisColecciones();
        // Crear y mostrar los elementos del HTML.
    } catch (error) {
        // Informar qué ocurrió.
    }
}
```

Solo `services/http.js` usa `fetch`. Los otros archivos de `services` agrupan las rutas por tema: autenticación, colecciones, multimedia, favoritos e invitaciones. Ningún servicio crea elementos del DOM.

El contenido recibido del backend se muestra con `textContent` o creando elementos con `createElement`. No se usa `innerHTML`, `document.write`, `eval` ni código HTML construido con datos externos. Los enlaces externos devueltos por el backend se validan antes de asignarlos al DOM.

No hay objetos globales `window.api`, funciones autoejecutadas ni cadenas `.then()/.catch()`. Las operaciones asíncronas usan `async/await` y `try/catch`. Las funciones que solo dibujan o calculan siguen siendo funciones normales. Los eventos del navegador usan `addEventListener`; `window.print()` abre el diálogo de impresión del navegador.

## Flujo del fotógrafo

- Registrarse, verificar el correo e iniciar sesión.
- Aceptar la política del panel.
- Crear una colección privada: se guarda inmediatamente en el servidor.
- Seleccionar JPG o MP4: se suben uno por uno. El backend comprueba el formato real, los permisos y el espacio disponible.
- Administrar etiquetas, visibilidad, archivos y colecciones.
- Generar el QR de acceso o el colaborativo; revisar los aportes en Moderación.

Las colecciones y los archivos se consultan al servidor al abrir la página. No hay copias de fotos en `localStorage`, base binaria en el navegador ni sincronización de borradores. Si falla una subida, se informa qué archivo falló; los que ya llegaron permanecen guardados. Puedes volver a seleccionar los archivos fallidos.

**Cambio respecto a la versión anterior:** los borradores sin publicar que solo estaban en el navegador no se importan automáticamente. Sus datos locales no se borran. Si tenías alguno, conserva los archivos originales y vuelve a crear/subir esa colección. Las colecciones ya guardadas en el backend aparecen en el panel.

## Flujo del cliente

- Iniciar sesión para explorar y filtrar colecciones públicas por etiquetas.
- Guardar y quitar favoritos con sesión iniciada.
- Abrir una invitación, iniciar sesión si hace falta y canjearla.
- Ver fotografías y videos; descargar en calidad estándar u original.
- Subir aportes desde un QR colaborativo sin registro.

El backend decide quién puede ver y descargar archivos privados. `Tus colecciones` recuerda los IDs de los accesos en este navegador, separados por usuario; el permiso real se comprueba en el servidor. Para recuperar un acceso en otro navegador, vuelve a abrir su invitación. Este backend aún no tiene un endpoint que liste todas las invitaciones canjeadas por un cliente.
