// Moderación de material colaborativo de invitados (HU12): lista pendientes,
// selección visual múltiple, aprobación o rechazo en lote de archivos.
const parametros = new URLSearchParams(window.location.search);
const coleccionId = parametros.has("coleccionId") ? Number(parametros.get("coleccionId")) : null;

const galeria = document.getElementById("galeriaPendientes");
const estadoVacio = document.getElementById("estadoPendientes");
const tituloColeccion = document.getElementById("tituloColeccionModeracion");
const controles = document.getElementById("controlesModeracion");
const seleccionarTodas = document.getElementById("seleccionarTodasPendientes");
const botonAprobar = document.getElementById("aprobarPendientes");
const botonRechazar = document.getElementById("rechazarPendientes");
const volverColeccion = document.getElementById("volverColeccion");

let pendientes = [];
const idsSeleccionados = new Set();
const urlsObjetos = new Set();

function formatearTamano(bytes) {
	const valor = Number(bytes) || 0;
	if (valor >= 1024 * 1024) return (valor / 1048576).toFixed(1) + " MB";
	if (valor >= 1024) return Math.round(valor / 1024) + " KB";
	return valor + " B";
}

function formatearFecha(fecha) {
	return new Date(String(fecha).replace(" ", "T")).toLocaleString("es-ES", { dateStyle: "short", timeStyle: "short" });
}

function tipoLegible(tipo) {
	return tipo === "video" ? "Video" : "Imagen";
}

function actualizarBotones() {
	const sinSeleccion = idsSeleccionados.size === 0;
	botonAprobar.disabled = sinSeleccion;
	botonRechazar.disabled = sinSeleccion;
	seleccionarTodas.checked = pendientes.length > 0 && idsSeleccionados.size === pendientes.length;

	galeria.querySelectorAll(".TarjetaPendiente").forEach(function (tarjeta) {
		tarjeta.classList.toggle("Seleccionada", idsSeleccionados.has(Number(tarjeta.dataset.id)));
	});
}

function renderizarPendientes() {
	galeria.querySelectorAll(".TarjetaPendiente").forEach(function (tarjeta) { tarjeta.remove(); });
	urlsObjetos.forEach(function (url) { URL.revokeObjectURL(url); });
	urlsObjetos.clear();
	estadoVacio.hidden = pendientes.length > 0;
	controles.hidden = pendientes.length === 0;
	actualizarBotones();

	pendientes.forEach(function (archivo) {
		const id = Number(archivo.id_multimedia);

		const tarjeta = document.createElement("article");
		tarjeta.className = "TarjetaPendiente";
		tarjeta.dataset.id = id;

		const esVideo = archivo.tipo && String(archivo.tipo).startsWith("video");

		const imagen = document.createElement(esVideo ? "video" : "img");
		imagen.className = "MiniaturaPendiente";
		imagen.alt = archivo.titulo || "Aporte de invitado";
		if (esVideo) {
			imagen.muted = true;
			imagen.playsInline = true;
			imagen.preload = "auto";
		}
		imagen.onerror = function () { imagen.style.visibility = "hidden"; };
		imagen.onclick = function () {
			if (imagen.src) window.open(imagen.src, "_blank");
		};

		cargarVistaPrevia(id).then(function (url) {
			imagen.src = url;
		}).catch(function () {
			imagen.style.visibility = "hidden";
		});

		const casilla = document.createElement("input");
		casilla.type = "checkbox";
		casilla.className = "CheckPendiente";
		casilla.checked = idsSeleccionados.has(id);
		casilla.addEventListener("change", function () {
			if (casilla.checked) idsSeleccionados.add(id);
			else idsSeleccionados.delete(id);
			actualizarBotones();
		});

		const datos = document.createElement("div");
		datos.className = "DatosPendiente";

		const nombre = document.createElement("strong");
		nombre.textContent = archivo.titulo || "Invitado";

		const detalle = document.createElement("p");
		detalle.textContent = tipoLegible(archivo.tipo) + " · " + formatearTamano(archivo.tamanio) + " · " + formatearFecha(archivo.creado_en);

		datos.appendChild(nombre);
		datos.appendChild(detalle);
		tarjeta.appendChild(casilla);
		tarjeta.appendChild(imagen);
		tarjeta.appendChild(datos);
		galeria.appendChild(tarjeta);
	});
}

async function cargarVistaPrevia(id) {
	const url = await window.api.obtenerVistaPrevia(id);
	urlsObjetos.add(url);
	return url;
}

async function cargarPendientes() {
	estadoVacio.hidden = false;
	estadoVacio.textContent = "Cargando aportes de invitados…";

	const token = localStorage.getItem("token");
	if (!token) {
		window.location.href = "login.html";
		return;
	}

	try {
		pendientes = await window.api.listarPendientes(coleccionId);
		idsSeleccionados.clear();
		estadoVacio.textContent = "No hay aportes de invitados pendientes de moderación.";
		renderizarPendientes();
	} catch (error) {
		estadoVacio.hidden = false;
		estadoVacio.textContent = error.message;
	}
}

async function aprobarSeleccionados() {
	if (idsSeleccionados.size === 0) return;
	try {
		const resultado = await window.api.aprobarColaborativo(coleccionId, Array.from(idsSeleccionados));
		alert("Se aprobaron " + resultado.aprobados + " archivos. Ya están visibles en la colección.");
		await cargarPendientes();
	} catch (error) {
		alert(error.message);
	}
}

async function rechazarSeleccionados() {
	if (idsSeleccionados.size === 0) return;
	if (!confirm("¿Rechazar y eliminar " + idsSeleccionados.size + " archivo(s)?")) return;
	try {
		const resultado = await window.api.rechazarColaborativo(coleccionId, Array.from(idsSeleccionados));
		alert("Se rechazaron y eliminaron " + resultado.eliminados + " archivos.");
		await cargarPendientes();
	} catch (error) {
		alert(error.message);
	}
}

if (!coleccionId || !Number.isInteger(coleccionId)) {
	window.location.href = "panel.html";
} else {
	if (volverColeccion) volverColeccion.href = "SubirImagenes.html?coleccionId=" + coleccionId;
	seleccionarTodas.addEventListener("change", function () {
		pendientes.forEach(function (archivo) {
			const id = Number(archivo.id_multimedia);
			if (seleccionarTodas.checked) idsSeleccionados.add(id);
			else idsSeleccionados.delete(id);
		});
		actualizarBotones();
	});
	botonAprobar.addEventListener("click", aprobarSeleccionados);
	botonRechazar.addEventListener("click", rechazarSeleccionados);
	cargarPendientes();
}