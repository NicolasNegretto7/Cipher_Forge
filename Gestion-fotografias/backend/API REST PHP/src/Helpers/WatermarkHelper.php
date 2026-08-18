<?php

declare(strict_types=1);

namespace App\Helpers;

use RuntimeException;

/**
 * Procesamiento y manipulación de imágenes utilizando la extensión PHP GD.
 * 
 * Genera miniaturas optimizadas y superpone marcas de agua de protección.
 */
class WatermarkHelper
{
    /**
     * Genera una miniatura proporcional de una imagen JPEG o PNG.
     * 
     * @param string $sourcePath Ruta absoluta de la imagen origen.
     * @param string $destPath Ruta absoluta del archivo destino.
     * @param int $maxDimension Tamaño máximo de ancho o alto en píxeles.
     * @return bool True si se generó correctamente.
     */
    public static function generateThumbnail(string $sourcePath, string $destPath, int $maxDimension = 400): bool
    {
        $info = getimagesize($sourcePath);
        if ($info === false) {
            throw new RuntimeException("No se pudo leer la información de la imagen de origen.");
        }

        [$width, $height, $type] = $info;

        // Calcula dimensiones proporcionales
        $ratio = $width / $height;
        if ($ratio > 1) {
            $newWidth = $maxDimension;
            $newHeight = (int) ($maxDimension / $ratio);
        } else {
            $newHeight = $maxDimension;
            $newWidth = (int) ($maxDimension * $ratio);
        }

        $sourceImage = match ($type) {
            IMAGETYPE_JPEG => imagecreatefromjpeg($sourcePath),
            IMAGETYPE_PNG  => imagecreatefrompng($sourcePath),
            default        => throw new RuntimeException("Formato de imagen no soportado para miniatura.")
        };

        if (!$sourceImage) {
            return false;
        }

        $thumbnail = imagecreatetruecolor($newWidth, $newHeight);

        // Preserva la transparencia si la imagen es PNG
        if ($type === IMAGETYPE_PNG) {
            imagealphablending($thumbnail, false);
            imagesavealpha($thumbnail, true);
        }

        // Redimensiona con interpolación suave
        imagecopyresampled($thumbnail, $sourceImage, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

        self::ensureDirectoryExists(dirname($destPath));

        $saved = match ($type) {
            IMAGETYPE_JPEG => imagejpeg($thumbnail, $destPath, 85),
            IMAGETYPE_PNG  => imagepng($thumbnail, $destPath, 6),
            default        => false
        };

        imagedestroy($sourceImage);
        imagedestroy($thumbnail);

        return $saved;
    }

    /**
     * Aplica una marca de agua diagonal semitransparente sobre la imagen.
     * 
     * @param string $sourcePath Ruta de la imagen original.
     * @param string $destPath Ruta donde se guardará la versión con marca de agua.
     * @param string $watermarkText Texto de la marca de agua.
     * @return bool True si se procesó con éxito.
     */
    public static function applyWatermark(
        string $sourcePath,
        string $destPath,
        string $watermarkText = 'CIPHER_FORGE — PREVIEW'
    ): bool {
        $info = getimagesize($sourcePath);
        if ($info === false) {
            throw new RuntimeException("Archivo de imagen no válido.");
        }

        [$width, $height, $type] = $info;

        $image = match ($type) {
            IMAGETYPE_JPEG => imagecreatefromjpeg($sourcePath),
            IMAGETYPE_PNG  => imagecreatefrompng($sourcePath),
            default        => throw new RuntimeException("Formato no soportado para marca de agua.")
        };

        if (!$image) {
            return false;
        }

        // Color blanco semitransparente (alpha 60 de 127 en GD)
        $watermarkColor = imagecolorallocatealpha($image, 255, 255, 255, 60);

        // Dibuja el texto centrado con fuente incorporada GD
        $font = 5; // Fuente más grande de mapa de bits nativa
        $textWidth = imagefontwidth($font) * strlen($watermarkText);
        $textHeight = imagefontheight($font);

        // Repetir el texto en patrón diagonal sobre la imagen
        $stepX = max(200, $textWidth + 50);
        $stepY = max(150, $textHeight + 50);

        for ($x = 50; $x < $width; $x += $stepX) {
            for ($y = 50; $y < $height; $y += $stepY) {
                imagestring($image, $font, $x, $y, $watermarkText, $watermarkColor);
            }
        }

        self::ensureDirectoryExists(dirname($destPath));

        $saved = match ($type) {
            IMAGETYPE_JPEG => imagejpeg($image, $destPath, 85),
            IMAGETYPE_PNG  => imagepng($image, $destPath, 6),
            default        => false
        };

        imagedestroy($image);

        return $saved;
    }

    private static function ensureDirectoryExists(string $dir): void
    {
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
    }
}
