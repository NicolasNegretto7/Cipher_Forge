const CAPACIDAD_ALMACENAMIENTO = 3 * 1024 * 1024 * 1024;

function obtenerColeccionesAlmacenadas() {
	return JSON.parse(localStorage.getItem("colecciones") || "[]");
}

function obtenerTamanoArchivo(archivo) {
	const tamano = Number(archivo.tamano);
	if (Number.isFinite(tamano) && tamano >= 0) return tamano;
	if (typeof archivo.src === "string" && archivo.src.includes(",")) {
		return Math.max(0, Math.ceil((archivo.src.split(",")[1].length * 3) / 4));
	}
	return 0;
}

function obtenerAlmacenamientoUsado() {
	return obtenerColeccionesAlmacenadas().reduce(function (totalColecciones, coleccion) {
		return totalColecciones + (coleccion.imagenes || []).reduce(function (totalArchivos, archivo) {
			return totalArchivos + obtenerTamanoArchivo(archivo);
		}, 0);
	}, 0);
}

function formatearAlmacenamiento(bytes) {
	if (bytes >= 1024 * 1024 * 1024) return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
	if (bytes >= 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB";
	return Math.round(bytes / 1024) + " KB";
}

function actualizarAlmacenamiento() {
	const usado = obtenerAlmacenamientoUsado();
	const restante = Math.max(0, CAPACIDAD_ALMACENAMIENTO - usado);

	document.querySelectorAll(".TextoAlmacenamiento").forEach(function (texto) {
		texto.textContent = formatearAlmacenamiento(usado) + " de 3 GB usados · " + formatearAlmacenamiento(restante) + " restantes";
	});
}

actualizarAlmacenamiento();
