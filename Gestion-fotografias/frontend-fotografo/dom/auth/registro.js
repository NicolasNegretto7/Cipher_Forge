import { registrarse } from "../../services/auth/authService.js";
function mostrarMensaje(elemento, texto, esError) {
    if (!elemento) {
        alert(texto);
        return;
    }
    elemento.textContent = texto;
    elemento.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

const formRegistro = document.getElementById("formRegistro");
if (formRegistro) {
    const mensaje = document.getElementById("mensajeRegistro");

    formRegistro.addEventListener("submit", async function (evento) {
        evento.preventDefault();

        const nombre = document.getElementById("nombre").value.trim();
        const correo = document.getElementById("correo").value.trim();
        const contrasena = document.getElementById("contraseña").value;
        const campoTelefono = document.getElementById("telefono");
        const telefono = campoTelefono ? campoTelefono.value.trim() : "";
        const boton = formRegistro.querySelector("button[type=submit]");

        boton.disabled = true;
        mostrarMensaje(mensaje, "Creando la cuenta...", false);

        try {
            const resultado = await registrarse({
                nombre_completo: nombre,
                email: correo,
                password: contrasena,
                telefono: telefono,
                rol: "fotografo",
                terminos_aceptados: document.getElementById("terminos").checked,
            });

            localStorage.setItem(
                "fotografo-email-verificacion-pendiente",
                resultado.email || correo,
            );
            mostrarMensaje(
                mensaje,
                "Cuenta creada correctamente. Verifica tu correo para poder iniciar sesión.",
                false,
            );
            setTimeout(function () {
                location.href = "verificaremail.html" + location.search;
            }, 1200);
        } catch (error) {
            mostrarMensaje(mensaje, error.message, true);
            boton.disabled = false;
        }

    });
}
