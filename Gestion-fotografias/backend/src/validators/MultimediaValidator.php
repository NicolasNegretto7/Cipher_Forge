<?php
// QUÉ: Valida el archivo y metadatos de una subida multimedia y genera su DTO.
// POR QUÉ: Asegura el tipo MIME, extensión y tamaño del archivo ANTES de llegar al servicio,
//          evitando guardar binarios no permitidos o que superen los límites (RF7, RF25).

declare(strict_types=1);

namespace App\validators;

use App\Core\Response;
use App\dtos\MultimediaDto;

class MultimediaValidator
{
    // Límites (bytes). Video: 800 MB como tope de archivo original (RF7).
    private const MAX_IMAGEN = 20 * 1024 * 1024;    // 20 MB
    private const MAX_VIDEO  = 800 * 1024 * 1024;   // 800 MB

    private const MIMES_IMAGEN = [
        'image/jpeg' => 'jpg',
        'image/png'  => 'png',
    ];

    private const MIMES_VIDEO = [
        'video/mp4'        => 'mp4',
        'video/quicktime'  => 'mov',
        'video/webm'       => 'webm',
        'video/x-msvideo'  => 'avi',
    ];

    /**
     * Valida el archivo subido ($_FILES['archivo']) y los metadatos para una colección.
     * Retorna un MultimediaDto si todo es correcto; de lo contrario corta con un error HTTP.
     */
    public function validateUpload(array $archivo, array $data, int $coleccionId): MultimediaDto
    {
        $errores = [];

        // 1. Verificar que se haya enviado un archivo y que no haya error de subida.
        if (($archivo['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            Response::error('No se recibió ningún archivo o la subida falló.', 400);
        }

        if (!is_uploaded_file($archivo['tmp_name'])) {
            Response::error('El archivo no proviene de una subida válida.', 400);
        }

        $mime = mime_content_type($archivo['tmp_name']);
        $tamano = (int) $archivo['size'];

        // 2. Determinar el tipo ('imagen' o 'video') según el MIME real del archivo.
        if (isset(self::MIMES_IMAGEN[$mime])) {
            $tipo = 'imagen';
        } elseif (isset(self::MIMES_VIDEO[$mime])) {
            $tipo = 'video';
        } else {
            $errores[] = 'Formato no permitido. Solo se aceptan imágenes (JPG/PNG) o videos (MP4/MOV/WEBM/AVI).';
            Response::error('Error de validación.', 400, $errores);
        }

        // 3. Validar el tamaño según el tipo.
        $limite = $tipo === 'imagen' ? self::MAX_IMAGEN : self::MAX_VIDEO;
        if ($tamano <= 0 || $tamano > $limite) {
            $errores[] = 'El archivo excede el tamaño máximo permitido (' . ($limite / (1024 * 1024)) . ' MB).';
            Response::error('Error de validación.', 400, $errores);
        }

        // 4. Validar metadatos opcionales de título/descripción.
        $titulo = null;
        if (isset($data['titulo']) && trim((string) $data['titulo']) !== '') {
            $titulo = trim((string) $data['titulo']);
            if (mb_strlen($titulo) > 60) {
                $errores[] = 'El título no puede superar los 60 caracteres.';
            }
        }

        $descripcion = null;
        if (isset($data['descripcion']) && trim((string) $data['descripcion']) !== '') {
            $descripcion = trim((string) $data['descripcion']);
            if (mb_strlen($descripcion) > 90) {
                $errores[] = 'La descripción no puede superar los 90 caracteres.';
            }
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return new MultimediaDto(
            coleccionId: $coleccionId,
            tipo:        $tipo,
            titulo:      $titulo,
            descripcion: $descripcion,
        );
    }
}
