// Pantalla del invitado (HU11): valida el token colaborativo y permite subir
// fotos/videos sin registro, sin acceso a visualizar el contenido del evento.
const parametros = new URLSearchParams(window.location.search);
const token = parametros.get("token") || "";

const panelCargando = document.getElementById("panelCargando");
const panelError = document.getElementById("panelError");
const mensajeError = document.getElementById("mensajeError");
const panelFormulario = document.getElementById("panelFormulario");
const nombreEvento = document.getElementById("nombreEvento");
const fechaCaducidad = document.getElementById("fechaCaducidad");
const formulario = document.getElementById("formularioColaborativo");
const selectorArchivos = document.getElementById("selectorArchivos");
const listaArchivosSeleccion = document.getElementById("listaArchivosSeleccion");
const botonEnviar = document.getElementById("botonEnviar");
const aceptoDatos = document.getElementById("aceptoDatos");
const panelExito = document.getElementById("panelExito");
const mensajeExito = document.getElementById("mensajeExito");

let archivosSeleccionados = [];

function mostrarPantalla(pantalla) {
	[panelCargando, panelError, panelFormulario, panelExito].forEach(function (p) {
		p.hidden = (p !== pantalla);
	});
}

function formatearCaducidad(fecha) {
	return new Date(String(fecha).replace(" ", "T")).toLocaleString("es-ES", { dateStyle: "long", timeStyle: "short" });
}

async function iniciar() {
	if (!token) {
		mensajeError.textContent = "No se recibió un código de evento en el enlace.";
		mostrarPantalla(panelError);
		return;
	}

	try {
		const datos = await window.api.verificarAccesoColaborativo(token);
		nombreEvento.textContent = datos.evento || "Evento";
		fechaCaducidad.textContent = formatearCaducidad(datos.expira_en);
		mostrarPantalla(panelFormulario);
	} catch (error) {
		mensajeError.textContent = error.message;
		mostrarPantalla(panelError);
	}
}

function actualizarBotonEnviar() {
	botonEnviar.disabled = (archivosSeleccionados.length === 0) || !aceptoDatos.checked;
}

selectorArchivos.addEventListener("change", function () {
	archivosSeleccionados = Array.from(selectorArchivos.files || []);
	if (archivosSeleccionados.length > 0) {
		listaArchivosSeleccion.textContent = archivosSeleccionados.length + " archivo(s) seleccionado(s)";
	} else {
		listaArchivosSeleccion.textContent = "";
	}
	actualizarBotonEnviar();
});

aceptoDatos.addEventListener("change", actualizarBotonEnviar);

formulario.addEventListener("submit", async function (evento) {
	evento.preventDefault();
	if (archivosSeleccionados.length === 0) return;
	if (!aceptoDatos.checked) {
		alert("Debés aceptar el tratamiento de tus datos (Ley 18.331) para poder subir archivos.");
		return;
	}

	botonEnviar.disabled = true;
	botonEnviar.textContent = "Subiendo…";

	try {
		const nombreInvitado = document.getElementById("nombreInvitado").value.trim();
		const resultado = await window.api.subirMaterialColaborativo(token, archivosSeleccionados, nombreInvitado, aceptoDatos.checked);
		mensajeExito.textContent = resultado.aviso;
		mostrarPantalla(panelExito);
	} catch (error) {
		alert(error.message);
		botonEnviar.textContent = "Subir ahora";
		botonEnviar.disabled = false;
	}
});

document.getElementById("botonOtroArchivo").addEventListener("click", function () {
	formulario.reset();
	archivosSeleccionados = [];
	listaArchivosSeleccion.textContent = "";
	botonEnviar.textContent = "Subir ahora";
	botonEnviar.disabled = true;
	mostrarPantalla(panelFormulario);
});

iniciar();