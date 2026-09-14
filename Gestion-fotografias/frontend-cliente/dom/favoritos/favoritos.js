import {
    listarFavoritos,
    agregarFavorito,
    quitarFavorito,
} from "../../services/favoritos/favoritosService.js";
import { haySesion } from "../../services/sesion/sesionService.js";
import { mostrarToast } from "../comun/interfaz.js";

let favoritos = [];

export async function cargarFavoritos() {
    if (!haySesion()) return;
    try {
        const lista = await listarFavoritos();
        favoritos = lista.map(function (coleccion) {
            return Number(coleccion.id_coleccion);
        });
    } catch (error) {
        mostrarToast("No se pudieron cargar los favoritos.", "Error");
    }
}

export function crearBotonFavorito(id) {
    id = Number(id);
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "FavoritoColeccion";

    function actualizar() {
        const activo = favoritos.includes(id);
        boton.classList.toggle("FavoritoActivo", activo);
        boton.textContent = activo ? "♥" : "♡";
        boton.title = activo ? "Quitar de favoritos" : "Guardar en favoritos";
        boton.setAttribute("aria-label", boton.title);
        boton.setAttribute("aria-pressed", String(activo));
    }

    async function cambiarFavorito(evento) {
        evento.stopPropagation();
        if (!haySesion()) {
            mostrarToast("Inicia sesión para guardar favoritos.", "Info");
            return;
        }
        boton.disabled = true;
        try {
            if (favoritos.includes(id)) {
                await quitarFavorito(id);
                favoritos = favoritos.filter(function (actual) {
                    return actual !== id;
                });
            } else {
                await agregarFavorito(id);
                favoritos.push(id);
            }
            actualizar();
        } catch (error) {
            mostrarToast(error.message, "Error");
        } finally {
            boton.disabled = false;
        }
    }

    actualizar();
    boton.addEventListener("click", cambiarFavorito);
    return boton;
}
