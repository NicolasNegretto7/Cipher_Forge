<?php
// QUÉ: Configuración centralizada de valores sensibles del backend.
// POR QUÉ: Evita repetir valores como la clave de firma JWT o las rutas de almacenamiento
//          en cada servicio/controlador, concentrando secretos en un solo lugar.

declare(strict_types=1);

namespace App\Core;

class Config
{
    // Clave secreta para firmar los tokens JWT.
    // En producción no debe versionarse; aquí se sobreescribe con la variable de entorno JWT_SECRET si existe.
    public static function jwtSecret(): string
    {
        return getenv('JWT_SECRET') ?: 'cipher_forge_clave_super_secreta_2026';
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

    // Límite máximo para clip de video de invitado (80 MB, RF25/HU28).
    public static function maxClipSizeBytes(): int
    {
        return 80 * 1024 * 1024;
    }

    // Texto que se incrusta como marca de agua sobre las vistas previas de imágenes.
    public static function watermarkText(): string
    {
        return 'Cipher Forge';
    }
}
