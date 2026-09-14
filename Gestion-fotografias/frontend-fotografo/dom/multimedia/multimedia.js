import {
    obtenerVistaPrevia,
    obtenerPoster,
} from "../../services/multimedia/multimediaService.js";

// Las URL temporales permiten mostrar archivos privados usando el token de sesión.
export async function cargarVista(elemento, archivo) {
    try {
        const blob = await obtenerVistaPrevia(archivo.id_multimedia);
        const url = URL.createObjectURL(blob);
        if (elemento.isConnected) elemento.src = url;
        else URL.revokeObjectURL(url);
    } catch (error) {
        elemento.setAttribute("aria-label", "Vista previa no disponible");
        elemento.classList.add("VistaNoDisponible");
    }
}

export async function cargarPortada(contenedor, coleccion) {
    if (!coleccion.portada_id_multimedia) return;
    try {
        let blob;
        if (coleccion.portada_tipo === "video")
            blob = await obtenerPoster(coleccion.portada_id_multimedia);
        else blob = await obtenerVistaPrevia(coleccion.portada_id_multimedia);
        const url = URL.createObjectURL(blob);
        if (!contenedor.isConnected) {
            URL.revokeObjectURL(url);
            return;
        }
        const imagen = document.createElement("img");
        imagen.className = "ImagenTarjeta";
        imagen.alt = coleccion.titulo;
        imagen.src = url;
        contenedor.replaceChildren(imagen);
    } catch (error) {
        // Conserva el nombre y el enlace de la colección si falta su portada.
    }
}

export function liberarVistas(contenedor) {
    for (const medio of contenedor.querySelectorAll("img, video")) {
        if (medio.src.startsWith("blob:")) URL.revokeObjectURL(medio.src);
    }
}
