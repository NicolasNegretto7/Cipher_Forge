import { iniciarSesion } from "../../services/auth/authService.js";
import { guardarSesion, limpiarSesion } from "../../services/sesion/sesionService.js";

const formulario = document.getElementById("formLogin");
const mensaje = document.getElementById("mensajeLogin");
const paginasUrl = new URL("../../pages/", import.meta.url);

function activarVistaContrasena(input) {
    if (!input) return;
    const contenedor = input.closest(".CampoContrasena");
    const icono = contenedor && contenedor.querySelector("[data-ojo]");
    if (!icono) return;

    const ojoAbierto = icono.querySelector(".IconoVer");
    const ojoCerrado = icono.querySelector(".IconoOcultar");

    function pintar(mostrar) {
        input.type = mostrar ? "text" : "password";
        icono.setAttribute("aria-pressed", String(mostrar));
        icono.setAttribute("aria-label", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
        icono.setAttribute("title", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
        if (ojoAbierto) ojoAbierto.style.display = mostrar ? "none" : "inline";
        if (ojoCerrado) ojoCerrado.style.display = mostrar ? "inline" : "none";
    }

    function alternar() {
        pintar(input.type === "password");
    }

    icono.addEventListener("click", alternar);
    icono.addEventListener("keydown", function (evento) {
        if (evento.key === "Enter" || evento.key === " ") {
            evento.preventDefault();
            alternar();
        }
    });

    pintar(false);
}

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
        // El JWT ya no viene en la respuesta: viaja en cookie HttpOnly
        // y el navegador la envía automáticamente en cada petición.
        guardarSesion(usuario);
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

activarVistaContrasena(document.getElementById("contraseña"));
