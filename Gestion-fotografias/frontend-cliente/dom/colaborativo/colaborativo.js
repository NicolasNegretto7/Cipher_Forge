import {
    verificarAccesoColaborativo,
    subirMaterialColaborativo,
} from "../../services/colaborativo/colaborativoService.js";

const LIMITE_IMAGEN_BYTES = 30 * 1024 * 1024;
const LIMITE_VIDEO_BYTES = 800 * 1024 * 1024;

// Pantalla del invitado (HU11): valida el token colaborativo y permite subir
// fotos/videos sin registro, sin acceso a visualizar el contenido del evento.
const parametros = new URLSearchParams(location.search);
const token = parametros.get("token") || "";

const panelCargando = document.getElementById("panelCargando");
const panelError = document.getElementById("panelError");
const mensajeError = document.getElementById("mensajeError");
const panelFormulario = document.getElementById("panelFormulario");
const nombreEvento = document.getElementById("nombreEvento");
const fechaCaducidad = document.getElementById("fechaCaducidad");
const formulario = document.getElementById("formularioColaborativo");
const selectorArchivos = document.getElementById("selectorArchivos");
const listaArchivosSeleccion = document.getElementById("listaArchivosSeleccion");
const botonEnviar = document.getElementById("botonEnviar");
const panelExito = document.getElementById("panelExito");
const mensajeExito = document.getElementById("mensajeExito");

let archivosSeleccionados = [];

function mostrarPantalla(pantalla) {
    [panelCargando, panelError, panelFormulario, panelExito].forEach(function (p) {
        p.hidden = p !== pantalla;
    });
}

function formatearCaducidad(fecha) {
    return new Date(String(fecha).replace(" ", "T")).toLocaleString("es-ES", {
        dateStyle: "long",
        timeStyle: "short",
    });
}

async function iniciar() {
    if (!token) {
        mensajeError.textContent = "No se recibió un código de evento en el enlace.";
        mostrarPantalla(panelError);
        return;
    }

    try {
        const datos = await verificarAccesoColaborativo(token);
        nombreEvento.textContent = datos.evento || "Evento";
        fechaCaducidad.textContent = formatearCaducidad(datos.expira_en);
        mostrarPantalla(panelFormulario);
    } catch (error) {
        mensajeError.textContent = error.message;
        mostrarPantalla(panelError);
    }
}

selectorArchivos.addEventListener("change", function () {
    archivosSeleccionados = [];
    const excedidos = [];
    for (const archivo of selectorArchivos.files) {
        const esVideo = String(archivo.type).startsWith("video") || archivo.name.toLowerCase().endsWith(".mp4");
        const limite = esVideo ? LIMITE_VIDEO_BYTES : LIMITE_IMAGEN_BYTES;
        const limiteMB = esVideo ? 800 : 30;
        if (archivo.size > limite) {
            excedidos.push(archivo.name + " (máximo " + limiteMB + " MB)");
            continue;
        }
        archivosSeleccionados.push(archivo);
    }
    if (excedidos.length > 0) {
        alert("Estos archivos superan el límite y no se incluirán:\n" + excedidos.join("\n"));
    }
    if (archivosSeleccionados.length > 0) {
        listaArchivosSeleccion.textContent =
            archivosSeleccionados.length + " archivo(s) seleccionado(s)";
        botonEnviar.disabled = false;
    } else {
        listaArchivosSeleccion.textContent = "";
        botonEnviar.disabled = true;
    }
});

formulario.addEventListener("submit", async function (evento) {
    evento.preventDefault();
    if (archivosSeleccionados.length === 0) return;

    botonEnviar.disabled = true;
    botonEnviar.textContent = "Subiendo…";

    try {
        const nombreInvitado = document.getElementById("nombreInvitado").value.trim();
        const resultado = await subirMaterialColaborativo(
            token,
            archivosSeleccionados,
            nombreInvitado,
        );
        mensajeExito.textContent = resultado.aviso;
        mostrarPantalla(panelExito);
    } catch (error) {
        alert(error.message);
        botonEnviar.textContent = "Subir ahora";
        botonEnviar.disabled = false;
    }
});

document.getElementById("botonOtroArchivo").addEventListener("click", function () {
    formulario.reset();
    archivosSeleccionados = [];
    listaArchivosSeleccion.textContent = "";
    botonEnviar.textContent = "Subir ahora";
    botonEnviar.disabled = true;
    mostrarPantalla(panelFormulario);
});

await iniciar();
