<?php

declare(strict_types=1);

namespace App\Core;

/**
 * RESPUESTA HTTP ESTANDARIZADA (JSON)
 * ==============================================================================
 * WHAT: Emite respuestas formateadas en JSON con su código de estado HTTP y corta
 *       la ejecución del script (`exit`).
 * WHY:  Centraliza la estructura de respuesta JSON de la API. Los métodos estáticos
 *       permiten responder y terminar la ejecución inmediatamente sin acoplar
 *       retornos manuales ni excepciones repetitivas en cada capa.
 * ==============================================================================
 */
class Response
{
    /**
     * Emite una respuesta de éxito (200 OK, 201 Created).
     *
     * @param mixed $data Carga útil de datos serializables a JSON.
     * @param string $message Mensaje descriptivo opcional.
     * @param int $status Código de estado HTTP.
     */
    public static function success(mixed $data = null, string $message = '', int $status = 200): void
    {
        self::send([
            'ok'      => true,
            'mensaje' => $message,
            'datos'   => $data,
        ], $status);
    }

    /**
     * Emite una respuesta de error (400 Bad Request, 401 Unauthorized, 403, 404, 500).
     *
     * @param string $message Descripción del error principal.
     * @param int $status Código HTTP de error.
     * @param array<string, mixed>|array<int, string> $errors Lista detallada de errores de validación.
     */
    public static function error(string $message, int $status = 400, array $errors = []): void
    {
        self::send([
            'ok'      => false,
            'mensaje' => $message,
            'errores' => $errors,
        ], $status);
    }

    /**
     * Serializa los datos a JSON, define headers HTTP y detiene la ejecución.
     *
     * @param array<string, mixed> $body Estructura del cuerpo de respuesta.
     * @param int $status Código de estado HTTP.
     */
    private static function send(array $body, int $status): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);

        // Termina el ciclo de vida de la petición HTTP
        exit;
    }
}
