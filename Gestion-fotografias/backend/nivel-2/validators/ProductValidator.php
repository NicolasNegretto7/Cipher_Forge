<?php

/**
 * VALIDADOR DE PRODUCTOS
 * ==================================================================
 * Cada endpoint tiene su propio método público. Eso permite leer en el
 * controller ProductValidator::validateStore() y saber inmediatamente
 * qué petición se está validando.
 *
 * Este archivo controla FORMATO: campos, texto, números e IDs.
 * Las reglas que necesitan consultar datos siguen en ProductService.
 *
 * Los métodos son "static": no guardan estado y se llaman con :: sin
 * crear un objeto ProductValidator.
 * ==================================================================
 */
class ProductValidator
{
    /** Valida GET /productos y su filtro opcional ?categoria=. */
    public static function validateIndex($category): array
    {
        // El operador !== significa "distinto en valor o tipo"; && significa "Y".
        // Si no mandaron categoría vale null y no hay nada que validar.
        if ($category !== null && (!is_string($category) || trim($category) === '')) {
            // Se puede devolver directamente un arreglo con un solo error.
            return ['La categoría no es válida.'];
        }

        return [];
    }

    /** Valida el {id} recibido en GET /productos/{id}. */
    public static function validateShow($id): array
    {
        // self:: llama a otro método de esta misma clase.
        return self::validateId($id);
    }

    /** Valida todos los campos necesarios para POST /productos. */
    public static function validateStore(array $data): array
    {
        $errors = [];

        // El operador ?? coloca un valor seguro cuando falta un campo.
        $name = $data['nombre'] ?? '';
        $description = $data['descripcion'] ?? '';
        $price = $data['precio'] ?? null;
        $stock = $data['stock'] ?? null;
        $category = $data['categoria'] ?? '';

        if (!is_string($name) || strlen(trim($name)) < 3) {
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        if (!is_string($description)) {
            $errors[] = 'La descripción tiene que ser texto.';
        }

        // is_numeric() acepta números y textos numéricos como "25.5".
        if (!is_numeric($price) || $price < 0) {
            $errors[] = 'El precio tiene que ser un número mayor o igual a 0.';
        }

        // FILTER_VALIDATE_INT comprueba que sea un entero, no un decimal.
        // filter_var() devuelve false cuando el valor no supera el filtro.
        if (filter_var($stock, FILTER_VALIDATE_INT) === false || $stock < 0) {
            $errors[] = 'El stock tiene que ser un entero mayor o igual a 0.';
        }

        if (!is_string($category) || trim($category) === '') {
            $errors[] = 'Falta la categoría.';
        }

        return $errors;
    }

    /**
     * Valida PUT /productos/{id}.
     * En un update los campos son opcionales, pero al menos uno debe venir.
     */
    public static function validateUpdate($id, array $data): array
    {
        // Empezamos con los posibles errores del ID y luego agregamos otros.
        $errors = self::validateId($id);

        // Esta es la lista de nombres de campos que el endpoint reconoce.
        $allowedFields = ['nombre', 'descripcion', 'precio', 'stock', 'categoria'];

        // array_keys() obtiene las claves recibidas.
        // array_intersect() conserva las que también están entre las permitidas.
        $receivedFields = array_intersect(array_keys($data), $allowedFields);

        // count() cuenta elementos. Si da 0, no hay nada válido para modificar.
        if (count($receivedFields) === 0) {
            $errors[] = 'No mandaste ningún campo válido para cambiar.';
        }

        // array_key_exists() distingue "no vino" de "vino con algún valor".
        // En update solo validamos un campo cuando realmente fue enviado.
        if (array_key_exists('nombre', $data)
            && (!is_string($data['nombre']) || strlen(trim($data['nombre'])) < 3)) {
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        if (array_key_exists('descripcion', $data) && !is_string($data['descripcion'])) {
            $errors[] = 'La descripción tiene que ser texto.';
        }

        if (array_key_exists('precio', $data)
            && (!is_numeric($data['precio']) || $data['precio'] < 0)) {
            $errors[] = 'El precio tiene que ser un número mayor o igual a 0.';
        }

        if (array_key_exists('stock', $data)
            && (filter_var($data['stock'], FILTER_VALIDATE_INT) === false || $data['stock'] < 0)) {
            $errors[] = 'El stock tiene que ser un entero mayor o igual a 0.';
        }

        if (array_key_exists('categoria', $data)
            && (!is_string($data['categoria']) || trim($data['categoria']) === '')) {
            $errors[] = 'La categoría no puede estar vacía.';
        }

        return $errors;
    }

    /** Valida el {id} recibido en DELETE /productos/{id}. */
    public static function validateDestroy($id): array
    {
        return self::validateId($id);
    }

    /** Valida el ID y la cantidad de POST /productos/{id}/vender. */
    public static function validateSell($id, array $data): array
    {
        $errors = self::validateId($id);

        // Si no mandan cantidad, el operador ?? usa 1 como valor por defecto.
        $quantity = $data['cantidad'] ?? 1;

        if (filter_var($quantity, FILTER_VALIDATE_INT) === false || $quantity < 1) {
            $errors[] = 'La cantidad tiene que ser un entero mayor o igual a 1.';
        }

        return $errors;
    }

    /**
     * private significa que este método solo se usa dentro del validator.
     * Se reutiliza para no copiar la misma validación en show/update/etc.
     */
    private static function validateId($id): array
    {
        if (filter_var($id, FILTER_VALIDATE_INT) === false || $id < 1) {
            return ['El ID del producto no es válido.'];
        }

        return [];
    }
}
