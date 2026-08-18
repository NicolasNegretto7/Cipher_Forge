<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\ZipHelper;
use App\Repositories\CollectionRepository;
use App\Repositories\ImageRepository;
use Throwable;

/**
 * Controlador para descargas masivas empaquetadas en formato ZIP.
 */
class DownloadController
{
    private CollectionRepository $collectionRepo;
    private ImageRepository $imageRepo;
    private string $storageBase;

    public function __construct(
        ?CollectionRepository $collectionRepo = null,
        ?ImageRepository $imageRepo = null
    ) {
        $this->collectionRepo = $collectionRepo ?? new CollectionRepository();
        $this->imageRepo = $imageRepo ?? new ImageRepository();
        $this->storageBase = __DIR__ . '/../../storage';
    }

    /**
     * GET /api/collections/{uuid}/download
     * Empaqueta todas las imágenes de la colección en un archivo ZIP y lo envía al cliente.
     */
    public function downloadZip(Request $request, array $params): void
    {
        try {
            $uuid = (string) ($params['uuid'] ?? '');
            $collection = $this->collectionRepo->findByUuid($uuid);

            if ($collection === null) {
                Response::error('Colección no encontrada.', 404);
            }

            $user = $request->getUser();
            $isOwner = $user && (int) $user['id'] === (int) $collection['user_id'];
            $isFotografo = $user && $user['role'] === 'fotografo';

            if ((int) $collection['is_private'] === 1 && !$isOwner && !$isFotografo) {
                Response::error('No tienes autorización para descargar esta colección privada.', 403);
            }

            $images = $this->imageRepo->findByCollectionId((int) $collection['id']);
            if (empty($images)) {
                Response::error('La colección no contiene imágenes para descargar.', 400);
            }

            // Preparar la lista de archivos a incluir en el ZIP
            $filesToZip = [];
            $useOriginals = ($isOwner || $isFotografo);
            $subFolder = $useOriginals ? 'uploads' : 'watermarked';

            foreach ($images as $img) {
                $physicalPath = $this->storageBase . '/' . $subFolder . '/' . $img['filename'];
                if (file_exists($physicalPath)) {
                    $filesToZip[] = [
                        'path' => $physicalPath,
                        'name' => $img['original_name'],
                    ];
                }
            }

            if (empty($filesToZip)) {
                Response::error('Los archivos físicos de la colección no están disponibles.', 404);
            }

            $zipPath = ZipHelper::createZip($filesToZip);
            $zipFilename = 'CipherForge_' . preg_replace('/[^a-zA-Z0-9_-]/', '_', (string) $collection['title']) . '.zip';

            // Encabezados para descarga de archivo comprimido
            header('Content-Type: application/zip');
            header('Content-Disposition: attachment; filename="' . $zipFilename . '"');
            header('Content-Length: ' . (string) filesize($zipPath));
            header('Pragma: no-cache');
            header('Expires: 0');

            // Transmitir y eliminar el archivo temporal
            readfile($zipPath);
            @unlink($zipPath);
            exit;
        } catch (Throwable $e) {
            Response::error('Error al generar la descarga ZIP: ' . $e->getMessage(), 500);
        }
    }
}
