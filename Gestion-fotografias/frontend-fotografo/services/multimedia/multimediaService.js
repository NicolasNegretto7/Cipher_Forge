import { enviarJson, enviarMultipart, adjuntarArchivos, obtenerArchivo } from "../http.js";

export async function subirMultimedia(coleccionId, archivos, metadatos) {
    const formulario = new FormData();
    adjuntarArchivos(formulario, archivos);
    if (metadatos && metadatos.titulo) formulario.append("titulo", metadatos.titulo);
    if (metadatos && metadatos.descripcion) formulario.append("descripcion", metadatos.descripcion);
    return await enviarMultipart(
        "/colecciones/" + coleccionId + "/multimedia",
        "POST",
        formulario,
        true,
    );
}

export async function listarMultimedia(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/multimedia", "GET");
}

export async function eliminarMultimedia(id) {
    return await enviarJson("/multimedia/" + id, "DELETE");
}

export async function obtenerVistaPrevia(id) {
    const archivo = await obtenerArchivo("/multimedia/" + id + "/vista-previa");
    return archivo.blob;
}

export async function obtenerPoster(id) {
    const archivo = await obtenerArchivo("/multimedia/" + id + "/poster");
    return archivo.blob;
}
