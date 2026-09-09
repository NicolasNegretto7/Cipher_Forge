const token = localStorage.getItem("token");
const usuarioGuardado = JSON.parse(localStorage.getItem("usuario") || "null");
const mensaje = document.getElementById("mensajePerfil");

function mostrarDatos() {
	document.getElementById("nombreCompleto").value = usuarioGuardado.nombre_completo || "";
	document.getElementById("telefono").value = usuarioGuardado.telefono || "";
}

function mostrarMensaje(texto, esError = false) {
	mensaje.textContent = texto;
	mensaje.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

async function guardarCampo(campo, valor) {
	const datosActualizados = await api.actualizarPerfil({ [campo]: valor });

	Object.assign(usuarioGuardado, datosActualizados);
	localStorage.setItem("usuario", JSON.stringify(usuarioGuardado));
	mostrarDatos();
	mostrarMensaje("Dato guardado correctamente.");
}

if (!token || !usuarioGuardado) {
	window.location.href = "login.html";
} else {
	mostrarDatos();

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
				if (error.status === 401) {
					window.location.href = "login.html";
					return;
				}
			} finally {
				boton.disabled = false;
			}
		});
	});
}