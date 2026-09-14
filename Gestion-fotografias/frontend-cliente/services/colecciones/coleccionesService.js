import { enviarJson } from "../http.js";

export async function listarColeccionesPublicas(hashtag) {
    const query = hashtag ? "?hashtag=" + encodeURIComponent(hashtag) : "";
    return await enviarJson("/colecciones/publicas" + query, "GET");
}

export async function detalleColeccion(id) {
    return await enviarJson("/colecciones/" + id, "GET");
}

export async function listarHashtags() {
    return await enviarJson("/hashtags", "GET");
}
