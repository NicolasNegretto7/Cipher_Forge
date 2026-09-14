import {
    listarFavoritos,
    quitarFavorito,
} from "../../services/favoritos/favoritosService.js";
import { requiereSesion } from "../comun/sesion.js";
import { mostrarToast } from "../comun/interfaz.js";
import { cargarPortada, liberarVistas } from "../multimedia/multimedia.js";
import { crearTarjetaColeccion } from "../colecciones/tarjetas.js";
import "../comun/auth.js";

const usuario = requiereSesion("cliente");
const galeria = document.getElementById("galeriaFavoritos");
const sinFavoritos = document.getElementById("sinFavoritos");
const mensajeCarga = document.getElementById("mensajeCarga");
const mensajeError = document.getElementById("mensajeError");

function crearBotonQuitar(coleccion, tarjeta) {
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "FavoritoColeccion FavoritoActivo";
    boton.textContent = "♥";
    boton.setAttribute("aria-label", "Quitar de favoritos");
    boton.addEventListener("click", async function () {
        boton.disabled = true;
        try {
            await quitarFavorito(coleccion.id_coleccion);
            liberarVistas(tarjeta);
            tarjeta.remove();
            sinFavoritos.hidden = galeria.children.length > 0;
        } catch (error) {
            mostrarToast(error.message, "Error");
        } finally {
            boton.disabled = false;
        }
    });
    return boton;
}

async function iniciar() {
    if (!usuario) return;
    try {
        const colecciones = await listarFavoritos();
        sinFavoritos.hidden = colecciones.length > 0;
        for (const coleccion of colecciones) {
            coleccion.id = coleccion.id_coleccion;
            const tarjeta = crearTarjetaColeccion(coleccion);
            tarjeta.appendChild(crearBotonQuitar(coleccion, tarjeta));
            galeria.appendChild(tarjeta);
            await cargarPortada(tarjeta.querySelector(".CubiertaTarjeta"), coleccion);
        }
    } catch (error) {
        mensajeError.textContent = error.message;
        mensajeError.hidden = false;
    } finally {
        mensajeCarga.hidden = true;
    }
}

await iniciar();
