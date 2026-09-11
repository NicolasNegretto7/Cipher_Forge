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
    // Evita registrar listeners duplicados si la función se invoca más de una vez.
    if (verificarModalPrivacidad._inicializado) return;
    verificarModalPrivacidad._inicializado = true;

    const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");
    const rol = usuario.rol || usuario.role;
    const idFotografo = usuario.id || usuario.id_fotografo || "";
    const claveAceptacion = "acepto-politica-fotografo-" + idFotografo;
    const yaAcepto =
        usuario.politicas_aceptadas === true ||
        usuario.politicas_aceptadas === 1 ||
        localStorage.getItem(claveAceptacion) === "true";

    if (rol === "fotografo" && !yaAcepto) {
        modalPrivacidad.classList.remove("oculto");
    } else {
        return;
    }

    function actualizarEstadoBoton() {
        llegoAlFinal = textoLey.scrollTop + textoLey.clientHeight >= textoLey.scrollHeight - 10;
        // No pisar el estado "Guardando..." mientras hay una petición en curso.
        if (!botonAceptar.dataset.guardando) {
            botonAceptar.disabled = !llegoAlFinal;
        }
    }

    actualizarEstadoBoton();

    textoLey.addEventListener("scroll", actualizarEstadoBoton);
    window.addEventListener("resize", actualizarEstadoBoton);
    // Recalcular cuando termine de cargar el layout/fuentes.
    window.addEventListener("load", actualizarEstadoBoton);

    botonAceptar.addEventListener("click", async function () {
        const mensajePolitica = document.getElementById("mensajePoliticas");

        if (!window.api || !window.api.aceptarPoliticas) {
            if (mensajePolitica) {
                mensajePolitica.textContent = "No se pudo cargar el módulo de conexión (api.js). Recarga la página e inténtalo de nuevo.";
                mensajePolitica.classList.add("error");
            }
            return;
        }
        if (!localStorage.getItem("token")) {
            if (mensajePolitica) {
                mensajePolitica.textContent = "Tu sesión expiró. Serás redirigido al inicio de sesión...";
                mensajePolitica.classList.add("error");
            }
            setTimeout(function () { window.location.href = "login.html"; }, 1200);
            return;
        }

        botonAceptar.dataset.guardando = "1";
        botonAceptar.disabled = true;

        if (mensajePolitica) {
            mensajePolitica.textContent = "Guardando tu aceptación...";
            mensajePolitica.classList.remove("error");
        }

        try {
            await window.api.aceptarPoliticas();
            usuario.politicas_aceptadas = true;
            localStorage.setItem("usuario", JSON.stringify(usuario));
            localStorage.setItem(claveAceptacion, "true");
            localStorage.removeItem("acepto-politica-fotografo");
            if (mensajePolitica) mensajePolitica.textContent = "";
            modalPrivacidad.classList.add("oculto");
            delete botonAceptar.dataset.guardando;
        } catch (error) {
            if (mensajePolitica) {
                var mensaje = (error && error.message) ? error.message : "Error inesperado al guardar.";
                // fetch lanza TypeError cuando el backend no está en ejecución.
                if (error instanceof TypeError || mensaje === "Failed to fetch") {
                    mensaje = "No se pudo conectar con el servidor (http://localhost:8080). Verifica que el backend esté en ejecución con Docker y vuelve a intentarlo.";
                }
                mensajePolitica.textContent = mensaje;
                mensajePolitica.classList.add("error");
            }
            if (error && error.status === 401) {
                // Sesión inválida o expirada: limpiar para NO rebotar entre
                // panel.html <-> login.html (el login redirige a panel si hay token).
                localStorage.removeItem("token");
                localStorage.removeItem("usuario");
                localStorage.removeItem("cuota-almacenamiento");
                setTimeout(function () { window.location.href = "login.html"; }, 1500);
                return;
            }
            delete botonAceptar.dataset.guardando;
            actualizarEstadoBoton();
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

    const borradas = [];
    const fallidas = [];

    for (const coleccionDeBorrado of aEliminar) {
        const idBackend = Number(coleccionDeBorrado.id);
        const borradaBackend = !coleccionDeBorrado.publicada || !Number.isInteger(idBackend) || idBackend <= 0;

        if (!borradaBackend && window.api && window.api.eliminarColeccion) {
            try {
                await window.api.eliminarColeccion(idBackend);
            } catch (error) {
                // Si el servidor no borró la colección, se conserva localmente para
                // reintentar: así la cuota del servidor sí disminuye al eliminarla.
                fallidas.push(coleccionDeBorrado.nombre || "Colección");
                continue;
            }
        }
        borradas.push(coleccionDeBorrado.id);
    }

    if (fallidas.length > 0) {
        alert("No se pudieron eliminar en el servidor y se conservaron: " + fallidas.join(", ") + ". Inténtalo de nuevo.");
    }

    colecciones = colecciones.filter(function (coleccion) {
        return !borradas.includes(coleccion.id);
    });
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
    coleccionesSeleccionadas = [];
    if (typeof actualizarAlmacenamiento === "function") actualizarAlmacenamiento();
    if (typeof refrescarCuotaServidor === "function") refrescarCuotaServidor();
    mostrarColecciones();
});

verificarModalPrivacidad();
mostrarColecciones();