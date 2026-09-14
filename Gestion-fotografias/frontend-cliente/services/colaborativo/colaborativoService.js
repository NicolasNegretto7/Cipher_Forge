import { enviarJson, enviarMultipart, adjuntarArchivos } from "../http.js";

export async function verificarAccesoColaborativo(tokenQr) {
    return await enviarJson("/colaborativo/" + encodeURIComponent(tokenQr), "GET");
}

export async function subirMaterialColaborativo(tokenQr, archivos, nombreInvitado) {
    const formulario = new FormData();
    adjuntarArchivos(formulario, archivos);
    if (nombreInvitado) formulario.append("nombre_invitado", nombreInvitado);
    return await enviarMultipart(
        "/colaborativo/" + encodeURIComponent(tokenQr) + "/subir",
        "POST",
        formulario,
        false,
    );
}
