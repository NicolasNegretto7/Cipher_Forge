<?php

declare(strict_types=1);

namespace App\Models;

/**
 * ENTIDAD DE DOMINIO: PRODUCTO
 * ==============================================================================
 * WHAT: Modela un producto en el inventario con reglas de integridad en sus setters.
 * WHY:  El modelo protege sus propios invariantes de negocio: impide que el stock o
 *       el precio adquieran valores negativos sin importar quién los invoque.
 * ==============================================================================
 */
class Product
{
    private int $id;
    private string $name;
    private string $description;
    private float $price;
    private int $stock;
    private string $category;
    private bool $active;

    public function __construct(
        int $id,
        string $name,
        string $description,
        float $price,
        int $stock,
        string $category,
        bool $active = true
    ) {
        $this->id          = $id;
        $this->setName($name);
        $this->setDescription($description);
        $this->setPrice($price);
        $this->setStock($stock);
        $this->setCategory($category);
        $this->active      = $active;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function setId(int $id): void
    {
        $this->id = $id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): void
    {
        $this->name = trim($name);
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): void
    {
        $this->description = trim($description);
    }

    public function getPrice(): float
    {
        return $this->price;
    }

    public function setPrice(float $price): void
    {
        // Invariante: El precio nunca puede ser negativo
        $this->price = max(0.0, $price);
    }

    public function getStock(): int
    {
        return $this->stock;
    }

    public function setStock(int $stock): void
    {
        // Invariante: El stock nunca puede ser negativo
        $this->stock = max(0, $stock);
    }

    public function getCategory(): string
    {
        return $this->category;
    }

    public function setCategory(string $category): void
    {
        $this->category = trim($category);
    }

    public function isActive(): bool
    {
        return $this->active;
    }

    public function setActive(bool $active): void
    {
        $this->active = $active;
    }

    /**
     * Regla de dominio: determina si hay unidades disponibles para la venta.
     */
    public function hasStock(): bool
    {
        return $this->stock > 0;
    }

    /**
     * Serializa la entidad a array asociativo con nomenclatura pública para la API.
     *
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id'          => $this->id,
            'nombre'      => $this->name,
            'descripcion' => $this->description,
            'precio'      => $this->price,
            'stock'       => $this->stock,
            'categoria'   => $this->category,
            'activo'      => $this->active,
            'hay_stock'   => $this->hasStock(),
        ];
    }
}
