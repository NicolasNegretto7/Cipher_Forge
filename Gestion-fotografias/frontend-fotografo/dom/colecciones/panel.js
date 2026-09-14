import {
    listarMisColecciones,
    eliminarColeccion,
} from "../../services/colecciones/coleccionesService.js";
import { requiereSesion } from "../comun/sesion.js";
import { cargarPortada, liberarVistas } from "../multimedia/multimedia.js";
import { actualizarAlmacenamiento } from "../comun/almacenamiento.js";
import { configurarPrivacidad } from "../perfil/privacidad.js";
import "../perfil/menu-perfil.js";

const usuario = requiereSesion("fotografo");
const galeria = document.getElementById("galeriaColecciones");
const mensaje = document.getElementById("sinColecciones");
const barraAcciones = document.getElementById("barraAccionesColecciones");
const botonEliminar = document.getElementById("eliminarColeccionesSeleccionadas");
let seleccionados = [];
let eliminando = false;

function crearTarjeta(coleccion) {
    const tarjeta = document.createElement("article");
    tarjeta.className = "TarjetaColeccion";
    const enlace = document.createElement("a");
    enlace.className = "EnlaceColeccion";
    enlace.href = "SubirImagenes.html?coleccionId=" + coleccion.id;
    const portada = document.createElement("div");
    portada.className = "CubiertaTarjeta";
    portada.textContent = coleccion.titulo.charAt(0).toUpperCase();
    enlace.appendChild(portada);
    const nombre = document.createElement("p");
    nombre.className = "NombreColeccion";
    nombre.textContent = coleccion.titulo;
    enlace.appendChild(nombre);
    tarjeta.appendChild(enlace);
    const selector = document.createElement("input");
    selector.type = "checkbox";
    selector.className = "SelectorColeccion";
    selector.setAttribute("aria-label", "Seleccionar " + coleccion.titulo);
    selector.addEventListener("change", function () {
        if (eliminando) {
            selector.checked = !selector.checked;
            return;
        }
        if (selector.checked) seleccionados.push(coleccion.id);
        else
            seleccionados = seleccionados.filter(function (id) {
                return id !== coleccion.id;
            });
        tarjeta.classList.toggle("Seleccionada", selector.checked);
        barraAcciones.classList.toggle("Visible", seleccionados.length > 0);
    });
    tarjeta.appendChild(selector);
    galeria.appendChild(tarjeta);
    return portada;
}

async function cargarColecciones() {
    mensaje.hidden = false;
    mensaje.textContent = "Cargando colecciones...";
    try {
        const colecciones = await listarMisColecciones();
        liberarVistas(galeria);
        galeria.replaceChildren();
        seleccionados = [];
        barraAcciones.classList.remove("Visible");
        mensaje.textContent = "No tienes colecciones aún.";
        mensaje.hidden = colecciones.length > 0;
        for (const coleccion of colecciones) {
            const portada = crearTarjeta(coleccion);
            await cargarPortada(portada, coleccion);
        }
    } catch (error) {
        mensaje.textContent = error.message;
        mensaje.hidden = false;
    }
}

async function eliminarSeleccionadas() {
    if (eliminando || !seleccionados.length) return;
    if (!confirm("¿Eliminar las colecciones seleccionadas y sus archivos?")) return;
    eliminando = true;
    botonEliminar.disabled = true;
    const errores = [];
    for (const id of seleccionados) {
        try {
            await eliminarColeccion(id);
        } catch (error) {
            errores.push(error.message);
        }
    }
    await cargarColecciones();
    await actualizarAlmacenamiento();
    botonEliminar.disabled = false;
    eliminando = false;
    if (errores.length) alert(errores.join("\n"));
}

async function iniciar() {
    if (!usuario) return;
    configurarPrivacidad(usuario);
    await cargarColecciones();
    await actualizarAlmacenamiento();
}

botonEliminar.addEventListener("click", eliminarSeleccionadas);
await iniciar();
