const botonQrColaborativo = document.getElementById("botonQrColaborativo");
const botonModerarColaborativo = document.getElementById("botonModerarColaborativo");
const modalQrColaborativo = document.getElementById("modalQrColaborativo");
const cerrarQrColaborativo = document.getElementById("cerrarQrColaborativo");
const imagenQrColaborativo = document.getElementById("imagenQrColaborativo");
const enlaceQrColaborativo = document.getElementById("enlaceQrColaborativo");
const copiarEnlaceColaborativo = document.getElementById("copiarEnlaceColaborativo");
const avisoExpiracionQr = document.getElementById("avisoExpiracionQr");
const abrirEnlaceColaborativo = document.getElementById("abrirEnlaceColaborativo");
const imprimirQrColaborativo = document.getElementById("imprimirQrColaborativo");

function cerrarModalQrColaborativo() {
	modalQrColaborativo.hidden = true;
	imagenQrColaborativo.innerHTML = "";
}

function coleccionPublicadaConId() {
	return typeof coleccion !== "undefined"
		&& coleccion.publicada === true
		&& Number.isInteger(Number(coleccion.id))
		&& Number(coleccion.id) > 0;
}

async function generarQrColaborativo() {
	if (!coleccionPublicadaConId()) {
		alert("Publica la colección antes de generar su código QR colaborativo.");
		return;
	}

	if (!window.api || !window.api.generarQrColaborativo) {
		alert("La capa de API no está disponible.");
		return;
	}

	botonQrColaborativo.disabled = true;

	try {
		const datos = await window.api.generarQrColaborativo(coleccion.id);

		const fechaExpiracion = String(datos.expiracion || "").replace(" ", "T");
		const caducidad = fechaExpiracion
			? new Date(fechaExpiracion).toLocaleString("es-ES")
			: "en 24 horas";

		imagenQrColaborativo.innerHTML = datos.svg_qr;
		enlaceQrColaborativo.value = datos.url_acceso;
		abrirEnlaceColaborativo.href = datos.url_acceso;
		imprimirQrColaborativo.href = datos.url_imprimir;
		avisoExpiracionQr.textContent = "Caduca el " + caducidad + ". Los invitados podrán subir fotos y videos sin registrarse.";
		modalQrColaborativo.hidden = false;
	} catch (error) {
		alert(error.message);
	} finally {
		botonQrColaborativo.disabled = false;
	}
}

botonQrColaborativo.addEventListener("click", generarQrColaborativo);
cerrarQrColaborativo.addEventListener("click", cerrarModalQrColaborativo);

modalQrColaborativo.addEventListener("click", function (evento) {
	if (evento.target === modalQrColaborativo) cerrarModalQrColaborativo();
});

copiarEnlaceColaborativo.addEventListener("click", async function () {
	await navigator.clipboard.writeText(enlaceQrColaborativo.value);
	copiarEnlaceColaborativo.textContent = "Enlace copiado";
	setTimeout(function () { copiarEnlaceColaborativo.textContent = "Copiar enlace"; }, 1500);
});

botonModerarColaborativo.addEventListener("click", function (evento) {
	evento.preventDefault();
	if (!coleccionPublicadaConId()) {
		alert("Publica la colección para poder moderar los aportes de los invitados.");
		return;
	}
	window.location.href = "moderacion.html?coleccionId=" + coleccion.id;
});