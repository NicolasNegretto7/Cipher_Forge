(function () {
    function mostrarToast(texto, tipo) {
        var contenedor = document.getElementById("toasts");
        if (!contenedor) {
            alert(texto);
            return;
        }

        var toast = document.createElement("div");
        toast.className = "Toast " + (tipo || "Info");
        toast.textContent = texto;
        contenedor.appendChild(toast);

        setTimeout(function () {
            toast.remove();
        }, 3200);
    }

    function formatearFecha(iso) {
        if (!iso) return "";
        try {
            return new Date(iso).toLocaleDateString("es-ES", {
                day: "numeric",
                month: "long",
                year: "numeric"
            });
        } catch (error) {
            return "";
        }
    }

    function escaparHtml(texto) {
        var div = document.createElement("div");
        div.textContent = texto ?? "";
        return div.innerHTML;
    }

    function mostrarCarga(elemento, ocultar) {
        if (!elemento) return;
        elemento.style.display = ocultar ? "none" : "block";
    }

    window.utils = {
        mostrarToast: mostrarToast,
        formatearFecha: formatearFecha,
        escaparHtml: escaparHtml,
        mostrarCarga: mostrarCarga
    };
})();