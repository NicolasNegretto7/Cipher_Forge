import { registrarse } from "../../services/auth/authService.js";

function mostrarMensaje(elemento, texto, esError) {
    if (!elemento) {
        alert(texto);
        return;
    }
    elemento.textContent = texto;
    elemento.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
}

function activarVistaContrasena(input) {
    if (!input) return;
    const contenedor = input.closest(".CampoContrasena");
    const icono = contenedor && contenedor.querySelector("[data-ojo]");
    if (!icono) return;

    const ojoAbierto = icono.querySelector(".IconoVer");
    const ojoCerrado = icono.querySelector(".IconoOcultar");

    function pintar(mostrar) {
        input.type = mostrar ? "text" : "password";
        icono.setAttribute("aria-pressed", String(mostrar));
        icono.setAttribute("aria-label", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
        icono.setAttribute("title", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
        if (ojoAbierto) ojoAbierto.style.display = mostrar ? "none" : "inline";
        if (ojoCerrado) ojoCerrado.style.display = mostrar ? "inline" : "none";
    }

    function alternar() {
        pintar(input.type === "password");
    }

    icono.addEventListener("click", alternar);
    icono.addEventListener("keydown", function (evento) {
        if (evento.key === "Enter" || evento.key === " ") {
            evento.preventDefault();
            alternar();
        }
    });

    pintar(false);
}

const formRegistro = document.getElementById("formRegistro");
const campoNombre = document.getElementById("nombre");
const campoContrasena = document.getElementById("contraseña");
const campoConfirmar = document.getElementById("confirmarContraseña");
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
        validarConfirmacion();
    });
}

if (campoConfirmar) {
    campoConfirmar.addEventListener("input", function () {
        if (campoConfirmar.value.length > LIMITE_CONTRASENA) {
            campoConfirmar.value = campoConfirmar.value.slice(0, LIMITE_CONTRASENA);
        }
        validarConfirmacion();
    });
}

function validarConfirmacion() {
    if (!campoConfirmar) return true;
    const coincide = !campoContrasena || campoConfirmar.value === campoContrasena.value;
    campoConfirmar.setCustomValidity(coincide ? "" : "Las contraseñas no coinciden");
    return coincide;
}

activarVistaContrasena(campoContrasena);
activarVistaContrasena(campoConfirmar);

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

        if (!validarConfirmacion()) {
            mostrarMensaje(mensaje, "Las contraseñas no coinciden.", true);
            if (campoConfirmar) campoConfirmar.focus();
            return;
        }

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
