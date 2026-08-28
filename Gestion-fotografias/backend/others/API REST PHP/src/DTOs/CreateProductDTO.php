<?php

declare(strict_types=1);

namespace App\DTOs;

/**
 * DTO DE CREACIÓN DE PRODUCTO (DATA TRANSFER OBJECT)
 * ==============================================================================
 * WHAT: Transporta y normaliza los datos validados para la creación de un nuevo producto.
 * WHY:  Aplica casts explícitos de tipos numéricos y saneamiento de espacios.
 * ==============================================================================
 */
class CreateProductDTO
{
    private string $name;
    private string $description;
    private float $price;
    private int $stock;
    private string $category;

    public function __construct(array $data)
    {
        $this->name        = trim((string) ($data['nombre'] ?? ''));
        $this->description = trim((string) ($data['descripcion'] ?? ''));
        $this->price       = (float) ($data['precio'] ?? 0.0);
        $this->stock       = (int) ($data['stock'] ?? 0);
        $this->category    = trim((string) ($data['categoria'] ?? ''));
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function getPrice(): float
    {
        return $this->price;
    }

    public function getStock(): int
    {
        return $this->stock;
    }

    public function getCategory(): string
    {
        return $this->category;
    }
}
