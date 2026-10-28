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
let focoAntesDeConfirmar = null;
let accionAlCerrar = null;

function cerrarConfirmacion(resultado) {
    if (modalConfirmacion.hidden) return;
    modalConfirmacion.hidden = true;
    const resolver = resolverConfirmacion;
    const accion = accionAlCerrar;
    resolverConfirmacion = null;
    accionAlCerrar = null;
    if (focoAntesDeConfirmar && typeof focoAntesDeConfirmar.focus === "function") {
        focoAntesDeConfirmar.focus();
    }
    focoAntesDeConfirmar = null;
    if (resolver) resolver(resultado);
    if (accion) accion();
}

function esPregunta(texto) {
    if (!texto) return false;
    return /[?¿]/.test(String(texto));
}

function esErrorDePermisos(texto) {
    if (!texto) return false;
    const lower = String(texto).toLowerCase();
    return (
        lower.includes("dueño") ||
        lower.includes("dueÃ±o") ||
        lower.includes("modificar la colección") ||
        lower.includes("modificar la coleccion") ||
        lower.includes("eliminar la colección") ||
        lower.includes("eliminar la coleccion") ||
        lower.includes("no autorizado") ||
        lower.includes("sesión") ||
        lower.includes("sesion") ||
        lower.includes("403") ||
        lower.includes("401")
    );
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

function mostrarDialogo(texto, opciones = {}) {
    return new Promise(function (resolve) {
        textoConfirmacion.textContent = texto;
        focoAntesDeConfirmar = document.activeElement;
        resolverConfirmacion = resolve;

        const pregunta = opciones.pregunta !== undefined ? opciones.pregunta : esPregunta(texto);
        const redirigir = opciones.redirigir !== undefined ? opciones.redirigir : esErrorDePermisos(texto);

        if (pregunta) {
            botonCancelarConfirmacion.hidden = false;
            botonAceptarConfirmacion.textContent = "Aceptar";
            accionAlCerrar = null;
            modalConfirmacion.hidden = false;
            botonCancelarConfirmacion.focus();
        } else {
            botonCancelarConfirmacion.hidden = true;
            botonAceptarConfirmacion.textContent = "Ok";
            accionAlCerrar = redirigir ? redirigirAlLoginCorrespondiente : null;
            modalConfirmacion.hidden = false;
            botonAceptarConfirmacion.focus();
        }
    });
}

function pedirConfirmacion(texto) {
    return mostrarDialogo(texto, { pregunta: true });
}

function mostrarAlertaError(texto) {
    return mostrarDialogo(texto, { pregunta: false });
}

// Sobrescribir alert y confirm para que no haya alerts nativos
window.alert = function (texto) {
    return mostrarDialogo(texto);
};

window.confirm = function (texto) {
    return mostrarDialogo(texto, { pregunta: true });
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
