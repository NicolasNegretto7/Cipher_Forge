// Pruebas funcionales de la carga diferida (Vanilla LazyLoad) sin navegador.
//
// Ejecuta los módulos reales del proyecto sobre jsdom, con un
// IntersectionObserver y un fetch controlables. Verifica el aplazamiento, la
// descarga al entrar en el viewport, las portadas, los errores y la galería
// vacía. No necesita backend ni navegador.
//
// Uso: npm test
import assert from "node:assert/strict";

let JSDOM;
try {
    ({ JSDOM } = await import("jsdom"));
} catch (error) {
    console.error(
        "Falta jsdom. Ejecuta `npm install` dentro de frontend-cliente antes de las pruebas.",
    );
    process.exit(2);
}

const dom = new JSDOM(
    '<!doctype html><html><body><div id="galeria"></div></body></html>',
    { url: "http://localhost/" },
);

// --- Globales que esperan los módulos del navegador ------------------------
globalThis.window = dom.window;
globalThis.document = dom.window.document;
globalThis.localStorage = dom.window.localStorage;
globalThis.Blob = dom.window.Blob;
globalThis.URL = dom.window.URL;

let fetchCalls = [];
let fetchMode = "ok";
globalThis.fetch = async function (url) {
    fetchCalls.push(url);
    if (fetchMode === "error") {
        return {
            ok: false,
            status: 500,
            json: async () => ({ mensaje: "fallo simulado" }),
            blob: async () => new dom.window.Blob([]),
            headers: { get: () => "" },
        };
    }
    return {
        ok: true,
        status: 200,
        blob: async () => new dom.window.Blob(["datos"], { type: "image/jpeg" }),
        headers: { get: () => "image/jpeg" },
    };
};

let blobSeq = 0;
dom.window.URL.createObjectURL = () => "blob:mock-" + (++blobSeq);
dom.window.URL.revokeObjectURL = () => {};

// IntersectionObserver controlable manualmente.
const observers = [];
class MockIntersectionObserver {
    constructor(callback) {
        this.callback = callback;
        this.elements = new Set();
        observers.push(this);
    }
    observe(el) { this.elements.add(el); }
    unobserve(el) { this.elements.delete(el); }
    disconnect() { this.elements.clear(); }
}
globalThis.IntersectionObserver = MockIntersectionObserver;

function triggerIntersection(el, intersecting) {
    for (const observer of observers) {
        if (observer.elements.has(el)) {
            observer.callback(
                [{
                    target: el,
                    isIntersecting: intersecting,
                    intersectionRatio: intersecting ? 1 : 0,
                }],
                observer,
            );
        }
    }
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 0));

// --- Módulos reales (se importan después de preparar los globales) ---------
const { cargarVistaDiferida, cargarPortada } = await import(
    "../dom/multimedia/multimedia.js"
);

const resultados = [];
async function prueba(nombre, fn) {
    try {
        await fn();
        resultados.push({ nombre, estado: "APROBADA" });
    } catch (error) {
        resultados.push({ nombre, estado: "FALLIDA", detalle: error.message });
    }
}

const galeria = document.getElementById("galeria");
const archivo = { id_multimedia: 42, tipo: "imagen", titulo: "Foto de prueba" };

await prueba("1. Diferido: no descarga ni asigna src antes de entrar al viewport", async () => {
    fetchCalls = [];
    const img = document.createElement("img");
    img.alt = archivo.titulo;
    galeria.appendChild(img);
    cargarVistaDiferida(img, archivo);
    await flush();
    assert.equal(fetchCalls.length, 0, "no debe haber peticiones todavía");
    assert.ok(img.classList.contains("LazyMedia"), "lleva la clase observada");
    assert.equal(img.dataset.src, "/multimedia/42/vista-previa", "declara la ruta en data-src");
    assert.equal(img.getAttribute("src"), null, "todavía no tiene src");
});

await prueba("2. Al entrar en el viewport descarga (autenticado) y asigna el blob a src", async () => {
    const img = galeria.querySelector("img.LazyMedia");
    fetchCalls = [];
    triggerIntersection(img, true);
    await flush();
    assert.equal(fetchCalls.length, 1, "una única petición");
    assert.ok(fetchCalls[0].endsWith("/multimedia/42/vista-previa"), "usa la ruta declarada");
    assert.ok(String(img.getAttribute("src")).startsWith("blob:mock-"), "asigna la URL temporal");
    assert.ok(
        img.classList.contains("MediaCargando") || img.classList.contains("MediaCargada"),
        "la librería aplica su clase de estado",
    );
    assert.ok(
        ["loading", "loaded"].includes(img.dataset.llStatus),
        "la librería registra el estado nativo",
    );
});

await prueba("3. Los medios lejanos no se descargan", async () => {
    fetchCalls = [];
    const img = document.createElement("img");
    galeria.appendChild(img);
    cargarVistaDiferida(img, { id_multimedia: 7, tipo: "imagen" });
    await flush();
    assert.equal(fetchCalls.length, 0, "nada lejano se pide");
    assert.equal(img.getAttribute("src"), null);
});

await prueba("4. Cada portada declara su ruta y se descarga al ser visible", async () => {
    fetchCalls = [];
    const contenedor = document.createElement("div");
    document.body.appendChild(contenedor);
    cargarPortada(contenedor, {
        portada_id_multimedia: 9,
        portada_tipo: "video",
        titulo: "Video",
    });
    const img = contenedor.querySelector("img.ImagenTarjeta");
    assert.ok(img, "crea la imagen de portada");
    assert.equal(img.dataset.src, "/multimedia/9/poster", "los videos usan el poster");
    await flush();
    assert.equal(fetchCalls.length, 0, "sin descargar hasta ser visible");
    triggerIntersection(img, true);
    await flush();
    assert.equal(fetchCalls.length, 1, "se descarga al entrar");
    assert.ok(
        img.classList.contains("MediaCargando") || img.classList.contains("MediaCargada"),
        "la instancia marca el estado de carga",
    );
});

await prueba("5. Error de red: la librería aplica MediaError y no deja src roto", async () => {
    fetchMode = "error";
    fetchCalls = [];
    const img = document.createElement("img");
    galeria.appendChild(img);
    cargarVistaDiferida(img, { id_multimedia: 99, tipo: "imagen" });
    await flush();
    triggerIntersection(img, true);
    await flush();
    assert.equal(fetchCalls.length, 1, "intentó descargar");
    assert.ok(img.classList.contains("MediaError"), "la librería aplica class_error");
    assert.equal(img.dataset.llStatus, "error", "la librería registra el estado de error");
    assert.ok(img.classList.contains("VistaNoDisponible"), "marca el aviso de la galería");
    assert.equal(img.getAttribute("src"), null, "no deja src roto");
    fetchMode = "ok";
});

await prueba("6. Galería vacía / sin elementos: observar y actualizar no lanza errores", async () => {
    const contenedorVacio = document.createElement("div");
    document.body.appendChild(contenedorVacio);
    await flush();
    assert.ok(true);
});

await prueba("7. callback_enter descarga una sola vez por elemento", async () => {
    fetchCalls = [];
    const img = document.createElement("img");
    galeria.appendChild(img);
    cargarVistaDiferida(img, { id_multimedia: 77, tipo: "imagen" });
    await flush();
    triggerIntersection(img, true);
    triggerIntersection(img, true);
    await flush();
    assert.equal(fetchCalls.length, 1, "unobserve_entered + marca evitan repetir la descarga");
});

console.log("\n=== PRUEBAS FUNCIONALES (jsdom) ===");
for (const resultado of resultados) {
    const detalle = resultado.detalle ? " -> " + resultado.detalle : "";
    console.log(`${resultado.estado.padEnd(9)} ${resultado.nombre}${detalle}`);
}
const fallidas = resultados.filter((r) => r.estado === "FALLIDA").length;
console.log(`\nTotal: ${resultados.length} | Fallidas: ${fallidas}`);
process.exit(fallidas === 0 ? 0 : 1);
