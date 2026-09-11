const CAPACIDAD_ALMACENAMIENTO = 3 * 1024 * 1024 * 1024;
const CLAVE_CUOTA = "cuota-almacenamiento";

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

// Solo archivos del borrador que aún NO están en el servidor (no subidos y no remotos):
// el resto ya cuenta en la cuota del backend y no debe duplicarse.
function obtenerAlmacenamientoPendiente() {
	return obtenerColeccionesAlmacenadas().reduce(function (totalColecciones, coleccion) {
		return totalColecciones + (coleccion.imagenes || []).reduce(function (totalArchivos, archivo) {
			if (archivo.remoto || archivo.subido) return totalArchivos;
			return totalArchivos + obtenerTamanoArchivo(archivo);
		}, 0);
	}, 0);
}

// Para el chequeo previo del selector: usa la cuota vigente si el servidor fue
// consultado (cache), o el total del borrador como medida conservadora local.
function obtenerEspacioEnUsoContexto() {
	const guardada = cuotaGuardada();
	if (guardada && Number.isFinite(Number(guardada.espacio_usado_bytes))) {
		return Number(guardada.espacio_usado_bytes);
	}
	return obtenerAlmacenamientoUsado();
}

function formatearAlmacenamiento(bytes) {
	if (bytes >= 1024 * 1024 * 1024) return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
	if (bytes >= 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB";
	return Math.round(bytes / 1024) + " KB";
}

function cuotaGuardada() {
	try {
		return JSON.parse(localStorage.getItem(CLAVE_CUOTA) || "null");
	} catch (e) {
		return null;
	}
}

function guardarCuota(cuota) {
	try {
		localStorage.setItem(CLAVE_CUOTA, JSON.stringify(cuota));
	} catch (e) {
		/* almacenamiento no disponible; se ignora */
	}
}

function pintarAlmacenamiento(usado, total, restante) {
	document.querySelectorAll(".TextoAlmacenamiento").forEach(function (texto) {
		texto.textContent = formatearAlmacenamiento(usado) + " de " + formatearAlmacenamiento(total) + " usados · " + formatearAlmacenamiento(restante) + " restantes";
	});

	const circulo = document.querySelector(".CirculoAlmacenamiento");
	if (circulo) {
		const pct = Math.min(100, (usado / total) * 100);
		circulo.style.background = "conic-gradient(var(--verde) " + pct + "%, #e5e7eb " + pct + "%)";
	}
}

function combinarConLocal(cuota) {
	const total = Number(cuota.espacio_total_bytes) || CAPACIDAD_ALMACENAMIENTO;
	const usadoServidor = Number(cuota.espacio_usado_bytes) || 0;
	// La cuota del servidor es la base (SUM sobre multimedia): baja al borrar
	// colecciones o archivos. Solo se suman los borradores aún no subidos.
	const usado = usadoServidor + obtenerAlmacenamientoPendiente();

	return {
		espacio_usado_bytes: usado,
		espacio_total_bytes: total,
		espacio_disponible_bytes: Math.max(0, total - usado)
	};
}

function aplicarCuota(cuota) {
	const usado = Number(cuota.espacio_usado_bytes) || 0;
	const total = Number(cuota.espacio_total_bytes) || CAPACIDAD_ALMACENAMIENTO;
	pintarAlmacenamiento(usado, total, Math.max(0, total - usado));
}

function actualizarAlmacenamiento() {
	const guardada = cuotaGuardada();
	if (guardada) {
		aplicarCuota(guardada);
		return;
	}

	const usado = obtenerAlmacenamientoUsado();
	const restante = Math.max(0, CAPACIDAD_ALMACENAMIENTO - usado);
	pintarAlmacenamiento(usado, CAPACIDAD_ALMACENAMIENTO, restante);
}

function refrescarCuotaServidor() {
	if (!window.api || !window.api.consultarCuota) return Promise.resolve();

	const token = localStorage.getItem("token");
	const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");
	if (!token || (usuario.rol || usuario.role) !== "fotografo") return Promise.resolve();

	return window.api.consultarCuota().then(function (cuota) {
		const combinada = combinarConLocal(cuota);
		guardarCuota(combinada);
		aplicarCuota(combinada);
	}).catch(function () {
		return null;
	});
}

function inicializarAlmacenamiento() {
	actualizarAlmacenamiento();
	refrescarCuotaServidor();
}

inicializarAlmacenamiento();

window.addEventListener("pageshow", function () {
	actualizarAlmacenamiento();
});

window.addEventListener("storage", function (evento) {
	if (evento.key === CLAVE_CUOTA && evento.newValue) {
		try {
			aplicarCuota(JSON.parse(evento.newValue));
		} catch (e) {
			/* ignore */
		}
	}
});