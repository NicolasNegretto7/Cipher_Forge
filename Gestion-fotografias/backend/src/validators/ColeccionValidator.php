<?php
// QUÉ: Valida los datos de entrada para la creación de una colección y genera su DTO.
// POR QUÉ: Asegura la integridad de los datos antes de que interactúen con el servicio o la base de datos.

declare(strict_types=1);

namespace App\validators;

use App\Core\Response;
use App\dtos\CreateColeccionDto;

class ColeccionValidator
{
    /**
     * Valida los datos de creación de colección y retorna un CreateColeccionDto.
     * Si ocurre algún error de validación, interrumpe el flujo emitiendo HTTP 400.
     */
    public function validateCreate(array $data): CreateColeccionDto
    {
        $errores = [];

        // CF-05: La ruta exige autenticación ('auth') y la colección SIEMPRE pertenece al
        // usuario autenticado. Se ignora cualquier fotografo_id enviado en el body y se
        // toma la identidad del token JWT (el servidor es la autoridad).
        $usuario = \App\middlewares\AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión para crear una colección.', 401);
        }
        $data['fotografo_id'] = $usuario['id'];

        // Validar fotografo_id
        if (!isset($data['fotografo_id']) || !is_numeric($data['fotografo_id']) || (int) $data['fotografo_id'] <= 0) {
            $errores[] = 'El identificador del fotógrafo (fotografo_id) es obligatorio y debe ser un entero positivo.';
        }

        // Validar titulo (máximo 60 caracteres según schema.sql)
        if (empty($data['titulo']) || trim((string) $data['titulo']) === '') {
            $errores[] = 'El título de la colección es obligatorio.';
        } elseif (mb_strlen(trim((string) $data['titulo'])) > 60) {
            $errores[] = 'El título no puede superar los 60 caracteres.';
        }

        // Validar tipo_visibilidad (ENUM: 'privada', 'publica')
        if (empty($data['tipo_visibilidad'])) {
            $errores[] = 'El tipo de visibilidad es obligatorio ("privada" o "publica").';
        } elseif (!in_array($data['tipo_visibilidad'], ['privada', 'publica'], true)) {
            $errores[] = 'El tipo de visibilidad debe ser estrictamente "privada" o "publica".';
        }

        // Validar descripcion (opcional, máximo 90 caracteres según schema.sql)
        $descripcion = null;
        if (isset($data['descripcion']) && trim((string) $data['descripcion']) !== '') {
            $descripcion = trim((string) $data['descripcion']);
            if (mb_strlen($descripcion) > 90) {
                $errores[] = 'La descripción no puede superar los 90 caracteres.';
            }
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return new CreateColeccionDto(
            fotografoId:     (int) $data['fotografo_id'],
            titulo:          trim((string) $data['titulo']),
            tipoVisibilidad: $data['tipo_visibilidad'],
            descripcion:     $descripcion,
        );
    }

    /**
     * Valida los campos de actualización de una colección existente (PUT).
     * H-04: Controla límites de VARCHAR(60) para título y VARCHAR(90) para descripción.
     */
    public function validateUpdate(array $data): array
    {
        $errores = [];
        $sanitizado = [];

        if (array_key_exists('titulo', $data)) {
            $titulo = trim((string) $data['titulo']);
            if ($titulo === '') {
                $errores[] = 'El título no puede estar vacío.';
            } elseif (mb_strlen($titulo) > 60) {
                $errores[] = 'El título no puede superar los 60 caracteres.';
            } else {
                $sanitizado['titulo'] = $titulo;
            }
        }

        if (array_key_exists('descripcion', $data)) {
            $descripcion = trim((string) $data['descripcion']);
            if (mb_strlen($descripcion) > 90) {
                $errores[] = 'La descripción no puede superar los 90 caracteres.';
            } else {
                $sanitizado['descripcion'] = $descripcion === '' ? null : $descripcion;
            }
        }

        if (array_key_exists('tipo_visibilidad', $data)) {
            $visibilidad = (string) $data['tipo_visibilidad'];
            if (!in_array($visibilidad, ['privada', 'publica'], true)) {
                $errores[] = 'El tipo de visibilidad debe ser estrictamente "privada" o "publica".';
            } else {
                $sanitizado['tipo_visibilidad'] = $visibilidad;
            }
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return $sanitizado;
    }

    /**
     * Valida y normaliza una lista de hashtags (HU26).
     * H-09: Asegura que ningún hashtag supere el límite de 40 caracteres (VARCHAR(40) en schema.sql).
     */
    public function validateHashtags(array $hashtags): array
    {
        $errores = [];
        $normalizados = [];

        foreach ($hashtags as $rawTag) {
            $tag = strtolower(ltrim(trim((string) $rawTag), '#'));
            if ($tag === '') {
                continue;
            }
            if (mb_strlen($tag) > 40) {
                $errores[] = "El hashtag '#{$tag}' supera el límite permitido de 40 caracteres.";
            } else {
                $normalizados[] = $tag;
            }
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return $normalizados;
    }
}

