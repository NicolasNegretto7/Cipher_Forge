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
        const coleccion = await crearColeccion({
            titulo: document.getElementById("nombreColeccion").value.trim(),
            descripcion: document.getElementById("descripcionColeccion").value.trim(),
            tipo_visibilidad: "privada"
        });
        location.href = "SubirImagenes.html?coleccionId=" + coleccion.id;
    } catch (error) {
        mensaje.textContent = error.message;
    } finally {
        boton.disabled = false;
    }
}

formulario.addEventListener("submit", guardarColeccion);
