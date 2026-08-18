<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\WatermarkHelper;
use App\Repositories\CollectionRepository;
use App\Repositories\ImageRepository;
use finfo;
use Throwable;

/**
 * Controlador para la subida segura y procesamiento de imágenes.
 */
class ImageController
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
     * POST /api/collections/{uuid}/images
     * Sube un archivo binario mediante multipart/form-data, valida su MIME real y aplica marca de agua.
     */
    public function upload(Request $request, array $params): void
    {
        try {
            $uuid = (string) ($params['uuid'] ?? '');
            $collection = $this->collectionRepo->findByUuid($uuid);

            if ($collection === null) {
                Response::error('Colección no encontrada.', 404);
            }

            $user = $request->getUser();
            if ((int) $collection['user_id'] !== (int) $user['id']) {
                Response::error('Solo el propietario de la colección puede subir imágenes.', 403);
            }

            $file = $request->getFile('image');
            if ($file === null || !isset($file['tmp_name']) || $file['error'] !== UPLOAD_ERR_OK) {
                Response::error('No se ha recibido ningún archivo válido o hubo un error en la carga.', 400);
            }

            // 1. Verificación del tipo MIME real mediante finfo (no confiar en $_FILES['image']['type'])
            $finfo = new finfo(FILEINFO_MIME_TYPE);
            $realMimeType = $finfo->file($file['tmp_name']);

            $allowedMimes = [
                'image/jpeg' => 'jpg',
                'image/png'  => 'png',
            ];

            if (!array_key_exists($realMimeType, $allowedMimes)) {
                Response::error("Tipo de archivo no permitido ({$realMimeType}). Solo se aceptan JPEG y PNG.", 422);
            }

            $extension = $allowedMimes[$realMimeType];

            // 2. Generar nombre físico seguro no predecible
            $secureFilename = bin2hex(random_bytes(16)) . '.' . $extension;

            $uploadsDir     = $this->storageBase . '/uploads';
            $watermarkedDir = $this->storageBase . '/watermarked';
            $previewsDir    = $this->storageBase . '/previews';

            foreach ([$uploadsDir, $watermarkedDir, $previewsDir] as $dir) {
                if (!is_dir($dir)) {
                    mkdir($dir, 0755, true);
                }
            }

            $destOriginalPath = $uploadsDir . '/' . $secureFilename;
            $destWatermarkedPath = $watermarkedDir . '/' . $secureFilename;
            $destPreviewPath = $previewsDir . '/' . $secureFilename;

            // 3. Mover archivo temporal al almacenamiento privado original
            if (!move_uploaded_file($file['tmp_name'], $destOriginalPath)) {
                Response::error('Fallo al almacenar el archivo en el servidor.', 500);
            }

            // 4. Generar versión con marca de agua y vista previa (GD)
            if (extension_loaded('gd')) {
                WatermarkHelper::applyWatermark($destOriginalPath, $destWatermarkedPath);
                WatermarkHelper::generateThumbnail($destOriginalPath, $destPreviewPath, 350);
            }

            // 5. Registrar metadatos en MySQL
            $imageId = $this->imageRepo->create(
                (int) $collection['id'],
                $secureFilename,
                (string) $file['name'],
                $realMimeType,
                (int) $file['size']
            );

            $savedImage = $this->imageRepo->findById($imageId);

            Response::success($savedImage, 'Imagen subida y procesada correctamente.', 201);
        } catch (Throwable $e) {
            Response::error('Error en el servidor al procesar la imagen: ' . $e->getMessage(), 500);
        }
    }
}
