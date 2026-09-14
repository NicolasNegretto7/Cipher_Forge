import { verificarEmail, reenviarCodigo } from "../../services/auth/authService.js";

const mensaje = document.getElementById("mensajeVerificar");
const campoEmail = document.getElementById("correoVerificar");
const campoCodigo = document.getElementById("codigoVerificar");
const botonReenviar = document.getElementById("botonReenviar");
const botonVerificar = document.querySelector("button[type=submit]");

function mostrarMensaje(texto, esError) {
    mensaje.textContent = texto;
    mensaje.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

function limpiarPendiente() {
    localStorage.removeItem("fotografo-email-verificacion-pendiente");
}

const email = localStorage.getItem("fotografo-email-verificacion-pendiente") || "";

if (email) campoEmail.value = email;

document.getElementById("formVerificarEmail").addEventListener("submit", async function (evento) {
    evento.preventDefault();

    const correo = campoEmail.value.trim();
    const cod = campoCodigo.value.trim();

    if (!correo || !cod) {
        mostrarMensaje("Ingresa tu correo y el código de verificación.", true);
        return;
    }

    botonReenviar.disabled = true;
    botonVerificar.disabled = true;
    mostrarMensaje("Verificando el código...", false);

    try {
        await verificarEmail(correo, cod);
        limpiarPendiente();
        mostrarMensaje("Correo verificado correctamente. Ya puedes iniciar sesión.", false);
        setTimeout(function () {
            location.href = "../index.html" + location.search;
        }, 1200);
    } catch (error) {
        mostrarMensaje(error.message, true);
        botonReenviar.disabled = false;
        botonVerificar.disabled = false;
    }
});

botonReenviar.addEventListener("click", async function () {
    const correo = campoEmail.value.trim();

    if (!correo) {
        mostrarMensaje("Ingresa tu correo primero para poder reenviar el código.", true);
        return;
    }

    botonReenviar.disabled = true;
    botonVerificar.disabled = true;
    mostrarMensaje("Reenviando código...", false);

    try {
        await reenviarCodigo(correo);
        mostrarMensaje("Código reenviado a " + correo + ".", false);
    } catch (error) {
        mostrarMensaje(error.message, true);
    } finally {
        botonReenviar.disabled = false;
        botonVerificar.disabled = false;
    }
});
