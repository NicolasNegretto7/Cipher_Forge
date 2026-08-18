<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Gestor de respuestas HTTP con formato JSON estandarizado para Cipher_Forge.
 * 
 * Cumple con el estándar del proyecto:
 * Éxito: {"success": true, "data": ...}
 * Error: {"success": false, "error": "mensaje"}
 */
class Response
{
    /**
     * Emite una respuesta JSON arbitraria con código de estado HTTP.
     * 
     * @param mixed $data Datos a serializar.
     * @param int $statusCode Código HTTP.
     */
    public static function json(mixed $data, int $statusCode = 200): void
    {
        if (!headers_sent()) {
            http_response_code($statusCode);
            header('Content-Type: application/json; charset=UTF-8');
        }

        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
        exit;
    }

    /**
     * Respuesta estructurada de éxito conforme al estándar del proyecto.
     * 
     * @param mixed $data Carga útil de la respuesta.
     * @param string|null $message Mensaje descriptivo opcional.
     * @param int $statusCode Código HTTP (200, 201).
     */
    public static function success(mixed $data = null, ?string $message = null, int $statusCode = 200): void
    {
        $payload = [
            'success' => true,
        ];

        if ($message !== null) {
            $payload['message'] = $message;
        }

        if ($data !== null) {
            $payload['data'] = $data;
        }

        self::json($payload, $statusCode);
    }

    /**
     * Respuesta estructurada de error conforme al estándar del proyecto.
     * 
     * @param string $message Mensaje principal de error.
     * @param int $statusCode Código de estado HTTP (400, 401, 403, 404, 422, 500).
     * @param array<string, mixed>|null $errors Errores específicos de validación por campo.
     */
    public static function error(string $message, int $statusCode = 400, ?array $errors = null): void
    {
        $payload = [
            'success' => false,
            'error'   => $message,
        ];

        if ($errors !== null) {
            $payload['errors'] = $errors;
        }

        self::json($payload, $statusCode);
    }
}
