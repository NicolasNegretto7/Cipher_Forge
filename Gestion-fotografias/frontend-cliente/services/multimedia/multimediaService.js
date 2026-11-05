import { enviarJson, obtenerArchivo } from "../http.js";

export async function listarMultimedia(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/multimedia", "GET");
}

// Rutas de los binarios derivados. Se exponen para que la capa DOM pueda
// declarar el origen diferido (data-src) sin repetir la ruta en dos sitios.
export function rutaVistaPrevia(id) {
    return "/multimedia/" + id + "/vista-previa";
}

export function rutaPoster(id) {
    return "/multimedia/" + id + "/poster";
}

// Descarga un binario de la API por su ruta, con la sesión activa.
export async function obtenerBinario(ruta) {
    const archivo = await obtenerArchivo(ruta);
    return archivo.blob;
}

export async function obtenerVistaPrevia(id) {
    return await obtenerBinario(rutaVistaPrevia(id));
}

// Entrega los datos necesarios para descargar. El enlace se crea en dom/multimedia/descargas.js.
export async function obtenerDescarga(id, calidad) {
    const ruta = "/multimedia/" + id + "/descargar?calidad=" + encodeURIComponent(calidad);
    const archivo = await obtenerArchivo(ruta);
    const coincidencia = /filename="?([^";\n]+)"?/.exec(archivo.disposicion);
    const extension = archivo.tipo.startsWith("video/") ? ".mp4" : ".jpg";
    const nombre = coincidencia ? coincidencia[1] : "descarga-" + id + "-" + calidad + extension;
    return { blob: archivo.blob, nombre: nombre };
}
