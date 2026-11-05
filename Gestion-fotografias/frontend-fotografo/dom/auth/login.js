import { iniciarSesion } from "../../services/auth/authService.js";
import { guardarSesion, limpiarSesion } from "../../services/sesion/sesionService.js";

const formulario = document.getElementById("formLogin");
const mensaje = document.getElementById("mensajeLogin");
const paginasUrl = new URL("../../pages/", import.meta.url);

function activarVistaContrasena(input) {
    if (!input) return;
    const contenedor = input.closest(".CampoContrasena");
    const boton = contenedor && contenedor.querySelector(".BotonOjo");
    if (!boton) return;

    boton.addEventListener("click", function () {
        const mostrar = input.type === "password";
        input.type = mostrar ? "text" : "password";
        boton.setAttribute("aria-pressed", String(mostrar));
        boton.setAttribute("aria-label", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
        boton.setAttribute("title", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
    });
}

function abrirPanel() {
    location.href = new URL("panel.html", paginasUrl).href;
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
        if (usuario.rol !== "fotografo") throw new Error("Ingresa con una cuenta de fotógrafo.");
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
document.getElementById("enlaceRegistro").href = new URL("registro.html", paginasUrl).href;

activarVistaContrasena(document.getElementById("contraseña"));
