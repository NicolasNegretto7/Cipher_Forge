import { requiereSesion } from "../comun/sesion.js";
import { actualizarPerfil } from "../../services/fotografo/fotografoService.js";
import { guardarUsuario } from "../../services/sesion/sesionService.js";

const usuarioGuardado = requiereSesion("fotografo");
const campoNombre = document.getElementById("nombreCompleto");
const campoTelefono = document.getElementById("telefono");
const LIMITE_NOMBRE = 30;
const LIMITE_TELEFONO = 9;

function limpiarNombre(valor) {
    return String(valor || "")
        .replace(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]/g, "")
        .slice(0, LIMITE_NOMBRE);
}

function limpiarTelefono(valor) {
    return String(valor || "").replace(/\D/g, "").slice(0, LIMITE_TELEFONO);
}

function moverCursorTelefono(posicion) {
    const destino = Math.min(posicion, campoTelefono.value.length);
    campoTelefono.setSelectionRange(destino, destino);
}

function mostrarDatos() {
    campoNombre.value = limpiarNombre(usuarioGuardado.nombre_completo);
    campoTelefono.value = limpiarTelefono(usuarioGuardado.telefono);
}

campoNombre.addEventListener("input", function () {
    campoNombre.value = limpiarNombre(campoNombre.value);
});

campoTelefono.addEventListener("input", function () {
    const valor = campoTelefono.value;
    const limpio = limpiarTelefono(valor);
    if (valor === limpio) return;

    const posicion = campoTelefono.selectionStart || 0;
    const numerosAntes = limpiarTelefono(valor.slice(0, posicion)).length;
    campoTelefono.value = limpio;
    moverCursorTelefono(numerosAntes);
});

campoTelefono.addEventListener("paste", function (evento) {
    const portapapeles = evento.clipboardData || window.clipboardData;
    if (!portapapeles) return;

    const texto = portapapeles.getData("text");
    if (!texto) return;
    evento.preventDefault();

    const inicio = campoTelefono.selectionStart || 0;
    const fin = campoTelefono.selectionEnd || 0;
    const antes = limpiarTelefono(campoTelefono.value.slice(0, inicio));
    const despues = limpiarTelefono(campoTelefono.value.slice(fin));
    const espacio = LIMITE_TELEFONO - antes.length - despues.length;
    const insertar = limpiarTelefono(texto).slice(0, Math.max(espacio, 0));

    campoTelefono.value = antes + insertar + despues;
    moverCursorTelefono(antes.length + insertar.length);
});

function mostrarToast(texto, tipo) {
    const contenedor = document.getElementById("toasts");
    if (!contenedor) return;
    const toast = document.createElement("div");
    toast.className = "Toast " + (tipo || "Exito");
    toast.textContent = texto;
    contenedor.appendChild(toast);
    setTimeout(function () {
        toast.classList.add("Saliendo");
        const quitar = function () {
            toast.remove();
        };
        toast.addEventListener("animationend", quitar, { once: true });
        setTimeout(quitar, 400);
    }, 3000);
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
}

async function enviarFormulario(evento, datos) {
    evento.preventDefault();
    const boton = evento.currentTarget.querySelector("button");
    if (!boton) return;
    boton.disabled = true;
    const vigilante = setTimeout(function () {
        boton.disabled = false;
        mostrarToast("El servidor tardó demasiado. Intenta de nuevo.", "Error");
    }, 15000);

    try {
        await guardarCambios(datos);
        mostrarToast("Dato guardado correctamente.", "Exito");
    } catch (error) {
        mostrarToast(error.message, "Error");
        if (error.status === 401) location.href = "login.html";
    } finally {
        clearTimeout(vigilante);
        boton.disabled = false;
    }
}

if (usuarioGuardado) {
    mostrarDatos();
    document.getElementById("formNombre").addEventListener("submit", async function (evento) {
        const datos = {
            nombre_completo: limpiarNombre(document.getElementById("nombreCompleto").value).trim(),
        };
        await enviarFormulario(evento, datos);
    });
    document.getElementById("formTelefono").addEventListener("submit", async function (evento) {
        const datos = { telefono: limpiarTelefono(campoTelefono.value) };
        await enviarFormulario(evento, datos);
    });
}
