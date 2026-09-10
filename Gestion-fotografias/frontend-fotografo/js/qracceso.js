const botonQrAcceso = document.getElementById("botonQrAcceso");
const modalQrAcceso = document.getElementById("modalQrAcceso");
const cerrarQrAcceso = document.getElementById("cerrarQrAcceso");
const imagenQrAcceso = document.getElementById("imagenQrAcceso");
const enlaceQrAcceso = document.getElementById("enlaceQrAcceso");
const copiarEnlaceAcceso = document.getElementById("copiarEnlaceAcceso");
const abrirEnlaceAcceso = document.getElementById("abrirEnlaceAcceso");
const avisoQrAcceso = document.getElementById("avisoQrAcceso");

function cerrarModalQrAcceso() {
	modalQrAcceso.hidden = true;
	imagenQrAcceso.innerHTML = "";
}

function coleccionPublicadaConId() {
	return typeof coleccion !== "undefined"
		&& coleccion.publicada === true
		&& Number.isInteger(Number(coleccion.id))
		&& Number(coleccion.id) > 0;
}

async function generarQrAcceso() {
	if (!coleccionPublicadaConId()) {
		alert("Publica la colección antes de generar su QR de acceso.");
		return;
	}

	if (!window.api || !window.api.generarQrAcceso) {
		alert("La capa de API no está disponible.");
		return;
	}

	botonQrAcceso.disabled = true;

	try {
		const datos = await window.api.generarQrAcceso(coleccion.id);

		imagenQrAcceso.innerHTML = datos.svg_qr;
		enlaceQrAcceso.value = datos.url_acceso;
		abrirEnlaceAcceso.href = datos.url_acceso;
		avisoQrAcceso.textContent = "Acceso permanente a «" + (datos.titulo || coleccion.titulo || "esta colección")
			+ "» (sin caducidad). Quien tenga el enlace podrá visualizar y descargar "
			+ "las fotos; si no inició sesión, deberá iniciar sesión o registrarse para canjear el acceso.";
		modalQrAcceso.hidden = false;
	} catch (error) {
		alert(error.message);
	} finally {
		botonQrAcceso.disabled = false;
	}
}

botonQrAcceso.addEventListener("click", generarQrAcceso);
cerrarQrAcceso.addEventListener("click", cerrarModalQrAcceso);

modalQrAcceso.addEventListener("click", function (evento) {
	if (evento.target === modalQrAcceso) cerrarModalQrAcceso();
});

copiarEnlaceAcceso.addEventListener("click", async function () {
	await navigator.clipboard.writeText(enlaceQrAcceso.value);
	copiarEnlaceAcceso.textContent = "Enlace copiado";
	setTimeout(function () { copiarEnlaceAcceso.textContent = "Copiar enlace"; }, 1500);
});