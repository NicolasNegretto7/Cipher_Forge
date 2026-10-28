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

const modalConfirmacion = document.getElementById("modalConfirmacion");
const textoConfirmacion = document.getElementById("textoConfirmacion");
const botonCancelarConfirmacion = document.getElementById("confirmacionCancelar");
const botonAceptarConfirmacion = document.getElementById("confirmacionAceptar");

let seleccionados = [];
let eliminando = false;
let resolverConfirmacion = null;
let accionAlCerrar = null;

function cerrarConfirmacion(resultado) {
    if (modalConfirmacion.hidden) return;
    modalConfirmacion.hidden = true;
    const resolver = resolverConfirmacion;
    const accion = accionAlCerrar;
    resolverConfirmacion = null;
    accionAlCerrar = null;
    if (resolver) resolver(resultado);
    if (accion) accion();
}

function pedirConfirmacion(texto) {
    return new Promise(function (resolve) {
        textoConfirmacion.textContent = texto;
        botonCancelarConfirmacion.hidden = false;
        botonAceptarConfirmacion.textContent = "Aceptar";
        resolverConfirmacion = resolve;
        accionAlCerrar = null;
        modalConfirmacion.hidden = false;
        botonCancelarConfirmacion.focus();
    });
}

function redirigirAlLoginCorrespondiente() {
    let esCliente = false;
    try {
        const clienteStorage = localStorage.getItem("cliente-usuario");
        const fotografoStorage = localStorage.getItem("fotografo-usuario");
        const clienteObj = clienteStorage ? JSON.parse(clienteStorage) : null;
        const fotografoObj = fotografoStorage ? JSON.parse(fotografoStorage) : null;

        if (clienteObj && clienteObj.rol === "cliente") {
            esCliente = true;
        } else if (fotografoObj && fotografoObj.rol === "cliente") {
            esCliente = true;
        } else if (usuario && usuario.rol === "cliente") {
            esCliente = true;
        }
    } catch (e) {}

    try {
        localStorage.removeItem("fotografo-usuario");
        localStorage.removeItem("fotografo-token");
        localStorage.removeItem("fotografo-cuota-almacenamiento");
        if (esCliente) {
            localStorage.removeItem("cliente-usuario");
            localStorage.removeItem("cliente-token");
            localStorage.removeItem("cliente-cuota-almacenamiento");
        }
    } catch (e) {}

    if (esCliente) {
        window.location.href = new URL("../../frontend-cliente/pages/login.html", window.location.href).href;
    } else {
        window.location.href = new URL("login.html", window.location.href).href;
    }
}

function mostrarAlertaError(texto) {
    return new Promise(function (resolve) {
        textoConfirmacion.textContent = texto;
        botonCancelarConfirmacion.hidden = true;
        botonAceptarConfirmacion.textContent = "Ok";
        resolverConfirmacion = resolve;
        accionAlCerrar = redirigirAlLoginCorrespondiente;
        modalConfirmacion.hidden = false;
        botonAceptarConfirmacion.focus();
    });
}

// Sobrescribir alert y confirm para que todos los llamados usen este modal
window.alert = function (texto) {
    return mostrarAlertaError(texto);
};

window.confirm = function (texto) {
    return pedirConfirmacion(texto);
};

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
        if (
            error.status === 401 ||
            error.status === 403 ||
            (error.message && (
                error.message.toLowerCase().includes("dueño") ||
                error.message.toLowerCase().includes("dueÃ±o") ||
                error.message.toLowerCase().includes("sesión") ||
                error.message.toLowerCase().includes("sesion")
            ))
        ) {
            await mostrarAlertaError(error.message);
        }
    }
}

async function eliminarSeleccionadas() {
    if (eliminando || !seleccionados.length) return;
    const confirmado = await pedirConfirmacion("¿Eliminar las colecciones seleccionadas y sus archivos?");
    if (!confirmado) return;
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
    if (errores.length) {
        await mostrarAlertaError(errores.join("\n"));
    }
}

async function iniciar() {
    if (!usuario) return;
    configurarPrivacidad(usuario);
    try {
        await cargarColecciones();
        await actualizarAlmacenamiento();
    } catch (error) {
        await mostrarAlertaError(error.message);
    }
}

botonAceptarConfirmacion.addEventListener("click", function () {
    cerrarConfirmacion(true);
});

botonCancelarConfirmacion.addEventListener("click", function () {
    cerrarConfirmacion(false);
});

modalConfirmacion.addEventListener("click", function (evento) {
    if (evento.target === modalConfirmacion) {
        cerrarConfirmacion(false);
    }
});

document.addEventListener("keydown", function (evento) {
    if (evento.key === "Escape" && !modalConfirmacion.hidden) {
        cerrarConfirmacion(false);
    }
});

botonEliminar.addEventListener("click", eliminarSeleccionadas);
await iniciar();
