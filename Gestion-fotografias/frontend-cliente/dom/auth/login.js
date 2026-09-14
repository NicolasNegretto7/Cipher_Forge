import { iniciarSesion } from "../../services/auth/authService.js";
import { guardarSesion, limpiarSesion } from "../../services/sesion/sesionService.js";

const formulario = document.getElementById("formLogin");
const mensaje = document.getElementById("mensajeLogin");
const paginasUrl = new URL("../../pages/", import.meta.url);

function abrirPanel() {
    const invitacion = new URLSearchParams(location.search).get("invitacion");
    const destino = invitacion
        ? "tuscoleccionescliente.html?invitacion=" + encodeURIComponent(invitacion)
        : "panelcliente.html";
    location.href = new URL(destino, paginasUrl).href;
}

async function ingresar(evento) {
    evento.preventDefault();
    const boton = formulario.querySelector("button[type=submit]");
    boton.disabled = true;
    mensaje.textContent = "Iniciando sesión...";
    mensaje.classList.remove("error");
    try {
        const usuario = await iniciarSesion({
            email: document.getElementById("correo").value.trim(),
            password: document.getElementById("contraseña").value,
        });
        if (usuario.rol !== "cliente") throw new Error("Ingresa con una cuenta de cliente.");
        guardarSesion(usuario.token, usuario);
        abrirPanel();
    } catch (error) {
        mensaje.textContent = error.message;
        mensaje.classList.add("error");
    } finally {
        boton.disabled = false;
    }
}

limpiarSesion();
formulario.addEventListener("submit", ingresar);
const invitacion = new URLSearchParams(location.search).get("invitacion");
const registro = invitacion
    ? "registro.html?invitacion=" + encodeURIComponent(invitacion)
    : "registro.html";
document.getElementById("enlaceRegistro").href = new URL(registro, paginasUrl).href;
