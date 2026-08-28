<?php

declare(strict_types=1);

namespace App\Validators;

/**
 * VALIDADOR DE PRODUCTOS
 * ==============================================================================
 * WHAT: Valida el formato y los tipos de datos para cada endpoint del recurso Productos.
 * WHY:  Mantiene los controladores limpios y libres de condicionales de validación
 *       repetitivos. Proporciona una interfaz estática con nombres semánticos.
 * ==============================================================================
 */
class ProductValidator
{
    /**
     * Valida el filtro opcional de categorías en GET /productos.
     *
     * @param mixed $category
     * @return array<int, string>
     */
    public static function validateIndex(mixed $category): array
    {
        if ($category !== null && (!is_string($category) || trim($category) === '')) {
            return ['La categoría no es válida.'];
        }

        return [];
    }

    /**
     * Valida el ID en GET /productos/{id}.
     */
    public static function validateShow(mixed $id): array
    {
        return self::validateId($id);
    }

    /**
     * Valida los datos requeridos para POST /productos.
     *
     * @param array<string, mixed> $data
     * @return array<int, string>
     */
    public static function validateStore(array $data): array
    {
        $errors = [];

        $name        = $data['nombre'] ?? '';
        $description = $data['descripcion'] ?? '';
        $price       = $data['precio'] ?? null;
        $stock       = $data['stock'] ?? null;
        $category    = $data['categoria'] ?? '';

        if (!is_string($name) || strlen(trim($name)) < 3) {
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        if (!is_string($description)) {
            $errors[] = 'La descripción tiene que ser texto.';
        }

        if (!is_numeric($price) || (float) $price < 0) {
            $errors[] = 'El precio tiene que ser un número mayor o igual a 0.';
        }

        if (filter_var($stock, FILTER_VALIDATE_INT) === false || (int) $stock < 0) {
            $errors[] = 'El stock tiene que ser un entero mayor o igual a 0.';
        }

        if (!is_string($category) || trim($category) === '') {
            $errors[] = 'Falta la categoría.';
        }

        return $errors;
    }

    /**
     * Valida la actualización parcial en PUT /productos/{id}.
     *
     * @param mixed $id
     * @param array<string, mixed> $data
     * @return array<int, string>
     */
    public static function validateUpdate(mixed $id, array $data): array
    {
        $errors = self::validateId($id);

        $allowedFields = ['nombre', 'descripcion', 'precio', 'stock', 'categoria'];
        $receivedFields = array_intersect(array_keys($data), $allowedFields);

        if (count($receivedFields) === 0) {
            $errors[] = 'No mandaste ningún campo válido para cambiar.';
        }

        if (array_key_exists('nombre', $data) && (!is_string($data['nombre']) || strlen(trim($data['nombre'])) < 3)) {
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        if (array_key_exists('descripcion', $data) && !is_string($data['descripcion'])) {
            $errors[] = 'La descripción tiene que ser texto.';
        }

        if (array_key_exists('precio', $data) && (!is_numeric($data['precio']) || (float) $data['precio'] < 0)) {
            $errors[] = 'El precio tiene que ser un número mayor o igual a 0.';
        }

        if (array_key_exists('stock', $data) && (filter_var($data['stock'], FILTER_VALIDATE_INT) === false || (int) $data['stock'] < 0)) {
            $errors[] = 'El stock tiene que ser un entero mayor o igual a 0.';
        }

        if (array_key_exists('categoria', $data) && (!is_string($data['categoria']) || trim($data['categoria']) === '')) {
            $errors[] = 'La categoría no puede estar vacía.';
        }

        return $errors;
    }

    /**
     * Valida el ID en DELETE /productos/{id}.
     */
    public static function validateDestroy(mixed $id): array
    {
        return self::validateId($id);
    }

    /**
     * Valida el ID y la cantidad en POST /productos/{id}/vender.
     *
     * @param mixed $id
     * @param array<string, mixed> $data
     * @return array<int, string>
     */
    public static function validateSell(mixed $id, array $data): array
    {
        $errors = self::validateId($id);

        $quantity = $data['cantidad'] ?? 1;

        if (filter_var($quantity, FILTER_VALIDATE_INT) === false || (int) $quantity < 1) {
            $errors[] = 'La cantidad tiene que ser un entero mayor o igual a 1.';
        }

        return $errors;
    }

    /**
     * Valida que un identificador numérico sea un entero positivo.
     *
     * @param mixed $id
     * @return array<int, string>
     */
    private static function validateId(mixed $id): array
    {
        if (filter_var($id, FILTER_VALIDATE_INT) === false || (int) $id < 1) {
            return ['El ID del producto no es válido.'];
        }

        return [];
    }
}
