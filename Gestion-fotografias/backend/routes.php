<?php

declare(strict_types=1);

use App\Core\Router;
use App\controllers\HomeController;
use App\controllers\AuthController;
use App\controllers\ColeccionController;
use App\controllers\MultimediaController;
use App\controllers\FotografoController;
use App\controllers\ColaborativoController;
use App\controllers\FavoritoController;
use App\controllers\SistemaController;

$router = new Router();

// Endpoint de prueba / diagnóstico
$router->add('GET', '/api/ping', HomeController::class, 'ping');

// -------------------------------------------------------------
// 1. Auth & Verificación de Correo (HU1, HU8, HU19, HU21, HU25)
// -------------------------------------------------------------
$router->add('POST', '/auth/register', AuthController::class, 'register'); //
$router->add('POST', '/auth/login', AuthController::class, 'login'); //
$router->add('POST', '/auth/verificar-email', AuthController::class, 'verificarEmail'); //
$router->add('POST', '/auth/reenviar-codigo', AuthController::class, 'reenviarCodigo'); //

// -------------------------------------------------------------
// 2. Fotógrafos, Perfiles, Políticas y Cuotas (HU18, HU31, HU16)
// -------------------------------------------------------------
$router->add('GET', '/fotografos', FotografoController::class, 'directorio');
$router->add('GET', '/fotografos/cuota', FotografoController::class, 'cuota', 'auth');
$router->add('GET', '/fotografos/{id}', FotografoController::class, 'perfil');
$router->add('PUT', '/fotografo/perfil', FotografoController::class, 'actualizarPerfil', 'auth');
$router->add('POST', '/fotografos/aceptar-politicas', FotografoController::class, 'aceptarPoliticas', 'auth');

// -------------------------------------------------------------
// 3. Colecciones, Hashtags e Invitaciones (HU2, HU3, HU17, HU24, HU26, HU27)
// -------------------------------------------------------------
$router->add('POST', '/colecciones', ColeccionController::class, 'create', 'auth');
$router->add('GET', '/colecciones/publicas', ColeccionController::class, 'listarPublicas');
$router->add('GET', '/colecciones/{id}', ColeccionController::class, 'detalle', 'optional');
$router->add('GET', '/invitaciones/{token}', ColeccionController::class, 'validarInvitacion', 'optional');
$router->add('POST', '/invitaciones/{token}/canjear', ColeccionController::class, 'canjearInvitacion', 'auth');
$router->add('GET', '/hashtags', ColeccionController::class, 'listarHashtags');
$router->add('PUT', '/colecciones/{id}/hashtags', ColeccionController::class, 'actualizarHashtags', 'auth');
$router->add('PUT', '/colecciones/{id}', ColeccionController::class, 'actualizar', 'auth');
$router->add('DELETE', '/colecciones/{id}', ColeccionController::class, 'eliminar', 'auth');

// -------------------------------------------------------------
// 4. Multimedia, Calidades, Descargas y Gestión (HU5, HU6, HU10, HU14, HU16, HU20, HU22, HU28, HU32)
// -------------------------------------------------------------
$router->add('POST', '/colecciones/{id}/multimedia', MultimediaController::class, 'upload', 'auth');
$router->add('GET', '/colecciones/{id}/multimedia', MultimediaController::class, 'listar', 'optional');
$router->add('GET', '/multimedia/{id}/vista-previa', MultimediaController::class, 'vistaPrevia', 'optional');
$router->add('GET', '/multimedia/{id}/original', MultimediaController::class, 'original', 'optional');
$router->add('GET', '/multimedia/{id}/descargar', MultimediaController::class, 'descargar', 'optional');
$router->add('PUT', '/multimedia/{id}', MultimediaController::class, 'actualizar', 'auth');
$router->add('DELETE', '/multimedia/{id}', MultimediaController::class, 'eliminar', 'auth');

// -------------------------------------------------------------
// 5. Carga Colaborativa por Invitados & Códigos QR (HU4, HU7, HU11, HU12)
// -------------------------------------------------------------
$router->add('POST', '/colecciones/{id}/qr-colaborativo', ColaborativoController::class, 'generar', 'auth');
$router->add('GET', '/colecciones/{id}/qr-colaborativo/imprimir', ColaborativoController::class, 'imprimir');
$router->add('POST', '/colecciones/{id}/qr-acceso', ColaborativoController::class, 'generarAcceso', 'auth');
$router->add('GET', '/qr/{token}/svg', ColaborativoController::class, 'svg');
$router->add('GET', '/colaborativo/{token}', ColaborativoController::class, 'verificar');
$router->add('POST', '/colaborativo/{token}/subir', ColaborativoController::class, 'subir');
$router->add('GET', '/colecciones/{id}/colaborativo/pendientes', MultimediaController::class, 'listarPendientes', 'auth');
$router->add('POST', '/colecciones/{id}/colaborativo/aprobar', MultimediaController::class, 'aprobarColaborativo', 'auth');
$router->add('POST', '/colecciones/{id}/colaborativo/rechazar', MultimediaController::class, 'rechazarColaborativo', 'auth');

// -------------------------------------------------------------
// 6. Favoritos (HU23 / RF21)
// -------------------------------------------------------------
$router->add('POST', '/favoritos/{id}', FavoritoController::class, 'agregar', 'auth');
$router->add('DELETE', '/favoritos/{id}', FavoritoController::class, 'quitar', 'auth');
$router->add('GET', '/favoritos', FavoritoController::class, 'listar', 'auth');

// -------------------------------------------------------------
// 7. Respaldos y Mantenimiento del Sistema (HU13 / RNF5, RNF6, RNF7)
// -------------------------------------------------------------
$router->add('POST', '/sistema/backup', SistemaController::class, 'backup');
$router->add('GET', '/sistema/backups', SistemaController::class, 'listarBackups');
$router->add('POST', '/sistema/limpiar-colaborativos', SistemaController::class, 'limpiarColaborativos');

return $router;