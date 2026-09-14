import { enviarJson } from "../http.js";

export async function agregarFavorito(idColeccion) {
    return await enviarJson("/favoritos/" + idColeccion, "POST");
}

export async function quitarFavorito(idColeccion) {
    return await enviarJson("/favoritos/" + idColeccion, "DELETE");
}

export async function listarFavoritos() {
    return await enviarJson("/favoritos", "GET");
}
