import { obtenerDescarga } from "../../services/multimedia/multimediaService.js";

export async function descargarMultimedia(id, calidad) {
    const archivo = await obtenerDescarga(id, calidad);
    const url = URL.createObjectURL(archivo.blob);
    const enlace = document.createElement("a");
    enlace.href = url;
    enlace.download = archivo.nombre;
    document.body.appendChild(enlace);
    enlace.click();
    enlace.remove();
    setTimeout(function () {
        URL.revokeObjectURL(url);
    }, 4000);
}
