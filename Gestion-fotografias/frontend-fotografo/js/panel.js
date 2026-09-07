const galeria = document.getElementById("galeriaPublica");
const buscador = document.getElementById("tagBusqueda");
const tagsBusqueda = document.getElementById("tagsBusqueda");
const contadorTags = document.getElementById("contadorTags");
const zonaBuscador = document.querySelector(".ZonaBuscadorTags");
const colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
const modalPrivacidad = document.getElementById("modalPrivacidad");
const textoLey = document.getElementById("textoLey");
const botonAceptar = document.getElementById("aceptarPolitica");
let tagsSeleccionados = [];
let coleccionAbierta = null;
let posicionImagen = 0;

function verificarModalPrivacidad() {
    if (!modalPrivacidad || !textoLey || !botonAceptar) return;

    const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");
    const rol = usuario.rol || usuario.role;
    const yaAcepto = localStorage.getItem("acepto-politica-fotografo") === "true";

    if (rol === "fotografo" && !yaAcepto) {
        modalPrivacidad.classList.remove("oculto");
    }

    textoLey.addEventListener("scroll", function () {
        const llegoAlFinal = textoLey.scrollTop + textoLey.clientHeight >= textoLey.scrollHeight - 10;
        botonAceptar.disabled = !llegoAlFinal;
    });

    botonAceptar.addEventListener("click", function () {
        localStorage.setItem("acepto-politica-fotografo", "true");
        modalPrivacidad.classList.add("oculto");
    });
}

function mostrarColecciones() {
    galeria.innerHTML = "";
    const coleccionesPublicas = colecciones.filter(function (coleccion) {
        if (coleccion.publicada !== true || coleccion.tipo_visibilidad !== "publica" || coleccion.imagenes.length === 0) return false;
        return true;
    });

    const coleccionesOrdenadas = coleccionesPublicas
        .map(function (coleccion, indice) {
            const coincide = tagsSeleccionados.length > 0 && tagsSeleccionados.every(function (tagBuscado) {
                return (coleccion.tags || []).some(function (tag) {
                    return tag.toLowerCase() === tagBuscado.toLowerCase();
                });
            });
            return { coleccion: coleccion, coincide: coincide, indice: indice };
        })
        .sort(function (a, b) {
            if (a.coincide !== b.coincide) return a.coincide ? -1 : 1;
            return a.indice - b.indice;
        })
        .map(function (item) { return item.coleccion; });

    coleccionesOrdenadas.forEach(function (coleccion) {
        const tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";
        tarjeta.addEventListener("click", function () { abrirColeccion(coleccion); });
        const imagen = document.createElement("img");
        imagen.className = "ImagenTarjeta";
        imagen.src = coleccion.imagenes[0].src;
        tarjeta.appendChild(imagen);
        const nombre = document.createElement("p");
        nombre.className = "NombreColeccion";
        nombre.textContent = coleccion.nombre;
        tarjeta.appendChild(nombre);
        const favorito = document.createElement("button");
        favorito.type = "button";
        favorito.className = "FavoritoColeccion";
        favorito.textContent = coleccion.favorita ? "♥" : "♡";
        favorito.addEventListener("click", function (evento) {
            evento.stopPropagation();
            coleccion.favorita = !coleccion.favorita;
            guardarColecciones();
            mostrarColecciones();
        });
        tarjeta.appendChild(favorito);
        galeria.appendChild(tarjeta);
    });
}

function guardarColecciones() {
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

buscador.addEventListener("keydown", function (evento) {
    if (evento.key !== "Enter") return;
    evento.preventDefault();
    const texto = buscador.value.trim();
    const tag = texto.startsWith("#") ? texto : "#" + texto;
    if (!texto || tagsSeleccionados.includes(tag)) return;
    tagsSeleccionados.push(tag);
    buscador.value = "";
    mostrarTags();
    mostrarColecciones();
});

buscador.addEventListener("focus", function () { zonaBuscador.classList.add("Abierto"); });
document.addEventListener("click", function (evento) {
    if (!zonaBuscador.contains(evento.target)) zonaBuscador.classList.remove("Abierto");
});

function mostrarTags() {
    tagsBusqueda.innerHTML = "";
    tagsSeleccionados.forEach(function (tag) {
        const etiqueta = document.createElement("button");
        etiqueta.type = "button";
        etiqueta.className = "EtiquetaTag";
        etiqueta.textContent = tag + " x";
        etiqueta.addEventListener("click", function () {
            tagsSeleccionados = tagsSeleccionados.filter(function (item) { return item !== tag; });
            mostrarTags();
            mostrarColecciones();
        });
        tagsBusqueda.appendChild(etiqueta);
    });

}

function abrirColeccion(coleccion) {
    coleccionAbierta = coleccion;
    posicionImagen = 0;
    mostrarImagenColeccion();
    document.getElementById("detalleColeccion").classList.add("Visible");
}

function mostrarImagenColeccion() {
    const imagen = coleccionAbierta.imagenes[posicionImagen];
    const contenedor = document.getElementById("imagenColeccionGrande");
    const info = document.getElementById("infoColeccion");
    contenedor.innerHTML = "";
    const vista = document.createElement(imagen.tipo.startsWith("video") ? "video" : "img");
    vista.src = imagen.src;
    vista.controls = imagen.tipo.startsWith("video");
    contenedor.appendChild(vista);
    info.innerHTML = "<h2>Nombre: " + coleccionAbierta.nombre + "</h2>";
    info.innerHTML += "<h3>Tags de la colección:</h3>";
    (coleccionAbierta.tags || []).forEach(function (tag) { info.innerHTML += "<span class=\"EtiquetaTag\">" + tag + "</span> "; });
    document.getElementById("imagenAnterior").style.display = posicionImagen > 0 ? "block" : "none";
    document.getElementById("imagenSiguiente").style.display = posicionImagen < coleccionAbierta.imagenes.length - 1 ? "block" : "none";
}

document.getElementById("imagenAnterior").addEventListener("click", function () { posicionImagen--; mostrarImagenColeccion(); });
document.getElementById("imagenSiguiente").addEventListener("click", function () { posicionImagen++; mostrarImagenColeccion(); });
document.getElementById("detalleColeccion").addEventListener("click", function (evento) {

    if (evento.target.id === "detalleColeccion") {
        document.getElementById("detalleColeccion").classList.remove("Visible");
    }
});

verificarModalPrivacidad();
mostrarTags();
mostrarColecciones();
