<?php

declare(strict_types=1);

namespace App\Core;


class Response
{
   
    public static function success(mixed $data = null, string $message = '', int $status = 200): void
    {
        self::send([
            'ok'      => true,
            'mensaje' => $message,
            'datos'   => $data,
        ], $status);
    }

    
    public static function error(string $message, int $status = 400, array $errors = []): void
    {
        self::send([
            'ok'      => false,
            'mensaje' => $message,
            'errores' => $errors,
        ], $status);
    }

    
    private static function send(array $body, int $status): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);

        exit;
    }
}
