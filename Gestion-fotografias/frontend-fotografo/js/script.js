const API_URL = "http://localhost:8080";

function guardarSesion(token, usuario) {
    localStorage.setItem("token", token);
    localStorage.setItem("usuario", JSON.stringify(usuario));
}

function limpiarSesionGuardada() {
    localStorage.removeItem("token");
    localStorage.removeItem("usuario");
    localStorage.removeItem("cuota-almacenamiento");
}

// Verifica la expiración (exp) del JWT en el cliente, sin validar la firma.
// Retorna true solo si el token tiene formato JWT válido y aún no expiró.
function tokenVigente(token) {
    try {
        const partes = String(token).split(".");
        if (partes.length !== 3) return false;
        const payload = JSON.parse(atob(partes[1].replace(/-/g, "+").replace(/_/g, "/")));
        if (!payload.exp) return true; // Sin exp: no podemos saber, se deja pasar.
        return Date.now() < Number(payload.exp) * 1000;
    } catch (e) {
        return false;
    }
}

function irSegunRol(rol) {
    if (rol === "fotografo") {
        window.location.href = "panel.html";
    } else {
        window.location.href = "../../frontend-cliente/pages/panelcliente.html";
    }
}

function mostrarMensaje(elemento, texto, esError) {
    if (!elemento) {
        alert(texto);
        return;
    }
    elemento.textContent = texto;
    elemento.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

async function registrarUsuario(datos) {
    return api.registrarse(datos);
}

async function iniciarSesion(datos) {
    return api.iniciarSesion(datos);
}

const formRegistro = document.getElementById("formRegistro");
if (formRegistro) {
    const mensaje = document.getElementById("mensajeRegistro");

    formRegistro.onsubmit = async function (evento) {
        evento.preventDefault();

        const nombre = document.getElementById("nombre").value.trim();
        const correo = document.getElementById("correo").value.trim();
        const contrasena = document.getElementById("contraseña").value;
        const telefono = document.getElementById("telefono")?.value.trim() || "";
        const rol = document.getElementById("rol").value;
        const boton = formRegistro.querySelector("button[type=submit]");

        boton.disabled = true;
        mostrarMensaje(mensaje, "Creando la cuenta...", false);

        try {
            const resultado = await registrarUsuario({
                nombre_completo: nombre,
                email: correo,
                password: contrasena,
                telefono: telefono,
                rol: rol
            });

            localStorage.setItem("email-verificacion-pendiente", resultado.email || correo);
            localStorage.setItem("codigo-verificacion-pendiente", resultado.codigo_verificacion || "");

            mostrarMensaje(mensaje, "Cuenta creada correctamente. Verifica tu correo para poder iniciar sesión.", false);
            setTimeout(function () {
                window.location.href = "verificaremail.html";
            }, 1200);
        } catch (error) {
            mostrarMensaje(mensaje, error.message, true);
            boton.disabled = false;
        }

        return false;
    };
}

const formLogin = document.getElementById("formLogin");
if (formLogin) {
    const mensajeLogin = document.getElementById("mensajeLogin");
    const tokenGuardado = localStorage.getItem("token");
    const usuarioGuardado = localStorage.getItem("usuario");

    // Solo reutilizar la sesión guardada si el JWT aún está vigente.
    // Antes se redirigía con cualquier token (incluso expirado/inválido) y eso
    // provocaba un rebote infinito panel.html <-> login.html: panel devolvía 401
    // y mandaba a login, y login devolvía a panel sin validar nada.
    if (tokenGuardado && usuarioGuardado && tokenVigente(tokenGuardado)) {
        try {
            const usuario = JSON.parse(usuarioGuardado);
            irSegunRol(usuario.rol || usuario.role);
        } catch (e) {
            limpiarSesionGuardada();
        }
    } else if (tokenGuardado || usuarioGuardado) {
        // Token ausente, malformado o expirado: no redirigir, limpiar para
        // que el usuario inicie sesión de nuevo en lugar de rebotar.
        limpiarSesionGuardada();
    }

    formLogin.onsubmit = async function (evento) {
        evento.preventDefault();

        const correo = document.getElementById("correo").value.trim();
        const contrasena = document.getElementById("contraseña").value;
        const boton = formLogin.querySelector("button[type=submit]");

        boton.disabled = true;
        mostrarMensaje(mensajeLogin, "Iniciando sesión...", false);

        try {
            const usuario = await iniciarSesion({
                email: correo,
                password: contrasena
            });

            guardarSesion(usuario.token, usuario);
            irSegunRol(usuario.rol || usuario.role);
        } catch (error) {
            mostrarMensaje(mensajeLogin, error.message, true);
            boton.disabled = false;
        }

        return false;
    };
}