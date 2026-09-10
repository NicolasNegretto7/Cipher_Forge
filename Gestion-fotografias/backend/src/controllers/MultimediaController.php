<?php
// QUÉ: Controlador que gestiona la subida y el acceso a archivos multimedia.
// POR QUÉ: Orquesta la entrada HTTP (multipart para subida, {id} para servir), delega
//          validación y negocio, y emite la respuesta adecuada (JSON o binario).

declare(strict_types=1);

namespace App\controllers;

use App\Core\Request;
use App\Core\Response;
use App\services\MultimediaService;
use App\validators\MultimediaValidator;

class MultimediaController
{
    private MultimediaService   $multimediaService;
    private MultimediaValidator $multimediaValidator;

    private const EXTENSION_POR_MIME = [
        'image/jpeg' => 'jpg',
        'video/mp4'  => 'mp4',
    ];

    public function __construct()
    {
        $this->multimediaService   = new MultimediaService();
        $this->multimediaValidator = new MultimediaValidator();
    }

    /**
     * POST /colecciones/{id}/multimedia
     * Sube uno o varios archivos multimedia a una colección controlando la cuota de 3 GB (HU5 / HU16).
     */
    public function upload(string $coleccionId): void
    {
        $coleccionId = (int) $coleccionId;
        $request = new Request();
        $data    = array_merge($request->getBody(), $_POST);

        if (!isset($_FILES['archivos'])) {
            Response::error('Debes enviar al menos un archivo en el campo "archivos".', 400);
        }

        $archivos = $this->normalizarArchivos($_FILES['archivos']);
        $resultado = $this->multimediaService->uploadMultiple($coleccionId, $archivos, $data, self::EXTENSION_POR_MIME);

        $mensaje = !empty($resultado['excedentes'])
            ? 'Subida parcial completada: algunos archivos excedieron la cuota de 3 GB.'
            : 'Archivos subidos correctamente.';

        Response::success($resultado, $mensaje, 201);
    }

    /**
     * GET /multimedia/{id}/vista-previa
     * Sirve la vista previa (imagen con marca de agua o clip de 15 s) tras validar acceso.
     */
    public function vistaPrevia(string $idMultimedia): void
    {
        $ruta = $this->multimediaService->obtenerVistaPrevia((int) $idMultimedia);
        $this->emitirArchivo($ruta, false);
    }

    /**
     * GET /multimedia/{id}/original
     * Sirve el archivo original (alta calidad) SOLO si el solicitante tiene permiso (HU20).
     */
    public function original(string $idMultimedia): void
    {
        $ruta = $this->multimediaService->obtenerOriginal((int) $idMultimedia);
        $this->emitirArchivo($ruta, true);
    }

    /**
     * GET /multimedia/{id}/descargar
     * Descarga directa individual en dos calidades ('buena' o 'alta') sin marcas de agua (HU10 / RF10).
     */
    public function descargar(string $idMultimedia): void
    {
        $request = new Request();
        $calidad = (string) $request->getQuery('calidad', 'alta');

        $ruta = $this->multimediaService->obtenerDescarga((int) $idMultimedia, $calidad);
        $this->emitirArchivo($ruta, true);
    }

    /**
     * DELETE /multimedia/{id}
     * Elimina una imagen o video por el fotógrafo dueño de la colección (HU6 / RF20).
     */
    public function eliminar(string $idMultimedia): void
    {
        $this->multimediaService->eliminar((int) $idMultimedia);
        Response::success(null, 'Archivo multimedia eliminado correctamente.');
    }

    /**
     * PUT /multimedia/{id}
     * Modifica los metadatos (título, descripción) o reasigna de colección (HU22 / RF20).
     */
    public function actualizar(string $idMultimedia): void
    {
        $request = new Request();
        $data    = $request->getBody();

        $actualizado = $this->multimediaService->actualizarMetadatos((int) $idMultimedia, $data);
        Response::success($actualizado, 'Datos del archivo actualizados exitosamente.');
    }

    /**
     * GET /colecciones/{id}/colaborativo/pendientes
     * Visualiza el material subido por invitados pendiente de aprobación (HU12 / RF15).
     */
    public function listarPendientes(string $coleccionId): void
    {
        $pendientes = $this->multimediaService->listarPendientes((int) $coleccionId);
        Response::success($pendientes, 'Archivos colaborativos pendientes de moderación.');
    }

    /**
     * POST /colecciones/{id}/colaborativo/aprobar
     * Aprueba una lista de archivos seleccionados por el fotógrafo (HU12 / RF15).
     */
    public function aprobarColaborativo(string $coleccionId): void
    {
        $request = new Request();
        $data    = $request->getBody();
        $ids     = $data['ids'] ?? [];

        if (!is_array($ids) || empty($ids)) {
            Response::error('Debes proporcionar un array con los "ids" a aprobar.', 400);
        }

        $aprobados = $this->multimediaService->aprobarColaborativo((int) $coleccionId, $ids);
        Response::success(['aprobados' => $aprobados], "Se han aprobado {$aprobados} archivos exitosamente.");
    }

    /**
     * POST /colecciones/{id}/colaborativo/rechazar
     * Rechaza y elimina archivos no deseados (HU12 / RF15).
     */
    public function rechazarColaborativo(string $coleccionId): void
    {
        $request = new Request();
        $data    = $request->getBody();
        $ids     = $data['ids'] ?? [];

        if (!is_array($ids) || empty($ids)) {
            Response::error('Debes proporcionar un array con los "ids" a rechazar.', 400);
        }

        $rechazados = $this->multimediaService->rechazarColaborativo((int) $coleccionId, $ids);
        Response::success(['eliminados' => $rechazados], "Se han rechazado y eliminado {$rechazados} archivos.");
    }

    /**
     * GET /colecciones/{id}/multimedia
     * Lista los contenidos aprobados de una colección tras validar acceso (para la galería).
     */
    public function listar(string $coleccionId): void
    {
        $multimedia = $this->multimediaService->listarColeccion((int) $coleccionId);
        Response::success($multimedia, 'Contenidos de la colección.');
    }

    // ------------------------------------------------------------------
    // Métodos internos
    // ------------------------------------------------------------------

    /**
     * Convierte $_FILES['archivos'] en un array normalizado de entradas de archivo.
     */
    private function normalizarArchivos(array $archivos): array
    {
        if (!is_array($archivos['name'])) {
            return [$archivos];
        }

        $resultado = [];
        foreach ($archivos['name'] as $i => $nombre) {
            $resultado[] = [
                'name'     => $nombre,
                'type'     => $archivos['type'][$i],
                'tmp_name' => $archivos['tmp_name'][$i],
                'error'    => $archivos['error'][$i],
                'size'     => $archivos['size'][$i],
            ];
        }
        return $resultado;
    }

    /**
     * Emite un archivo binario al cliente con las cabeceras correctas.
     * $forzarDescarga=true añade Content-Disposition: attachment.
     */
    private function emitirArchivo(string $ruta, bool $forzarDescarga): void
    {
        $mime = mime_content_type($ruta);
        header('Content-Type: ' . $mime);

        if ($forzarDescarga) {
            $nombre = basename($ruta);
            header('Content-Disposition: attachment; filename="' . $nombre . '"');
        } else {
            header('Content-Disposition: inline');
        }

        header('Content-Length: ' . filesize($ruta));
        header('Cache-Control: no-store');

        readfile($ruta);
        exit;
    }
}
