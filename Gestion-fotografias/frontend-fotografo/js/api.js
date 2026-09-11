// Capa central de endpoints del Frontend para Cipher Forge.
// Cada función representa un endpoint del backend (ver backend/routes.php) y devuelve json.datos.
// Exponer el objeto global `window.api`. Si tu backend corre en otra URL, define window.__CIPHER_API_URL antes de cargar este archivo.
(function () {
    const API_URL = (function () {
        if (typeof window.__CIPHER_API_URL === "string" && window.__CIPHER_API_URL.trim() !== "") {
            return window.__CIPHER_API_URL;
        }
        return "http://localhost:8080";
    })();

    function tokenSesion() {
        return localStorage.getItem("token") || null;
    }

    function cabeceras(conCuerpo) {
        const cab = {};
        if (conCuerpo) cab["Content-Type"] = "application/json";
        const t = tokenSesion();
        if (t) cab["Authorization"] = "Bearer " + t;
        return cab;
    }

    async function parsear(respuesta) {
        const json = await respuesta.json();
        if (!respuesta.ok) {
            const error = new Error(json.mensaje || "Error inesperado en la solicitud.");
            error.status = respuesta.status;
            error.errores = Array.isArray(json.errores) ? json.errores : [];
            throw error;
        }
        return json.datos;
    }

    async function enviarJson(ruta, metodo, cuerpo) {
        const respuesta = await fetch(API_URL + ruta, {
            method: metodo,
            headers: cabeceras(cuerpo !== undefined),
            body: cuerpo !== undefined ? JSON.stringify(cuerpo) : undefined
        });
        return parsear(respuesta);
    }

    async function enviarMultipart(ruta, metodo, formulario, conAuth) {
        const cab = {};
        const t = tokenSesion();
        if (conAuth && t) cab["Authorization"] = "Bearer " + t;
        const respuesta = await fetch(API_URL + ruta, {
            method: metodo,
            headers: cab,
            body: formulario
        });
        return parsear(respuesta);
    }

    function adjuntarArchivos(formulario, archivos) {
        if (Array.isArray(archivos)) {
            archivos.forEach(function (archivo) { formulario.append("archivos[]", archivo); });
        } else {
            formulario.append("archivos[]", archivos);
        }
    }

    // ---------------------------------------------------------------
    // 1. Autenticación y verificación de correo (HU1, HU8, HU19, HU21, HU25)
    // ---------------------------------------------------------------
    async function registrarse(datos) {
        return enviarJson("/auth/register", "POST", datos);
    }

    async function iniciarSesion(datos) {
        return enviarJson("/auth/login", "POST", datos);
    }

    async function verificarEmail(email, codigo) {
        return enviarJson("/auth/verificar-email", "POST", { email: email, codigo: codigo });
    }

    async function reenviarCodigo(email) {
        return enviarJson("/auth/reenviar-codigo", "POST", { email: email });
    }

    // ---------------------------------------------------------------
    // 2. Fotógrafos, perfil, políticas y cuota (HU18, HU31, HU16)
    // ---------------------------------------------------------------
    async function actualizarPerfil(datos) {
        return enviarJson("/fotografo/perfil", "PUT", datos);
    }

    async function perfilPublicoFotografo(id) {
        return enviarJson("/fotografos/" + encodeURIComponent(id), "GET");
    }

    async function aceptarPoliticas() {
        return enviarJson("/fotografos/aceptar-politicas", "POST");
    }

    async function consultarCuota() {
        return enviarJson("/fotografos/cuota", "GET");
    }

    // ---------------------------------------------------------------
    // 3. Colecciones, hashtags e invitaciones (HU2, HU3, HU17, HU20, HU24, HU26, HU27)
    // ---------------------------------------------------------------
    async function crearColeccion(datos) {
        return enviarJson("/colecciones", "POST", datos);
    }

    async function listarColeccionesPublicas(hashtag) {
        const query = hashtag ? "?hashtag=" + encodeURIComponent(hashtag) : "";
        return enviarJson("/colecciones/publicas" + query, "GET");
    }

    async function detalleColeccion(id) {
        return enviarJson("/colecciones/" + id, "GET");
    }

    async function validarInvitacion(tokenInvitacion) {
        return enviarJson("/invitaciones/" + encodeURIComponent(tokenInvitacion), "GET");
    }

    async function canjearInvitacion(tokenInvitacion) {
        return enviarJson("/invitaciones/" + encodeURIComponent(tokenInvitacion) + "/canjear", "POST");
    }

    async function listarHashtags() {
        return enviarJson("/hashtags", "GET");
    }

    async function actualizarHashtags(coleccionId, hashtags) {
        return enviarJson("/colecciones/" + coleccionId + "/hashtags", "PUT", { hashtags: hashtags || [] });
    }

    async function actualizarColeccion(id, datos) {
        return enviarJson("/colecciones/" + id, "PUT", datos);
    }

    async function eliminarColeccion(id) {
        return enviarJson("/colecciones/" + id, "DELETE");
    }

    // ---------------------------------------------------------------
    // 4. Multimedia, calidades, descargas y gestión (HU5, HU6, HU10, HU14, HU16, HU20, HU22, HU28, HU32)
    // ---------------------------------------------------------------
    async function subirMultimedia(coleccionId, archivos, metadatos) {
        const formulario = new FormData();
        adjuntarArchivos(formulario, archivos);
        if (metadatos && metadatos.titulo) formulario.append("titulo", metadatos.titulo);
        if (metadatos && metadatos.descripcion) formulario.append("descripcion", metadatos.descripcion);
        return enviarMultipart("/colecciones/" + coleccionId + "/multimedia", "POST", formulario, true);
    }

    async function listarMultimedia(coleccionId) {
        return enviarJson("/colecciones/" + coleccionId + "/multimedia", "GET");
    }

    async function actualizarMultimedia(id, datos) {
        return enviarJson("/multimedia/" + id, "PUT", datos);
    }

    async function eliminarMultimedia(id) {
        return enviarJson("/multimedia/" + id, "DELETE");
    }

    function urlVistaPrevia(id) {
        return API_URL + "/multimedia/" + id + "/vista-previa";
    }

    async function obtenerVistaPrevia(id) {
        const respuesta = await fetch(API_URL + "/multimedia/" + id + "/vista-previa", {
            headers: cabeceras(false)
        });
        if (!respuesta.ok) {
            const error = new Error("No se pudo cargar la vista previa.");
            error.status = respuesta.status;
            throw error;
        }
        return URL.createObjectURL(await respuesta.blob());
    }

    function urlOriginal(id) {
        return API_URL + "/multimedia/" + id + "/original";
    }

    function urlDescarga(id, calidad) {
        return API_URL + "/multimedia/" + id + "/descargar?calidad=" + encodeURIComponent(calidad || "alta");
    }

    // ---------------------------------------------------------------
    // 5. Carga colaborativa por invitados y códigos QR (HU4, HU7, HU11, HU12)
    // ---------------------------------------------------------------
    async function generarQrColaborativo(coleccionId) {
        return enviarJson("/colecciones/" + coleccionId + "/qr-colaborativo", "POST");
    }

    async function generarQrAcceso(coleccionId) {
        return enviarJson("/colecciones/" + coleccionId + "/qr-acceso", "POST");
    }

    function urlImprimirQrColaborativo(coleccionId) {
        return API_URL + "/colecciones/" + coleccionId + "/qr-colaborativo/imprimir";
    }

    function urlSvgQr(tokenQr) {
        return API_URL + "/qr/" + encodeURIComponent(tokenQr) + "/svg";
    }

    async function verificarAccesoColaborativo(tokenQr) {
        return enviarJson("/colaborativo/" + encodeURIComponent(tokenQr), "GET");
    }

    async function subirMaterialColaborativo(tokenQr, archivos, nombreInvitado) {
        const formulario = new FormData();
        adjuntarArchivos(formulario, archivos);
        if (nombreInvitado) formulario.append("nombre_invitado", nombreInvitado);
        return enviarMultipart("/colaborativo/" + encodeURIComponent(tokenQr) + "/subir", "POST", formulario, false);
    }

    async function listarPendientes(coleccionId) {
        return enviarJson("/colecciones/" + coleccionId + "/colaborativo/pendientes", "GET");
    }

    async function aprobarColaborativo(coleccionId, ids) {
        return enviarJson("/colecciones/" + coleccionId + "/colaborativo/aprobar", "POST", { ids: ids });
    }

    async function rechazarColaborativo(coleccionId, ids) {
        return enviarJson("/colecciones/" + coleccionId + "/colaborativo/rechazar", "POST", { ids: ids });
    }

    // ---------------------------------------------------------------
    // 6. Favoritos (HU23 / RF21)
    // ---------------------------------------------------------------
    async function agregarFavorito(idMultimedia) {
        return enviarJson("/favoritos/" + idMultimedia, "POST");
    }

    async function quitarFavorito(idMultimedia) {
        return enviarJson("/favoritos/" + idMultimedia, "DELETE");
    }

    async function listarFavoritos() {
        return enviarJson("/favoritos", "GET");
    }

    // ---------------------------------------------------------------
    // 7. Respaldos y mantenimiento del sistema (HU13 / RNF5, RNF6, RNF7)
    // ---------------------------------------------------------------
    async function generarBackup() {
        return enviarJson("/sistema/backup", "POST");
    }

    async function listarBackups() {
        return enviarJson("/sistema/backups", "GET");
    }

    async function limpiarColaborativos() {
        return enviarJson("/sistema/limpiar-colaborativos", "POST");
    }

    window.api = {
        // 1. Autenticación
        registrarse: registrarse,
        iniciarSesion: iniciarSesion,
        verificarEmail: verificarEmail,
        reenviarCodigo: reenviarCodigo,
        // 2. Fotógrafos
        actualizarPerfil: actualizarPerfil,
        perfilPublicoFotografo: perfilPublicoFotografo,
        aceptarPoliticas: aceptarPoliticas,
        consultarCuota: consultarCuota,
        // 3. Colecciones
        crearColeccion: crearColeccion,
        listarColeccionesPublicas: listarColeccionesPublicas,
        detalleColeccion: detalleColeccion,
        validarInvitacion: validarInvitacion,
        canjearInvitacion: canjearInvitacion,
        listarHashtags: listarHashtags,
        actualizarHashtags: actualizarHashtags,
        actualizarColeccion: actualizarColeccion,
        eliminarColeccion: eliminarColeccion,
        // 4. Multimedia
        subirMultimedia: subirMultimedia,
        listarMultimedia: listarMultimedia,
        actualizarMultimedia: actualizarMultimedia,
        eliminarMultimedia: eliminarMultimedia,
        urlVistaPrevia: urlVistaPrevia,
        obtenerVistaPrevia: obtenerVistaPrevia,
        urlOriginal: urlOriginal,
        urlDescarga: urlDescarga,
        // 5. Colaborativo y QR
        generarQrColaborativo: generarQrColaborativo,
        generarQrAcceso: generarQrAcceso,
        urlImprimirQrColaborativo: urlImprimirQrColaborativo,
        urlSvgQr: urlSvgQr,
        verificarAccesoColaborativo: verificarAccesoColaborativo,
        subirMaterialColaborativo: subirMaterialColaborativo,
        listarPendientes: listarPendientes,
        aprobarColaborativo: aprobarColaborativo,
        rechazarColaborativo: rechazarColaborativo,
        // 6. Favoritos
        agregarFavorito: agregarFavorito,
        quitarFavorito: quitarFavorito,
        listarFavoritos: listarFavoritos,
        // 7. Sistema
        generarBackup: generarBackup,
        listarBackups: listarBackups,
        limpiarColaborativos: limpiarColaborativos
    };
})();