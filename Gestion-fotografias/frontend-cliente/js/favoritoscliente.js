(function () {
    var galeria = document.getElementById("galeriaFavoritos");
    var sinFavoritos = document.getElementById("sinFavoritos");
    var mensajeCarga = document.getElementById("mensajeCarga");
    var mensajeError = document.getElementById("mensajeError");

    function mostrarError(texto) {
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (mensajeError) {
            mensajeError.textContent = texto;
            mensajeError.hidden = false;
        }
    }

    // CC-15: cada fila de /favoritos es una colección pública completa.
    function crearTarjeta(coleccionFavorita) {
        var tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";

        var envoltorio = document.createElement("div");
        envoltorio.className = "CubiertaTarjeta";

        var placeholder = document.createElement("div");
        placeholder.className = "CubiertaVacia";
        placeholder.textContent = (coleccionFavorita.titulo.charAt(0) || "?").toUpperCase();
        envoltorio.appendChild(placeholder);

        var idPortada = Number(coleccionFavorita.portada_id_multimedia);
        if (Number.isInteger(idPortada) && idPortada > 0) {
            var imagen = document.createElement("img");
            imagen.className = "ImagenTarjeta";
            imagen.src = window.api.urlVistaPrevia(idPortada);
            imagen.alt = coleccionFavorita.titulo;
            imagen.onerror = function () { imagen.remove(); };
            envoltorio.appendChild(imagen);
        }

        var quitar = document.createElement("button");
        quitar.type = "button";
        quitar.className = "FavoritoColeccion FavoritoActivo";
        quitar.textContent = "♥";
        quitar.title = "Quitar de favoritos";
        quitar.addEventListener("click", function (evento) {
            evento.stopPropagation();
            quitar.disabled = true;
            window.api.quitarFavorito(coleccionFavorita.id_coleccion)
                .then(function () {
                    window.utils.mostrarToast("Colección eliminada de favoritos.", "Exito");
                    tarjeta.remove();
                    if (galeria.children.length === 0) {
                        sinFavoritos.hidden = false;
                    }
                })
                .catch(function (error) {
                    window.utils.mostrarToast(error.message || "No se pudo quitar el favorito.", "Error");
                    quitar.disabled = false;
                });
        });
        envoltorio.appendChild(quitar);

        tarjeta.appendChild(envoltorio);

        var contenido = document.createElement("div");
        contenido.className = "DatosTarjetaFavorita";

        var nombre = document.createElement("p");
        nombre.className = "NombreColeccion";
        nombre.textContent = coleccionFavorita.titulo;
        contenido.appendChild(nombre);

        var origen = document.createElement("p");
        origen.className = "DatosColeccion";
        origen.textContent = coleccionFavorita.fotografo_nombre || "";
        contenido.appendChild(origen);

        var total = Number(coleccionFavorita.total_archivos) || 0;
        var totalTexto = document.createElement("p");
        totalTexto.className = "DatosColeccion";
        totalTexto.textContent = total + (total === 1 ? " archivo" : " archivos");
        totalTexto.style.margin = "0 15px 15px 15px";
        contenido.appendChild(totalTexto);

        tarjeta.appendChild(contenido);

        tarjeta.addEventListener("click", function () {
            window.location.href = "coleccion.html?id=" + coleccionFavorita.id_coleccion;
        });

        return tarjeta;
    }

    window.api.listarFavoritos()
        .then(function (favoritos) {
            if (mensajeCarga) mensajeCarga.hidden = true;
            var colecciones = favoritos || [];
            sinFavoritos.hidden = colecciones.length !== 0;
            colecciones.forEach(function (coleccionFavorita) {
                galeria.appendChild(crearTarjeta(coleccionFavorita));
            });
        })
        .catch(function (error) {
            mostrarError(error.message || "No se pudieron cargar tus favoritos.");
        });
})();