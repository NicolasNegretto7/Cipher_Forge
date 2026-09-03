<?php
// QUÉ: Procesador de archivos multimedia en el servidor.
// POR QUÉ: Centraliza la persistencia de archivos (originales y vistas previas), la generación
//          de las marcas de agua sobre imágenes (GD) y los recortes de 15 s de video (FFmpeg),
//          separando la lógica binaria del servicio de negocio.

declare(strict_types=1);

namespace App\helpers;

use App\Core\Config;

class MediaProcessor
{
    /**
     * Genera un nombre de archivo único (sin posibilidad de colisión entre usuarios).
     */
    public static function nombreUnico(string $extension): string
    {
        return bin2hex(random_bytes(16)) . '.' . $extension;
    }

    /**
     * Guarda el archivo original en uploads/originals y retorna su ruta relativa (para la BD).
     */
    public static function guardarOriginal(string $tmpPath, string $extension): string
    {
        $dir = Config::originalsDir();
        self::asegurarDirectorio($dir);

        $nombre = self::nombreUnico($extension);
        $destino = $dir . '/' . $nombre;

        if (!move_uploaded_file($tmpPath, $destino)) {
            return '';
        }

        return 'uploads/originals/' . $nombre;
    }

    /**
     * Genera la vista previa con marca de agua para una imagen y guarda el archivo.
     * Retorna la ruta relativa de la vista previa.
     */
    public static function generarPreviewImagen(string $rutaOriginalAbsoluta): string
    {
        $dir = Config::previewsDir();
        self::asegurarDirectorio($dir);

        $info = getimagesize($rutaOriginalAbsoluta);
        if ($info === false) {
            return '';
        }

        $mime = $info['mime'];
        $origen = match ($mime) {
            'image/jpeg' => imagecreatefromjpeg($rutaOriginalAbsoluta),
            'image/png'  => imagecreatefrompng($rutaOriginalAbsoluta),
            default      => false,
        };

        if (!$origen) {
            return '';
        }

        // Reducción de tamaño para vista previa optimizada (ancho máximo 1280 px).
        $ancho = imagesx($origen);
        $alto  = imagesy($origen);
        $anchoMax = 1280;
        if ($ancho > $anchoMax) {
            $nuevoAlto = (int) round($alto * ($anchoMax / $ancho));
            $redim = imagecreatetruecolor($anchoMax, $nuevoAlto);
            imagecopyresampled($redim, $origen, 0, 0, 0, 0, $anchoMax, $nuevoAlto, $ancho, $alto);
            $ancho = $anchoMax;
            $alto  = $nuevoAlto;
        } else {
            $redim = $origen;
        }

        // --- Marca de agua semitransparente diagonal ---
        $texto = Config::watermarkText();
        $negro = imagecolorallocatealpha($redim, 0, 0, 0, 90);      // 35% opacidad aprox (alpha 90/127)
        $blanco = imagecolorallocatealpha($redim, 255, 255, 255, 90);
        $font = 5; // Font GD integrada

        $tamLetra = 1;
        $xIni = (int) ($ancho * 0.05);
        $yIni = (int) ($alto * 0.05);
        $paso = (int) ($alto * 0.18);

        // Recorre la imagen en diagonal repetidas veces para dificultar su remoción.
        $y = $yIni;
        while ($y < $alto) {
            $x = $xIni;
            while ($x < $ancho) {
                imagestring($redim, $font, $x + $tamLetra, $y + $tamLetra, $texto, $negro);
                imagestring($redim, $font, $x, $y, $texto, $blanco);
                $x += (int) ($texto === '' ? 200 : 180);
            }
            $y += $paso;
        }

        $nombre = self::nombreUnico('jpg');
        $destino = $dir . '/' . $nombre;

        imagejpeg($redim, $destino, 85);
        imagedestroy($origen);
        imagedestroy($redim);

        return 'uploads/previews/' . $nombre;
    }

    /**
     * Genera un recorte de 15 segundos de un video usando FFmpeg y guarda el clip.
     * Retorna la ruta relativa del recorte de vista previa.
     */
    public static function generarPreviewVideo(string $rutaOriginalAbsoluta): string
    {
        $dir = Config::previewsDir();
        self::asegurarDirectorio($dir);

        $nombre = self::nombreUnico('mp4');
        $destino = $dir . '/' . $nombre;

        // Toma los primeros 15 segundos del video preservando audio/video.
        $cmd = sprintf(
            'ffmpeg -y -i %s -t 15 -preset veryfast %s 2>&1',
            escapeshellarg($rutaOriginalAbsoluta),
            escapeshellarg($destino)
        );

        exec($cmd, $out, $code);

        if ($code !== 0 || !file_exists($destino)) {
            return '';
        }

        return 'uploads/previews/' . $nombre;
    }

    /**
     * Convierte una ruta relativa guardada en la BD en una ruta absoluta dentro del contenedor.
     */
    public static function aRutaAbsoluta(string $rutaRelativa): string
    {
        return Config::uploadsDir() . '/' . str_replace('uploads/', '', $rutaRelativa);
    }

    private static function asegurarDirectorio(string $dir): void
    {
        if (!is_dir($dir)) {
            mkdir($dir, 0775, true);
        }
    }
}
