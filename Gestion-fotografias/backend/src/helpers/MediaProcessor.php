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
    // "Buena Calidad" (HU10 / RF10 / CC-24 / CC-30 / CC-32): copia del original con calidad baja
    // para que la diferencia sea visualmente evidente (pixeleada/borrosa) respecto a la "Alta".
    // Imagen: JPEG 10 y resolución máxima HD (1280 px) cuando el original la supera.
    // Video: re-codificación FFmpeg (H.264 CRF 35, tope 1280 px, audio AAC 96k).
    // La "Alta Calidad" se sirve siempre desde `originals/` (archivo original íntegro).
    public const CALIDAD_BUENA_JPEG = 10;
    public const ANCHO_MAX_BUENA_CALIDAD = 1280;
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

        $info = @getimagesize($rutaOriginalAbsoluta);
        if ($info === false) {
            return '';
        }

        $mime = $info['mime'];
        $origen = match ($mime) {
            'image/jpeg' => @imagecreatefromjpeg($rutaOriginalAbsoluta),
            'image/png'  => @imagecreatefrompng($rutaOriginalAbsoluta),
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
        $paso = max(1, (int) ($alto * 0.18));

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
     * Genera la versión de "Buena Calidad": copia del original SIN marca de agua con
     * calidad baja (JPEG 30) y resolución máxima Full HD (1920 px) si el original la
     * supera (CC-24). La "Alta Calidad" se sirve siempre desde `originals/`.
     * Retorna la ruta relativa o '' si no se pudo generar (el llamador usa el original).
     */
    public static function generarBuenaCalidadImagen(string $rutaOriginalAbsoluta): string
    {
        $dir = Config::standardDir();
        self::asegurarDirectorio($dir);

        $info = @getimagesize($rutaOriginalAbsoluta);
        if ($info === false) {
            return '';
        }

        $mime = $info['mime'];
        $origen = match ($mime) {
            'image/jpeg' => @imagecreatefromjpeg($rutaOriginalAbsoluta),
            'image/png'  => @imagecreatefrompng($rutaOriginalAbsoluta),
            default      => false,
        };

        if (!$origen) {
            return '';
        }

        // Tope de resolución Full HD: si la imagen es más ancha que 1920 px se reescala
        // (manteniendo proporción); si no, se conservan las dimensiones originales.
        $ancho = imagesx($origen);
        $alto  = imagesy($origen);
        $anchoMax = self::ANCHO_MAX_BUENA_CALIDAD;

        if ($ancho > $anchoMax) {
            $nuevoAlto = (int) round($alto * ($anchoMax / $ancho));
            $redim = imagecreatetruecolor($anchoMax, $nuevoAlto);
            imagecopyresampled($redim, $origen, 0, 0, 0, 0, $anchoMax, $nuevoAlto, $ancho, $alto);
        } else {
            $redim = $origen;
        }

        $nombre = self::nombreUnico('jpg');
        $destino = $dir . '/' . $nombre;

        imagejpeg($redim, $destino, self::CALIDAD_BUENA_JPEG); // Calidad baja
        if ($redim !== $origen) {
            imagedestroy($redim);
        }
        imagedestroy($origen);

        return 'uploads/standard/' . $nombre;
    }

    /**
     * Genera la versión de "Buena Calidad" de un video: original re-codificado con FFmpeg
     * a calidad claramente degradada (H.264 libx264 CRF 35), resolución máxima HD (1280 px)
     * si el original la supera, audio AAC 96 kbps y `+faststart` (H05/CC-30/CC-32).
     * La "Alta Calidad" se sirve siempre desde `originals/` (archivo original íntegro).
     * Retorna la ruta relativa o '' si no se pudo generar (el llamador usa el original).
     */
    public static function generarBuenaCalidadVideo(string $rutaOriginalAbsoluta): string
    {
        $dir = Config::standardDir();
        self::asegurarDirectorio($dir);

        $nombre = self::nombreUnico('mp4');
        $destino = $dir . '/' . $nombre;

        $cmd = sprintf(
            'ffmpeg -y -i %s -vf "scale=\'min(%d,iw)\':-2" -c:v libx264 -crf 35 -preset veryfast -maxrate 1500k -bufsize 3000k -c:a aac -b:a 96k -movflags +faststart %s 2>&1',
            escapeshellarg($rutaOriginalAbsoluta),
            self::ANCHO_MAX_BUENA_CALIDAD,
            escapeshellarg($destino)
        );

        exec($cmd, $out, $code);

        if ($code !== 0 || !file_exists($destino)) {
            return '';
        }

        return 'uploads/standard/' . $nombre;
    }

    /**
     * Extrae un fotograma (poster) de un video con FFmpeg y lo guarda como JPG (CC-35).
     * Intenta el segundo 1 para evitar el fundido inicial negro; si el video es más corto,
     * reintenta en el fotograma 0. Retorna la ruta relativa o '' si no se pudo generar.
     */
    public static function generarPosterVideo(string $rutaOriginalAbsoluta): string
    {
        $dir = Config::standardDir();
        self::asegurarDirectorio($dir);

        $nombre = self::nombreUnico('jpg');
        $destino = $dir . '/' . $nombre;

        $generado = false;
        foreach ([1, 0] as $segundo) {
            $cmd = sprintf(
                'ffmpeg -y -i %s -ss %d -frames:v 1 -vf "scale=\'min(%d,iw)\':-2" %s 2>&1',
                escapeshellarg($rutaOriginalAbsoluta),
                $segundo,
                self::ANCHO_MAX_BUENA_CALIDAD,
                escapeshellarg($destino)
            );
            exec($cmd, $out, $code);
            if ($code === 0 && file_exists($destino) && filesize($destino) > 0) {
                $generado = true;
                break;
            }
            @unlink($destino);
        }

        if (!$generado) {
            return '';
        }

        return 'uploads/standard/' . $nombre;
    }

    /**
     * Elimina con seguridad un archivo físico en disco a partir de su ruta relativa (HU6).
     */
    public static function eliminarArchivoFisico(?string $rutaRelativa): bool
    {
        if ($rutaRelativa === null || $rutaRelativa === '') {
            return false;
        }

        $rutaAbsoluta = self::aRutaAbsoluta($rutaRelativa);
        if (file_exists($rutaAbsoluta) && is_file($rutaAbsoluta)) {
            return @unlink($rutaAbsoluta);
        }

        return false;
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
