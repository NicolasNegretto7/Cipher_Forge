/* ==========================================================================
   CipherPhotos · Landing Page
   Modal de selección de rol: abre desde "Registrarse" e "Iniciar sesión" y
   lleva a la página del rol elegido (fotógrafo o cliente).
   ========================================================================== */

(function () {
    "use strict";

    var RUTAS = {
        fotografo: {
            login: "../frontend-fotografo/pages/login.html",
            registro: "../frontend-fotografo/pages/registro.html",
        },
        cliente: {
            login: "../frontend-cliente/pages/login.html",
            registro: "../frontend-cliente/pages/registro.html",
        },
    };

    var ETIQUETAS = {
        login: "Iniciar sesión",
        registro: "Registrarse",
    };

    var modal = document.getElementById("modalRol");
    if (!modal) return;

    var etiqueta = document.getElementById("modalRolEtiqueta");
    var botonCerrar = document.getElementById("cerrarModalRol");
    var disparadores = document.querySelectorAll("[data-destino]");
    var opciones = modal.querySelectorAll(".RolOpcion");

    var destino = "login";
    var ultimoFoco = null;
    var paddingPrevio = null;

    // Al bloquear el scroll desaparece la barra de desplazamiento y el fondo
    // saltaría ~15 px a los lados. Reservamos ese ancho para que no se mueva.
    function bloquearFondo() {
        var anchoBarra = window.innerWidth - document.documentElement.clientWidth;
        paddingPrevio = document.body.style.paddingRight;
        if (anchoBarra > 0) {
            var actual = parseFloat(window.getComputedStyle(document.body).paddingRight) || 0;
            document.body.style.paddingRight = actual + anchoBarra + "px";
        }
        document.body.classList.add("ModalAbierto");
    }

    function liberarFondo() {
        document.body.classList.remove("ModalAbierto");
        if (paddingPrevio !== null) {
            document.body.style.paddingRight = paddingPrevio;
            paddingPrevio = null;
        }
    }

    function abrir(origen) {
        destino = origen.dataset.destino === "registro" ? "registro" : "login";
        if (etiqueta) etiqueta.textContent = ETIQUETAS[destino];
        ultimoFoco = origen;
        bloquearFondo();
        modal.hidden = false;
        var primera = modal.querySelector(".RolOpcion");
        if (primera) primera.focus({ preventScroll: true });
    }

    function cerrar() {
        if (modal.hidden) return;
        modal.hidden = true;
        liberarFondo();
        if (ultimoFoco) ultimoFoco.focus({ preventScroll: true });
    }

    function enfocarSiguiente(evento) {
        var enfocables = modal.querySelectorAll(
            "button, [href], input, select, textarea, [tabindex]:not([tabindex='-1'])",
        );
        if (!enfocables.length) return;
        var primero = enfocables[0];
        var ultimo = enfocables[enfocables.length - 1];
        if (evento.shiftKey && document.activeElement === primero) {
            evento.preventDefault();
            ultimo.focus();
        } else if (!evento.shiftKey && document.activeElement === ultimo) {
            evento.preventDefault();
            primero.focus();
        }
    }

    Array.prototype.forEach.call(disparadores, function (boton) {
        boton.addEventListener("click", function () {
            abrir(boton);
        });
    });

    if (botonCerrar) botonCerrar.addEventListener("click", cerrar);

    modal.addEventListener("click", function (evento) {
        if (evento.target === modal) cerrar();
    });

    Array.prototype.forEach.call(opciones, function (opcion) {
        opcion.addEventListener("click", function () {
            var rutasRol = RUTAS[opcion.dataset.rol];
            if (rutasRol && rutasRol[destino]) {
                window.location.href = rutasRol[destino];
            }
        });
    });

    document.addEventListener("keydown", function (evento) {
        if (modal.hidden) return;
        if (evento.key === "Escape" || evento.key === "Esc") {
            evento.preventDefault();
            cerrar();
            return;
        }
        if (evento.key === "Tab") enfocarSiguiente(evento);
    });
})();
