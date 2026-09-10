<?php
// QUÉ: Configuración centralizada de valores sensibles del backend.
// POR QUÉ: Evita repetir valores como la clave de firma JWT o las rutas de almacenamiento
//          en cada servicio/controlador, concentrando secretos en un solo lugar.

declare(strict_types=1);

namespace App\Core;

class Config
{
    // Clave secreta para firmar los tokens JWT (CF-13).
    // Preferencia: variable de entorno JWT_SECRET. Si no está definida, se genera una
    // clave aleatoria de 256 bits en la primera ejecución y se persiste en uploads/.jwt_secret
    // (carpeta git-ignored y denegada por HTTP), de modo que los tokens sobrevivan reinicios
    // y nunca se use una clave conocida/versionada como fallback.
    public static function jwtSecret(): string
    {
        $env = getenv('JWT_SECRET');
        if (is_string($env) && trim($env) !== '') {
            return trim($env);
        }

        $archivo = self::uploadsDir() . '/.jwt_secret';
        if (is_file($archivo)) {
            $guardado = @file_get_contents($archivo);
            if (is_string($guardado) && trim($guardado) !== '') {
                return trim($guardado);
            }
        }

        $secreto = bin2hex(random_bytes(32));
        @file_put_contents($archivo, $secreto, LOCK_EX);
        @chmod($archivo, 0600);

        return $secreto;
    }

    // Horas de validez de un token de acceso.
    public static function tokenHoras(): int
    {
        return 24;
    }

    // Raíz de almacenamiento de archivos multimedia (sistema de archivos del contenedor).
    public static function uploadsDir(): string
    {
        return __DIR__ . '/../../uploads';
    }

    // Subcarpetas: originales (alta calidad) y vistas previas (marca de agua / clip).
    public static function originalsDir(): string
    {
        return self::uploadsDir() . '/originals';
    }

    public static function previewsDir(): string
    {
        return self::uploadsDir() . '/previews';
    }

    // Subcarpeta para versiones de buena calidad (sin marca de agua, optimizadas).
    public static function standardDir(): string
    {
        return self::uploadsDir() . '/standard';
    }

    // Directorio de respaldos de base de datos (rotación máx 3 copias).
    public static function backupsDir(): string
    {
        return __DIR__ . '/../../backups';
    }

    // Límite de cuota de almacenamiento por fotógrafo (3 GB = 3221225472 bytes, RF17/HU16).
    public static function maxStorageBytes(): int
    {
        return 3 * 1024 * 1024 * 1024;
    }

    // Límite máximo para video original (800 MB, RF7/HU28).
    public static function maxVideoSizeBytes(): int
    {
        return 800 * 1024 * 1024;
    }

    // Texto que se incrusta como marca de agua sobre las vistas previas de imágenes.
    public static function watermarkText(): string
    {
        return 'Cipher Forge';
    }
}
