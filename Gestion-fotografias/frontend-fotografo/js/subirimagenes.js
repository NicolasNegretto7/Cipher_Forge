const parametros = new URLSearchParams(window.location.search);
// coleccionId solo existe si estamos EDITANDO una colección que ya fue
// guardada antes (o sea, que ya tiene al menos una imagen subida).
const coleccionId = parametros.has("coleccionId") ? Number(parametros.get("coleccionId")) : null;

const nombreTexto = document.getElementById("nombreColeccion");
const zonaCarga = document.getElementById("zonaCarga");
const selectorArchivos = document.getElementById("selectorArchivos");
const galeria = document.getElementById("galeria");
const estadoVacio = document.getElementById("estadoVacio");
const barraAcciones = document.getElementById("barraAcciones");
const detalleMedia = document.getElementById("detalleMedia");
const vistaGrande = document.getElementById("vistaGrande");
const tagInput = document.getElementById("tagInput");
const listaTags = document.getElementById("listaTags");

let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccion = coleccionId !== null
	? colecciones.find(function (item) { return item.id === coleccionId; })
	: undefined;


let esColeccionNueva = false;
if (!coleccion) {
	coleccion = {
		id: Date.now() + Math.random(),
		nombre: parametros.get("nombre") || "Nueva colección",
		favorita: false,
		publicada: false,
		imagenes: []
	};
	esColeccionNueva = true;
}

let archivos = coleccion.imagenes;
let seleccionados = [];
let archivoDetalle = null;
let archivoDetalleId = null;
let tagsTemporales = [];


archivos.forEach(function (archivo) {
	if (!archivo.tags) archivo.tags = [];
});

nombreTexto.textContent = coleccion.nombre;

zonaCarga.addEventListener("click", function () { selectorArchivos.click(); });
selectorArchivos.addEventListener("change", function () {
	guardarArchivos(selectorArchivos.files);
	selectorArchivos.value = "";
});

function guardarArchivos(lista) {
	Array.from(lista).forEach(function (archivo) {
		const lector = new FileReader();
		lector.onload = function (evento) {
			archivos.push({
				id: Date.now() + Math.random(), nombre: archivo.name,
				tipo: archivo.type, src: evento.target.result, tags: [],
			});
			guardarCambios();
			mostrarGaleria();
		};
		lector.readAsDataURL(archivo);
	});
}

function mostrarGaleria() {
	galeria.querySelectorAll(".TarjetaMedia").forEach(function (tarjeta) { tarjeta.remove(); });
	estadoVacio.style.display = archivos.length === 0 ? "block" : "none";

	archivos.forEach(function (archivo) {
		const tarjeta = document.createElement("div");
		tarjeta.className = "TarjetaMedia";
		tarjeta.classList.toggle("Seleccionada", seleccionados.includes(archivo.id));
		const esVideo = archivo.tipo.startsWith("video");
		const vista = document.createElement(esVideo ? "video" : "img");
		vista.src = archivo.src;
		vista.className = "VistaMiniatura";
		vista.addEventListener("click", function () { abrirDetalle(archivo); });
		if (esVideo) {
			const play = document.createElement("span");
			play.className = "IconoPlay";
			play.textContent = "▶";
			tarjeta.appendChild(play);
		}

		const selector = document.createElement("button");
		selector.type = "button";
		selector.className = "SelectorArchivo";
		selector.textContent = seleccionados.includes(archivo.id) ? "✔" : "";
		selector.classList.toggle("Seleccionado", seleccionados.includes(archivo.id));
		selector.addEventListener("click", function (evento) {
			evento.stopPropagation();
			cambiarSeleccion(archivo.id);
		});

		const favorito = document.createElement("button");
		favorito.type = "button";
		favorito.className = "BotonFavorito";
		favorito.textContent = coleccion.favorita ? "♥" : "♡";
		favorito.classList.toggle("FavoritoActivo", coleccion.favorita);
		favorito.addEventListener("click", function (evento) {
			evento.stopPropagation();
			coleccion.favorita = !coleccion.favorita;
			guardarCambios();
			mostrarGaleria();
		});

		const nombreArchivo = document.createElement("p");
		nombreArchivo.className = "NombreArchivo";
		nombreArchivo.textContent = archivo.nombre;
		tarjeta.append(vista, selector, favorito, nombreArchivo);
		galeria.appendChild(tarjeta);
	});
	barraAcciones.classList.toggle("Visible", seleccionados.length > 0);
}

function cambiarSeleccion(id) {
	if (seleccionados.includes(id)) {
		seleccionados = seleccionados.filter(function (item) { return item !== id; });
	} else seleccionados.push(id);
	mostrarGaleria();
}

function guardarCambios() {
	coleccion.imagenes = archivos;

	if (archivos.length === 0) {
		colecciones = colecciones.filter(function (item) {
			return item.id !== coleccion.id;
		});
		esColeccionNueva = true;
		localStorage.setItem("colecciones", JSON.stringify(colecciones));
		return;
	}

	if (esColeccionNueva) {
		colecciones.push(coleccion);
		esColeccionNueva = false;
	} else {
		colecciones = colecciones.map(function (item) {
			return item.id === coleccion.id ? coleccion : item;
		});
	}

	localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

document.getElementById("agregarFavoritos").addEventListener("click", function () {
	archivos.forEach(function (archivo) {
		if (seleccionados.includes(archivo.id)) coleccion.favorita = true;
	});
	guardarCambios();
	mostrarGaleria();
});

document.getElementById("eliminarSeleccionados").addEventListener("click", function () {
	archivos = archivos.filter(function (archivo) { return !seleccionados.includes(archivo.id); });
	seleccionados = [];
	guardarCambios();
	mostrarGaleria();
});

document.getElementById("botonPublicar").addEventListener("click", function () {

	if (archivos.length === 0) {
		alert("Subí al menos una imagen antes de publicar la colección.");
		return;
	}
	coleccion.publicada = true;
	guardarCambios();
});

function abrirDetalle(archivo) {
	archivoDetalle = archivo;
	archivoDetalleId = archivo.id;
	tagsTemporales = [...archivo.tags];
	vistaGrande.innerHTML = "";
	const vista = document.createElement(archivo.tipo.startsWith("video") ? "video" : "img");
	vista.src = archivo.src;
	vista.controls = archivo.tipo.startsWith("video");
	vistaGrande.appendChild(vista);
	tagInput.value = "";
	mostrarTags(tagsTemporales);
	detalleMedia.classList.add("Visible");
}

tagInput.addEventListener("keydown", function (evento) {
	if (evento.key !== "Enter" || !archivoDetalle) return;
	evento.preventDefault();
	const tag = tagInput.value.trim();
	const tagFinal = tag.startsWith("#") ? tag : "#" + tag;
	if (!tag || tagsTemporales.includes(tagFinal)) return;
	tagsTemporales.push(tagFinal);
	tagInput.value = "";
	guardarTagsDeImagen();
	mostrarTags(tagsTemporales);
});

function mostrarTags(tags) {
	listaTags.innerHTML = "";
	tags.forEach(function (tag) {
		const etiqueta = document.createElement("button");
		etiqueta.type = "button";
		etiqueta.className = "EtiquetaTag";
		etiqueta.textContent = tag + " x";
		etiqueta.addEventListener("click", function () {
			tagsTemporales = tagsTemporales.filter(function (item) { return item !== tag; });
			guardarTagsDeImagen();
			mostrarTags(tagsTemporales);
		});
		listaTags.appendChild(etiqueta);
	});
}

function guardarTags() {
	guardarTagsDeImagen();
	detalleMedia.classList.remove("Visible");
}

function guardarTagsDeImagen() {
	if (!archivoDetalleId) return;
	const archivo = archivos.find(function (item) {
		return item.id === archivoDetalleId;
	});
	if (!archivo) return;
	archivo.tags = [...tagsTemporales];
	guardarCambios();
}

document.getElementById("guardarTags").addEventListener("click", guardarTags);

document.getElementById("cerrarDetalle").addEventListener("click", function () {
	detalleMedia.classList.remove("Visible");
});

mostrarGaleria();