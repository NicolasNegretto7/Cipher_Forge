const API_URL = "http://localhost:8080";

function guardarSesion(token, usuario) {
    localStorage.setItem("token", token);
    localStorage.setItem("usuario", JSON.stringify(usuario));
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
        const aceptaPoliticas = document.getElementById("aceptaPoliticas")?.checked || false;
        const boton = formRegistro.querySelector("button[type=submit]");

        if (!aceptaPoliticas) {
            mostrarMensaje(mensaje, "Debés aceptar los Términos y Condiciones y la Política de Privacidad (Ley 18.331) para registrarte.", true);
            return;
        }

        boton.disabled = true;
        mostrarMensaje(mensaje, "Creando la cuenta...", false);

        try {
            const resultado = await registrarUsuario({
                nombre_completo: nombre,
                email: correo,
                password: contrasena,
                telefono: telefono,
                rol: rol,
                acepta_politicas: aceptaPoliticas
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

    if (tokenGuardado && usuarioGuardado) {
        const usuario = JSON.parse(usuarioGuardado);
        irSegunRol(usuario.rol || usuario.role);
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