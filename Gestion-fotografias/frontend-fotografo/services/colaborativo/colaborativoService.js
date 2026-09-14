import { enviarJson } from "../http.js";

export async function generarQrColaborativo(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/qr-colaborativo", "POST");
}

export async function generarQrAcceso(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/qr-acceso", "POST");
}

export async function listarPendientes(coleccionId) {
    return await enviarJson("/colecciones/" + coleccionId + "/colaborativo/pendientes", "GET");
}

export async function aprobarColaborativo(coleccionId, ids) {
    return await enviarJson("/colecciones/" + coleccionId + "/colaborativo/aprobar", "POST", {
        ids: ids,
    });
}

export async function rechazarColaborativo(coleccionId, ids) {
    return await enviarJson("/colecciones/" + coleccionId + "/colaborativo/rechazar", "POST", {
        ids: ids,
    });
}
