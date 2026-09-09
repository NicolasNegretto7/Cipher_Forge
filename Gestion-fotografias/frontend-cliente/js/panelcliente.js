(function () {
    var galeria = document.getElementById("galeriaPublica");
    var estadoVacio = document.getElementById("estadoVacio");
    var mensajeCarga = document.getElementById("mensajeCarga");
    var mensajeError = document.getElementById("mensajeError");
    var tagBusqueda = document.getElementById("tagBusqueda");
    var zonaBuscadorTags = document.getElementById("zonaBuscadorTags");
    var listaTagsBusqueda = document.getElementById("tagsBusqueda");
    var sugerenciasHashtags = document.getElementById("sugerenciasHashtags");
    var todasLasColecciones = [];
    var tagsSeleccionados = [];
    var favoritosIds = new Set();

    function cargarFavoritosExistentes() {
        if (!window.api || !window.api.listarFavoritos) return Promise.resolve();
        return window.api.listarFavoritos()
            .then(function (favoritos) {
                (favoritos || []).forEach(function (favorito) {
                    favoritosIds.add(favorito.id_multimedia);
                });
            })
            .catch(function () {});
    }

    function normalizarTag(valor) {
        return String(valor || "").trim().toLowerCase().replace(/^#/, "");
    }

    function mostrarError(texto) {
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (mensajeError) {
            mensajeError.textContent = texto;
            mensajeError.hidden = false;
        }
    }

    function limpiarError() {
        if (mensajeError) mensajeError.hidden = true;
    }

    function primeraImagen(coleccion) {
        return new Promise(function (resolver) {
            if (!window.api || !window.api.listarMultimedia) return resolver(null);
            window.api.listarMultimedia(coleccion.id)
                .then(function (archivos) {
                    var aprobados = (archivos || []).filter(function (a) { return a.aprobado === 1 || a.aprobado === true || a.aprobado === null; });
                    var primero = aprobados[0] || (archivos || [])[0];
                    if (primero && (primero.tipo || "").toLowerCase() === "video") return resolver(null);
                    resolver(primero ? primero.id_multimedia || primero.id : null);
                })
                .catch(function () { resolver(null); });
        });
    }

    function toggleFavorito(idMultimedia, boton) {
        if (!window.auth || !window.auth.haySesion()) {
            window.utils.mostrarToast("Inicia sesión para guardar favoritos.", "Info");
            return;
        }
        boton.disabled = true;
        var agregar = !boton.classList.contains("FavoritoActivo");
        var accion = agregar ? window.api.agregarFavorito(idMultimedia) : window.api.quitarFavorito(idMultimedia);
        accion
            .then(function () {
                boton.classList.toggle("FavoritoActivo", agregar);
                boton.textContent = agregar ? "♥" : "♡";
                boton.title = agregar ? "Quitar de favoritos" : "Guardar en favoritos";
                if (agregar) {
                    favoritosIds.add(idMultimedia);
                } else {
                    favoritosIds.delete(idMultimedia);
                }
                window.utils.mostrarToast(agregar ? "Añadido a favoritos." : "Eliminado de favoritos.", "Exito");
            })
            .catch(function (error) {
                window.utils.mostrarToast(error.message || "No se pudo actualizar el favorito.", "Error");
            })
            .finally(function () { boton.disabled = false; });
    }

    function crearTarjeta(coleccion) {
        var tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";

        var envoltorio = document.createElement("div");
        envoltorio.className = "CubiertaTarjeta";

        var placeholder = document.createElement("div");
        placeholder.className = "CubiertaVacia";
        placeholder.textContent = coleccion.titulo.charAt(0).toUpperCase();
        envoltorio.appendChild(placeholder);

        var idMedia = null;
        var botonFavorito = document.createElement("button");
        botonFavorito.type = "button";
        botonFavorito.className = "FavoritoColeccion";
        botonFavorito.textContent = "♡";
        botonFavorito.title = "Guardar en favoritos";
        botonFavorito.addEventListener("click", function (evento) {
            evento.stopPropagation();
            if (!idMedia) {
                window.utils.mostrarToast("Esta colección aún no tiene imágenes.", "Info");
                return;
            }
            if (!window.auth || !window.auth.haySesion()) {
                window.utils.mostrarToast("Inicia sesión para guardar favoritos.", "Info");
                return;
            }
            toggleFavorito(idMedia, botonFavorito);
        });
        envoltorio.appendChild(botonFavorito);

        primeraImagen(coleccion).then(function (idArchivo) {
            idMedia = idArchivo;
            if (!idArchivo) {
                botonFavorito.classList.add("Desactivado");
                return;
            }
            var imagen = document.createElement("img");
            imagen.className = "ImagenTarjeta";
            imagen.src = window.api.urlVistaPrevia(idArchivo);
            imagen.alt = coleccion.titulo;
            imagen.onerror = function () {
                tarjeta.remove();
                if (galeria.children.length === 0 && estadoVacio) {
                    estadoVacio.hidden = false;
                }
            };
            envoltorio.replaceChildren(imagen, botonFavorito);
            if (favoritosIds.has(idArchivo)) {
                botonFavorito.classList.add("FavoritoActivo");
                botonFavorito.textContent = "♥";
                botonFavorito.title = "Quitar de favoritos";
            }
        });

        tarjeta.appendChild(envoltorio);

        var nombre = document.createElement("p");
        nombre.className = "NombreColeccion";
        nombre.textContent = coleccion.titulo;
        tarjeta.appendChild(nombre);

        var datos = document.createElement("p");
        datos.className = "DatosColeccion";
        datos.textContent = coleccion.fotografo_nombre || "";
        tarjeta.appendChild(datos);

        if (coleccion.hashtags && coleccion.hashtags.length > 0) {
            var tags = document.createElement("div");
            tags.className = "ListaTagsColeccion";
            coleccion.hashtags.forEach(function (tag) {
                var chip = document.createElement("span");
                chip.className = "ChipTag";
                chip.textContent = "#" + tag;
                chip.addEventListener("click", function (evento) {
                    evento.stopPropagation();
                    agregarTag(tag);
                });
                tags.appendChild(chip);
            });
            tarjeta.appendChild(tags);
        }

        tarjeta.addEventListener("click", function () {
            window.location.href = "coleccion.html?id=" + coleccion.id;
        });

        return tarjeta;
    }

    function cumpleFiltro(coleccion) {
        if (tagsSeleccionados.length === 0) return true;
        var tagsColeccion = (coleccion.hashtags || []).map(normalizarTag);
        return tagsSeleccionados.every(function (tag) {
            return tagsColeccion.includes(tag);
        });
    }

    function filtrarYMostrar() {
        var lista = todasLasColecciones.slice().sort(function (a, b) {
            var aCoincide = cumpleFiltro(a) ? 1 : 0;
            var bCoincide = cumpleFiltro(b) ? 1 : 0;
            return bCoincide - aCoincide;
        });
        galeria.innerHTML = "";
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (estadoVacio) estadoVacio.hidden = lista.length !== 0;
        lista.forEach(function (coleccion) {
            galeria.appendChild(crearTarjeta(coleccion));
        });
    }

    function pintarTagsSeleccionados() {
        listaTagsBusqueda.innerHTML = "";
        if (tagsSeleccionados.length === 0) return;
        tagsSeleccionados.forEach(function (tag) {
            var chip = document.createElement("button");
            chip.type = "button";
            chip.className = "EtiquetaTag";
            chip.textContent = "#" + tag + " ×";
            chip.addEventListener("click", function () {
                quitarTag(tag);
            });
            listaTagsBusqueda.appendChild(chip);
        });
    }

    function agregarTag(valor) {
        var tag = normalizarTag(valor);
        if (!tag) return;
        if (!tagsSeleccionados.includes(tag)) {
            tagsSeleccionados.push(tag);
        }
        tagBusqueda.value = "";
        pintarTagsSeleccionados();
        filtrarYMostrar();
    }

    function quitarTag(tag) {
        tagsSeleccionados = tagsSeleccionados.filter(function (t) { return t !== tag; });
        pintarTagsSeleccionados();
        filtrarYMostrar();
    }

    function cargarColecciones() {
        limpiarError();
        if (mensajeCarga) {
            mensajeCarga.textContent = "Cargando colecciones...";
            mensajeCarga.hidden = false;
        }

        window.api.listarColeccionesPublicas()
            .then(function (colecciones) {
                todasLasColecciones = (colecciones || []).filter(function (coleccion) {
                    return Number(coleccion.total_archivos) > 0;
                });
                filtrarYMostrar();
            })
            .catch(function (error) {
                mostrarError(error.message || "No se pudieron cargar las colecciones.");
            });
    }

    function cargarSugerencias() {
        if (!window.api || !window.api.listarHashtags || !sugerenciasHashtags) return;
        window.api.listarHashtags()
            .then(function (hashtags) {
                (hashtags || []).forEach(function (h) {
                    var opcion = document.createElement("option");
                    opcion.value = "#" + h.nombre_hashtags;
                    sugerenciasHashtags.appendChild(opcion);
                });
            })
            .catch(function () {});
    }

    tagBusqueda.addEventListener("focus", function () {
        zonaBuscadorTags.classList.add("Abierto");
    });

    tagBusqueda.addEventListener("blur", function () {
        setTimeout(function () { zonaBuscadorTags.classList.remove("Abierto"); }, 150);
    });

    tagBusqueda.addEventListener("keydown", function (evento) {
        if (evento.key === "Enter") {
            evento.preventDefault();
            agregarTag(tagBusqueda.value);
        }
    });

    var parametros = new URLSearchParams(window.location.search);
    if (parametros.has("hashtag")) {
        agregarTag(parametros.get("hashtag"));
    }

    cargarFavoritosExistentes().then(function () {
        cargarSugerencias();
        cargarColecciones();
    });
})();