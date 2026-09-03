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
        'image/jpeg'       => 'jpg',
        'image/png'        => 'png',
        'video/mp4'        => 'mp4',
        'video/quicktime'  => 'mov',
        'video/webm'       => 'webm',
        'video/x-msvideo'  => 'avi',
    ];

    public function __construct()
    {
        $this->multimediaService   = new MultimediaService();
        $this->multimediaValidator = new MultimediaValidator();
    }

    /**
     * POST /colecciones/{id}/multimedia
     * Sube uno o varios archivos multimedia a una colección (HU5).
     */
    public function upload(string $coleccionId): void
    {
        $coleccionId = (int) $coleccionId;
        $request = new Request();
        $data    = $request->getBody();

        if (!isset($_FILES['archivos'])) {
            Response::error('Debes enviar al menos un archivo en el campo "archivos".', 400);
        }

        $subidos = [];

        // Permitir array de archivos (multi-subida) o un único archivo.
        $archivos = $this->normalizarArchivos($_FILES['archivos']);

        foreach ($archivos as $archivo) {
            // Validar tipo, tamaño y metadatos de cada archivo.
            $dto = $this->multimediaValidator->validateUpload($archivo, $data, $coleccionId);

            $mime = mime_content_type($archivo['tmp_name']);
            $extension = self::EXTENSION_POR_MIME[$mime] ?? 'bin';

            $subidos[] = $this->multimediaService->upload($dto, $archivo, $extension, $mime);
        }

        Response::success($subidos, 'Archivos subidos correctamente.', 201);
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
     * GET /colecciones/{id}/multimedia
     * Lista los contenidos de una colección tras validar acceso (para la galería).
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
