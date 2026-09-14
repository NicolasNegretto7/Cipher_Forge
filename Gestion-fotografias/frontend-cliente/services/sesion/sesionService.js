export function obtenerToken() {
    return localStorage.getItem("cliente-token");
}

export function obtenerUsuario() {
    try {
        return JSON.parse(localStorage.getItem("cliente-usuario") || "null");
    } catch (error) {
        return null;
    }
}

export function guardarSesion(token, usuario) {
    localStorage.setItem("cliente-token", token);
    delete usuario.token;
    guardarUsuario(usuario);
}

export function guardarUsuario(usuario) {
    localStorage.setItem("cliente-usuario", JSON.stringify(usuario));
}

export function limpiarSesion() {
    localStorage.removeItem("cliente-token");
    localStorage.removeItem("cliente-usuario");
    localStorage.removeItem("cliente-cuota-almacenamiento");
}

export function haySesion() {
    return Boolean(obtenerToken() && obtenerUsuario());
}
