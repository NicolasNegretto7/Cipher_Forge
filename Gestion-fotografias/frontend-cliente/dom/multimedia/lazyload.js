// Instancia única y centralizada de Vanilla LazyLoad (v19.1.3).
//
// La aplicación usa el patrón oficial "lazy functions" de la librería: una
// sola instancia decide cuándo un elemento entra en el viewport y
// `callback_enter` dispara la descarga. Como los binarios viven detrás de la
// API y exigen una petición autenticada (cookie de sesión y, si existe, token
// Bearer), la descarga se hace con `fetch` y el resultado se aplica como URL
// `blob:`; un `<img src="...">` normal no llevaría esas credenciales.
//
// La ruta real se declara en `data-src`. Para que LazyLoad no la copie a `src`
// por su cuenta (lo que provocaría una petición sin credenciales), se configura
// `data_src: "lazy-src"`: la librería busca `data-lazy-src`, que no existe, y
// `callback_enter` consume `data-src`.
import LazyLoad from "../../lib/vanilla-lazyload.esm.js";

const ATRIBUTO_RUTA = "data-src";

// Cargador registrado por dom/multimedia/multimedia.js. Mantener aquí solo la
// referencia evita acoplar esta instancia a la capa de servicios.
let cargarMedia = null;
let actualizacionProgramada = false;

const instancia = new LazyLoad({
    elements_selector: ".LazyMedia",
    threshold: 0,
    unobserve_entered: true,
    data_src: "lazy-src",
    class_loading: "MediaCargando",
    class_loaded: "MediaCargada",
    class_error: "MediaError",
    class_entered: "MediaVisible",
    callback_enter(elemento) {
        const ruta = elemento.getAttribute(ATRIBUTO_RUTA);
        if (!ruta || !cargarMedia) return;
        // El observador puede notificar el mismo elemento más de una vez antes
        // de desobservarlo; la marca garantiza una sola descarga por elemento.
        if (elemento.dataset.lazyIniciado === "1") return;
        elemento.dataset.lazyIniciado = "1";
        cargarMedia(elemento, ruta);
    },
    callback_error(elemento) {
        // La librería ya aplica `MediaError`; para las miniaturas de galería se
        // añade además el aviso visual que conserva el hueco de la imagen.
        if (elemento.dataset.lazyAviso !== "1") return;
        elemento.setAttribute("aria-label", "Vista previa no disponible");
        elemento.classList.add("VistaNoDisponible");
    },
});

// Agrupa en un solo update() las altas del mismo tick para no reconsultar el
// DOM una vez por cada imagen.
function programarActualizacion() {
    if (actualizacionProgramada) return;
    actualizacionProgramada = true;
    queueMicrotask(function () {
        actualizacionProgramada = false;
        instancia.update();
    });
}

// Registra el cargador que ejecutará `callback_enter`.
export function configurarCargador(cargador) {
    cargarMedia = cargador;
}

// Declara la ruta diferida de un elemento y lo incorpora a la instancia única.
export function registrarMedia(elemento, ruta, opciones) {
    if (!elemento || !ruta) return;
    elemento.classList.add("LazyMedia");
    elemento.setAttribute(ATRIBUTO_RUTA, ruta);
    if (opciones && opciones.avisarError) elemento.dataset.lazyAviso = "1";
    programarActualizacion();
}

// Permite forzar una revisión del DOM tras inserciones fuera de registrarMedia.
export function actualizar() {
    programarActualizacion();
}

export { instancia };
