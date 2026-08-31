<?php
// QUÉ: Helper para leer y parsear el body JSON de la petición HTTP.
// POR QUÉ: El Router no pasa parámetros al controlador — cada controlador
//           usa esta clase para obtener los datos del body de forma segura.

declare(strict_types=1);

namespace App\Core;

class Request
{
    private array $body;

    public function __construct()
    {
        $raw = file_get_contents('php://input');

        // Si el body está vacío o no es JSON válido, queda como array vacío
        $decoded = json_decode($raw ?: '', true);
        $this->body = is_array($decoded) ? $decoded : [];
    }

    /**
     * Retorna todo el body parseado como array asociativo.
     */
    public function getBody(): array
    {
        return $this->body;
    }

    /**
     * Retorna el valor de una clave específica del body.
     * Si no existe, retorna el valor por defecto.
     */
    public function get(string $key, mixed $default = null): mixed
    {
        return $this->body[$key] ?? $default;
    }
}
