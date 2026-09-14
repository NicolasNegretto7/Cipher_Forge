import {
    actualizarHashtags,
    listarHashtags,
} from "../../services/colecciones/coleccionesService.js";

export async function configurarTags(coleccion) {
    const campo = document.getElementById("tagInput");
    const lista = document.getElementById("listaTags");
    let tags = coleccion.hashtags || [];
    let guardando = false;

    function mostrarTags() {
        lista.replaceChildren();
        for (const tag of tags) {
            const boton = document.createElement("button");
            boton.type = "button";
            boton.className = "EtiquetaTag";
            boton.textContent = "#" + tag + " ×";
            boton.addEventListener("click", async function () {
                await guardarTags(
                    tags.filter(function (actual) {
                        return actual !== tag;
                    }),
                );
            });
            lista.appendChild(boton);
        }
    }

    async function guardarTags(nuevos) {
        if (guardando) return;
        guardando = true;
        campo.disabled = true;
        try {
            const resultado = await actualizarHashtags(coleccion.id, nuevos);
            tags = resultado.hashtags || nuevos;
            campo.value = "";
            mostrarTags();
        } catch (error) {
            alert(error.message);
        } finally {
            campo.disabled = false;
            guardando = false;
        }
    }

    campo.addEventListener("keydown", async function (evento) {
        if (evento.key !== "Enter") return;
        evento.preventDefault();
        const tag = campo.value.trim().replace(/^#/, "").toLowerCase();
        if (tag && !tags.includes(tag)) {
            const nuevosTags = tags.slice();
            nuevosTags.push(tag);
            await guardarTags(nuevosTags);
        }
    });
    mostrarTags();
    try {
        const sugerencias = await listarHashtags();
        const opciones = document.getElementById("sugerenciasHashtags");
        for (const tag of sugerencias) {
            const opcion = document.createElement("option");
            opcion.value = "#" + tag.nombre_hashtags;
            opciones.appendChild(opcion);
        }
    } catch (error) {
        // Se pueden escribir etiquetas aunque no carguen las sugerencias.
    }
}
