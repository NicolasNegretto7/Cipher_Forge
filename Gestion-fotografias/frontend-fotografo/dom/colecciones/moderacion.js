import {
    listarPendientes,
    aprobarColaborativo,
    rechazarColaborativo,
} from "../../services/colaborativo/colaborativoService.js";
import { cargarVista, liberarVistas } from "../multimedia/multimedia.js";
import { requiereSesion } from "../comun/sesion.js";
const usuario = requiereSesion("fotografo");
// Moderación de material colaborativo de invitados (HU12): lista pendientes,
// selección visual múltiple, aprobación o rechazo en lote de archivos.
const parametros = new URLSearchParams(location.search);
const coleccionId = parametros.has("coleccionId") ? Number(parametros.get("coleccionId")) : null;

const galeria = document.getElementById("galeriaPendientes");
const estadoVacio = document.getElementById("estadoPendientes");
const tituloColeccion = document.getElementById("tituloColeccionModeracion");
const controles = document.getElementById("controlesModeracion");
const seleccionarTodas = document.getElementById("seleccionarTodasPendientes");
const botonAprobar = document.getElementById("aprobarPendientes");
const botonRechazar = document.getElementById("rechazarPendientes");
const volverColeccion = document.getElementById("volverColeccion");

let pendientes = [];
let idsSeleccionados = [];
let moderando = false;

function formatearTamano(bytes) {
    const valor = Number(bytes) || 0;
    if (valor >= 1024 * 1024) return (valor / 1048576).toFixed(1) + " MB";
    if (valor >= 1024) return Math.round(valor / 1024) + " KB";
    return valor + " B";
}

function formatearFecha(fecha) {
    return new Date(String(fecha).replace(" ", "T")).toLocaleString("es-ES", {
        dateStyle: "short",
        timeStyle: "short",
    });
}

function tipoLegible(tipo) {
    return tipo === "video" ? "Video" : "Imagen";
}

function actualizarBotones() {
    const sinSeleccion = idsSeleccionados.length === 0;
    botonAprobar.disabled = moderando || sinSeleccion;
    botonRechazar.disabled = moderando || sinSeleccion;
    seleccionarTodas.checked =
        pendientes.length > 0 && idsSeleccionados.length === pendientes.length;
    seleccionarTodas.disabled = moderando;
    for (const tarjeta of galeria.querySelectorAll(".TarjetaPendiente")) {
        tarjeta.classList.toggle(
            "Seleccionada",
            idsSeleccionados.includes(Number(tarjeta.dataset.id)),
        );
        tarjeta.querySelector("input").disabled = moderando;
    }
}

async function renderizarPendientes() {
    liberarVistas(galeria);
    galeria.querySelectorAll(".TarjetaPendiente").forEach(function (tarjeta) {
        tarjeta.remove();
    });
    estadoVacio.hidden = pendientes.length > 0;
    controles.hidden = pendientes.length === 0;
    actualizarBotones();

    for (const archivo of pendientes) {
        const id = Number(archivo.id_multimedia);

        const tarjeta = document.createElement("article");
        tarjeta.className = "TarjetaPendiente";
        tarjeta.dataset.id = id;

        const esVideo = archivo.tipo && String(archivo.tipo).startsWith("video");

        const imagen = document.createElement(esVideo ? "video" : "img");
        imagen.className = "MiniaturaPendiente";
        imagen.alt = archivo.titulo || "Aporte de invitado";
        if (esVideo) {
            imagen.muted = true;
            imagen.playsInline = true;
            imagen.preload = "auto";
        }
        imagen.addEventListener("error", function () {
            imagen.classList.add("MiniaturaNoDisponible");
        });
        imagen.addEventListener("click", function () {
            if (imagen.src) window.open(imagen.src, "_blank", "noopener,noreferrer");
        });

        const casilla = document.createElement("input");
        casilla.type = "checkbox";
        casilla.className = "CheckPendiente";
        casilla.checked = idsSeleccionados.includes(id);
        casilla.addEventListener("change", function () {
            if (casilla.checked && !idsSeleccionados.includes(id)) {
                idsSeleccionados.push(id);
            } else if (!casilla.checked) {
                idsSeleccionados = idsSeleccionados.filter(function (seleccionado) {
                    return seleccionado !== id;
                });
            }
            actualizarBotones();
        });

        const datos = document.createElement("div");
        datos.className = "DatosPendiente";

        const nombre = document.createElement("strong");
        nombre.textContent = archivo.titulo || "Invitado";

        const detalle = document.createElement("p");
        detalle.textContent =
            tipoLegible(archivo.tipo) +
            " · " +
            formatearTamano(archivo.tamanio) +
            " · " +
            formatearFecha(archivo.creado_en);

        datos.appendChild(nombre);
        datos.appendChild(detalle);
        tarjeta.appendChild(casilla);
        tarjeta.appendChild(imagen);
        tarjeta.appendChild(datos);
        galeria.appendChild(tarjeta);
        await cargarVista(imagen, archivo);
    }
}

async function cargarPendientes() {
    estadoVacio.hidden = false;
    estadoVacio.textContent = "Cargando aportes de invitados…";

    try {
        pendientes = await listarPendientes(coleccionId);
        idsSeleccionados = [];
        estadoVacio.textContent = "No hay aportes de invitados pendientes de moderación.";
        await renderizarPendientes();
    } catch (error) {
        estadoVacio.hidden = false;
        estadoVacio.textContent = error.message;
    }
}

async function aprobarSeleccionados() {
    if (moderando || idsSeleccionados.length === 0) return;
    moderando = true;
    actualizarBotones();
    try {
        const resultado = await aprobarColaborativo(coleccionId, idsSeleccionados);
        alert(
            "Se aprobaron " + resultado.aprobados + " archivos. Ya están visibles en la colección.",
        );
        await cargarPendientes();
    } catch (error) {
        alert(error.message);
    } finally {
        moderando = false;
        actualizarBotones();
    }
}

async function rechazarSeleccionados() {
    if (moderando || idsSeleccionados.length === 0) return;
    if (!confirm("¿Rechazar y eliminar " + idsSeleccionados.length + " archivo(s)?")) return;
    moderando = true;
    actualizarBotones();
    try {
        const resultado = await rechazarColaborativo(coleccionId, idsSeleccionados);
        alert("Se rechazaron y eliminaron " + resultado.eliminados + " archivos.");
        await cargarPendientes();
    } catch (error) {
        alert(error.message);
    } finally {
        moderando = false;
        actualizarBotones();
    }
}

if (!coleccionId || !Number.isInteger(coleccionId)) {
    location.href = "panel.html";
} else if (usuario) {
    if (volverColeccion) volverColeccion.href = "SubirImagenes.html?coleccionId=" + coleccionId;
    seleccionarTodas.addEventListener("change", function () {
        pendientes.forEach(function (archivo) {
            const id = Number(archivo.id_multimedia);
            if (seleccionarTodas.checked && !idsSeleccionados.includes(id)) {
                idsSeleccionados.push(id);
            }
        });
        if (!seleccionarTodas.checked) idsSeleccionados = [];
        actualizarBotones();
    });
    botonAprobar.addEventListener("click", aprobarSeleccionados);
    botonRechazar.addEventListener("click", rechazarSeleccionados);
    await cargarPendientes();
}
