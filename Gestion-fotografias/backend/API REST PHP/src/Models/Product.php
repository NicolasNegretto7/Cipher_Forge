<?php

declare(strict_types=1);

namespace App\Models;

use JsonSerializable;

/**
 * Entidad de dominio que representa un Producto.
 * 
 * Modela el estado del recurso y proporciona serialización controlada hacia JSON.
 */
class Product implements JsonSerializable
{
    public function __construct(
        private ?int $id,
        private string $name,
        private ?string $description,
        private float $price,
        private int $stock,
        private ?string $createdAt = null,
        private ?string $updatedAt = null
    ) {}

    /**
     * Construye una instancia de Product a partir de un array asociativo (ej. de BD o JSON).
     * 
     * @param array<string, mixed> $data Datos crudos.
     * @return self
     */
    public static function fromArray(array $data): self
    {
        return new self(
            id: isset($data['id']) ? (int) $data['id'] : null,
            name: (string) ($data['name'] ?? ''),
            description: isset($data['description']) ? (string) $data['description'] : null,
            price: isset($data['price']) ? (float) $data['price'] : 0.0,
            stock: isset($data['stock']) ? (int) $data['stock'] : 0,
            createdAt: $data['created_at'] ?? null,
            updatedAt: $data['updated_at'] ?? null
        );
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): ?string
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

    public function getCreatedAt(): ?string
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): ?string
    {
        return $this->updatedAt;
    }

    /**
     * Exporta la entidad a array asociativo estándar.
     * 
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'description' => $this->description,
            'price'       => $this->price,
            'stock'       => $this->stock,
            'created_at'  => $this->createdAt,
            'updated_at'  => $this->updatedAt,
        ];
    }

    /**
     * Define la representación del objeto cuando se ejecuta json_encode().
     * 
     * @return array<string, mixed>
     */
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
}
