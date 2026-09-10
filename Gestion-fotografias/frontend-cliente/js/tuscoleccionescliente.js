(function () {
    var CLAVE_MIS_COLECCIONES = "mis-colecciones";
    var CLAVE_INVITACIONES_PENDIENTES = "invitaciones-pendientes";
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

    function invitacionesPendientes() {
        try {
            return JSON.parse(localStorage.getItem(CLAVE_INVITACIONES_PENDIENTES) || "[]");
        } catch (error) {
            return [];
        }
    }

    function guardarInvitacionesPendientes(lista) {
        localStorage.setItem(CLAVE_INVITACIONES_PENDIENTES, JSON.stringify(lista));
    }

    function guardarInvitacionPendiente(tokenInvitacion) {
        var lista = invitacionesPendientes();
        if (lista.indexOf(tokenInvitacion) === -1) {
            lista.push(tokenInvitacion);
            guardarInvitacionesPendientes(lista);
        }
    }

    function quitarInvitacionPendiente(tokenInvitacion) {
        var lista = invitacionesPendientes().filter(function (t) { return t !== tokenInvitacion; });
        guardarInvitacionesPendientes(lista);
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

    function boton(texto, clase, alHacerClick) {
        var b = document.createElement("button");
        b.type = "button";
        b.className = clase;
        b.textContent = texto;
        b.addEventListener("click", alHacerClick);
        return b;
    }

    function ejecutarCanje(estado, tokenInvitacion, contenedor, botonCanjear) {
        if (botonCanjear) {
            botonCanjear.disabled = true;
            botonCanjear.textContent = "Canjeando...";
        }

        window.api.canjearInvitacion(tokenInvitacion)
            .then(function (resultado) {
                var coleccion = (resultado && resultado.coleccion) || {};
                agregarColeccionAcceso(Number(coleccion.id) || estado.coleccion_id, coleccion.titulo || estado.coleccion_titulo);
                quitarInvitacionPendiente(tokenInvitacion);
                document.getElementById("estadoInvitacion").textContent = "Acceso concedido. Ya puedes ver esta colección.";
                contenedor.innerHTML = "";
                var ver = boton("Ver colección", "BotonVerde", function () {
                    window.location.href = "coleccion.html?id=" + (coleccion.id || estado.coleccion_id);
                });
                contenedor.appendChild(ver);
                cargarMisColecciones();
                window.utils.mostrarToast("Acceso concedido.", "Exito");
            })
            .catch(function (error) {
                window.utils.mostrarToast(error.message || "No se pudo canjear la invitación.", "Error");
                if (botonCanjear) {
                    botonCanjear.disabled = false;
                    botonCanjear.textContent = "Canjear acceso";
                } else {
                    contenedor.innerHTML = "";
                    var reintentar = boton("Canjear acceso", "BotonVerde", function () {
                        ejecutarCanje(estado, tokenInvitacion, contenedor, reintentar);
                    });
                    contenedor.appendChild(reintentar);
                }
            });
    }

    function accionesInvitacion(estado, tokenInvitacion) {
        var contenedor = document.getElementById("accionesInvitacion");
        contenedor.innerHTML = "";

        if (!estado.autenticado) {
            var enlace = document.createElement("a");
            enlace.className = "BotonVerde";
            enlace.href = LOGIN_URL;
            enlace.textContent = "Iniciar sesión";
            contenedor.appendChild(enlace);
            return;
        }

        if (estado.tiene_acceso) {
            agregarColeccionAcceso(Number(estado.coleccion_id) || estado.coleccion_id, estado.coleccion_titulo);
            quitarInvitacionPendiente(tokenInvitacion);
            cargarMisColecciones();
            var ver = boton("Ver colección", "BotonVerde", function () {
                window.location.href = "coleccion.html?id=" + estado.coleccion_id;
            });
            contenedor.appendChild(ver);
            return;
        }

        var procesando = boton("Canjeando acceso...", "BotonVerde", function () {});
        procesando.disabled = true;
        contenedor.appendChild(procesando);
        ejecutarCanje(estado, tokenInvitacion, contenedor, null);
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

    function reconciliarInvitacionesPendientes() {
        var pendientes = invitacionesPendientes().filter(function (t) { return t !== tokenInvitacion; });
        if (pendientes.length === 0) return;

        Promise.all(pendientes.map(function (token) {
            return window.api.validarInvitacion(token)
                .then(function (estado) {
                    if (estado.tiene_acceso) {
                        agregarColeccionAcceso(Number(estado.coleccion_id) || estado.coleccion_id, estado.coleccion_titulo);
                        quitarInvitacionPendiente(token);
                        return;
                    }
                    return window.api.canjearInvitacion(token)
                        .then(function (resultado) {
                            var coleccion = (resultado && resultado.coleccion) || {};
                            agregarColeccionAcceso(Number(coleccion.id) || estado.coleccion_id, coleccion.titulo || estado.coleccion_titulo);
                            quitarInvitacionPendiente(token);
                        });
                })
                .catch(function () { return; });
        })).then(function () {
            cargarMisColecciones();
        });
    }

    var tokenInvitacion = obtenerTokenInvitacion();
    if (tokenInvitacion) {
        guardarInvitacionPendiente(tokenInvitacion);
        procesarInvitacion(tokenInvitacion);
    } else if (window.auth && window.auth.haySesion()) {
        reconciliarInvitacionesPendientes();
    }

    cargarMisColecciones();
})();