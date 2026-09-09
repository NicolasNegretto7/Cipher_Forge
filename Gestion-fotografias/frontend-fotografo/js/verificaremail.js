(function () {
    const mensaje = document.getElementById("mensajeVerificar");
    const campoEmail = document.getElementById("correoVerificar");
    const campoCodigo = document.getElementById("codigoVerificar");
    const botonReenviar = document.getElementById("botonReenviar");

    function mostrarMensaje(texto, esError) {
        mensaje.textContent = texto;
        mensaje.className = esError ? "mensaje-perfil error" : "mensaje-perfil";
    }

    function limpiarPendiente() {
        localStorage.removeItem("email-verificacion-pendiente");
        localStorage.removeItem("codigo-verificacion-pendiente");
    }

    const parametros = new URLSearchParams(window.location.search);
    const email = parametros.get("email") || localStorage.getItem("email-verificacion-pendiente") || "";
    const codigo = parametros.get("codigo") || localStorage.getItem("codigo-verificacion-pendiente") || "";

    if (email) campoEmail.value = email;
    if (codigo) campoCodigo.value = codigo;

    document.getElementById("formVerificarEmail").addEventListener("submit", async function (evento) {
        evento.preventDefault();

        const correo = campoEmail.value.trim();
        const cod = campoCodigo.value.trim();

        if (!correo || !cod) {
            mostrarMensaje("Ingresa tu correo y el código de verificación.", true);
            return;
        }

        botonReenviar.disabled = true;
        mostrarMensaje("Verificando el código...", false);

        try {
            await api.verificarEmail(correo, cod);
            limpiarPendiente();
            mostrarMensaje("Correo verificado correctamente. Ya puedes iniciar sesión.", false);
            setTimeout(function () {
                window.location.href = "login.html";
            }, 1200);
        } catch (error) {
            mostrarMensaje(error.message, true);
            botonReenviar.disabled = false;
        }
    });

    botonReenviar.addEventListener("click", async function () {
        const correo = campoEmail.value.trim();

        if (!correo) {
            mostrarMensaje("Ingresa tu correo primero para poder reenviar el código.", true);
            return;
        }

        botonReenviar.disabled = true;
        mostrarMensaje("Reenviando código...", false);

        try {
            const resultado = await api.reenviarCodigo(correo);
            const nuevoCodigo = resultado.codigo_verificacion || "";
            if (nuevoCodigo) {
                campoCodigo.value = nuevoCodigo;
                localStorage.setItem("codigo-verificacion-pendiente", nuevoCodigo);
            }
            mostrarMensaje("Código reenviado a " + correo + ".", false);
        } catch (error) {
            mostrarMensaje(error.message, true);
        } finally {
            botonReenviar.disabled = false;
        }
    });
})();