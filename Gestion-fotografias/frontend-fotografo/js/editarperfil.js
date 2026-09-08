const API_URL = "http://localhost:8080";

const token = localStorage.getItem("token");
const usuarioGuardado = JSON.parse(localStorage.getItem("usuario") || "null");
const mensaje = document.getElementById("mensajePerfil");

if (!token || !usuarioGuardado) {
	window.location.href = "login.html";
}

function mostrarDatos() {
	document.getElementById("nombreCompleto").value = usuarioGuardado.nombre_completo || "";
	document.getElementById("telefono").value = usuarioGuardado.telefono || "";
}

function mostrarMensaje(texto, esError = false) {
	mensaje.textContent = texto;
	mensaje.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

async function guardarCampo(campo, valor) {
	const respuesta = await fetch(API_URL + "/fotografo/perfil", {
		method: "PUT",
		headers: {
			"Content-Type": "application/json",
			"Authorization": "Bearer " + token
		},
		body: JSON.stringify({ [campo]: valor })
	});

	const resultado = await respuesta.json();

	if (!respuesta.ok) {
		throw new Error(resultado.mensaje || "No se pudo guardar el dato.");
	}

	const datosActualizados = resultado.datos;
	Object.assign(usuarioGuardado, datosActualizados);
	localStorage.setItem("usuario", JSON.stringify(usuarioGuardado));
	mostrarDatos();
	mostrarMensaje("Dato guardado correctamente.");
}

document.querySelectorAll(".formulario-perfil").forEach(function (formulario) {
	formulario.addEventListener("submit", async function (evento) {
		evento.preventDefault();

		const campo = formulario.dataset.campo;
		const valor = formulario.elements[campo].value.trim();
		const boton = formulario.querySelector("button");

		boton.disabled = true;
		mostrarMensaje("Guardando...");

		try {
			await guardarCampo(campo, valor);
		} catch (error) {
			mostrarMensaje(error.message, true);
		} finally {
			boton.disabled = false;
		}
	});
});

mostrarDatos();
