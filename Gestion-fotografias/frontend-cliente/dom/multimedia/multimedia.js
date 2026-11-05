import {
    rutaVistaPrevia,
    rutaPoster,
    obtenerVistaPrevia,
    obtenerBinario,
} from "../../services/multimedia/multimediaService.js";
import { registrarMedia, configurarCargador } from "./lazyload.js";

// Asigna al elemento la URL temporal (blob) de la imagen ya descargada.
function aplicarBlob(elemento, blob) {
    const url = URL.createObjectURL(blob);
    if (elemento.isConnected) elemento.src = url;
    else URL.revokeObjectURL(url);
}

function marcarVistaNoDisponible(elemento, error) {
    console.warn("No se pudo cargar la vista previa.", error);
    elemento.setAttribute("aria-label", "Vista previa no disponible");
    elemento.classList.add("VistaNoDisponible");
}

// Usa el constructor de eventos del documento del elemento para funcionar
// igual en el navegador y en entornos de prueba (jsdom).
function notificarError(elemento) {
    const vista = elemento.ownerDocument && elemento.ownerDocument.defaultView;
    const Constructor = vista && vista.Event ? vista.Event : Event;
    elemento.dispatchEvent(new Constructor("error"));
}

// Cargador único de medios diferidos. LazyLoad lo invoca desde `callback_enter`
// cuando el elemento entra en el viewport. La descarga sigue siendo autenticada
// y el resultado se aplica como URL `blob:`.
configurarCargador(async function (elemento, ruta) {
    try {
        aplicarBlob(elemento, await obtenerBinario(ruta));
    } catch (error) {
        console.warn("No se pudo cargar el medio diferido.", error);
        // Deja que la instancia aplique su estado de error (class_error y
        // callback_error) en lugar de duplicar esa lógica aquí.
        notificarError(elemento);
    }
});

// Carga inmediata: la vista se necesita ya (visor a pantalla completa).
export async function cargarVista(elemento, archivo) {
    try {
        aplicarBlob(elemento, await obtenerVistaPrevia(archivo.id_multimedia));
    } catch (error) {
        marcarVistaNoDisponible(elemento, error);
    }
}

// Carga diferida: declara la ruta en data-src y la instancia única la descarga
// cuando el elemento entra en el viewport.
export function cargarVistaDiferida(elemento, archivo) {
    registrarMedia(elemento, rutaVistaPrevia(archivo.id_multimedia), {
        avisarError: true,
    });
}

export function cargarPortada(contenedor, coleccion) {
    if (!coleccion.portada_id_multimedia) return;
    const imagen = document.createElement("img");
    imagen.className = "ImagenTarjeta";
    imagen.alt = coleccion.titulo;
    const ruta =
        coleccion.portada_tipo === "video"
            ? rutaPoster(coleccion.portada_id_multimedia)
            : rutaVistaPrevia(coleccion.portada_id_multimedia);
    contenedor.replaceChildren(imagen);
    registrarMedia(imagen, ruta);
}

export function liberarVistas(contenedor) {
    for (const medio of contenedor.querySelectorAll("img, video")) {
        if (medio.src.startsWith("blob:")) URL.revokeObjectURL(medio.src);
    }
}
