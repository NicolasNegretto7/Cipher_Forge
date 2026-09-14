import {
    generarQrAcceso,
    generarQrColaborativo,
} from "../../services/colaborativo/colaborativoService.js";

export function configurarQr(coleccionId) {
    document.getElementById("botonModerarColaborativo").href =
        "moderacion.html?coleccionId=" + coleccionId;
    configurarModal("Acceso", coleccionId);
    configurarModal("Colaborativo", coleccionId);
    document.getElementById("imprimirQrColaborativo").addEventListener("click", function () {
        window.print();
    });
}

function validarEnlace(valor) {
    const enlace = new URL(valor);
    const esHttp = enlace.protocol === "http:" || enlace.protocol === "https:";
    if (!esHttp) throw new Error("El servidor devolvió un enlace no válido.");
    return enlace.href;
}

function mostrarImagenQr(contenedor, svg) {
    const archivo = new Blob([String(svg)], { type: "image/svg+xml" });
    const urlTemporal = URL.createObjectURL(archivo);
    const imagen = document.createElement("img");
    imagen.alt = "Código QR";
    imagen.src = urlTemporal;
    imagen.addEventListener("load", function () {
        URL.revokeObjectURL(urlTemporal);
    });
    imagen.addEventListener("error", function () {
        URL.revokeObjectURL(urlTemporal);
    });
    contenedor.replaceChildren(imagen);
}

function configurarModal(tipo, coleccionId) {
    const boton = document.getElementById("botonQr" + tipo);
    const modal = document.getElementById("modalQr" + tipo);
    const imagen = document.getElementById("imagenQr" + tipo);
    const enlace = document.getElementById("enlaceQr" + tipo);
    const copiar = document.getElementById("copiarEnlace" + tipo);

    async function mostrarQr() {
        boton.disabled = true;
        try {
            let datos;
            if (tipo === "Acceso") {
                datos = await generarQrAcceso(coleccionId);
                document.getElementById("avisoQrAcceso").textContent =
                    "Enlace permanente para acceder a la colección. Se requiere iniciar sesión para canjearlo.";
            } else {
                datos = await generarQrColaborativo(coleccionId);
                const fecha = new Date(datos.expiracion.replace(" ", "T"));
                document.getElementById("avisoExpiracionQr").textContent =
                    "Los invitados pueden subir archivos hasta el " +
                    fecha.toLocaleString("es-UY") +
                    ".";
            }
            const urlAcceso = validarEnlace(datos.url_acceso);
            mostrarImagenQr(imagen, datos.svg_qr);
            enlace.value = urlAcceso;
            document.getElementById("abrirEnlace" + tipo).href = urlAcceso;
            copiar.textContent = "Copiar enlace";
            modal.hidden = false;
        } catch (error) {
            alert(error.message);
        } finally {
            boton.disabled = false;
        }
    }

    async function copiarEnlace() {
        try {
            await navigator.clipboard.writeText(enlace.value);
            copiar.textContent = "Enlace copiado";
        } catch (error) {
            enlace.select();
            alert("Selecciona y copia el enlace con Ctrl+C.");
        }
    }

    function cerrar() {
        modal.hidden = true;
    }
    boton.addEventListener("click", mostrarQr);
    copiar.addEventListener("click", copiarEnlace);
    document.getElementById("cerrarQr" + tipo).addEventListener("click", cerrar);
    modal.addEventListener("click", function (evento) {
        if (evento.target === modal) cerrar();
    });
    document.addEventListener("keydown", function (evento) {
        if (evento.key === "Escape") cerrar();
    });
}
