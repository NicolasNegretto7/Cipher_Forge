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
const campoNombre = document.getElementById("nombre");
const campoContrasena = document.getElementById("contraseña");
const campoTelefono = document.getElementById("telefono");

const LIMITE_NOMBRE = 30;
const LIMITE_CONTRASENA = 30;
const LIMITE_TELEFONO = 9;

function limpiarNombre(valor) {
    return String(valor || "")
        .replace(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]/g, "")
        .slice(0, LIMITE_NOMBRE);
}

function limpiarTelefono(valor) {
    return String(valor || "").replace(/\D/g, "").slice(0, LIMITE_TELEFONO);
}

function moverCursorTelefono(posicion) {
    if (!campoTelefono) return;
    const destino = Math.min(posicion, campoTelefono.value.length);
    campoTelefono.setSelectionRange(destino, destino);
}

if (campoNombre) {
    campoNombre.addEventListener("input", function () {
        campoNombre.value = limpiarNombre(campoNombre.value);
    });
}

if (campoContrasena) {
    campoContrasena.addEventListener("input", function () {
        if (campoContrasena.value.length > LIMITE_CONTRASENA) {
            campoContrasena.value = campoContrasena.value.slice(0, LIMITE_CONTRASENA);
        }
    });
}

if (campoTelefono) {
    campoTelefono.addEventListener("input", function () {
        const valor = campoTelefono.value;
        const limpio = limpiarTelefono(valor);
        if (valor === limpio) return;

        const posicion = campoTelefono.selectionStart || 0;
        const numerosAntes = limpiarTelefono(valor.slice(0, posicion)).length;
        campoTelefono.value = limpio;
        moverCursorTelefono(numerosAntes);
    });

    campoTelefono.addEventListener("paste", function (evento) {
        const portapapeles = evento.clipboardData || window.clipboardData;
        if (!portapapeles) return;

        const texto = portapapeles.getData("text");
        if (!texto) return;
        evento.preventDefault();

        const inicio = campoTelefono.selectionStart || 0;
        const fin = campoTelefono.selectionEnd || 0;
        const antes = limpiarTelefono(campoTelefono.value.slice(0, inicio));
        const despues = limpiarTelefono(campoTelefono.value.slice(fin));
        const espacio = LIMITE_TELEFONO - antes.length - despues.length;
        const insertar = limpiarTelefono(texto).slice(0, Math.max(espacio, 0));

        campoTelefono.value = antes + insertar + despues;
        moverCursorTelefono(antes.length + insertar.length);
    });
}

if (formRegistro) {
    const mensaje = document.getElementById("mensajeRegistro");

    formRegistro.addEventListener("submit", async function (evento) {
        evento.preventDefault();

        const nombre = limpiarNombre(document.getElementById("nombre").value).trim();
        const correo = document.getElementById("correo").value.trim();
        const contrasena = document.getElementById("contraseña").value.slice(0, LIMITE_CONTRASENA);
        const telefono = campoTelefono ? limpiarTelefono(campoTelefono.value).trim() : "";
        const boton = formRegistro.querySelector("button[type=submit]");

        boton.disabled = true;
        mostrarMensaje(mensaje, "Creando la cuenta...", false);

        try {
            const resultado = await registrarse({
                nombre_completo: nombre,
                email: correo,
                password: contrasena,
                telefono: telefono,
                rol: "cliente",
                terminos_aceptados: document.getElementById("terminos").checked,
            });

            localStorage.setItem("cliente-email-verificacion-pendiente", resultado.email || correo);
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

const enlaceLogin = document.getElementById("enlaceLogin");
if (enlaceLogin) {
    enlaceLogin.href = "login.html" + location.search;
}
