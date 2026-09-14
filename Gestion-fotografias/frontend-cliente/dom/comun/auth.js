import { cerrarSesion } from "./sesion.js";

document.addEventListener("click", function (evento) {
    if (evento.target.closest(".CerrarSesionCliente")) {
        evento.preventDefault();
        cerrarSesion();
    }
});
