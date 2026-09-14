export function crearTarjetaColeccion(coleccion) {
    const tarjeta = document.createElement("article");
    tarjeta.className = "TarjetaColeccion";
    const enlace = document.createElement("a");
    enlace.className = "EnlaceColeccion";
    enlace.href = "coleccion.html?id=" + coleccion.id;

    const portada = document.createElement("div");
    portada.className = "CubiertaTarjeta";
    portada.textContent = (coleccion.titulo || "?").charAt(0).toUpperCase();
    enlace.appendChild(portada);
    const nombre = document.createElement("p");
    nombre.className = "NombreColeccion";
    nombre.textContent = coleccion.titulo;
    enlace.appendChild(nombre);
    const fotografo = document.createElement("p");
    fotografo.className = "DatosColeccion";
    fotografo.textContent = coleccion.fotografo_nombre || "";
    enlace.appendChild(fotografo);
    tarjeta.appendChild(enlace);
    return tarjeta;
}
