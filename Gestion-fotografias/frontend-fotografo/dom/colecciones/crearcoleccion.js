import { crearColeccion } from "../../services/colecciones/coleccionesService.js";
import { requiereSesion } from "../comun/sesion.js";

const usuario = requiereSesion("fotografo");
const formulario = document.getElementById("formColeccion");
const mensaje = document.getElementById("mensajeColeccion");

async function guardarColeccion(evento) {
    evento.preventDefault();
    if (!usuario) return;
    const boton = formulario.querySelector("button[type=submit]");
    boton.disabled = true;
    mensaje.textContent = "Creando colección...";
    try {
        const tipoVisibilidad = document.querySelector('input[name="tipo_visibilidad"]:checked').value;
        const hashtagsInput = document.getElementById("hashtagsColeccion").value.trim();
        const hashtags = hashtagsInput ? hashtagsInput.split(",").map(t => t.trim()).filter(t => t) : [];

        const coleccion = await crearColeccion({
            titulo: document.getElementById("nombreColeccion").value.trim(),
            descripcion: document.getElementById("descripcionColeccion").value.trim(),
            tipo_visibilidad: tipoVisibilidad,
            ...(hashtags.length > 0 && { hashtags })
        });
        location.href = "SubirImagenes.html?coleccionId=" + coleccion.id;
    } catch (error) {
        mensaje.textContent = error.message;
    } finally {
        boton.disabled = false;
    }
}

formulario.addEventListener("submit", guardarColeccion);
