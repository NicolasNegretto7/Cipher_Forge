<?php

declare(strict_types=1);

namespace App\Helpers;

/**
 * Utilidades criptográficas para generación de tokens, UUIDs y hashing de contraseñas.
 */
class TokenHelper
{
    /**
     * Genera un token criptográficamente seguro de longitud variable.
     * 
     * @param int $bytes Número de bytes aleatorios (32 bytes = 64 caracteres hex).
     * @return string Token en formato hexadecimal.
     */
    public static function generateToken(int $bytes = 32): string
    {
        return bin2hex(random_bytes($bytes));
    }

    /**
     * Calcula el hash SHA-256 de un token para almacenamiento seguro en BD.
     * 
     * @param string $token Token en texto plano.
     * @return string Hash de 64 caracteres.
     */
    public static function hashToken(string $token): string
    {
        return hash('sha256', $token);
    }

    /**
     * Genera un identificador único universal (UUID v4) conforme a RFC 4122.
     * 
     * @return string Cadena UUID (ejemplo: 'f47ac10b-58cc-4372-a567-0e02b2c3d479').
     */
    public static function generateUuid(): string
    {
        $data = random_bytes(16);
        // Configura versión 4 (0100) en el byte 6
        $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
        // Configura bits de variante RFC 4122 (10) en el byte 8
        $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);

        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }

    /**
     * Aplica hash a una contraseña utilizando Argon2id (o Bcrypt como fallback).
     * 
     * @param string $password Contraseña en texto plano.
     * @return string Hash seguro para persistir en BD.
     */
    public static function hashPassword(string $password): string
    {
        if (defined('PASSWORD_ARGON2ID')) {
            return password_hash($password, PASSWORD_ARGON2ID, [
                'memory_cost' => 65536, // 64 MB de memoria
                'time_cost'   => 4,     // 4 iteraciones
                'threads'     => 1,
            ]);
        }

        return password_hash($password, PASSWORD_DEFAULT);
    }

    /**
     * Comprueba si una contraseña en texto plano coincide con el hash almacenado.
     * 
     * @param string $password Contraseña en texto plano a verificar.
     * @param string $hash Hash almacenado en la base de datos.
     * @return bool True si es válida, False en caso contrario.
     */
    public static function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }
}
