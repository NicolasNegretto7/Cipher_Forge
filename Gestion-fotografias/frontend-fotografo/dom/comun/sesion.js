import {
    haySesion,
    obtenerUsuario,
    limpiarSesion,
} from "../../services/sesion/sesionService.js";

const LOGIN_URL = new URL("../../index.html", import.meta.url).href;

export function requiereSesion(rol) {
    const usuario = obtenerUsuario();
    if (!haySesion() || (rol && usuario.rol !== rol)) {
        limpiarSesion();
        location.href = LOGIN_URL;
        return null;
    }
    return usuario;
}

export function cerrarSesion() {
    limpiarSesion();
    location.href = LOGIN_URL;
}
