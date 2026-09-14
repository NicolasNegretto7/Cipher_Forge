import {
    listarColeccionesPublicas,
    listarHashtags,
} from "../../services/colecciones/coleccionesService.js";
import { cargarPortada, liberarVistas } from "../multimedia/multimedia.js";
import { cargarFavoritos, crearBotonFavorito } from "../favoritos/favoritos.js";
import { requiereSesion } from "../comun/sesion.js";
import { crearTarjetaColeccion } from "./tarjetas.js";
import "../comun/auth.js";

const usuario = requiereSesion("cliente");
const galeria = document.getElementById("galeriaPublica");
const estadoVacio = document.getElementById("estadoVacio");
const mensajeCarga = document.getElementById("mensajeCarga");
const mensajeError = document.getElementById("mensajeError");
const campoTag = document.getElementById("tagBusqueda");
const listaTags = document.getElementById("tagsBusqueda");
let colecciones = [];
let tagsSeleccionados = [];
let numeroBusqueda = 0;

function normalizarTag(tag) {
    return tag.trim().toLowerCase().replace(/^#/, "");
}

async function mostrarColecciones() {
    const busquedaActual = ++numeroBusqueda;
    liberarVistas(galeria);
    galeria.replaceChildren();
    const filtradas = colecciones.filter(function (coleccion) {
        const tags = (coleccion.hashtags || []).map(normalizarTag);
        return tagsSeleccionados.every(function (tag) {
            return tags.includes(tag);
        });
    });
    estadoVacio.hidden = filtradas.length > 0;
    for (const coleccion of filtradas) {
        // Si el filtro cambió durante una descarga, deja de dibujar el resultado anterior.
        if (busquedaActual !== numeroBusqueda) return;
        const tarjeta = crearTarjetaColeccion(coleccion);
        tarjeta.appendChild(crearBotonFavorito(coleccion.id));
        const etiquetas = document.createElement("div");
        etiquetas.className = "ListaTagsColeccion";
        for (const tag of coleccion.hashtags || []) {
            const boton = document.createElement("button");
            boton.type = "button";
            boton.className = "ChipTag";
            boton.textContent = "#" + tag;
            boton.addEventListener("click", async function () {
                await agregarTag(tag);
            });
            etiquetas.appendChild(boton);
        }
        tarjeta.appendChild(etiquetas);
        galeria.appendChild(tarjeta);
        await cargarPortada(tarjeta.querySelector(".CubiertaTarjeta"), coleccion);
    }
}

function mostrarTags() {
    listaTags.replaceChildren();
    for (const tag of tagsSeleccionados) {
        const boton = document.createElement("button");
        boton.type = "button";
        boton.className = "EtiquetaTag";
        boton.textContent = "#" + tag + " ×";
        boton.addEventListener("click", async function () {
            tagsSeleccionados = tagsSeleccionados.filter(function (actual) {
                return actual !== tag;
            });
            mostrarTags();
            await mostrarColecciones();
        });
        listaTags.appendChild(boton);
    }
}

async function agregarTag(valor) {
    const tag = normalizarTag(valor);
    if (!tag || tagsSeleccionados.includes(tag)) return;
    tagsSeleccionados.push(tag);
    campoTag.value = "";
    mostrarTags();
    await mostrarColecciones();
}

async function cargarSugerencias() {
    try {
        const hashtags = await listarHashtags();
        for (const hashtag of hashtags) {
            const opcion = document.createElement("option");
            opcion.value = "#" + hashtag.nombre_hashtags;
            document.getElementById("sugerenciasHashtags").appendChild(opcion);
        }
    } catch (error) {
        // El buscador también acepta etiquetas escritas a mano.
    }
}

async function iniciar() {
    try {
        colecciones = await listarColeccionesPublicas();
        await cargarFavoritos();
        const tag = new URLSearchParams(location.search).get("hashtag");
        if (tag) tagsSeleccionados.push(normalizarTag(tag));
        mostrarTags();
        await mostrarColecciones();
        await cargarSugerencias();
    } catch (error) {
        mensajeError.textContent = error.message;
        mensajeError.hidden = false;
    } finally {
        mensajeCarga.hidden = true;
    }
}

campoTag.addEventListener("keydown", async function (evento) {
    if (evento.key === "Enter") {
        evento.preventDefault();
        await agregarTag(campoTag.value);
    }
});
if (usuario) await iniciar();
