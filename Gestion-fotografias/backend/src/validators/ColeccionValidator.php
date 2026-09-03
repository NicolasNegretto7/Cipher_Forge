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
}
