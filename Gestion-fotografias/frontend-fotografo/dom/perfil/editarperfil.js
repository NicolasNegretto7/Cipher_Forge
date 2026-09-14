import { requiereSesion } from "../comun/sesion.js";
import { actualizarPerfil } from "../../services/fotografo/fotografoService.js";
import { guardarUsuario } from "../../services/sesion/sesionService.js";

const usuarioGuardado = requiereSesion("fotografo");
const mensaje = document.getElementById("mensajePerfil");

function mostrarDatos() {
    document.getElementById("nombreCompleto").value = usuarioGuardado.nombre_completo || "";
    document.getElementById("telefono").value = usuarioGuardado.telefono || "";
}

function mostrarMensaje(texto, esError = false) {
    mensaje.textContent = texto;
    mensaje.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

async function guardarCambios(datos) {
    const respuesta = await actualizarPerfil(datos);
    if (respuesta.nombre_completo !== undefined) {
        usuarioGuardado.nombre_completo = respuesta.nombre_completo;
    }
    if (respuesta.telefono !== undefined) {
        usuarioGuardado.telefono = respuesta.telefono;
    }
    guardarUsuario(usuarioGuardado);
    mostrarDatos();
    mostrarMensaje("Dato guardado correctamente.");
}

async function enviarFormulario(evento, datos) {
    evento.preventDefault();
    const boton = evento.currentTarget.querySelector("button");
    boton.disabled = true;
    mostrarMensaje("Guardando...");

    try {
        await guardarCambios(datos);
    } catch (error) {
        mostrarMensaje(error.message, true);
        if (error.status === 401) location.href = "login.html";
    } finally {
        boton.disabled = false;
    }
}

if (usuarioGuardado) {
    mostrarDatos();
    document.getElementById("formNombre").addEventListener("submit", async function (evento) {
        const datos = {
            nombre_completo: document.getElementById("nombreCompleto").value.trim(),
        };
        await enviarFormulario(evento, datos);
    });
    document.getElementById("formTelefono").addEventListener("submit", async function (evento) {
        const datos = { telefono: document.getElementById("telefono").value.trim() };
        await enviarFormulario(evento, datos);
    });
}
