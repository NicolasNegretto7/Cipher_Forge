import { enviarJson } from "../http.js";

export async function validarInvitacion(tokenInvitacion) {
    return await enviarJson("/invitaciones/" + encodeURIComponent(tokenInvitacion), "GET");
}

export async function canjearInvitacion(tokenInvitacion) {
    return await enviarJson(
        "/invitaciones/" + encodeURIComponent(tokenInvitacion) + "/canjear",
        "POST",
    );
}
