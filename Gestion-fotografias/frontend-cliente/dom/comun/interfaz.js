export function mostrarToast(texto, tipo) {
    let contenedor = document.getElementById("toasts");
    if (!contenedor) {
        alert(texto);
        return;
    }

    let toast = document.createElement("div");
    toast.className = "Toast " + (tipo || "Info");
    toast.textContent = texto;
    contenedor.appendChild(toast);

    setTimeout(function () {
        toast.remove();
    }, 3200);
}
