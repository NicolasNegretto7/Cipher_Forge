const parametros = new URLSearchParams(window.location.search);
const API_URL = "http://localhost:8080";
const coleccionId = parametros.has("coleccionId") ? Number(parametros.get("coleccionId")) : null;
const nombreTexto = document.getElementById("nombreColeccion");
const descripcionTexto = document.getElementById("descripcionColeccionTexto");
const estadoVisibilidad = document.getElementById("estadoVisibilidad");
const zonaCarga = document.getElementById("zonaCarga");
const selectorArchivos = document.getElementById("selectorArchivos");
const galeria = document.getElementById("galeria");
const estadoVacio = document.getElementById("estadoVacio");
const barraAcciones = document.getElementById("barraAcciones");
const tagInput = document.getElementById("tagInput");
const listaTags = document.getElementById("listaTags");

// Marcador minúsculo (PNG 1x1) cuando no hay previsualización persistida.
const PLACEHOLDER_SRC = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==";

// Bytes originales de la sesión (id -> File): IndexedDB los persiste, este mapa acelera la subida.
const bytesOriginalesEnSesion = {};

let colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
let coleccion = colecciones.find(function (item) { return item.id === coleccionId; });
let esColeccionNueva = false;

if (!coleccion) {
    coleccion = {
        id: Date.now() + Math.random(),
        localId: null,
        nombre: parametros.get("nombre") || "Nueva colección",
        descripcion: "",
        tipo_visibilidad: "privada",
        tags: [],
        favorita: false,
        publicada: false,
        imagenes: []
    };
    coleccion.localId = coleccion.id;
    esColeccionNueva = true;
}

if (!coleccion.tags) coleccion.tags = [];
if (!coleccion.imagenes) coleccion.imagenes = [];
let archivos = coleccion.imagenes;
let seleccionados = [];

nombreTexto.textContent = coleccion.nombre;
descripcionTexto.textContent = coleccion.descripcion || "";
estadoVisibilidad.textContent = coleccion.tipo_visibilidad === "publica"
    ? "Visible en colecciones públicas"
    : "Privada: no aparece en colecciones públicas";

function guardarColeccion() {
    coleccion.imagenes = archivos;

    const indiceColeccion = colecciones.findIndex(function (item) {
        return item.id === coleccion.id || item.id === coleccion.localId || item.localId === coleccion.localId;
    });

    if (esColeccionNueva || indiceColeccion === -1) {
        colecciones.push(coleccion);
        esColeccionNueva = false;
    } else {
        colecciones[indiceColeccion] = coleccion;
    }

    const datos = JSON.stringify(colecciones);
    try {
        localStorage.setItem("colecciones", datos);
    } catch (error) {
        // Cuota local agotada: se limpian las previsualizaciones grandes de TODAS las colecciones
        // (los bytes reales siguen en IndexedDB y se restauran al recargar la página).
        const reemplazarPorMarcador = function (archivo) {
            if (typeof archivo.src === "string" && archivo.src.length > PLACEHOLDER_SRC.length + 100) {
                archivo.src = PLACEHOLDER_SRC;
            }
        };
        (coleccion.imagenes || []).forEach(reemplazarPorMarcador);
        colecciones.forEach(function (coleccionItem) {
            (coleccionItem.imagenes || []).forEach(reemplazarPorMarcador);
        });
        localStorage.setItem("colecciones", JSON.stringify(colecciones));
    }
}

function mostrarTags() {
    listaTags.innerHTML = "";

    coleccion.tags.forEach(function (tag) {
        const etiqueta = document.createElement("button");
        etiqueta.type = "button";
        etiqueta.className = "EtiquetaTag";
        etiqueta.textContent = tag + " x";
        etiqueta.addEventListener("click", function () {
            coleccion.tags = coleccion.tags.filter(function (item) { return item !== tag; });
            guardarColeccion();
            mostrarTags();
        });
        listaTags.appendChild(etiqueta);
    });
}

tagInput.addEventListener("keydown", function (evento) {
    if (evento.key !== "Enter") return;
    evento.preventDefault();

    const texto = tagInput.value.trim();
    if (!texto) return;

    const tag = texto.startsWith("#") ? texto : "#" + texto;
    if (!coleccion.tags.includes(tag)) {
        coleccion.tags.push(tag);
        guardarColeccion();
        mostrarTags();
    }

    tagInput.value = "";
});

if (window.api && window.api.listarHashtags) {
    window.api.listarHashtags()
        .then(function (hashtags) {
            const lista = document.getElementById("sugerenciasHashtags");
            if (!lista) return;
            (hashtags || []).forEach(function (h) {
                const opcion = document.createElement("option");
                opcion.value = "#" + h.nombre_hashtags;
                opcion.label = "#" + h.nombre_hashtags + " (" + h.total_colecciones + ")";
                lista.appendChild(opcion);
            });
        })
        .catch(function () {});
}

zonaCarga.addEventListener("click", function () { selectorArchivos.click(); });
function leerArchivoComoDataUrl(archivo) {
    return new Promise(function (resolver, rechazar) {
        const lector = new FileReader();
        lector.onload = function () { resolver(lector.result); };
        lector.onerror = rechazar;
        lector.readAsDataURL(archivo);
    });
}

function cargarImagenDesdeSrc(src) {
    return new Promise(function (resolver, rechazar) {
        const imagen = new Image();
        imagen.onload = function () { resolver(imagen); };
        imagen.onerror = rechazar;
        imagen.src = src;
    });
}

// Reencoda una imagen como JPEG pequeño para no agotar localStorage (los bytes originales van a IndexedDB).
async function generarMiniaturaImagen(src, maxLado) {
    const lienzo = document.createElement("canvas");
    const imagen = await cargarImagenDesdeSrc(src);
    const escala = Math.min(1, maxLado / Math.max(imagen.naturalWidth, imagen.naturalHeight));
    lienzo.width = Math.max(1, Math.round(imagen.naturalWidth * escala));
    lienzo.height = Math.max(1, Math.round(imagen.naturalHeight * escala));
    lienzo.getContext("2d").drawImage(imagen, 0, 0, lienzo.width, lienzo.height);
    return lienzo.toDataURL("image/jpeg", 0.72);
}

// Captura un fotograma de un video como miniatura JPEG (para videos grandes que no caben en localStorage).
async function generarPosterVideo(src) {
    const video = document.createElement("video");
    video.muted = true;
    video.preload = "metadata";
    video.src = src;
    await new Promise(function (resolver, rechazar) {
        video.onloadeddata = resolver;
        video.onerror = rechazar;
    });
    const instante = Math.min(0.5, (Number(video.duration) || 1) / 2);
    video.currentTime = instante;
    await new Promise(function (resolver, rechazar) {
        video.onseeked = resolver;
        video.onerror = rechazar;
    });
    const lienzo = document.createElement("canvas");
    const escala = Math.min(1, 640 / Math.max(video.videoWidth, video.videoHeight));
    lienzo.width = Math.max(1, Math.round(video.videoWidth * escala));
    lienzo.height = Math.max(1, Math.round(video.videoHeight * escala));
    lienzo.getContext("2d").drawImage(video, 0, 0, lienzo.width, lienzo.height);
    return lienzo.toDataURL("image/jpeg", 0.72);
}

function obtenerArchivoOriginal(archivo) {
    const enSesion = bytesOriginalesEnSesion[archivo.id];
    if (enSesion) return Promise.resolve(enSesion);
    return obtenerBinario(archivo.id).then(function (desdeIndice) {
        if (desdeIndice) return desdeIndice;
        if (typeof archivo.src === "string" && archivo.src.indexOf("data:") === 0) {
            return dataUrlAFile(archivo.src, archivo.nombre || "imagen.jpg");
        }
        return null;
    });
}

// Devuelve a la vista las previsualizaciones de archivos cuyos bytes viven en IndexedDB.
async function restaurarVistasDesdeBinarios() {
    for (const archivo of archivos) {
        if (archivo.remoto || archivo.subido) continue;
        const blob = await obtenerBinario(archivo.id);
        if (!blob) continue;
        if (archivo.vista_restaurada) {
            try { URL.revokeObjectURL(archivo.vista_restaurada); } catch (error) { }
        }
        archivo.src = URL.createObjectURL(blob);
        archivo.vista_restaurada = archivo.src;
        archivo.es_poster = false;
    }
    mostrarGaleria();
    actualizarAlmacenamiento();
}

selectorArchivos.addEventListener("change", async function () {
    const excedidos = [];

    for (const archivo of Array.from(selectorArchivos.files)) {
        const tamanoArchivo = Number(archivo.size) || 0;
        if (obtenerAlmacenamientoUsado() + tamanoArchivo > CAPACIDAD_ALMACENAMIENTO) {
            excedidos.push(archivo.name);
            continue;
        }

        const srcCompleto = await leerArchivoComoDataUrl(archivo);
        const id = Date.now() + Math.random();
        bytesOriginalesEnSesion[id] = archivo;
        guardarBinario(id, archivo);

        let src = srcCompleto;
        let esPoster = false;
        const esVideo = String(archivo.type).startsWith("video");
        if (esVideo && tamanoArchivo > 2000000) {
            esPoster = true;
            try { src = await generarPosterVideo(srcCompleto); } catch (error) { src = PLACEHOLDER_SRC; }
        } else if (!esVideo && tamanoArchivo > 2000000) {
            try { src = await generarMiniaturaImagen(srcCompleto, 1600); } catch (error) { src = srcCompleto; }
        }

        archivos.push({
            id: id,
            nombre: archivo.name,
            tipo: archivo.type,
            tamano: tamanoArchivo,
            src: src,
            es_poster: esPoster,
            favorita: false
        });
        guardarColeccion();
        actualizarAlmacenamiento();
        mostrarGaleria();
    }

    if (excedidos.length > 0) {
        alert("No se pudieron subir por superar el espacio restante: " + excedidos.join(", "));
    }
    selectorArchivos.value = "";
});

function mostrarGaleria() {
    galeria.querySelectorAll(".TarjetaMedia").forEach(function (tarjeta) { tarjeta.remove(); });
    estadoVacio.style.display = archivos.length === 0 ? "block" : "none";

    archivos.forEach(function (archivo) {
        const tarjeta = document.createElement("div");
        tarjeta.className = "TarjetaMedia";
        tarjeta.classList.toggle("Seleccionada", seleccionados.includes(archivo.id));

        const esVideo = archivo.tipo && String(archivo.tipo).startsWith("video");
        let vista;
        if (esVideo && !archivo.es_poster && archivo.src) {
            vista = document.createElement("video");
            vista.muted = true;
        } else {
            vista = document.createElement("img");
        }
        vista.src = archivo.src;
        vista.className = "VistaMiniatura";
        tarjeta.appendChild(vista);

        const selector = document.createElement("button");
        selector.type = "button";
        selector.className = "SelectorArchivo";
        selector.textContent = seleccionados.includes(archivo.id) ? "✔" : "";
        selector.classList.toggle("Seleccionado", seleccionados.includes(archivo.id));
        selector.addEventListener("click", function () {
            if (seleccionados.includes(archivo.id)) {
                seleccionados = seleccionados.filter(function (id) { return id !== archivo.id; });
            } else {
                seleccionados.push(archivo.id);
            }
            mostrarGaleria();
        });
        tarjeta.appendChild(selector);
        galeria.appendChild(tarjeta);
    });

    barraAcciones.classList.toggle("Visible", archivos.length > 0);
}

// Carga una vista previa desde el backend autenticada (las colecciones privadas
// exigen el token; un <img> directo no lo enviaría).
function cargarVistaRemota(idMultimedia) {
    const token = localStorage.getItem("token");
    return fetch(window.api.urlVistaPrevia(idMultimedia), {
        headers: token ? { Authorization: "Bearer " + token } : {}
    }).then(function (respuesta) {
        if (!respuesta.ok) throw new Error("No se pudo cargar la vista previa.");
        return respuesta.blob();
    }).then(function (blob) {
        return URL.createObjectURL(blob);
    });
}

// Incorpora a "su colección" los archivos ya aprobados en el servidor,
// incluidos los aportes de invitados aprobados en moderación, para que se
// publiquen junto al material subido por el fotógrafo.
async function sincronizarColeccionBackend() {
    const idBackend = Number(coleccion.id);
    const publicada = coleccion.publicada === true;

    if (!publicada || !Number.isInteger(idBackend) || idBackend <= 0 || !window.api || !window.api.listarMultimedia) {
        return;
    }

    try {
        const servidor = (await window.api.listarMultimedia(idBackend)) || [];

        // Descarta entradas remotas previas (sus blob URLs mueren al recargar).
        archivos = archivos.filter(function (archivo) { return !archivo.remoto; });

        for (const item of servidor) {
            const yaExiste = archivos.some(function (archivo) {
                return archivo.id_multimedia === item.id_multimedia;
            });
            if (yaExiste) continue;

            try {
                const src = await cargarVistaRemota(item.id_multimedia);
                archivos.push({
                    id: item.id_multimedia,
                    nombre: item.titulo || ("archivo-" + item.id_multimedia),
                    tipo: item.tipo === "video" ? "video/mp4" : "image/jpeg",
                    tamano: item.tamanio,
                    src: src,
                    favorita: false,
                    subido: true,
                    id_multimedia: item.id_multimedia,
                    remoto: true
                });
            } catch (error) {
                /* si la vista previa no responde, se omite el ítem remoto */
            }
        }

        mostrarGaleria();
    } catch (error) {
        /* si el servidor no responde, se continúa con el borrador local */
    }
}

document.getElementById("seleccionarTodas").addEventListener("click", function () {
    seleccionados = archivos.map(function (archivo) { return archivo.id; });
    mostrarGaleria();
});

document.getElementById("eliminarSeleccionados").addEventListener("click", function () {

    const eliminados = seleccionados.slice();
    eliminados.forEach(function (id) {
        const archivo = archivos.find(function (a) { return a.id === id; });
        if (archivo && archivo.subido && archivo.id_multimedia && window.api && window.api.eliminarMultimedia) {
            window.api.eliminarMultimedia(archivo.id_multimedia).catch(function () {
                /* el borrado local prevalece aunque el servidor falle */
            });
        }
        if (archivo && !archivo.remoto) {
            delete bytesOriginalesEnSesion[archivo.id];
            borrarBinario(archivo.id);
        }
    });

    archivos = archivos.filter(function (archivo) { return !seleccionados.includes(archivo.id); });
    seleccionados = [];
    if (archivos.length === 0) {
        eliminarColeccionVacia();
    } else {
        guardarColeccion();
    }
    actualizarAlmacenamiento();
    mostrarGaleria();
});

function eliminarColeccionVacia() {
    // Se conserva como borrador para permitir nuevas subidas en esta colección.
    coleccion.imagenes = [];
    guardarColeccion();
    actualizarAlmacenamiento();
}

const botonPublicar = document.getElementById("botonPublicar");
const menuVisibilidad = document.getElementById("menuVisibilidad");

botonPublicar.addEventListener("click", function () {
    const menuAbierto = botonPublicar.getAttribute("aria-expanded") === "true";
    botonPublicar.setAttribute("aria-expanded", String(!menuAbierto));
    menuVisibilidad.hidden = menuAbierto;
});

function dataUrlAFile(dataUrl, nombreArchivo) {
    const partes = dataUrl.split(",");
    const tipo = (partes[0].match(/data:([^;]+)/) || [])[1] || "image/jpeg";
    const binario = atob(partes[1]);
    const bytes = new Uint8Array(binario.length);
    for (let i = 0; i < binario.length; i++) {
        bytes[i] = binario.charCodeAt(i);
    }
    const nombreBase = nombreArchivo || "imagen.jpg";
    const nombreLimpio = nombreBase.replace(/[\\/:*?"<>|]+/g, "-");
    return new File([bytes], nombreLimpio, { type: tipo });
}

async function subirImagenesPendientes(coleccionIdBackend) {
    const pendientes = archivos.filter(function (archivo) { return !archivo.subido; });
    if (pendientes.length === 0) return;

    const subidas = [];
    const sinDisponibles = [];
    for (const archivo of pendientes) {
        const original = await obtenerArchivoOriginal(archivo);
        if (original) {
            subidas.push([archivo, original]);
        } else {
            sinDisponibles.push(archivo.nombre || ("archivo-" + archivo.id));
        }
    }

    if (subidas.length === 0) {
        if (sinDisponibles.length > 0) {
            alert("No se pudo recuperar el contenido original de: " + sinDisponibles.join(", ") + ". Vuelve a añadir esos archivos.");
        }
        return;
    }

    const resultado = await window.api.subirMultimedia(coleccionIdBackend, subidas.map(function (pareja) { return pareja[1]; }), {
        titulo: coleccion.nombre,
        descripcion: coleccion.descripcion || ""
    });

    const subidos = (resultado && resultado.subidos) || [];
    subidas.forEach(function (pareja, indice) {
        pareja[0].subido = true;
        if (subidos[indice]) pareja[0].id_multimedia = subidos[indice].id_multimedia;
    });
    if (sinDisponibles.length > 0) {
        alert("Se subieron los archivos disponibles. No se pudo recuperar el contenido original de: " + sinDisponibles.join(", ") + ". Vuelve a añadir esos archivos.");
    }
}

async function publicarColeccion(tipoVisibilidad) {
    if (archivos.length === 0) {
        alert("Agrega al menos una imagen antes de publicar la colección.");
        return;
    }

    const usuario = JSON.parse(localStorage.getItem("usuario") || "null");
    const rol = usuario && (usuario.rol || usuario.role);
    const fotografoId = Number(usuario && (usuario.id || usuario.id_fotografo));

    if (!usuario || rol !== "fotografo" || !Number.isInteger(fotografoId) || fotografoId <= 0) {
        alert("Solo los usuarios con rol fotógrafo pueden publicar colecciones.");
        return;
    }

    if (!localStorage.getItem("token")) {
        alert("Debes iniciar sesión para publicar la colección.");
        return;
    }

    const botonSeleccionado = menuVisibilidad.querySelector("[data-visibilidad='" + tipoVisibilidad + "']");
    const idBorrador = coleccion.id;
    botonSeleccionado.disabled = true;

    try {
        let coleccionIdBackend = Number(coleccion.id);

        if (!coleccion.publicada || !coleccionIdBackend) {
            const creada = await window.api.crearColeccion({
                fotografo_id: fotografoId,
                titulo: coleccion.nombre,
                tipo_visibilidad: tipoVisibilidad,
                descripcion: coleccion.descripcion || "",
                hashtags: coleccion.tags || []
            });
            coleccionIdBackend = Number(creada.id);
            coleccion.id = coleccionIdBackend;
            coleccion.publicada = true;
            coleccion.localId = coleccion.localId || idBorrador;
        }

        await subirImagenesPendientes(coleccionIdBackend);

        const datosActualizacion = { tipo_visibilidad: tipoVisibilidad };
        if (coleccion.tags && Array.isArray(coleccion.tags)) {
            datosActualizacion.hashtags = coleccion.tags;
        }
        if (window.api && window.api.actualizarColeccion) {
            await window.api.actualizarColeccion(coleccionIdBackend, datosActualizacion);
        }

        coleccion.tipo_visibilidad = tipoVisibilidad;
        guardarColeccion();
        estadoVisibilidad.textContent = tipoVisibilidad === "publica"
            ? "Visible en colecciones públicas"
            : "Privada: no aparece en colecciones públicas";
        menuVisibilidad.hidden = true;
        botonPublicar.setAttribute("aria-expanded", "false");
        alert(tipoVisibilidad === "publica"
            ? "Colección publicada y visible en colecciones públicas."
            : "Colección publicada como privada.");
    } catch (error) {
        alert(error.message || "No se pudo publicar la colección.");
    } finally {
        botonSeleccionado.disabled = false;
    }
}

menuVisibilidad.querySelectorAll("[data-visibilidad]").forEach(function (opcion) {
    opcion.addEventListener("click", function () {
        publicarColeccion(opcion.dataset.visibilidad);
    });
});

mostrarTags();
mostrarGaleria();
sincronizarColeccionBackend();
restaurarVistasDesdeBinarios();
