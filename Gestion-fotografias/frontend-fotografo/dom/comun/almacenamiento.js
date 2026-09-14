import { consultarCuota } from "../../services/fotografo/fotografoService.js";

export function formatearAlmacenamiento(bytes) {
    if (bytes >= 1024 ** 3) return (bytes / 1024 ** 3).toFixed(2) + " GB";
    if (bytes >= 1024 ** 2) return (bytes / 1024 ** 2).toFixed(1) + " MB";
    return Math.round(bytes / 1024) + " KB";
}

export async function actualizarAlmacenamiento() {
    const textos = document.querySelectorAll(".TextoAlmacenamiento");
    try {
        const cuota = await consultarCuota();
        for (const texto of textos) {
            texto.textContent =
                formatearAlmacenamiento(cuota.espacio_usado_bytes) +
                " de " +
                formatearAlmacenamiento(cuota.espacio_total_bytes) +
                " usados";
        }
    } catch (error) {
        for (const texto of textos) texto.textContent = "No se pudo consultar el espacio usado.";
    }
}
