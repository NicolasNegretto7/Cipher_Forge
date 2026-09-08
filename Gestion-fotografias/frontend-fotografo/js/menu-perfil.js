(function () {
    function renderPerfil() {
        const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");
        const nombre = usuario.nombre_completo || "Fotógrafo";
        const email = usuario.email || "Sin correo";
        const inicial = nombre.charAt(0).toUpperCase();

        document.querySelectorAll(".CuentaPerfil").forEach(function (cuenta) {
            const nombreMenu = cuenta.querySelector(".NombreCuenta");
            const emailMenu = cuenta.querySelector(".EmailCuenta");
            const avatar = cuenta.querySelectorAll(".AvatarPerfil");

            nombreMenu.textContent = nombre;
            emailMenu.textContent = email;
            avatar.forEach(function (elemento) {
                elemento.textContent = inicial;
            });
        });
    }

    document.querySelectorAll(".CuentaPerfil").forEach(function (cuenta) {
        const boton = cuenta.querySelector(".BotonCuenta");
        const menu = cuenta.querySelector(".MenuCuenta");

        boton.addEventListener("click", function (evento) {
            evento.stopPropagation();
            const abierto = menu.hidden;
            menu.hidden = !abierto;
            boton.setAttribute("aria-expanded", String(abierto));
        });

        cuenta.querySelector(".CerrarSesion").addEventListener("click", function () {
            localStorage.removeItem("token");
            localStorage.removeItem("usuario");
            window.location.href = "login.html";
        });

        document.addEventListener("click", function () {
            menu.hidden = true;
            boton.setAttribute("aria-expanded", "false");
        });
    });

    renderPerfil();

    window.addEventListener("pageshow", function () {
        renderPerfil();
    });

    window.addEventListener("storage", function (evento) {
        if (evento.key === "usuario") {
            renderPerfil();
        }
    });
})();