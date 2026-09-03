const parametros = new URLSearchParams(window.location.search);
const API_URL = "http://localhost:8080";
const coleccionId = parametros.has("coleccionId") ? Number(parametros.get("coleccionId")) : null;
const nombreTexto = document.getElementById("nombreColeccion");
const descripcionTexto = document.getElementById("descripcionColeccionTexto");
const estadoVisibilidad = document.getElementById("estadoVisibilidad");
const zonaCarga = document.getElementById("zonaCarga");
const selectorArchivos = document.getElementById("selectorArchivos");
const galeria = document.getElementById("galeria");
const estadoVacio = document.getElementById("estadoVacio");
const barraAcciones = document.getElementById("barraAcciones");
const tagInput = document.getElementById("tagInput");
const listaTags = document.getElementById("listaTags");

let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccion = colecciones.find(function (item) { return item.id === coleccionId; });
let esColeccionNueva = false;

if (!coleccion) {
    coleccion = {
        id: Date.now() + Math.random(),
        localId: null,
        nombre: parametros.get("nombre") || "Nueva colección",
        descripcion: "",
        tipo_visibilidad: "privada",
        tags: [],
        favorita: false,
        publicada: false,
        imagenes: []
    };
    coleccion.localId = coleccion.id;
    esColeccionNueva = true;
}

if (!coleccion.tags) coleccion.tags = [];
if (!coleccion.imagenes) coleccion.imagenes = [];
let archivos = coleccion.imagenes;
let seleccionados = [];

nombreTexto.textContent = coleccion.nombre;
descripcionTexto.textContent = coleccion.descripcion || "";
estadoVisibilidad.textContent = coleccion.tipo_visibilidad === "publica"
    ? "Visible en colecciones públicas"
    : "Privada: no aparece en colecciones públicas";

function guardarColeccion() {
    coleccion.imagenes = archivos;

    if (esColeccionNueva) {
        colecciones.push(coleccion);
        esColeccionNueva = false;
    } else {
        colecciones = colecciones.map(function (item) {
            return item.id === coleccion.id || item.id === coleccion.localId || item.localId === coleccion.localId ? coleccion : item;
        });
    }

    localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

function mostrarTags() {
    listaTags.innerHTML = "";

    coleccion.tags.forEach(function (tag) {
        const etiqueta = document.createElement("button");
        etiqueta.type = "button";
        etiqueta.className = "EtiquetaTag";
        etiqueta.textContent = tag + " x";
        etiqueta.addEventListener("click", function () {
            coleccion.tags = coleccion.tags.filter(function (item) { return item !== tag; });
            guardarColeccion();
            mostrarTags();
        });
        listaTags.appendChild(etiqueta);
    });
}

tagInput.addEventListener("keydown", function (evento) {
    if (evento.key !== "Enter") return;
    evento.preventDefault();

    const texto = tagInput.value.trim();
    if (!texto) return;

    const tag = texto.startsWith("#") ? texto : "#" + texto;
    if (!coleccion.tags.includes(tag)) {
        coleccion.tags.push(tag);
        guardarColeccion();
        mostrarTags();
    }

    tagInput.value = "";
});

zonaCarga.addEventListener("click", function () { selectorArchivos.click(); });
selectorArchivos.addEventListener("change", function () {
    Array.from(selectorArchivos.files).forEach(function (archivo) {
        const lector = new FileReader();
        lector.onload = function (evento) {
            archivos.push({
                id: Date.now() + Math.random(),
                nombre: archivo.name,
                tipo: archivo.type,
                src: evento.target.result,
                favorita: false
            });
            guardarColeccion();
            mostrarGaleria();
        };
        lector.readAsDataURL(archivo);
    });
    selectorArchivos.value = "";
});

function mostrarGaleria() {
    galeria.querySelectorAll(".TarjetaMedia").forEach(function (tarjeta) { tarjeta.remove(); });
    estadoVacio.style.display = archivos.length === 0 ? "block" : "none";

    archivos.forEach(function (archivo) {
        const tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaMedia";
        tarjeta.classList.toggle("Seleccionada", seleccionados.includes(archivo.id));

        const vista = document.createElement(archivo.tipo.startsWith("video") ? "video" : "img");
        vista.src = archivo.src;
        vista.className = "VistaMiniatura";
        tarjeta.appendChild(vista);

        const favorito = document.createElement("button");
        favorito.type = "button";
        favorito.className = "FavoritoArchivo";
        favorito.textContent = archivo.favorita ? "♥" : "♡";
        favorito.classList.toggle("Activo", archivo.favorita);
        favorito.addEventListener("click", function (evento) {
            evento.stopPropagation();
            archivo.favorita = !archivo.favorita;
            guardarColeccion();
            mostrarGaleria();
        });
        tarjeta.appendChild(favorito);

        const selector = document.createElement("button");
        selector.type = "button";
        selector.className = "SelectorArchivo";
        selector.textContent = seleccionados.includes(archivo.id) ? "✔" : "";
        selector.classList.toggle("Seleccionado", seleccionados.includes(archivo.id));
        selector.addEventListener("click", function () {
            if (seleccionados.includes(archivo.id)) {
                seleccionados = seleccionados.filter(function (id) { return id !== archivo.id; });
            } else {
                seleccionados.push(archivo.id);
            }
            mostrarGaleria();
        });
        tarjeta.appendChild(selector);
        galeria.appendChild(tarjeta);
    });

    barraAcciones.classList.toggle("Visible", seleccionados.length > 0);
}

document.getElementById("agregarFavoritos").addEventListener("click", function () {
    archivos.forEach(function (archivo) {
        if (seleccionados.includes(archivo.id)) archivo.favorita = true;
    });
    guardarColeccion();
    seleccionados = [];
    mostrarGaleria();
});

document.getElementById("eliminarSeleccionados").addEventListener("click", function () {
    archivos = archivos.filter(function (archivo) { return !seleccionados.includes(archivo.id); });
    seleccionados = [];
    if (archivos.length === 0) {
        eliminarColeccionVacia();
    } else {
        guardarColeccion();
    }
    mostrarGaleria();
});

function eliminarColeccionVacia() {
    colecciones = colecciones.filter(function (item) {
        return item.id !== coleccion.id;
    });
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

const botonPublicar = document.getElementById("botonPublicar");
const menuVisibilidad = document.getElementById("menuVisibilidad");

botonPublicar.addEventListener("click", function () {
    const menuAbierto = botonPublicar.getAttribute("aria-expanded") === "true";
    botonPublicar.setAttribute("aria-expanded", String(!menuAbierto));
    menuVisibilidad.hidden = menuAbierto;
});

async function publicarColeccion(tipoVisibilidad) {
    if (archivos.length === 0) {
        alert("Agrega al menos una imagen antes de publicar la colección.");
        return;
    }

    const usuario = JSON.parse(localStorage.getItem("usuario") || "null");
    const rol = usuario && (usuario.rol || usuario.role);
    const fotografoId = Number(usuario && (usuario.id || usuario.id_fotografo));

    if (!usuario || rol !== "fotografo" || !Number.isInteger(fotografoId) || fotografoId <= 0) {
        alert("Solo los usuarios con rol fotógrafo pueden publicar colecciones.");
        return;
    }

    const botonSeleccionado = menuVisibilidad.querySelector("[data-visibilidad='" + tipoVisibilidad + "']");
    const idBorrador = coleccion.id;
    botonSeleccionado.disabled = true;

    try {
        const respuesta = await fetch(API_URL + "/colecciones", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                fotografo_id: fotografoId,
                titulo: coleccion.nombre,
                tipo_visibilidad: tipoVisibilidad,
                descripcion: coleccion.descripcion || ""
            })
        });

        const json = await respuesta.json();
        if (!respuesta.ok) {
            throw new Error(json.mensaje || "No se pudo publicar la colección.");
        }

        coleccion.id = Number(json.datos.id);
        coleccion.tipo_visibilidad = tipoVisibilidad;
        coleccion.publicada = true;
        coleccion.localId = coleccion.localId || idBorrador;
        guardarColeccion();
        estadoVisibilidad.textContent = tipoVisibilidad === "publica"
            ? "Visible en colecciones públicas"
            : "Privada: no aparece en colecciones públicas";
        menuVisibilidad.hidden = true;
        botonPublicar.setAttribute("aria-expanded", "false");
        alert(tipoVisibilidad === "publica"
            ? "Colección publicada y visible en colecciones públicas."
            : "Colección publicada como privada.");
    } catch (error) {
        alert(error.message);
    } finally {
        botonSeleccionado.disabled = false;
    }
}

menuVisibilidad.querySelectorAll("[data-visibilidad]").forEach(function (opcion) {
    opcion.addEventListener("click", function () {
        publicarColeccion(opcion.dataset.visibilidad);
    });
});

mostrarTags();
mostrarGaleria();
