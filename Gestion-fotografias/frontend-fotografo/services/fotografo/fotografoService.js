import { enviarJson } from "../http.js";

export async function actualizarPerfil(datos) {
    return await enviarJson("/fotografo/perfil", "PUT", datos);
}

export async function aceptarPoliticas() {
    return await enviarJson("/fotografos/aceptar-politicas", "POST");
}

export async function consultarCuota() {
    return await enviarJson("/fotografos/cuota", "GET");
}
