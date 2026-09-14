import { enviarJson } from "../http.js";

export async function registrarse(datos) {
    return await enviarJson("/auth/register", "POST", datos);
}

export async function iniciarSesion(datos) {
    return await enviarJson("/auth/login", "POST", datos);
}

export async function verificarEmail(email, codigo) {
    return await enviarJson("/auth/verificar-email", "POST", { email: email, codigo: codigo });
}

export async function reenviarCodigo(email) {
    return await enviarJson("/auth/reenviar-codigo", "POST", { email: email });
}
