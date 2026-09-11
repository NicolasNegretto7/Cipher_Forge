(function () {
    var parametros = new URLSearchParams(window.location.search);
    var coleccionId = Number(parametros.get("id") || parametros.get("coleccion"));
    var coleccion = null;
    var archivos = [];
    var posicionVisor = 0;

    var galeria = document.getElementById("galeria");
    var estadoVacio = document.getElementById("estadoVacio");
    var mensajeCarga = document.getElementById("mensajeCarga");
    var mensajeError = document.getElementById("mensajeError");
    var tituloColeccion = document.getElementById("tituloColeccion");
    var infoColeccion = document.getElementById("infoColeccion");
    var visor = document.getElementById("visor");
    var visorContenido = document.getElementById("visorContenido");
    var accionesVisor = document.getElementById("accionesVisor");
    var favoritosIds = new Set();
    var objectUrlsVistas = [];

    function liberarObjectUrlsVistas() {
        objectUrlsVistas.forEach(function (url) {
            try { URL.revokeObjectURL(url); } catch (error) { }
        });
        objectUrlsVistas = [];
    }

    function mostrarError(texto) {
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (mensajeError) {
            mensajeError.textContent = texto;
            mensajeError.hidden = false;
        }
    }

    function esVideo(archivo) {
        return (archivo.tipo || "").toLowerCase() === "video";
    }

    function cargarFavoritos() {
        if (!window.api || !window.api.listarFavoritos) return Promise.resolve();
        return window.api.listarFavoritos()
            .then(function (favoritos) {
                (favoritos || []).forEach(function (favorito) {
                    favoritosIds.add(Number(favorito.id_coleccion));
                });
            })
            .catch(function () {});
    }

    // Marca o desmarca la colección pública completa como favorita (HU23 / RF21 / CC-15).
    function toggleFavoritoColeccion(idColeccion, boton) {
        if (!window.auth || !window.auth.haySesion()) {
            window.utils.mostrarToast("Inicia sesión para guardar favoritos.", "Info");
            return;
        }
        boton.disabled = true;
        var agregar = !boton.classList.contains("FavoritoActivo");
        var accion = agregar
            ? window.api.agregarFavorito(idColeccion)
            : window.api.quitarFavorito(idColeccion);
        accion
            .then(function () {
                boton.classList.toggle("FavoritoActivo", agregar);
                boton.textContent = agregar ? "♥" : "♡";
                boton.title = agregar ? "Quitar de favoritos" : "Guardar en favoritos";
                if (agregar) {
                    favoritosIds.add(idColeccion);
                } else {
                    favoritosIds.delete(idColeccion);
                }
                window.utils.mostrarToast(agregar ? "Añadido a favoritos." : "Eliminado de favoritos.", "Exito");
            })
            .catch(function (error) {
                window.utils.mostrarToast(error.message || "No se pudo actualizar el favorito.", "Error");
            })
            .finally(function () { boton.disabled = false; });
    }

    function cerrarMenus() {
        var menus = document.querySelectorAll(".MenuDescarga.Abierto");
        menus.forEach(function (menu) { menu.classList.remove("Abierto"); });
    }

    function descargar(idMultimedia, calidad) {
        var etiqueta = calidad === "alta" ? "Alta Calidad (original)" : "Buena Calidad (estándar)";
        window.api.descargarMultimedia(idMultimedia, calidad)
            .then(function () {
                window.utils.mostrarToast("Descarga iniciada: " + etiqueta + ".", "Exito");
            })
            .catch(function (error) {
                window.utils.mostrarToast(error.message || "No se pudo descargar el archivo.", "Error");
            });
    }

    function crearZonaDescarga(idMultimedia) {
        var contenedor = document.createElement("div");
        contenedor.className = "ZonaDescarga";

        var boton = document.createElement("button");
        boton.type = "button";
        boton.className = "BotonDescargar";
        boton.textContent = "Descargar";
        boton.addEventListener("click", function (evento) {
            evento.stopPropagation();
            cerrarMenus();
            contenedor.querySelector(".MenuDescarga").classList.toggle("Abierto");
        });
        contenedor.appendChild(boton);

        var menu = document.createElement("div");
        menu.className = "MenuDescarga";

        var buena = document.createElement("button");
        buena.type = "button";
        buena.className = "OpcionDescarga";
        buena.textContent = "Buena Calidad (estándar)";
        buena.addEventListener("click", function () { cerrarMenus(); descargar(idMultimedia, "buena"); });
        menu.appendChild(buena);

        var alta = document.createElement("button");
        alta.type = "button";
        alta.className = "OpcionDescarga";
        alta.textContent = "Alta Calidad (original)";
        alta.addEventListener("click", function () { cerrarMenus(); descargar(idMultimedia, "alta"); });
        menu.appendChild(alta);

        contenedor.appendChild(menu);
        return contenedor;
    }

    function crearVista(archivo) {
        var vista = document.createElement(esVideo(archivo) ? "video" : "img");
        vista.className = "VistaMiniatura";
        if (esVideo(archivo)) {
            vista.controls = false;
            vista.muted = true;
        }
        if (window.api && window.api.obtenerVistaPrevia) {
            window.api.obtenerVistaPrevia(archivo.id_multimedia)
                .then(function (url) {
                    objectUrlsVistas.push(url);
                    vista.src = url;
                })
                .catch(function () { });
        } else {
            vista.src = window.api.urlVistaPrevia(archivo.id_multimedia);
        }
        return vista;
    }

    function abrirVisor(indice) {
        if (!archivos.length) return;
        posicionVisor = indice;
        visorContenido.innerHTML = "";
        accionesVisor.innerHTML = "";
        var archivo = archivos[posicionVisor];
        var elemento = crearVista(archivo);
        elemento.className = "";
        if (esVideo(archivo)) {
            elemento.controls = true;
            elemento.muted = false;
        }
        visorContenido.appendChild(elemento);
        var zona = crearZonaDescarga(archivo.id_multimedia);
        accionesVisor.appendChild(zona);
        actualizarFlechasVisor();
        visor.classList.add("Abierto");
    }

    function actualizarFlechasVisor() {
        var anterior = document.getElementById("anteriorVisor");
        var siguiente = document.getElementById("siguienteVisor");
        anterior.style.display = posicionVisor > 0 ? "block" : "none";
        siguiente.style.display = posicionVisor < archivos.length - 1 ? "block" : "none";
    }

    function crearTarjeta(archivo, indice) {
        var tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaMedia";

        var vista = crearVista(archivo);
        vista.addEventListener("click", function () { abrirVisor(indice); });
        tarjeta.appendChild(vista);

        var datos = document.createElement("div");
        datos.className = "DatosImagenTarjeta";
        if (archivo.descripcion) {
            var descripcion = document.createElement("p");
            descripcion.className = "DescripcionImagen";
            descripcion.textContent = archivo.descripcion;
            datos.appendChild(descripcion);
        }
        if (coleccion.hashtags && coleccion.hashtags.length > 0) {
            var contenedor = document.createElement("div");
            contenedor.className = "ListaTagsColeccion";
            coleccion.hashtags.forEach(function (tag) {
                var chip = document.createElement("span");
                chip.className = "ChipTag";
                chip.textContent = "#" + tag;
                contenedor.appendChild(chip);
            });
            datos.appendChild(contenedor);
        }
        tarjeta.appendChild(datos);

        tarjeta.appendChild(crearZonaDescarga(archivo.id_multimedia));

        return tarjeta;
    }

    function mostrarGaleria() {
        liberarObjectUrlsVistas();
        galeria.innerHTML = "";
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (estadoVacio) estadoVacio.hidden = archivos.length !== 0;

        archivos.forEach(function (archivo, indice) {
            galeria.appendChild(crearTarjeta(archivo, indice));
        });
    }

    function pintarInfo() {
        tituloColeccion.textContent = coleccion.titulo;

        var partes = [];
        if (coleccion.fotografo_nombre) partes.push("Fotógrafo: " + coleccion.fotografo_nombre);
        if (coleccion.descripcion) partes.push(coleccion.descripcion);
        partes.push(coleccion.tipo_visibilidad === "publica" ? "Colección pública" : "Colección privada");

        infoColeccion.innerHTML = partes.map(function (p) {
            return "<p>" + window.utils.escaparHtml(p) + "</p>";
        }).join("");

        if (coleccion.hashtags && coleccion.hashtags.length > 0) {
            var contenedor = document.createElement("div");
            contenedor.className = "ListaTagsColeccion";
            coleccion.hashtags.forEach(function (tag) {
                var chip = document.createElement("span");
                chip.className = "ChipTag";
                chip.textContent = "#" + tag;
                contenedor.appendChild(chip);
            });
            infoColeccion.appendChild(contenedor);
        }

        // Solo las colecciones públicas se pueden marcar como favoritas (CC-15)
        if (coleccion.tipo_visibilidad === "publica") {
            var esFavorito = favoritosIds.has(coleccion.id);
            var botonFavorito = document.createElement("button");
            botonFavorito.type = "button";
            botonFavorito.className = "FavoritoColeccion" + (esFavorito ? " FavoritoActivo" : "");
            botonFavorito.textContent = esFavorito ? "♥" : "♡";
            botonFavorito.title = esFavorito ? "Quitar de favoritos" : "Guardar en favoritos";
            botonFavorito.addEventListener("click", function (evento) {
                evento.stopPropagation();
                toggleFavoritoColeccion(coleccion.id, botonFavorito);
            });
            infoColeccion.appendChild(botonFavorito);
        }
    }

    if (!Number.isInteger(coleccionId) || coleccionId <= 0) {
        mostrarError("Colección no válida.");
    } else {
        cargarFavoritos().then(function () {
            return window.api.detalleColeccion(coleccionId)
                .then(function (datos) {
                    coleccion = datos;
                    pintarInfo();
                    return window.api.listarMultimedia(coleccionId);
                })
                .then(function (datos) {
                    archivos = datos || [];
                    mostrarGaleria();
                })
                .catch(function (error) {
                    mostrarError(error.status === 403
                        ? "No tienes permiso para ver esta colección privada."
                        : (error.message || "No se pudo cargar la colección."));
                });
        });
    }

    document.getElementById("cerrarVisor").addEventListener("click", function () {
        visor.classList.remove("Abierto");
        visorContenido.innerHTML = "";
        accionesVisor.innerHTML = "";
    });

    visor.addEventListener("click", function (evento) {
        if (evento.target === visor) {
            document.getElementById("cerrarVisor").click();
        }
    });

    document.getElementById("anteriorVisor").addEventListener("click", function () {
        if (posicionVisor > 0) abrirVisor(posicionVisor - 1);
    });

    document.getElementById("siguienteVisor").addEventListener("click", function () {
        if (posicionVisor < archivos.length - 1) abrirVisor(posicionVisor + 1);
    });

    document.addEventListener("click", function (evento) {
        if (!evento.target.closest || !evento.target.closest(".ZonaDescarga")) {
            cerrarMenus();
        }
    });

    document.addEventListener("keydown", function (evento) {
        if (evento.key === "Escape") {
            cerrarMenus();
            if (visor.classList.contains("Abierto")) {
                document.getElementById("cerrarVisor").click();
            }
        } else if (visor.classList.contains("Abierto") && evento.key === "ArrowLeft" && posicionVisor > 0) {
            abrirVisor(posicionVisor - 1);
        } else if (visor.classList.contains("Abierto") && evento.key === "ArrowRight" && posicionVisor < archivos.length - 1) {
            abrirVisor(posicionVisor + 1);
        }
    });
})();