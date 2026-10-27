<?php
// QUÉ: Configuración centralizada de valores sensibles del backend.
// POR QUÉ: Evita repetir valores como la clave de firma JWT o las rutas de almacenamiento
//          en cada servicio/controlador, concentrando secretos en un solo lugar.

declare(strict_types=1);

namespace App\Core;

class Config
{
    // Clave secreta para firmar los tokens JWT (CF-13).
    // Debe definirse SIEMPRE por variable de entorno JWT_SECRET (mínimo 32 bytes aleatorios;
    // generar con `openssl rand -hex 32`).
    // C-01: ya NO se genera ni persiste un secreto en uploads/.jwt_secret. Ese archivo quedaba
    // dentro de una carpeta servida por Apache, lo que permitía leer el secreto y forjar tokens.
    // Sin JWT_SECRET la aplicación falla cerrada en lugar de usar una clave débil o expuesta.
    public static function jwtSecret(): string
    {
        $env = getenv('JWT_SECRET');
        if (is_string($env) && trim($env) !== '') {
            return trim($env);
        }

        throw new \RuntimeException(
            'Falta la variable de entorno JWT_SECRET. Definila con al menos 32 bytes aleatorios (openssl rand -hex 32).'
        );
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

    // Rangos desde los que se permite invocar los endpoints administrativos /sistema/* (H02).
    // Por defecto (sin SISTEMA_ALLOWED_IPS) el backend admite únicamente tráfico no público:
    // loopback, rangos privados RFC1918 y redes de reserva; el host local de desarrollo llega
    // a través del NAT del bridge de Docker con una IP privada (p. ej. 172.x). Si se define
    // SISTEMA_ALLOWED_IPS (CIDRs separados por coma), se exige coincidencia explícita.
    public static function ipsPermitidasSistema(): array
    {
        $env = getenv('SISTEMA_ALLOWED_IPS');
        if (is_string($env) && trim($env) !== '') {
            return array_values(array_filter(array_map('trim', explode(',', $env))));
        }

        return [];
    }
}
