<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\ImageRepository;
use Throwable;

/**
 * Controlador para servir y transmitir archivos binarios de forma segura.
 * 
 * Los archivos residen fuera de la raíz pública y se despachan mediante readfile().
 */
class FileController
{
    private ImageRepository $imageRepo;
    private string $storageBase;

    public function __construct(?ImageRepository $imageRepo = null)
    {
        $this->imageRepo = $imageRepo ?? new ImageRepository();
        $this->storageBase = __DIR__ . '/../../storage';
    }

    /**
     * GET /api/files/{id}?type=preview|watermarked|original
     * Transmite la imagen solicitada validando permisos de acceso.
     */
    public function serve(Request $request, array $params): void
    {
        try {
            $id = (int) ($params['id'] ?? 0);
            $image = $this->imageRepo->findById($id);

            if ($image === null) {
                Response::error('Archivo no encontrado.', 404);
            }

            $type = (string) $request->getQueryParam('type', 'watermarked');
            $user = $request->getUser();

            // Si solicita la versión original sin marca de agua, requiere permisos estrictos
            if ($type === 'original') {
                $isOwner = $user && (int) $user['id'] === (int) $image['owner_id'];
                $isFotografo = $user && $user['role'] === 'fotografo';

                if (!$isOwner && !$isFotografo) {
                    Response::error('No tienes autorización para descargar la versión original.', 403);
                }

                $filePath = $this->storageBase . '/uploads/' . $image['filename'];
            } elseif ($type === 'preview') {
                $filePath = $this->storageBase . '/previews/' . $image['filename'];
                if (!file_exists($filePath)) {
                    $filePath = $this->storageBase . '/watermarked/' . $image['filename'];
                }
            } else {
                // watermarked (default)
                $filePath = $this->storageBase . '/watermarked/' . $image['filename'];
                if (!file_exists($filePath)) {
                    $filePath = $this->storageBase . '/uploads/' . $image['filename'];
                }
            }

            if (!file_exists($filePath)) {
                Response::error('El archivo físico no existe en el almacenamiento del servidor.', 404);
            }

            // Envío de encabezados binarios
            header('Content-Type: ' . $image['mime_type']);
            header('Content-Length: ' . (string) filesize($filePath));
            
            $disposition = ($type === 'original') ? 'attachment' : 'inline';
            header('Content-Disposition: ' . $disposition . '; filename="' . rawurlencode($image['original_name']) . '"');
            header('Cache-Control: private, max-age=3600');

            // readfile lee el archivo de disco y lo envía directamente al buffer de salida HTTP
            readfile($filePath);
            exit;
        } catch (Throwable $e) {
            Response::error('Error al servir el archivo: ' . $e->getMessage(), 500);
        }
    }
}
