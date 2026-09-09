(function () {
    var LOGIN_URL = "../../frontend-fotografo/index.html";

    function obtenerToken() {
        return localStorage.getItem("token") || null;
    }

    function obtenerUsuario() {
        try {
            var usuario = JSON.parse(localStorage.getItem("usuario") || "null");
            return usuario;
        } catch (error) {
            return null;
        }
    }

    function haySesion() {
        return obtenerToken() !== null && obtenerUsuario() !== null;
    }

    function requiereSesion() {
        if (!haySesion()) {
            window.location.href = LOGIN_URL;
            return null;
        }
        return obtenerUsuario();
    }

    function cerrarSesion() {
        localStorage.removeItem("token");
        localStorage.removeItem("usuario");
        localStorage.removeItem("cuota-almacenamiento");
        window.location.href = LOGIN_URL;
    }

    document.addEventListener("click", function (evento) {
        var objetivo = evento.target.closest(".CerrarSesionCliente");
        if (objetivo) {
            evento.preventDefault();
            cerrarSesion();
        }
    });

    window.auth = {
        obtenerToken: obtenerToken,
        obtenerUsuario: obtenerUsuario,
        haySesion: haySesion,
        requiereSesion: requiereSesion,
        cerrarSesion: cerrarSesion
    };
})();