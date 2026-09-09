(function () {
    var CLAVE_MIS_COLECCIONES = "mis-colecciones";
    var LOGIN_URL = "../../frontend-fotografo/index.html";

    var galeria = document.getElementById("galeriaColecciones");
    var sinColecciones = document.getElementById("sinColecciones");
    var mensajeCarga = document.getElementById("mensajeCarga");
    var mensajeError = document.getElementById("mensajeError");
    var zonaInvitacion = document.getElementById("zonaInvitacion");

    function misColecciones() {
        try {
            return JSON.parse(localStorage.getItem(CLAVE_MIS_COLECCIONES) || "[]");
        } catch (error) {
            return [];
        }
    }

    function guardarMisColecciones(lista) {
        localStorage.setItem(CLAVE_MIS_COLECCIONES, JSON.stringify(lista));
    }

    function agregarColeccionAcceso(idColeccion, titulo) {
        var lista = misColecciones();
        var existe = lista.some(function (item) { return item.id === idColeccion; });
        if (!existe) {
            lista.unshift({ id: idColeccion, titulo: titulo });
            guardarMisColecciones(lista);
        }
    }

    function mostrarError(texto) {
        if (mensajeCarga) mensajeCarga.hidden = true;
        if (mensajeError) {
            mensajeError.textContent = texto;
            mensajeError.hidden = false;
        }
    }

    function crearTarjeta(coleccion) {
        var tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaColeccion";

        var espacio = document.createElement("div");
        espacio.className = "CubiertaTarjeta";
        var calce = document.createElement("div");
        calce.className = "CubiertaVacia";
        calce.textContent = coleccion.titulo.charAt(0).toUpperCase();
        espacio.appendChild(calce);
        tarjeta.appendChild(espacio);

        var nombre = document.createElement("p");
        nombre.className = "NombreColeccion";
        nombre.textContent = coleccion.titulo;
        tarjeta.appendChild(nombre);

        var datos = document.createElement("p");
        datos.className = "DatosColeccion";
        datos.textContent = coleccion.tipo_visibilidad === "publica"
            ? "Colección pública de " + (coleccion.fotografo_nombre || "")
            : "Colección privada de " + (coleccion.fotografo_nombre || "");
        tarjeta.appendChild(datos);

        tarjeta.addEventListener("click", function () {
            window.location.href = "coleccion.html?id=" + coleccion.id;
        });

        return tarjeta;
    }

    function cargarMisColecciones() {
        if (mensajeCarga) mensajeCarga.hidden = false;
        var ids = misColecciones();
        if (ids.length === 0) {
            if (mensajeCarga) mensajeCarga.hidden = true;
            sinColecciones.hidden = false;
            return;
        }

        Promise.all(ids.map(function (item) {
            return window.api.detalleColeccion(item.id)
                .then(function (datos) { return datos; })
                .catch(function () { return null; });
        })).then(function (resultados) {
            galeria.innerHTML = "";
            if (mensajeCarga) mensajeCarga.hidden = true;

            var disponibles = resultados.filter(function (c) { return c !== null; });

            if (disponibles.length === 0) {
                sinColecciones.hidden = false;
                return;
            }

            sinColecciones.hidden = true;
            disponibles.forEach(function (coleccion) {
                galeria.appendChild(crearTarjeta(coleccion));
            });
        });
    }

    function accionesInvitacion(estado, tokenInvitacion) {
        var contenedor = document.getElementById("accionesInvitacion");
        contenedor.innerHTML = "";

        function boton(texto, clase, alHacerClick) {
            var b = document.createElement("button");
            b.type = "button";
            b.className = clase;
            b.textContent = texto;
            b.addEventListener("click", alHacerClick);
            return b;
        }

        if (!estado.autenticado) {
            var enlace = document.createElement("a");
            enlace.className = "BotonVerde";
            enlace.href = LOGIN_URL;
            enlace.textContent = "Iniciar sesión";
            contenedor.appendChild(enlace);
            return;
        }

        if (estado.tiene_acceso) {
            var ver = boton("Ver colección", "BotonVerde", function () {
                window.location.href = "coleccion.html?id=" + estado.coleccion_id;
            });
            contenedor.appendChild(ver);
            return;
        }

        var canjear = boton("Canjear acceso", "BotonVerde", function () {
            canjear.disabled = true;
            canjear.textContent = "Canjeando...";
            window.api.canjearInvitacion(tokenInvitacion)
                .then(function (resultado) {
                    var coleccion = (resultado && resultado.coleccion) || {};
                    agregarColeccionAcceso(Number(coleccion.id) || estado.coleccion_id, coleccion.titulo || estado.coleccion_titulo);
                    document.getElementById("estadoInvitacion").textContent = "Acceso concedido. Ya puedes ver esta colección.";
                    cargarMisColecciones();
                    contenedor.innerHTML = "";
                    var ver = boton("Ver colección", "BotonVerde", function () {
                        window.location.href = "coleccion.html?id=" + (coleccion.id || estado.coleccion_id);
                    });
                    contenedor.appendChild(ver);
                    window.utils.mostrarToast("Acceso concedido.", "Exito");
                })
                .catch(function (error) {
                    window.utils.mostrarToast(error.message || "No se pudo canjear la invitación.", "Error");
                    canjear.disabled = false;
                    canjear.textContent = "Canjear acceso";
                });
        });
        contenedor.appendChild(canjear);
    }

    function procesarInvitacion(tokenInvitacion) {
        window.api.validarInvitacion(tokenInvitacion)
            .then(function (estado) {
                zonaInvitacion.hidden = false;
                document.getElementById("tituloInvitacion").textContent = estado.coleccion_titulo || "Colección";

                var textoEstado;
                if (!estado.autenticado) {
                    textoEstado = "Recibiste una invitación para acceder a una colección. Inicia sesión para canjearla.";
                } else if (estado.tiene_acceso) {
                    textoEstado = "Ya tienes acceso a esta colección.";
                } else {
                    textoEstado = "Recibiste una invitación para acceder a esta colección.";
                }
                document.getElementById("estadoInvitacion").textContent = textoEstado;
                accionesInvitacion(estado, tokenInvitacion);
            })
            .catch(function (error) {
                zonaInvitacion.hidden = false;
                document.getElementById("tituloInvitacion").textContent = "Invitación";
                document.getElementById("estadoInvitacion").textContent = error.message || "El enlace de invitación es inválido.";
                document.getElementById("accionesInvitacion").innerHTML = "";
            });
    }

    function obtenerTokenInvitacion() {
        var parametros = new URLSearchParams(window.location.search);
        var desdeConsulta = parametros.get("invitacion") || parametros.get("token");
        if (desdeConsulta) return desdeConsulta;

        var coincidencia = window.location.pathname.match(/\/invitacion\/([a-f0-9]{20,})/i);
        if (coincidencia) return coincidencia[1];

        return null;
    }

    var tokenInvitacion = obtenerTokenInvitacion();
    if (tokenInvitacion) {
        procesarInvitacion(tokenInvitacion);
    }

    cargarMisColecciones();
})();