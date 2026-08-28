<?php

declare(strict_types=1);

namespace App\DTOs;

/**
 * DTO DE ACTUALIZACIÓN DE PRODUCTO (DATA TRANSFER OBJECT)
 * ==============================================================================
 * WHAT: Almacena y tipa exclusivamente los campos que el cliente envió para actualizar.
 * WHY:  En operaciones parciales (PATCH/PUT), permite que el servicio distinga
 *       entre un campo omitido y un campo enviado con valor null o vacío.
 * ==============================================================================
 */
class UpdateProductDTO
{
    /**
     * @var array<string, mixed>
     */
    private array $fields = [];

    public function __construct(array $data)
    {
        if (array_key_exists('nombre', $data)) {
            $this->fields['nombre'] = trim((string) $data['nombre']);
        }

        if (array_key_exists('descripcion', $data)) {
            $this->fields['descripcion'] = trim((string) $data['descripcion']);
        }

        if (array_key_exists('precio', $data)) {
            $this->fields['precio'] = (float) $data['precio'];
        }

        if (array_key_exists('stock', $data)) {
            $this->fields['stock'] = (int) $data['stock'];
        }

        if (array_key_exists('categoria', $data)) {
            $this->fields['categoria'] = trim((string) $data['categoria']);
        }
    }

    /**
     * Comprueba si un campo específico fue enviado en la petición.
     */
    public function has(string $field): bool
    {
        return array_key_exists($field, $this->fields);
    }

    /**
     * Retorna el valor tipado del campo solicitado.
     */
    public function get(string $field): mixed
    {
        return $this->fields[$field] ?? null;
    }
}
