const galeria = document.getElementById("galeriaColecciones");
const sinColecciones = document.getElementById("sinColecciones");
let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
const coleccionesConArchivos = colecciones.filter(function (coleccion) {
    return coleccion.imagenes && coleccion.imagenes.length > 0;
});

if (coleccionesConArchivos.length !== colecciones.length) {
    colecciones = coleccionesConArchivos;
    localStorage.setItem("colecciones", JSON.stringify(colecciones));
}

sinColecciones.style.display = colecciones.length === 0 ? "block" : "none";

colecciones.forEach(function (coleccion) {
    const tarjeta = document.createElement("a");
    tarjeta.className = "TarjetaColeccion";
    tarjeta.href = "SubirImagenes.html?coleccionId=" + coleccion.id;

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

    galeria.appendChild(tarjeta);
});
