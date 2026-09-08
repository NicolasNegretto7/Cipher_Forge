const botonGenerarQr = document.getElementById("botonGenerarQr");
const modalQr = document.getElementById("modalQr");
const cerrarQr = document.getElementById("cerrarQr");
const imagenQr = document.getElementById("imagenQr");
const enlaceQr = document.getElementById("enlaceQr");
const copiarEnlace = document.getElementById("copiarEnlace");
const abrirEnlace = document.getElementById("abrirEnlace");

function cerrarModalQr() {
	modalQr.hidden = true;
	imagenQr.innerHTML = "";
}

async function generarQr() {
	if (!coleccion.publicada || !Number.isInteger(Number(coleccion.id))) {
		alert("Publica la colección antes de generar su código QR.");
		return;
	}

	botonGenerarQr.disabled = true;

	try {
		const token = localStorage.getItem("token");
		const respuesta = await fetch(API_URL + "/colecciones/" + coleccion.id + "/qr-acceso", {
			method: "POST",
			headers: {
				"Authorization": "Bearer " + token
			}
		});
		const json = await respuesta.json();

		if (!respuesta.ok) {
			throw new Error(json.mensaje || "No se pudo generar el código QR.");
		}

		imagenQr.innerHTML = json.datos.svg_qr;
		enlaceQr.value = json.datos.url_acceso;
		abrirEnlace.href = json.datos.url_acceso;
		modalQr.hidden = false;
	} catch (error) {
		alert(error.message);
	} finally {
		botonGenerarQr.disabled = false;
	}
}

botonGenerarQr.addEventListener("click", generarQr);
cerrarQr.addEventListener("click", cerrarModalQr);

modalQr.addEventListener("click", function (evento) {
	if (evento.target === modalQr) cerrarModalQr();
});

copiarEnlace.addEventListener("click", async function () {
	await navigator.clipboard.writeText(enlaceQr.value);
	copiarEnlace.textContent = "Enlace copiado";
	setTimeout(function () { copiarEnlace.textContent = "Copiar enlace"; }, 1500);
});
