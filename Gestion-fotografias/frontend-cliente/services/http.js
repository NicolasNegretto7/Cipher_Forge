import { API_URL } from "./config.js";
import { obtenerToken, limpiarSesion } from "./sesion/sesionService.js";

function cabeceras(conCuerpo) {
    const headers = {};
    if (conCuerpo) headers["Content-Type"] = "application/json";
    const token = obtenerToken();
    if (token) headers.Authorization = "Bearer " + token;
    return headers;
}

async function parsear(respuesta) {
    if (respuesta.status === 401) limpiarSesion();
    let json;
    try {
        json = await respuesta.json();
    } catch (error) {
        throw new Error("El servidor no devolvió una respuesta válida.");
    }
    // Validar que la respuesta sea un objeto para evitar usar datos maliciosos arbitrarios.
    if (json === null || typeof json !== "object") {
        throw new Error("El servidor no devolvió una respuesta válida.");
    }
    if (!respuesta.ok) {
        const mensajeBase = typeof json.mensaje === "string" ? json.mensaje : "No se pudo completar la solicitud.";
        let mensaje = mensajeBase;
        const errores = Array.isArray(json.errores) ? json.errores : [];
        for (const detalle of errores) {
            if (typeof detalle === "string") mensaje += "\n" + detalle;
            else if (detalle && typeof detalle === "object") {
                const motivo = typeof detalle.motivo === "string" ? detalle.motivo : "Archivo inválido.";
                mensaje += "\n" + motivo;
            }
        }
        const error = new Error(mensaje);
        error.status = respuesta.status;
        error.errores = errores;
        throw error;
    }
    if (json.datos === undefined) {
        return json;
    }
    if (json.datos === null || typeof json.datos !== "object") {
        throw new Error("El servidor no devolvió una respuesta válida.");
    }
    return json.datos;
}

export async function enviarJson(ruta, metodo, cuerpo) {
    const opciones = {
        method: metodo,
        headers: cabeceras(cuerpo !== undefined),
        credentials: 'include',
    };
    if (cuerpo !== undefined) opciones.body = JSON.stringify(cuerpo);
    const respuesta = await fetch(API_URL + ruta, opciones);
    return await parsear(respuesta);
}

export async function enviarMultipart(ruta, metodo, formulario, conAuth) {
    const opciones = {
        method: metodo,
        headers: {},
        body: formulario,
        credentials: 'include',
    };
    if (conAuth) opciones.headers = cabeceras(false);
    const respuesta = await fetch(API_URL + ruta, opciones);
    return await parsear(respuesta);
}

export function adjuntarArchivos(formulario, archivos) {
    for (const archivo of archivos) formulario.append("archivos[]", archivo);
}

// Devuelve el archivo y sus cabeceras. No crea imágenes ni enlaces HTML.
export async function obtenerArchivo(ruta) {
    const respuesta = await fetch(API_URL + ruta, { headers: cabeceras(false), credentials: 'include' });
    if (!respuesta.ok) await parsear(respuesta);
    const blob = await respuesta.blob();
    return {
        blob: blob,
        disposicion: respuesta.headers.get("Content-Disposition") || "",
        tipo: respuesta.headers.get("Content-Type") || blob.type,
    };
}
