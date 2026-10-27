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
const cajaTags = document.getElementById("buscadorTags");
const zonaBuscadorTags = document.getElementById("zonaBuscadorTags");
let colecciones = [];
let tagsSeleccionados = [];
// Tarjetas ya construidas, por id de colección, para poder ocultarlas y
// reordenarlas al filtrar sin volver a crear el DOM (las imágenes no parpadean).
const tarjetas = new Map();

function normalizarTag(tag) {
    return tag.trim().toLowerCase().replace(/^#/, "");
}

// Posición del primer tag seleccionado que tiene la colección: las del primer
// tag van primero, después las del segundo, etc. Infinity si no coincide.
function prioridadTags(coleccion) {
    const tags = new Set((coleccion.hashtags || []).map(normalizarTag));
    for (let i = 0; i < tagsSeleccionados.length; i += 1) {
        if (tags.has(tagsSeleccionados[i])) return i;
    }
    return Infinity;
}

function abrirCajaTags() {
    cajaTags.hidden = false;
}

function cerrarCajaTags() {
    cajaTags.hidden = true;
}

async function mostrarColecciones() {
    liberarVistas(galeria);
    galeria.replaceChildren();
    tarjetas.clear();
    const conArchivos = colecciones.filter(function (coleccion) {
        return (Number(coleccion.total_archivos) || 0) > 0;
    });
    // Insertar todas las tarjetas de golpe: con columnas CSS, añadirlas una a
    // una (esperando cada portada) reequilibraba el mosaico y las tarjetas ya
    // colocadas cambiaban de sitio. Las portadas se cargan en paralelo al final.
    const cargasPortada = [];
    for (const coleccion of conArchivos) {
        // En el mosaico público solo se ve el nombre de la colección y sus
        // tags: el nombre del fotógrafo no se muestra.
        const tarjeta = crearTarjetaColeccion(coleccion, { mostrarFotografo: false });
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
        tarjetas.set(coleccion.id, { tarjeta: tarjeta, coleccion: coleccion });
        cargasPortada.push(
            cargarPortada(tarjeta.querySelector(".CubiertaTarjeta"), coleccion),
        );
    }
    await Promise.all(cargasPortada);
    aplicarFiltroTags();
}

// Filtra y reordena sin recrear el DOM: las colecciones que no coinciden con
// los tags escritos se ocultan con el atributo hidden y las que coinciden
// quedan primero. Al borrar el último tag, todas vuelven a verse.
function aplicarFiltroTags() {
    const hayTags = tagsSeleccionados.length > 0;
    // Con tags el mosaico fluye en filas (izquierda a derecha); sin tags
    // recupera el mosaico de columnas original.
    galeria.classList.toggle("Filtrando", hayTags);
    const entradas = Array.from(tarjetas.values());
    // Sin tags se conserva el orden original del mosaico; reordenar por título
    // hacía que las tarjetas cambiaran de sitio al terminar de cargar.
    if (hayTags) {
        entradas.sort(function (a, b) {
            const pa = prioridadTags(a.coleccion);
            const pb = prioridadTags(b.coleccion);
            if (pa === pb) return 0;
            return pa - pb;
        });
    }
    let visibles = 0;
    for (const entrada of entradas) {
        const coincide = !hayTags || prioridadTags(entrada.coleccion) !== Infinity;
        entrada.tarjeta.hidden = !coincide;
        if (coincide) visibles += 1;
        // Mover la tarjeta ya montada la reordena sin recargar la imagen.
        galeria.appendChild(entrada.tarjeta);
    }
    estadoVacio.hidden = visibles > 0;
}

function mostrarTags() {
    listaTags.replaceChildren();
    for (const tag of tagsSeleccionados) {
        const boton = document.createElement("button");
        boton.type = "button";
        boton.className = "EtiquetaTag";
        boton.textContent = "#" + tag + " ×";
        boton.addEventListener("click", function () {
            tagsSeleccionados = tagsSeleccionados.filter(function (actual) {
                return actual !== tag;
            });
            mostrarTags();
            aplicarFiltroTags();
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
    aplicarFiltroTags();
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
        console.warn("No se pudieron cargar sugerencias de hashtags.", error);
    }
}

async function iniciar() {
    try {
        colecciones = await listarColeccionesPublicas();
        await cargarFavoritos();
        const tag = new URLSearchParams(location.search).get("hashtag");
        if (tag) {
            tagsSeleccionados.push(normalizarTag(tag));
            abrirCajaTags();
        }
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

campoTag.addEventListener("focus", abrirCajaTags);
// Solo letras y números: sin símbolos ni espacios raros.
campoTag.addEventListener("input", function () {
    const limpio = campoTag.value
        .toLowerCase()
        .replace(/[^a-záéíóúüñ0-9]/gi, "");
    if (limpio !== campoTag.value) campoTag.value = limpio;
});
campoTag.addEventListener("keydown", async function (evento) {
    if (evento.key === "Enter") {
        evento.preventDefault();
        await agregarTag(campoTag.value);
    }
});
zonaBuscadorTags.addEventListener("click", function (evento) {
    evento.stopPropagation();
});
document.addEventListener("click", cerrarCajaTags);
document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape") cerrarCajaTags();
});
if (usuario) await iniciar();
