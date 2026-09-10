// QUÉ: Almacén indexado de los archivos originales (Bytes/File) que el fotógrafo adjunta a una colección.
// POR QUÉ: localStorage (~5 MB) no alcanza para guardar photos de cámara (>2 MB) como dataURL;
//         los bytes van a IndexedDB (sin ese techo) y en localStorage solo queda una miniatura.
const BD_BINARIOS_NOMBRE = "cipher-forge-binarios";
const BD_BINARIOS_VERSION = 1;
const BD_BINARIOS_ALMACEN = "archivos";

let bdBinarios = null;

function abrirBaseBinarios() {
    return new Promise(function (resolver, rechazar) {
        if (bdBinarios) { resolver(bdBinarios); return; }
        const solicitud = indexedDB.open(BD_BINARIOS_NOMBRE, BD_BINARIOS_VERSION);
        solicitud.onupgradeneeded = function () {
            const base = solicitud.result;
            if (!base.objectStoreNames.contains(BD_BINARIOS_ALMACEN)) {
                base.createObjectStore(BD_BINARIOS_ALMACEN);
            }
        };
        solicitud.onsuccess = function () {
            bdBinarios = solicitud.result;
            resolver(bdBinarios);
        };
        solicitud.onerror = function () { rechazar(solicitud.error); };
    });
}

function transaccionBinarios(modo, tarea) {
    return new Promise(function (resolver, rechazar) {
        const tx = bdBinarios.transaction(BD_BINARIOS_ALMACEN, modo);
        const resultado = tarea(tx.objectStore(BD_BINARIOS_ALMACEN));
        tx.oncomplete = function () { resolver(resultado); };
        tx.onerror = function () { rechazar(tx.error); };
    });
}

function guardarBinario(clave, dato) {
    try {
        return abrirBaseBinarios().then(function () {
            return transaccionBinarios("readwrite", function (almacen) { almacen.put(dato, clave); });
        });
    } catch (error) {
        return Promise.resolve();
    }
}

function obtenerBinario(clave) {
    try {
        return abrirBaseBinarios().then(function () {
            return new Promise(function (resolver, rechazar) {
                const tx = bdBinarios.transaction(BD_BINARIOS_ALMACEN, "readonly");
                const peticion = tx.objectStore(BD_BINARIOS_ALMACEN).get(clave);
                peticion.onsuccess = function () { resolver(peticion.result || null); };
                peticion.onerror = function () { rechazar(peticion.error); };
            });
        });
    } catch (error) {
        return Promise.resolve(null);
    }
}

function borrarBinario(clave) {
    try {
        return abrirBaseBinarios().then(function () {
            return transaccionBinarios("readwrite", function (almacen) { almacen.delete(clave); });
        });
    } catch (error) {
        return Promise.resolve();
    }
}