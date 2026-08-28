const galeria = document.getElementById("galeriaFavoritos");
const sinFavoritos = document.getElementById("sinFavoritos");
const colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccionAbierta = null;
let posicionImagen = 0;
const favoritas = colecciones.filter(function (coleccion) {
    return (coleccion.favorita || coleccion.imagenes.some(function (imagen) {
        return imagen.favorita;
    })) && coleccion.imagenes.length > 0;
});
sinFavoritos.style.display = favoritas.length === 0 ? "block" : "none";



     favoritas.forEach(function (coleccion) {
    const tarjeta = document.createElement("div");
    tarjeta.className = "TarjetaColeccion";
    tarjeta.addEventListener("click", function () { abrirColeccion(coleccion); });
    const imagen = document.createElement("img");
    imagen.className = "ImagenTarjeta";
    imagen.src = coleccion.imagenes[0].src;
    tarjeta.appendChild(imagen);
    const nombre = document.createElement("p");
    nombre.className = "NombreColeccion";
    nombre.textContent = coleccion.nombre;
    tarjeta.appendChild(nombre);
    galeria.appendChild(tarjeta);
});


    function abrirColeccion(coleccion) {
    coleccionAbierta = coleccion;
    posicionImagen = 0;
    mostrarImagen();
    document.getElementById("detalleColeccion").classList.add("Visible");
}



       
        function mostrarImagen() {
    const imagen = coleccionAbierta.imagenes[posicionImagen];
    const vista = document.createElement(imagen.tipo.startsWith("video") ? "video" : "img");
    vista.src = imagen.src;
    vista.controls = imagen.tipo.startsWith("video");
    const contenedor = document.getElementById("imagenColeccionGrande");
    const info = document.getElementById("infoColeccion");
    contenedor.innerHTML = "";
    contenedor.appendChild(vista);
    info.innerHTML = "<h2>Nombre: " + coleccionAbierta.nombre + "</h2>";
    info.innerHTML += "<h3>Tags de la colección:</h3>";
    (coleccionAbierta.tags || []).forEach(function (tag) { info.innerHTML += "<span class=\"EtiquetaTag\">" + tag + "</span> "; });
    document.getElementById("imagenAnterior").style.display = posicionImagen > 0 ? "block" : "none";
    document.getElementById("imagenSiguiente").style.display = posicionImagen < coleccionAbierta.imagenes.length - 1 ? "block" : "none";
}

document.getElementById("imagenAnterior").addEventListener("click", function () { posicionImagen--; mostrarImagen(); });
document.getElementById("imagenSiguiente").addEventListener("click", function () { posicionImagen++; mostrarImagen(); });
document.getElementById("cerrarColeccion").addEventListener("click", function () { document.getElementById("detalleColeccion").classList.remove("Visible"); });
