<?php

declare(strict_types=1);

namespace App\Helpers;

use RuntimeException;
use ZipArchive;

/**
 * Empaquetado y compresión de archivos mediante la extensión ZipArchive.
 */
class ZipHelper
{
    /**
     * Crea un archivo ZIP temporal con una lista de imágenes.
     * 
     * @param array<int, array{path: string, name: string}> $files Lista de archivos con ruta física y nombre de entrada.
     * @return string Ruta absoluta del archivo .zip generado en el directorio temporal del sistema.
     */
    public static function createZip(array $files): string
    {
        if (!class_exists('ZipArchive')) {
            throw new RuntimeException("La extensión ZipArchive de PHP no está habilitada en el servidor.");
        }

        $tempZipPath = tempnam(sys_get_temp_dir(), 'cipher_forge_') . '.zip';

        $zip = new ZipArchive();
        $openResult = $zip->open($tempZipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE);

        if ($openResult !== true) {
            throw new RuntimeException("No se pudo inicializar el archivo ZIP temporal (código {$openResult}).");
        }

        foreach ($files as $file) {
            if (file_exists($file['path'])) {
                $zip->addFile($file['path'], $file['name']);
            }
        }

        $zip->close();

        return $tempZipPath;
    }
}
