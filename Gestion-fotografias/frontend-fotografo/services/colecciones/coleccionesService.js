import { enviarJson } from "../http.js";

export async function crearColeccion(datos) {
    return await enviarJson("/colecciones", "POST", datos);
}

export async function listarMisColecciones() {
    return await enviarJson("/colecciones/mias", "GET");
}

export async function detalleColeccion(id) {
    return await enviarJson("/colecciones/" + id, "GET");
}

export async function listarHashtags() {
    return await enviarJson("/hashtags", "GET");
}

export async function actualizarHashtags(coleccionId, hashtags) {
    return await enviarJson("/colecciones/" + coleccionId + "/hashtags", "PUT", {
        hashtags: hashtags || [],
    });
}

export async function actualizarColeccion(id, datos) {
    return await enviarJson("/colecciones/" + id, "PUT", datos);
}

export async function eliminarColeccion(id) {
    return await enviarJson("/colecciones/" + id, "DELETE");
}
