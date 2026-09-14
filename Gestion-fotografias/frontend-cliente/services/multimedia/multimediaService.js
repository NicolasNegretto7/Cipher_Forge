import { enviarJson, obtenerArchivo } from "../http.js";

export async function listarMultimedia(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/multimedia", "GET");
}

export async function obtenerVistaPrevia(id) {
    const archivo = await obtenerArchivo("/multimedia/" + id + "/vista-previa");
    return archivo.blob;
}

export async function obtenerPoster(id) {
    const archivo = await obtenerArchivo("/multimedia/" + id + "/poster");
    return archivo.blob;
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
