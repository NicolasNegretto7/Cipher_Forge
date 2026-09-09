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

    function agruparPorColeccion(favoritos) {
        var grupos = new Map();
        (favoritos || []).forEach(function (favorito) {
            if (!grupos.has(favorito.coleccion_id)) {
                grupos.set(favorito.coleccion_id, []);
            }
            grupos.get(favorito.coleccion_id).push(favorito);
        });
        var resultado = [];
        grupos.forEach(function (items, coleccionId) {
            items.sort(function (a, b) { return (b.vista_previa || "").localeCompare(a.vista_previa || ""); });
            resultado.push({
                coleccion_id: coleccionId,
                titulo: items[0].coleccion_titulo || items[0].titulo || "Colección",
                fotografo_nombre: items[0].fotografo_nombre || "",
                portada: items[0],
                ids_media: items.map(function (item) { return item.id_multimedia; })
            });
        });
        return resultado;
    }

    function crearTarjeta(coleccionFavorita) {
        var tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";

        var envoltorio = document.createElement("div");
        envoltorio.className = "CubiertaTarjeta";

        var placeholder = document.createElement("div");
        placeholder.className = "CubiertaVacia";
        placeholder.textContent = (coleccionFavorita.titulo.charAt(0) || "?").toUpperCase();
        envoltorio.appendChild(placeholder);

        var imagen = document.createElement("img");
        imagen.className = "ImagenTarjeta";
        imagen.src = window.api.urlVistaPrevia(coleccionFavorita.portada.id_multimedia);
        imagen.alt = coleccionFavorita.titulo;
        imagen.onerror = function () { imagen.remove(); };
        envoltorio.appendChild(imagen);

        var quitar = document.createElement("button");
        quitar.type = "button";
        quitar.className = "FavoritoColeccion FavoritoActivo";
        quitar.textContent = "♥";
        quitar.title = "Quitar de favoritos";
        quitar.addEventListener("click", function (evento) {
            evento.stopPropagation();
            quitar.disabled = true;
            var pendientes = coleccionFavorita.ids_media.map(function (id) {
                return window.api.quitarFavorito(id);
            });
            Promise.all(pendientes)
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

        var total = document.createElement("p");
        total.className = "DatosColeccion";
        total.textContent = coleccionFavorita.ids_media.length + (coleccionFavorita.ids_media.length === 1 ? " archivo" : " archivos");
        total.style.margin = "0 15px 15px 15px";
        contenido.appendChild(total);

        tarjeta.appendChild(contenido);

        tarjeta.addEventListener("click", function () {
            window.location.href = "coleccion.html?id=" + coleccionFavorita.coleccion_id;
        });

        return tarjeta;
    }

    window.api.listarFavoritos()
        .then(function (favoritos) {
            if (mensajeCarga) mensajeCarga.hidden = true;
            var colecciones = agruparPorColeccion(favoritos);
            sinFavoritos.hidden = colecciones.length !== 0;
            colecciones.forEach(function (coleccionFavorita) {
                galeria.appendChild(crearTarjeta(coleccionFavorita));
            });
        })
        .catch(function (error) {
            mostrarError(error.message || "No se pudieron cargar tus favoritos.");
        });
})();