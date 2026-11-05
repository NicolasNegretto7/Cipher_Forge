// Prueba E2E real de la carga diferida con Microsoft Edge headless.
//
// Requisitos:
//   - Backend de Cipher Photo activo en la URL de services/config.js (8080).
//   - Microsoft Edge instalado (o variable EDGE_PATH).
//   - `npm install` en frontend-cliente.
//
// Sirve el frontend en un puerto local efímero y comprueba, con tráfico real:
//   A) 30 imágenes: no todas se descargan al inicio y sí al desplazarse.
//   B) coleccion.html real: renderiza y asigna blobs a imágenes y videos.
//   C) panelcliente.html real: las portadas se cargan solo al ser visibles.
//
// Uso: npm run test:e2e
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const AQUI = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(AQUI, "..");
const LIMITE = 30;

let chromium;
try {
    ({ chromium } = await import("playwright-core"));
} catch (error) {
    console.error(
        "Falta playwright-core. Ejecuta `npm install` dentro de frontend-cliente.",
    );
    process.exit(2);
}

let API_URL;
try {
    ({ API_URL } = await import("../services/config.js"));
} catch (error) {
    console.error("No se pudo leer services/config.js:", error.message);
    process.exit(2);
}

function localizarEdge() {
    const candidatos = [
        process.env.EDGE_PATH,
        "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
        "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
    ].filter(Boolean);
    return candidatos.find((ruta) => fs.existsSync(ruta)) || null;
}

async function pedirJson(ruta) {
    const respuesta = await fetch(API_URL + ruta, {
        signal: AbortSignal.timeout(8000),
    });
    if (!respuesta.ok) throw new Error("HTTP " + respuesta.status + " en " + ruta);
    return await respuesta.json();
}

// Recolecta ids de imágenes públicas reales para el arnés de 30 elementos.
async function recolectarImagenes(limite) {
    const publicas = await pedirJson("/colecciones/publicas");
    const colecciones = (publicas.datos || [])
        .filter((c) => Number(c.total_archivos) > 0)
        .sort((a, b) => Number(b.total_archivos) - Number(a.total_archivos));

    const ids = [];
    for (const coleccion of colecciones) {
        if (ids.length >= limite) break;
        try {
            const multimedia = await pedirJson(
                "/colecciones/" + coleccion.id + "/multimedia",
            );
            for (const archivo of multimedia.datos || []) {
                if (archivo.tipo === "imagen") ids.push(archivo.id_multimedia);
            }
        } catch (error) {
            // Una colección inaccesible no invalida la prueba.
        }
    }
    return { ids: ids.slice(0, limite), coleccionDestacada: colecciones[0] };
}

let datos;
try {
    datos = await recolectarImagenes(LIMITE);
} catch (error) {
    console.error(
        "No se pudo contactar el backend en " + API_URL + ": " + error.message,
    );
    console.error("Arranca el backend y vuelve a ejecutar `npm run test:e2e`.");
    process.exit(2);
}

if (datos.ids.length < 10 || !datos.coleccionDestacada) {
    console.error(
        "Se necesitan al menos 10 imágenes públicas para una prueba significativa. " +
            "Encontradas: " + datos.ids.length,
    );
    process.exit(2);
}

const HARNESS = `<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Harness LazyLoad</title>
<style>
  body{margin:0;font-family:sans-serif}
  #galeria{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;padding:20px}
  .TarjetaMedia{height:420px}
  .VistaMiniatura{width:100%;height:100%;object-fit:cover;display:block;background:#ddd}
</style></head>
<body>
<h1>Harness LazyLoad</h1>
<div id="galeria"></div>
<script type="module">
  import { cargarVistaDiferida } from "./dom/multimedia/multimedia.js";
  const ids = ${JSON.stringify(datos.ids)};
  const galeria = document.getElementById("galeria");
  for (const id of ids) {
    const article = document.createElement("article");
    article.className = "TarjetaMedia";
    const img = document.createElement("img");
    img.className = "VistaMiniatura";
    img.alt = "Foto " + id;
    article.appendChild(img);
    galeria.appendChild(article);
    cargarVistaDiferida(img, { id_multimedia: id, tipo: "imagen" });
  }
  window.__total = ids.length;
</script>
</body></html>`;

const TIPOS = {
    ".html": "text/html; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".svg": "image/svg+xml",
};

const servidor = http.createServer((req, res) => {
    let ruta = decodeURIComponent((req.url || "/").split("?")[0]);
    if (ruta === "/__harness.html") {
        res.setHeader("Content-Type", TIPOS[".html"]);
        res.end(HARNESS);
        return;
    }
    if (ruta === "/favicon.ico") {
        res.statusCode = 204;
        res.end();
        return;
    }
    const archivo = path.join(ROOT, ruta);
    if (!archivo.startsWith(ROOT)) {
        res.statusCode = 403;
        res.end();
        return;
    }
    fs.readFile(archivo, (error, contenido) => {
        if (error) {
            res.statusCode = 404;
            res.end("404");
            return;
        }
        res.setHeader(
            "Content-Type",
            TIPOS[path.extname(archivo).toLowerCase()] || "application/octet-stream",
        );
        res.end(contenido);
    });
});
await new Promise((resolve) => servidor.listen(0, "127.0.0.1", resolve));
const ORIGEN = "http://127.0.0.1:" + servidor.address().port;

const edge = localizarEdge();
let navegador;
try {
    navegador = edge
        ? await chromium.launch({ executablePath: edge, headless: true })
        : await chromium.launch({ channel: "msedge", headless: true });
} catch (error) {
    console.error("No se pudo iniciar Microsoft Edge:", error.message);
    servidor.close();
    process.exit(2);
}

const resultados = [];

async function nuevaPagina() {
    const page = await navegador.newPage({ viewport: { width: 1280, height: 720 } });
    const peticiones = [];
    const erroresPagina = [];
    const erroresConsola = [];
    page.on("request", (peticion) => {
        if (/\/multimedia\/\d+\/vista-previa/.test(peticion.url())) {
            peticiones.push(peticion.url());
        }
    });
    page.on("pageerror", (error) => erroresPagina.push(String(error)));
    page.on("console", (mensaje) => {
        if (mensaje.type() === "error") erroresConsola.push(mensaje.text());
    });
    return { page, peticiones, erroresPagina, erroresConsola };
}

function erroresConsolaReales(errores) {
    return errores.filter((texto) => !/Failed to load resource/i.test(texto));
}

async function desplazarProgresivo(page) {
    const alto = await page.evaluate(() => document.body.scrollHeight);
    for (let y = 0; y <= alto; y += 400) {
        await page.evaluate((valor) => window.scrollTo(0, valor), y);
        await page.waitForTimeout(100);
    }
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await page.waitForTimeout(2500);
}

async function iniciarSesionLocal(page) {
    await page.addInitScript(() => {
        localStorage.setItem(
            "cliente-usuario",
            JSON.stringify({ id: 1, rol: "cliente", nombre: "Prueba", email: "prueba@local" }),
        );
    });
}

// --- A. Arnés de imágenes reales -------------------------------------------
try {
    const { page, peticiones, erroresPagina, erroresConsola } = await nuevaPagina();
    await page.goto(ORIGEN + "/__harness.html", { waitUntil: "load" });
    await page.waitForTimeout(1600);

    const inicial = await page.evaluate(() => ({
        total: window.__total,
        conSrc: document.querySelectorAll("img.LazyMedia[src]").length,
    }));
    const peticionesIniciales = peticiones.length;
    const capturaInicial = path.join(os.tmpdir(), "cipher-lazyload-top.png");
    await page.screenshot({ path: capturaInicial });

    await desplazarProgresivo(page);
    const final = await page.evaluate(() => ({
        total: window.__total,
        conSrc: document.querySelectorAll("img.LazyMedia[src]").length,
        cargadas: document.querySelectorAll("img.LazyMedia.MediaCargada").length,
        errores: document.querySelectorAll("img.LazyMedia.MediaError").length,
    }));
    const peticionesFinales = peticiones.length;
    const capturaFinal = path.join(os.tmpdir(), "cipher-lazyload-bottom.png");
    await page.screenshot({ path: capturaFinal });

    const ok =
        inicial.conSrc > 0 &&
        inicial.conSrc < inicial.total &&
        peticionesIniciales > 0 &&
        peticionesIniciales < inicial.total &&
        final.conSrc > inicial.conSrc &&
        final.conSrc === final.total &&
        final.cargadas === final.total &&
        final.errores === 0 &&
        erroresPagina.length === 0 &&
        erroresConsolaReales(erroresConsola).length === 0;

    resultados.push({
        nombre: "A. " + inicial.total + " imágenes: no todas al inicio, todas al desplazar",
        ok,
        detalle: {
            conSrcAlInicio: inicial.conSrc,
            peticionesAlInicio: peticionesIniciales,
            conSrcAlFinal: final.conSrc,
            cargadasAlFinal: final.cargadas,
            erroresDeCarga: final.errores,
            peticionesAlFinal: peticionesFinales,
            erroresPagina,
            capturas: [capturaInicial, capturaFinal],
        },
    });
    await page.close();
} catch (error) {
    resultados.push({ nombre: "A. Arnés de imágenes reales", ok: false, detalle: error.message });
}

// --- B. Página real de colección -------------------------------------------
try {
    const { page, peticiones, erroresPagina, erroresConsola } = await nuevaPagina();
    await iniciarSesionLocal(page);
    await page.goto(
        ORIGEN + "/pages/coleccion.html?id=" + datos.coleccionDestacada.id,
        { waitUntil: "load" },
    );
    await page.waitForTimeout(1500);
    await desplazarProgresivo(page);

    const estado = await page.evaluate(() => ({
        titulo: document.getElementById("tituloColeccion")?.textContent || "",
        tarjetas: document.querySelectorAll("#galeria .TarjetaMedia").length,
        lazy: document.querySelectorAll("#galeria .LazyMedia").length,
        conSrc: document.querySelectorAll("#galeria .LazyMedia[src]").length,
        imagenes: document.querySelectorAll("#galeria img.LazyMedia").length,
        videos: document.querySelectorAll("#galeria video.LazyMedia").length,
        dataSrc: Array.from(document.querySelectorAll("#galeria .LazyMedia"))
            .map((medio) => medio.dataset.src)
            .filter(Boolean),
        cargadas: document.querySelectorAll("#galeria .LazyMedia.MediaCargada").length,
        erroresDeCarga: document.querySelectorAll("#galeria .LazyMedia.MediaError").length,
        estados: Array.from(document.querySelectorAll("#galeria .LazyMedia"))
            .map((medio) => medio.dataset.llStatus)
            .filter(Boolean),
        errorVisible: !document.getElementById("mensajeError")?.hidden,
    }));

    const ok =
        estado.tarjetas > 0 &&
        estado.lazy === estado.tarjetas &&
        estado.conSrc === estado.lazy &&
        estado.dataSrc.length === estado.lazy &&
        estado.dataSrc.every((ruta) =>
            /^\/multimedia\/\d+\/(vista-previa|poster)$/.test(ruta),
        ) &&
        estado.cargadas === estado.lazy &&
        estado.erroresDeCarga === 0 &&
        !estado.errorVisible &&
        erroresPagina.length === 0 &&
        erroresConsolaReales(erroresConsola).length === 0;

    resultados.push({
        nombre: "B. coleccion.html real: imágenes y videos usan data-src y cargan blobs",
        ok,
        detalle: {
            estado,
            peticiones: peticiones.length,
            erroresPagina,
            // El 401 de /favoritos es esperado: la sesión del test es local y
            // no incluye la cookie HttpOnly real.
            erroresRedEsperados: erroresConsola.filter((t) => /Failed to load resource/i.test(t)),
        },
    });
    await page.close();
} catch (error) {
    resultados.push({ nombre: "B. Página real de colección", ok: false, detalle: error.message });
}

// --- C. Mosaico público de portadas ----------------------------------------
try {
    const { page, peticiones, erroresPagina, erroresConsola } = await nuevaPagina();
    await iniciarSesionLocal(page);
    await page.goto(ORIGEN + "/pages/panelcliente.html", { waitUntil: "load" });
    await page.waitForTimeout(3000);

    const estado = await page.evaluate(() => ({
        tarjetas: document.querySelectorAll("#galeriaPublica .TarjetaColeccion").length,
        portadas: document.querySelectorAll("#galeriaPublica img.ImagenTarjeta.LazyMedia").length,
        conSrc: document.querySelectorAll("#galeriaPublica img.ImagenTarjeta.LazyMedia[src]").length,
        dataSrc: Array.from(
            document.querySelectorAll("#galeriaPublica img.ImagenTarjeta.LazyMedia"),
        )
            .map((img) => img.dataset.src)
            .filter(Boolean),
        cargadas: document.querySelectorAll(
            "#galeriaPublica img.ImagenTarjeta.LazyMedia.MediaCargada",
        ).length,
        erroresDeCarga: document.querySelectorAll(
            "#galeriaPublica img.ImagenTarjeta.LazyMedia.MediaError",
        ).length,
        errorVisible: !document.getElementById("mensajeError")?.hidden,
    }));

    const ok =
        estado.tarjetas > 0 &&
        estado.portadas > 0 &&
        estado.conSrc > 0 &&
        estado.conSrc <= estado.portadas &&
        (estado.portadas < 15 || estado.conSrc < estado.portadas) &&
        estado.dataSrc.length === estado.portadas &&
        estado.dataSrc.every((ruta) =>
            /^\/multimedia\/\d+\/(vista-previa|poster)$/.test(ruta),
        ) &&
        estado.cargadas === estado.conSrc &&
        estado.erroresDeCarga === 0 &&
        !estado.errorVisible &&
        erroresPagina.length === 0 &&
        erroresConsolaReales(erroresConsola).length === 0;

    resultados.push({
        nombre: "C. panelcliente.html real: portadas cargadas solo al ser visibles",
        ok,
        detalle: {
            estado,
            peticiones: peticiones.length,
            erroresPagina,
            erroresRedEsperados: erroresConsola.filter((t) => /Failed to load resource/i.test(t)),
        },
    });
    await page.close();
} catch (error) {
    resultados.push({ nombre: "C. Mosaico público", ok: false, detalle: error.message });
}

await navegador.close();
await new Promise((resolve) => servidor.close(resolve));

console.log("\n=== PRUEBAS E2E (Edge real contra el backend) ===");
for (const resultado of resultados) {
    console.log(`${resultado.ok ? "APROBADA" : "FALLIDA"} ${resultado.nombre}`);
    console.log(JSON.stringify(resultado.detalle, null, 2));
}
const fallidas = resultados.filter((resultado) => !resultado.ok).length;
console.log(`\nTotal: ${resultados.length} | Fallidas: ${fallidas}`);
process.exit(fallidas === 0 ? 0 : 1);
