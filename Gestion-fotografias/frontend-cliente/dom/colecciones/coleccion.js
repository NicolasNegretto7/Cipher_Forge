import { detalleColeccion } from "../../services/colecciones/coleccionesService.js";
import { listarMultimedia } from "../../services/multimedia/multimediaService.js";
import { descargarMultimedia } from "../multimedia/descargas.js";
import { cargarVista, liberarVistas } from "../multimedia/multimedia.js";
import { mostrarToast } from "../comun/interfaz.js";
import { cargarFavoritos, crearBotonFavorito } from "../favoritos/favoritos.js";
import { requiereSesion } from "../comun/sesion.js";
import "../comun/auth.js";

const usuario = requiereSesion("cliente");
const parametros = new URLSearchParams(location.search);
const coleccionId = Number(parametros.get("id") || parametros.get("coleccion"));
const galeria = document.getElementById("galeria");
const mensajeCarga = document.getElementById("mensajeCarga");
const mensajeError = document.getElementById("mensajeError");
const visor = document.getElementById("visor");
const contenidoVisor = document.getElementById("visorContenido");
const accionesVisor = document.getElementById("accionesVisor");
let archivos = [];
let posicionVisor = 0;

function crearDescargas(archivo) {
    const zona = document.createElement("div");
    zona.className = "ZonaDescarga";
    for (const calidad of ["buena", "alta"]) {
        const boton = document.createElement("button");
        boton.type = "button";
        boton.className = "BotonDescargar";
        boton.textContent = calidad === "alta" ? "Alta" : "Buena";
        boton.addEventListener("click", async function () {
            boton.disabled = true;
            try {
                await descargarMultimedia(archivo.id_multimedia, calidad);
            } catch (error) {
                mostrarToast(error.message, "Error");
            } finally {
                boton.disabled = false;
            }
        });
        zona.appendChild(boton);
    }
    return zona;
}

// Icono de descarga en la esquina de la imagen: abre el mismo cuadro blanco
// con la imagen grande y los botones de calidad.
function crearBotonDescargaIcono(archivo, indice) {
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "BotonDescargaIcono";
    boton.title = "Descargar";
    boton.setAttribute("aria-label", "Descargar " + (archivo.titulo || "archivo"));
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("aria-hidden", "true");
    const flecha = document.createElementNS("http://www.w3.org/2000/svg", "path");
    flecha.setAttribute("d", "M12 3v11m0 0 4-4m-4 4-4-4M4 19h16");
    svg.appendChild(flecha);
    boton.appendChild(svg);
    boton.addEventListener("click", async function (evento) {
        evento.stopPropagation();
        await abrirVisor(indice);
    });
    return boton;
}

function cerrarVisor() {
    visor.classList.remove("Abierto");
    liberarVistas(contenidoVisor);
    contenidoVisor.replaceChildren();
    accionesVisor.replaceChildren();
}

async function abrirVisor(indice) {
    if (indice < 0 || indice >= archivos.length) return;
    cerrarVisor();
    posicionVisor = indice;
    const archivo = archivos[indice];
    const medio = document.createElement(archivo.tipo === "video" ? "video" : "img");
    if (archivo.tipo === "video") medio.controls = true;
    else medio.alt = archivo.titulo || "Fotografía";
    contenidoVisor.appendChild(medio);
    const pregunta = document.createElement("p");
    pregunta.className = "PreguntaCalidad";
    pregunta.textContent = "¿En qué calidad quieres descargar el archivo?";
    accionesVisor.appendChild(pregunta);
    accionesVisor.appendChild(crearDescargas(archivo));
    document.getElementById("anteriorVisor").hidden = indice === 0;
    document.getElementById("siguienteVisor").hidden = indice === archivos.length - 1;
    visor.classList.add("Abierto");
    await cargarVista(medio, archivo);
}

function crearTarjeta(archivo, indice) {
    const tarjeta = document.createElement("article");
    tarjeta.className = "TarjetaMedia";
    const vista = document.createElement(archivo.tipo === "video" ? "video" : "img");
    vista.className = "VistaMiniatura";
    vista.tabIndex = 0;
    vista.setAttribute("aria-label", archivo.titulo || "Abrir archivo");
    vista.addEventListener("click", async function () {
        await abrirVisor(indice);
    });
    vista.addEventListener("keydown", async function (evento) {
        if (evento.key === "Enter") await abrirVisor(indice);
    });
    tarjeta.appendChild(vista);
    tarjeta.appendChild(crearBotonDescargaIcono(archivo, indice));
    if (archivo.descripcion) {
        const descripcion = document.createElement("p");
        descripcion.className = "DescripcionImagen";
        descripcion.textContent = archivo.descripcion;
        tarjeta.appendChild(descripcion);
    }
    galeria.appendChild(tarjeta);
    return vista;
}

function mostrarInformacion(coleccion) {
    document.getElementById("tituloColeccion").textContent = coleccion.titulo;
    const info = document.getElementById("infoColeccion");
    info.replaceChildren();
    for (const texto of [
        coleccion.fotografo_nombre,
        coleccion.descripcion,
        "Colección " + coleccion.tipo_visibilidad,
    ]) {
        if (!texto) continue;
        const parrafo = document.createElement("p");
        parrafo.textContent = texto;
        info.appendChild(parrafo);
    }
    for (const tag of coleccion.hashtags || []) {
        const etiqueta = document.createElement("span");
        etiqueta.className = "ChipTag";
        etiqueta.textContent = "#" + tag;
        info.appendChild(etiqueta);
    }
    if (coleccion.tipo_visibilidad === "publica")
        document.querySelector(".TituloColeccion").appendChild(crearBotonFavorito(coleccion.id));
}

async function iniciar() {
    try {
        if (!Number.isInteger(coleccionId) || coleccionId <= 0)
            throw new Error("Colección no válida.");
        const coleccion = await detalleColeccion(coleccionId);
        await cargarFavoritos();
        mostrarInformacion(coleccion);
        archivos = await listarMultimedia(coleccionId);
        document.getElementById("estadoVacio").hidden = archivos.length > 0;
        for (let indice = 0; indice < archivos.length; indice++) {
            const vista = crearTarjeta(archivos[indice], indice);
            await cargarVista(vista, archivos[indice]);
        }
    } catch (error) {
        mensajeError.textContent = error.message;
        mensajeError.hidden = false;
    } finally {
        mensajeCarga.hidden = true;
    }
}

document.getElementById("cerrarVisor").addEventListener("click", cerrarVisor);
visor.addEventListener("click", function (evento) {
    if (evento.target === visor) cerrarVisor();
});
document.getElementById("anteriorVisor").addEventListener("click", async function () {
    await abrirVisor(posicionVisor - 1);
});
document.getElementById("siguienteVisor").addEventListener("click", async function () {
    await abrirVisor(posicionVisor + 1);
});
document.addEventListener("keydown", async function (evento) {
    if (!visor.classList.contains("Abierto")) return;
    if (evento.key === "Escape") cerrarVisor();
    if (evento.key === "ArrowLeft") await abrirVisor(posicionVisor - 1);
    if (evento.key === "ArrowRight") await abrirVisor(posicionVisor + 1);
});
if (usuario) await iniciar();
