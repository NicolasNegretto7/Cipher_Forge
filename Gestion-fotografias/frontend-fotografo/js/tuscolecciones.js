const galeria = document.getElementById("galeriaColecciones");
const sinColecciones = document.getElementById("sinColecciones");
let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccionesSeleccionadas = [];
const coleccionesConArchivos = colecciones.filter(function (coleccion) {
    return coleccion.imagenes && coleccion.imagenes.length > 0;
});

if (coleccionesConArchivos.length !== colecciones.length) {
    colecciones = coleccionesConArchivos;
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

sinColecciones.style.display = colecciones.length === 0 ? "block" : "none";

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

document.getElementById("eliminarColeccionesSeleccionadas").addEventListener("click", function () {
    colecciones = colecciones.filter(function (coleccion) {
        return !coleccionesSeleccionadas.includes(coleccion.id);
    });
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
    coleccionesSeleccionadas = [];
    actualizarAlmacenamiento();
    mostrarColecciones();
});

mostrarColecciones();
