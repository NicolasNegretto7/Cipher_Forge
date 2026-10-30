import { detalleColeccion } from "../../services/colecciones/coleccionesService.js";
import {
    validarInvitacion,
    canjearInvitacion,
} from "../../services/invitaciones/invitacionesService.js";
import { haySesion } from "../../services/sesion/sesionService.js";
import { requiereSesion } from "../comun/sesion.js";
import { crearTarjetaColeccion } from "./tarjetas.js";
import "../comun/auth.js";

const galeria = document.getElementById("galeriaColecciones");
const mensajeCarga = document.getElementById("mensajeCarga");
const mensajeError = document.getElementById("mensajeError");
const zonaInvitacion = document.getElementById("zonaInvitacion");
const estadoInvitacion = document.getElementById("estadoInvitacion");
const acciones = document.getElementById("accionesInvitacion");
const parametros = new URLSearchParams(location.search);
const tokenInvitacion = parametros.get("invitacion") || parametros.get("token");
const clavePendientes = "cliente-invitaciones-pendientes";


if (tokenInvitacion) {
    const pendientes = leerLista(clavePendientes);
    if (!pendientes.includes(tokenInvitacion)) {
        pendientes.push(tokenInvitacion);
        localStorage.setItem(clavePendientes, JSON.stringify(pendientes));
    }
}

const usuario = requiereSesion("cliente");
//
const claveColecciones = "cliente-colecciones-" + (usuario ? usuario.id : "invitado");

function leerLista(clave) {
    try {
        const lista = JSON.parse(localStorage.getItem(clave) || "[]");
        return Array.isArray(lista) ? lista : [];
    } catch (error) {
        console.warn("No se pudo leer datos almacenados.", error);
        return [];
    }
}

function esIdValido(valor) {
    const numero = Number(valor);
    return Number.isInteger(numero) && numero > 0;
}

function esTituloValido(valor) {
    if (typeof valor !== "string") return false;
    const titulo = valor.trim();
    if (titulo.length === 0 || titulo.length > 255) return false;
    return true;
}

function guardarAcceso(id, titulo) {
    if (!esIdValido(id)) return;
    if (!esTituloValido(titulo)) return;
    const lista = leerLista(claveColecciones)
        .filter(function (item) {
            return item && esIdValido(item.id) && esTituloValido(item.titulo);
        })
        .map(function (item) {
            return { id: Number(item.id), titulo: String(item.titulo).trim() };
        });
    if (
        !lista.some(function (item) {
            return item.id === Number(id);
        })
    ) {
        lista.push({ id: Number(id), titulo: String(titulo).trim() });
        localStorage.setItem(claveColecciones, JSON.stringify(lista));
    } else {
        localStorage.setItem(claveColecciones, JSON.stringify(lista));
    }
}

function quitarPendiente(token) {
    const lista = leerLista(clavePendientes).filter(function (actual) {
        return actual !== token;
    });
    localStorage.setItem(clavePendientes, JSON.stringify(lista));
}

async function concederAcceso(token, estado) {
    if (estado && estado.tiene_acceso) {
        guardarAcceso(estado.coleccion_id, estado.coleccion_titulo);
    } else {
        const resultado = await canjearInvitacion(token);
        if (resultado && resultado.coleccion) {
            guardarAcceso(resultado.coleccion.id, resultado.coleccion.titulo);
        }
    }
    quitarPendiente(token);
}

async function mostrarInvitacion(token) {
    zonaInvitacion.hidden = false;
    acciones.replaceChildren();
    estadoInvitacion.textContent = "Consultando invitación...";
    try {
        const estado = await validarInvitacion(token);
        document.getElementById("tituloInvitacion").textContent = estado.coleccion_titulo;
        if (!estado.autenticado) {
            estadoInvitacion.textContent = "Inicia sesión para acceder a esta colección.";
            const enlace = document.createElement("a");
            enlace.className = "BotonVerde";
            // Se vuelve aquí después del login para canjear esta invitación.
            enlace.href = "login.html?invitacion=" + encodeURIComponent(token);
            enlace.textContent = "Iniciar sesión";
            acciones.appendChild(enlace);
            return;
        }
        await concederAcceso(token, estado);
        estadoInvitacion.textContent = "Ya tienes acceso a esta colección.";
        const enlace = document.createElement("a");
        enlace.className = "BotonVerde";
        enlace.href = "coleccion.html?id=" + estado.coleccion_id;
        enlace.textContent = "Ver colección";
        acciones.appendChild(enlace);
    } catch (error) {
        estadoInvitacion.textContent = error.message;
        const boton = document.createElement("button");
        boton.type = "button";
        boton.className = "BotonVerde";
        boton.textContent = "Reintentar";
        boton.addEventListener("click", async function () {
            boton.disabled = true;
            await mostrarInvitacion(token);
            await cargarColecciones();
        });
        acciones.appendChild(boton);
    }
}

async function cargarColecciones() {
    galeria.replaceChildren();
    if (!haySesion()) {
        mensajeCarga.textContent = "Inicia sesión para consultar tus colecciones.";
        return;
    }
    mensajeCarga.hidden = false;
    const guardadas = leerLista(claveColecciones)
        .filter(function (item) {
            return item && esIdValido(item.id) && esTituloValido(item.titulo);
        })
        .map(function (item) {
            return { id: Number(item.id), titulo: String(item.titulo).trim() };
        });
    // Persistir lista saneada
    localStorage.setItem(claveColecciones, JSON.stringify(guardadas));
    const vistos = [];
    const errores = [];
    for (const item of guardadas) {
        if (vistos.includes(item.id)) continue;
        vistos.push(item.id);
        try {
            const coleccion = await detalleColeccion(item.id);
            if (coleccion && esIdValido(coleccion.id) && esTituloValido(coleccion.titulo)) {
                guardarAcceso(coleccion.id, coleccion.titulo);
                galeria.appendChild(crearTarjetaColeccion(coleccion));
            }
        } catch (error) {
            if (error.status !== 403 && error.status !== 404 && error.message) errores.push(error.message);
        }
    }
    mensajeCarga.hidden = true;
    document.getElementById("sinColecciones").hidden = galeria.children.length > 0;
    mensajeError.hidden = errores.length === 0;
    mensajeError.textContent = errores.length
        ? "No se pudieron consultar algunos accesos. " + errores[0]
        : "";
}

async function iniciar() {
    if (tokenInvitacion) {
        const pendientes = leerLista(clavePendientes);
        if (!pendientes.includes(tokenInvitacion)) {
            pendientes.push(tokenInvitacion);
            localStorage.setItem(clavePendientes, JSON.stringify(pendientes));
        }
        await mostrarInvitacion(tokenInvitacion);
    }
    if (haySesion()) {
        for (const token of leerLista(clavePendientes)) {
            if (token === tokenInvitacion) continue;
            try {
                const estado = await validarInvitacion(token);
                await concederAcceso(token, estado);
            } catch (error) {
                // Conserva la invitación para reintentar desde su enlace.
                console.warn("No se pudo procesar una invitación pendiente.", error);
            }
        }
    }
    await cargarColecciones();
}

if (usuario) await iniciar();
