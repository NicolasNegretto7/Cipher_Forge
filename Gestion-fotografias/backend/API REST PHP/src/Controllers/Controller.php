<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\AuthMiddleware;

/**
 * CONTROLADOR BASE (CLASE PADRE)
 * ==============================================================================
 * WHAT: Clase base para todos los controladores que proporciona métodos de ayuda
 *       para decodificar el cuerpo JSON (`requestData()`) y consultar el usuario
 *       autenticado (`user()`).
 * WHY:  Evita duplicar la lectura de `php://input` y `json_decode` en cada método.
 * ==============================================================================
 */
class Controller
{
    /**
     * Lee el flujo crudo php://input y devuelve los datos decodificados como array.
     *
     * @return array<string, mixed>
     */
    protected function requestData(): array
    {
        $raw = file_get_contents('php://input');

        if ($raw === false || trim($raw) === '') {
            return [];
        }

        $data = json_decode($raw, true);

        return is_array($data) ? $data : [];
    }

    /**
     * Retorna los datos del usuario autenticado provistos por AuthMiddleware.
     *
     * @return array<string, mixed>|null
     */
    protected function user(): ?array
    {
        return AuthMiddleware::user();
    }
}
