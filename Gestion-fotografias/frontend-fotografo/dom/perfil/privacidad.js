import { aceptarPoliticas } from "../../services/fotografo/fotografoService.js";
import { guardarUsuario } from "../../services/sesion/sesionService.js";

export function configurarPrivacidad(usuario) {
    if (Number(usuario.politicas_aceptadas) === 1) return;
    const modal = document.getElementById("modalPrivacidad");
    const texto = document.getElementById("textoLey");
    const boton = document.getElementById("aceptarPolitica");
    const mensaje = document.getElementById("mensajePoliticas");
    let guardando = false;
    modal.classList.remove("oculto");

    function actualizarBoton() {
        const llegoAlFinal = texto.scrollTop + texto.clientHeight >= texto.scrollHeight - 10;
        boton.disabled = guardando || !llegoAlFinal;
    }

    async function aceptar() {
        guardando = true;
        actualizarBoton();
        mensaje.textContent = "Guardando...";
        try {
            await aceptarPoliticas();
            usuario.politicas_aceptadas = true;
            guardarUsuario(usuario);
            modal.classList.add("oculto");
        } catch (error) {
            mensaje.textContent = error.message;
        } finally {
            guardando = false;
            actualizarBoton();
        }
    }

    texto.addEventListener("scroll", actualizarBoton);
    window.addEventListener("resize", actualizarBoton);
    boton.addEventListener("click", aceptar);
    actualizarBoton();
}
