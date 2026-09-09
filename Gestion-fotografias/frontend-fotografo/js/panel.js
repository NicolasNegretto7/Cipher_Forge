const galeria = document.getElementById("galeriaColecciones");
const sinColecciones = document.getElementById("sinColecciones");
const modalPrivacidad = document.getElementById("modalPrivacidad");
const textoLey = document.getElementById("textoLey");
const botonAceptar = document.getElementById("aceptarPolitica");
let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccionesSeleccionadas = [];
let llegoAlFinal = false;

function verificarModalPrivacidad() {
    if (!modalPrivacidad || !textoLey || !botonAceptar) return;

    const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");
    const rol = usuario.rol || usuario.role;
    const yaAcepto = usuario.politicas_aceptadas === true || localStorage.getItem("acepto-politica-fotografo") === "true";

    if (rol === "fotografo" && !yaAcepto) {
        modalPrivacidad.classList.remove("oculto");
    }

    llegoAlFinal = textoLey.scrollTop + textoLey.clientHeight >= textoLey.scrollHeight - 10;
    botonAceptar.disabled = !llegoAlFinal;

    textoLey.addEventListener("scroll", function () {
        llegoAlFinal = textoLey.scrollTop + textoLey.clientHeight >= textoLey.scrollHeight - 10;
        botonAceptar.disabled = !llegoAlFinal;
    });

    botonAceptar.addEventListener("click", async function () {
        if (!window.api || !window.api.aceptarPoliticas) return;
        const mensajePolitica = document.getElementById("mensajePoliticas");
        botonAceptar.disabled = true;

        if (mensajePolitica) {
            mensajePolitica.textContent = "Guardando tu aceptación...";
            mensajePolitica.classList.remove("error");
        }

        try {
            await window.api.aceptarPoliticas();
            usuario.politicas_aceptadas = true;
            localStorage.setItem("usuario", JSON.stringify(usuario));
            localStorage.setItem("acepto-politica-fotografo", "true");
            if (mensajePolitica) mensajePolitica.textContent = "";
            modalPrivacidad.classList.add("oculto");
        } catch (error) {
            if (mensajePolitica) {
                mensajePolitica.textContent = error.message;
                mensajePolitica.classList.add("error");
            }
            if (error.status === 401) {
                modalPrivacidad.classList.add("oculto");
                window.location.href = "login.html";
                return;
            }
            botonAceptar.disabled = !llegoAlFinal;
        }
    });
}

function mostrarColecciones() {
    galeria.querySelectorAll(".TarjetaColeccion").forEach(function (tarjeta) { tarjeta.remove(); });
    sinColecciones.style.display = colecciones.length === 0 ? "block" : "none";

    colecciones.forEach(function (coleccion) {
        const tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";
        tarjeta.classList.toggle("Seleccionada", coleccionesSeleccionadas.includes(coleccion.id));
        tarjeta.addEventListener("click", function () {
            window.location.href = "SubirImagenes.html?coleccionId=" + coleccion.id;
        });

        if (coleccion.imagenes.length > 0) {
            const imagen = document.createElement("img");
            imagen.className = "ImagenTarjeta";
            imagen.src = coleccion.imagenes[0].src;
            tarjeta.appendChild(imagen);
        }

        const nombre = document.createElement("p");
        nombre.className = "NombreColeccion";
        nombre.textContent = coleccion.nombre;
        tarjeta.appendChild(nombre);

        const selector = document.createElement("button");
        selector.type = "button";
        selector.className = "SelectorColeccion";
        selector.textContent = coleccionesSeleccionadas.includes(coleccion.id) ? "✔" : "";
        selector.classList.toggle("Seleccionado", coleccionesSeleccionadas.includes(coleccion.id));
        selector.addEventListener("click", function (evento) {
            evento.stopPropagation();
            if (coleccionesSeleccionadas.includes(coleccion.id)) {
                coleccionesSeleccionadas = coleccionesSeleccionadas.filter(function (id) { return id !== coleccion.id; });
            } else {
                coleccionesSeleccionadas.push(coleccion.id);
            }
            mostrarColecciones();
        });
        tarjeta.appendChild(selector);

        galeria.appendChild(tarjeta);
    });
    document.getElementById("barraAccionesColecciones").classList.toggle("Visible", coleccionesSeleccionadas.length > 0);
}

document.getElementById("eliminarColeccionesSeleccionadas").addEventListener("click", async function () {
    const aEliminar = colecciones.filter(function (coleccion) {
        return coleccionesSeleccionadas.includes(coleccion.id);
    });

    if (window.api && window.api.eliminarColeccion) {
        for (const coleccionDeBorrado of aEliminar) {
            const idBackend = Number(coleccionDeBorrado.id);
            if (coleccionDeBorrado.publicada === true && Number.isInteger(idBackend) && idBackend > 0) {
                try {
                    await window.api.eliminarColeccion(idBackend);
                } catch (error) {
                    /* el borrado local prevalece aunque el servidor falle */
                }
            }
        }
    }

    colecciones = colecciones.filter(function (coleccion) {
        return !coleccionesSeleccionadas.includes(coleccion.id);
    });
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
    coleccionesSeleccionadas = [];
    if (typeof actualizarAlmacenamiento === "function") actualizarAlmacenamiento();
    mostrarColecciones();
});

verificarModalPrivacidad();
mostrarColecciones();