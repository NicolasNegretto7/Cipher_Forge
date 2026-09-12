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
    // Límites (bytes). Imagen: 30 MB acordado con el cliente (RF26). Video: 800 MB como tope de archivo original (RF7 / RF26).
    private const MAX_IMAGEN = 30 * 1024 * 1024;    // 30 MB
    private const MAX_VIDEO  = 800 * 1024 * 1024;   // 800 MB

    // Formatos aceptados por decisión del cliente/equipo (CF-03): únicamente JPG y MP4.
    private const MIMES_IMAGEN = [
        'image/jpeg' => 'jpg',
    ];

    private const MIMES_VIDEO = [
        'video/mp4'  => 'mp4',
    ];

    /**
     * Evalúa el archivo y metadatos retornando un array con el resultado sin interrumpir la ejecución.
     * H-06: Permite que subidas múltiples omitan archivos con error y continúen con los válidos.
     */
    public function checkUpload(array $archivo, array $data, int $coleccionId, bool $esInvitado = false): array
    {
        // 1. Verificar error de subida o archivo temporal
        if (($archivo['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            return ['ok' => false, 'error' => 'No se recibió el archivo o la subida falló.'];
        }

        if (!is_uploaded_file($archivo['tmp_name'])) {
            return ['ok' => false, 'error' => 'El archivo no proviene de una subida válida.'];
        }

        $mime = mime_content_type($archivo['tmp_name']);
        $tamano = (int) $archivo['size'];

        // 2. Determinar tipo y extensión según MIME
        if (isset(self::MIMES_IMAGEN[$mime])) {
            $tipo = 'imagen';
            $extension = self::MIMES_IMAGEN[$mime];
            $limite = self::MAX_IMAGEN;
        } elseif (isset(self::MIMES_VIDEO[$mime])) {
            $tipo = 'video';
            $extension = self::MIMES_VIDEO[$mime];
            $limite = self::MAX_VIDEO;
        } else {
            return ['ok' => false, 'error' => 'Formato no permitido. Solo se aceptan imágenes JPG y videos MP4.'];
        }

        // 3. Validar tamaño máximo
        if ($tamano <= 0 || $tamano > $limite) {
            $limiteMb = (int) ($limite / (1024 * 1024));
            return ['ok' => false, 'error' => "El archivo excede el tamaño máximo permitido ({$limiteMb} MB)."];
        }

        // 4. Validar metadatos opcionales
        $titulo = null;
        if (isset($data['titulo']) && trim((string) $data['titulo']) !== '') {
            $titulo = trim((string) $data['titulo']);
            if (mb_strlen($titulo) > 60) {
                return ['ok' => false, 'error' => 'El título no puede superar los 60 caracteres.'];
            }
        }

        $descripcion = null;
        if (isset($data['descripcion']) && trim((string) $data['descripcion']) !== '') {
            $descripcion = trim((string) $data['descripcion']);
            if (mb_strlen($descripcion) > 90) {
                return ['ok' => false, 'error' => 'La descripción no puede superar los 90 caracteres.'];
            }
        }

        $dto = new MultimediaDto(
            coleccionId: $coleccionId,
            tipo:        $tipo,
            titulo:      $titulo,
            descripcion: $descripcion,
            esInvitado:  $esInvitado,
        );

        return [
            'ok'        => true,
            'dto'       => $dto,
            'tipo'      => $tipo,
            'mime'      => $mime,
            'extension' => $extension,
        ];
    }

    /**
     * Valida la subida de un archivo individual y corta con HTTP 400 si falla.
     */
    public function validateUpload(array $archivo, array $data, int $coleccionId, bool $esInvitado = false): MultimediaDto
    {
        $resultado = $this->checkUpload($archivo, $data, $coleccionId, $esInvitado);

        if (!$resultado['ok']) {
            Response::error('Error de validación.', 400, [$resultado['error']]);
        }

        return $resultado['dto'];
    }

    /**
     * Valida metadatos para la actualización de un archivo multimedia (PUT).
     * H-04: Controla límites de VARCHAR(60) para título y VARCHAR(90) para descripción.
     */
    public function validateUpdate(array $data): array
    {
        $errores = [];
        $sanitizado = [];

        if (array_key_exists('titulo', $data)) {
            $titulo = trim((string) $data['titulo']);
            if (mb_strlen($titulo) > 60) {
                $errores[] = 'El título no puede superar los 60 caracteres.';
            } else {
                $sanitizado['titulo'] = $titulo;
            }
        }

        if (array_key_exists('descripcion', $data)) {
            $descripcion = trim((string) $data['descripcion']);
            if (mb_strlen($descripcion) > 90) {
                $errores[] = 'La descripción no puede superar los 90 caracteres.';
            } else {
                $sanitizado['descripcion'] = $descripcion === '' ? null : $descripcion;
            }
        }

        if (array_key_exists('coleccion_id', $data)) {
            if (!is_numeric($data['coleccion_id']) || (int) $data['coleccion_id'] <= 0) {
                $errores[] = 'El identificador de la colección destino debe ser un entero positivo.';
            } else {
                $sanitizado['coleccion_id'] = (int) $data['coleccion_id'];
            }
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return $sanitizado;
    }
}
