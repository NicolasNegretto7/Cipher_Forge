import {
    detalleColeccion,
    actualizarColeccion,
} from "../../services/colecciones/coleccionesService.js";
import {
    listarMultimedia,
    subirMultimedia,
    eliminarMultimedia,
} from "../../services/multimedia/multimediaService.js";
import { requiereSesion } from "../comun/sesion.js";
import { cargarVista, liberarVistas } from "../multimedia/multimedia.js";
import { actualizarAlmacenamiento, formatearAlmacenamiento } from "../comun/almacenamiento.js";
import { consultarCuota } from "../../services/fotografo/fotografoService.js";
import { configurarTags } from "./tags.js";
import { configurarQr } from "./qr.js";

const usuario = requiereSesion("fotografo");
const coleccionId = Number(new URLSearchParams(location.search).get("coleccionId"));
const galeria = document.getElementById("galeria");
const mensaje = document.getElementById("estadoVacio");
const selectorArchivos = document.getElementById("selectorArchivos");
const zonaCarga = document.getElementById("zonaCarga");
const botonAgregar = document.getElementById("agregarArchivos");
const barraAcciones = document.getElementById("barraAcciones");
const botonPublicar = document.getElementById("botonPublicar");
const menuVisibilidad = document.getElementById("menuVisibilidad");
const estadoVisibilidad = document.getElementById("estadoVisibilidad");
const botonMasOpciones = document.getElementById("botonMasOpciones");
const menuMasOpciones = document.getElementById("menuMasOpciones");
const botonEliminar = document.getElementById("eliminarSeleccionados");
const botonSeleccionar = document.getElementById("seleccionarTodas");
const visor = document.getElementById("visor");
const contenidoVisor = document.getElementById("visorContenido");
const modalConfirmacion = document.getElementById("modalConfirmacion");
const textoConfirmacion = document.getElementById("textoConfirmacion");
const botonAceptarConfirmacion = document.getElementById("confirmacionAceptar");
const botonCancelarConfirmacion = document.getElementById("confirmacionCancelar");
const campoTitulo = document.getElementById("nombreColeccion");
const campoDescripcion = document.getElementById("descripcionColeccionTexto");
const LIMITE_IMAGEN_BYTES = 30 * 1024 * 1024;
const LIMITE_VIDEO_BYTES = 800 * 1024 * 1024;
const MAX_TITULO = 60;
const MAX_DESCRIPCION = 90;

let archivos = [];
let seleccionados = [];
let ocupado = false;
let tituloColeccion = "";
let descripcionColeccion = "";
let guardandoCampo = false;
let guardadoPorEnter = false;
let resolverConfirmacion = null;
let focoAntesDeConfirmar = null;

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

function pedirConfirmacion(texto) {
    return new Promise(function (resolve) {
        textoConfirmacion.textContent = texto;
        focoAntesDeConfirmar = document.activeElement;
        resolverConfirmacion = resolve;
        modalConfirmacion.hidden = false;
        botonCancelarConfirmacion.focus();
    });
}

function cerrarConfirmacion(resultado) {
    if (modalConfirmacion.hidden) return;
    modalConfirmacion.hidden = true;
    const resolver = resolverConfirmacion;
    resolverConfirmacion = null;
    if (focoAntesDeConfirmar && typeof focoAntesDeConfirmar.focus === "function") {
        focoAntesDeConfirmar.focus();
    }
    focoAntesDeConfirmar = null;
    if (resolver) resolver(resultado);
}

function indicarTrabajo(enCurso) {
    ocupado = enCurso;
    selectorArchivos.disabled = enCurso;
    if (zonaCarga.tagName === "BUTTON") {
        zonaCarga.disabled = enCurso;
    } else if (zonaCarga.tagName === "LABEL") {
        if (enCurso) {
            zonaCarga.setAttribute("aria-disabled", "true");
        } else {
            zonaCarga.removeAttribute("aria-disabled");
        }
    }
    botonAgregar.disabled = enCurso;
    botonPublicar.disabled = enCurso;
    botonEliminar.disabled = enCurso;
    botonSeleccionar.disabled = enCurso;
    campoTitulo.contentEditable = String(!enCurso);
    campoDescripcion.contentEditable = String(!enCurso);
    for (const boton of menuVisibilidad.querySelectorAll("button")) boton.disabled = enCurso;
}

function actualizarEstadoVisibilidad(tipo) {
    const esPublica = tipo === "publica";
    estadoVisibilidad.textContent = esPublica ? "Pública" : "Privada";
    estadoVisibilidad.classList.toggle("EstadoPublica", esPublica);
    estadoVisibilidad.classList.toggle("EstadoPrivada", !esPublica);
    estadoVisibilidad.hidden = false;
}

function mostrarVisibilidad(tipo) {
    actualizarEstadoVisibilidad(tipo);
    mostrarToast(
        tipo === "publica" ? "Visible en colecciones públicas" : "Colección privada",
        "Exito",
    );
}

function cerrarMenuMas() {
    if (menuMasOpciones.hidden) return;
    menuMasOpciones.hidden = true;
    botonMasOpciones.setAttribute("aria-expanded", "false");
}

function alternarMenuMas() {
    const abrir = menuMasOpciones.hidden;
    menuVisibilidad.hidden = true;
    botonPublicar.setAttribute("aria-expanded", "false");
    menuMasOpciones.hidden = !abrir;
    botonMasOpciones.setAttribute("aria-expanded", String(abrir));
}

// Texto visible del campo editable, en una sola línea (Enter guarda, no salta).
function leerTextoCampo(campo) {
    return (campo.innerText || "").replace(/\s+/g, " ").trim();
}

function escribirTextoCampo(campo, texto) {
    campo.textContent = texto;
}

async function guardarCampoEditable(campo, clave, texto, textoAnterior) {
    const esTitulo = clave === "titulo";
    const maximo = esTitulo ? MAX_TITULO : MAX_DESCRIPCION;
    if (esTitulo && texto === "") {
        escribirTextoCampo(campo, textoAnterior);
        alert("El título no puede quedar vacío.");
        return;
    }
    if (texto.length > maximo) {
        escribirTextoCampo(campo, textoAnterior);
        alert((esTitulo ? "El título" : "La descripción") + " no puede superar los " + maximo + " caracteres.");
        return;
    }
    if (texto === textoAnterior) {
        escribirTextoCampo(campo, textoAnterior);
        return;
    }
    guardandoCampo = true;
    indicarTrabajo(true);
    try {
        const datos = {};
        datos[clave] = texto;
        await actualizarColeccion(coleccionId, datos);
        if (esTitulo) tituloColeccion = texto;
        else descripcionColeccion = texto;
        escribirTextoCampo(campo, texto);
        mostrarToast(
            esTitulo ? "El título se actualizó correctamente." : "La descripción se actualizó correctamente.",
            "Exito",
        );
    } catch (error) {
        escribirTextoCampo(campo, textoAnterior);
        alert(error.message);
    } finally {
        indicarTrabajo(false);
        guardandoCampo = false;
    }
}

function configurarCampoEditable(campo, clave) {
    let textoAnterior = "";
    campo.addEventListener("focus", function () {
        textoAnterior = clave === "titulo" ? tituloColeccion : descripcionColeccion;
    });
    campo.addEventListener("keydown", function (evento) {
        if (evento.key === "Enter") {
            // Guardar en lugar de salto de línea. El texto se lee ANTES del blur
            // y el blur se salta (guardadoPorEnter) para no restaurar lo escrito.
            evento.preventDefault();
            const texto = leerTextoCampo(campo);
            guardadoPorEnter = true;
            campo.blur();
            guardarCampoEditable(campo, clave, texto, textoAnterior);
        } else if (evento.key === "Escape") {
            evento.preventDefault();
            escribirTextoCampo(campo, textoAnterior);
            campo.blur();
        }
    });
    // Solo texto plano: al pegar se descarta formato y saltos de línea.
    campo.addEventListener("paste", function (evento) {
        evento.preventDefault();
        const texto = (evento.clipboardData || window.clipboardData)
            .getData("text")
            .replace(/\s+/g, " ");
        const seleccion = window.getSelection();
        if (seleccion && seleccion.rangeCount > 0) {
            try {
                const rango = seleccion.getRangeAt(0);
                rango.deleteContents();
                rango.insertNode(document.createTextNode(texto));
                rango.collapse(false);
                seleccion.removeAllRanges();
                seleccion.addRange(rango);
                return;
            } catch (error) {
                // Fallback
            }
        }
        if (typeof document.execCommand === "function") {
            document.execCommand("insertText", false, texto);
        }
    });
    // Sin Enter no se guarda: se restaura el último valor.
    campo.addEventListener("blur", function () {
        if (guardadoPorEnter) {
            guardadoPorEnter = false;
            return;
        }
        if (guardandoCampo) return;
        escribirTextoCampo(campo, clave === "titulo" ? tituloColeccion : descripcionColeccion);
    });
}

function actualizarSeleccion() {
    for (const tarjeta of galeria.querySelectorAll(".TarjetaMedia")) {
        const seleccionada = seleccionados.includes(Number(tarjeta.dataset.id));
        tarjeta.classList.toggle("Seleccionada", seleccionada);
        tarjeta.querySelector("input").checked = seleccionada;
    }
    botonSeleccionar.textContent =
        seleccionados.length === archivos.length
            ? "Quitar selección"
            : "Seleccionar todos los archivos";
}

function crearTarjeta(archivo) {
    const tarjeta = document.createElement("article");
    tarjeta.className = "TarjetaMedia";
    tarjeta.dataset.id = archivo.id_multimedia;
    const vista = document.createElement(archivo.tipo === "video" ? "video" : "img");
    vista.className = "VistaMiniatura";
    vista.setAttribute("aria-label", archivo.titulo || "Abrir archivo");
    vista.tabIndex = 0;
    vista.addEventListener("click", async function () {
        await abrirVisor(archivo);
    });
    vista.addEventListener("keydown", async function (evento) {
        if (evento.key === "Enter") await abrirVisor(archivo);
    });
    tarjeta.appendChild(vista);
    const selector = document.createElement("input");
    selector.type = "checkbox";
    selector.className = "SelectorArchivo";
    selector.setAttribute("aria-label", "Seleccionar " + (archivo.titulo || "archivo"));
    selector.addEventListener("change", function () {
        if (ocupado) {
            actualizarSeleccion();
            return;
        }
        const id = Number(archivo.id_multimedia);
        if (selector.checked) seleccionados.push(id);
        else
            seleccionados = seleccionados.filter(function (seleccionado) {
                return seleccionado !== id;
            });
        actualizarSeleccion();
    });
    tarjeta.appendChild(selector);
    if (botonAgregar && typeof botonAgregar.before === "function") {
        botonAgregar.before(tarjeta);
    } else if (galeria && botonAgregar) {
        galeria.insertBefore(tarjeta, botonAgregar);
    } else if (galeria) {
        galeria.appendChild(tarjeta);
    }
    return vista;
}

async function cargarArchivos() {
    archivos = await listarMultimedia(coleccionId);
    liberarVistas(galeria);
    for (const tarjeta of galeria.querySelectorAll(".TarjetaMedia")) tarjeta.remove();
    seleccionados = [];
    const hayArchivos = archivos.length > 0;
    mensaje.hidden = hayArchivos;
    mensaje.textContent = "Aún no hay archivos. Sube un JPG o MP4 para comenzar.";
    barraAcciones.classList.toggle("Visible", hayArchivos);
    if (zonaCarga && "hidden" in zonaCarga) {
        zonaCarga.hidden = hayArchivos;
    }
    botonAgregar.hidden = !hayArchivos;
    for (const archivo of archivos) {
        const vista = crearTarjeta(archivo);
        await cargarVista(vista, archivo);
    }
    actualizarSeleccion();
}

function validarTamanoArchivo(archivo) {
    const esVideo = String(archivo.type).startsWith("video") || archivo.name.toLowerCase().endsWith(".mp4");
    const limite = esVideo ? LIMITE_VIDEO_BYTES : LIMITE_IMAGEN_BYTES;
    const limiteMB = esVideo ? 800 : 30;
    if (archivo.size > limite) {
        return archivo.name + ": supera el límite de " + limiteMB + " MB.";
    }
    return null;
}

async function subirUnArchivo(archivo, espacioDisponible) {
    const errorTamano = validarTamanoArchivo(archivo);
    if (errorTamano) {
        throw new Error(errorTamano);
    }
    if (espacioDisponible !== Infinity && archivo.size > espacioDisponible) {
        throw new Error(archivo.name + ": no queda espacio disponible (" + formatearAlmacenamiento(espacioDisponible) + " libres).");
    }
    const resultado = await subirMultimedia(coleccionId, [archivo], {
        titulo: archivo.name.slice(0, 60),
    });
    if (resultado && resultado.excedentes && resultado.excedentes.length > 0) {
        throw new Error(archivo.name + ": no queda espacio disponible.");
    }
    return { resultado, size: archivo.size };
}

async function subirArchivos() {
    if (ocupado || !selectorArchivos.files.length) return;
    indicarTrabajo(true);
    const errores = [];
    let espacioDisponible = 0;
    try {
        const cuota = await consultarCuota();
        espacioDisponible = Number(cuota.espacio_disponible_bytes) || 0;
    } catch (error) {
        console.warn("No se pudo consultar el espacio disponible.", error);
        errores.push("No se pudo consultar el espacio disponible. Se intentará subir igualmente.");
        espacioDisponible = Infinity;
    }
    const archivos = Array.from(selectorArchivos.files);
    for (const archivo of archivos) {
        try {
            const info = await subirUnArchivo(archivo, espacioDisponible);
            if (espacioDisponible !== Infinity && info && typeof info.size === "number") {
                espacioDisponible = Math.max(0, espacioDisponible - info.size);
            }
        } catch (error) {
            errores.push(archivo.name + ": " + (error.message || "Error al subir el archivo."));
        }
    }
    try {
        await cargarArchivos();
        await actualizarAlmacenamiento();
    } catch (error) {
        console.warn("No se pudo actualizar la galería tras subir archivos.", error);
        errores.push("No se pudo actualizar la galería: " + error.message);
    } finally {
        selectorArchivos.value = "";
        indicarTrabajo(false);
    }
    if (errores.length) alert(errores.join("\n"));
}

async function eliminarSeleccionados() {
    if (ocupado || !seleccionados.length) return;
    const vaciaraColeccion = seleccionados.length === archivos.length;
    const aviso = vaciaraColeccion
        ? "¿Eliminar todos los archivos? La colección quedará vacía."
        : "¿Eliminar los archivos seleccionados?";
    if (!(await pedirConfirmacion(aviso))) return;
    indicarTrabajo(true);
    const errores = [];
    for (const id of seleccionados) {
        try {
            await eliminarMultimedia(id);
        } catch (error) {
            errores.push(error.message);
        }
    }
    try {
        await cargarArchivos();
        await actualizarAlmacenamiento();
    } catch (error) {
        console.warn("No se pudo actualizar la galería tras eliminar archivos.", error);
        errores.push(error.message);
    } finally {
        indicarTrabajo(false);
    }
    if (errores.length) alert(errores.join("\n"));
}

async function publicarColeccion(tipo) {
    if (ocupado) return;
    menuVisibilidad.hidden = true;
    botonPublicar.setAttribute("aria-expanded", "false");
    if (tipo === "publica" && archivos.length === 0) {
        mostrarToast("Sube al menos una imagen o video para poder hacerla pública.", "Error");
        return;
    }
    indicarTrabajo(true);
    try {
        const respuesta = await actualizarColeccion(coleccionId, { tipo_visibilidad: tipo });
        mostrarVisibilidad(respuesta && respuesta.tipo_visibilidad ? respuesta.tipo_visibilidad : tipo);
    } catch (error) {
        mostrarToast(error.message, "Error");
    } finally {
        indicarTrabajo(false);
    }
}

function cerrarVisor() {
    visor.classList.remove("Abierto");
    liberarVistas(contenidoVisor);
    contenidoVisor.replaceChildren();
}

async function abrirVisor(archivo) {
    cerrarVisor();
    const medio = document.createElement(archivo.tipo === "video" ? "video" : "img");
    if (archivo.tipo === "video") medio.controls = true;
    else medio.alt = archivo.titulo || "Fotografía";
    contenidoVisor.appendChild(medio);
    visor.classList.add("Abierto");
    await cargarVista(medio, archivo);
}

async function iniciar() {
    indicarTrabajo(true);
    if (!usuario) return;
    if (!Number.isInteger(coleccionId) || coleccionId <= 0) {
        mensaje.textContent = "La colección no es válida. Vuelve al panel.";
        return;
    }
    try {
        const coleccion = await detalleColeccion(coleccionId);
        tituloColeccion = coleccion.titulo || "";
        descripcionColeccion = coleccion.descripcion || "";
        escribirTextoCampo(campoTitulo, tituloColeccion);
        escribirTextoCampo(campoDescripcion, descripcionColeccion);
        actualizarEstadoVisibilidad(coleccion.tipo_visibilidad);
        configurarQr(coleccionId);
        await configurarTags(coleccion);
        await cargarArchivos();
        await actualizarAlmacenamiento();
        indicarTrabajo(false);
    } catch (error) {
        mensaje.hidden = false;
        mensaje.textContent = error.message;
    }
}

if (zonaCarga) {
    zonaCarga.addEventListener("click", function (evento) {
        if (zonaCarga.tagName === "LABEL") return;
        evento.preventDefault();
        selectorArchivos.click();
    });
}
botonAgregar.addEventListener("click", function () {
    selectorArchivos.click();
});
selectorArchivos.addEventListener("change", subirArchivos);
botonEliminar.addEventListener("click", eliminarSeleccionados);
botonSeleccionar.addEventListener("click", function () {
    seleccionados =
        seleccionados.length === archivos.length
            ? []
            : archivos.map(function (archivo) {
                  return Number(archivo.id_multimedia);
              });
    actualizarSeleccion();
});
botonPublicar.addEventListener("click", function () {
    cerrarMenuMas();
    menuVisibilidad.hidden = !menuVisibilidad.hidden;
    botonPublicar.setAttribute("aria-expanded", String(!menuVisibilidad.hidden));
});
botonMasOpciones.addEventListener("click", alternarMenuMas);
menuMasOpciones.addEventListener("click", function (evento) {
    if (evento.target.closest(".OpcionMas")) cerrarMenuMas();
});
document.addEventListener("click", function (evento) {
    if (menuMasOpciones.hidden) return;
    if (!evento.target.closest(".ControlesQrColaborativo")) cerrarMenuMas();
});
for (const boton of menuVisibilidad.querySelectorAll("button")) {
    boton.addEventListener("click", async function () {
        await publicarColeccion(boton.dataset.visibilidad);
    });
}
botonAceptarConfirmacion.addEventListener("click", function () {
    cerrarConfirmacion(true);
});
botonCancelarConfirmacion.addEventListener("click", function () {
    cerrarConfirmacion(false);
});
modalConfirmacion.addEventListener("click", function (evento) {
    if (evento.target === modalConfirmacion) cerrarConfirmacion(false);
});
document.getElementById("cerrarVisor").addEventListener("click", cerrarVisor);
configurarCampoEditable(campoTitulo, "titulo");
configurarCampoEditable(campoDescripcion, "descripcion");
visor.addEventListener("click", function (evento) {
    if (evento.target === visor) cerrarVisor();
});
document.addEventListener("keydown", function (evento) {
    if (evento.key !== "Escape") return;
    if (!menuMasOpciones.hidden) {
        cerrarMenuMas();
        botonMasOpciones.focus();
        return;
    }
    if (!modalConfirmacion.hidden) {
        cerrarConfirmacion(false);
        return;
    }
    cerrarVisor();
});
await iniciar();
