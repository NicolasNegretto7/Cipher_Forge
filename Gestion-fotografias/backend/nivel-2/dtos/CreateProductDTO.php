<?php

/**
 * DTO PARA CREAR UN PRODUCTO (Data Transfer Object)
 * ==================================================================
 * Un DTO recibe datos que el validator ya aprobó, les da una FORMA
 * conocida, los NORMALIZA, los TIPA y los transporta hasta el service.
 * Así ProductService recibe un objeto con un contrato claro, en vez del
 * arreglo crudo que llegó desde HTTP.
 *
 * Este DTO selecciona únicamente los campos necesarios para crear un
 * producto. Normaliza los textos con trim(), convierte el precio a float
 * y el stock a int, y los guarda en propiedades con tipos definidos.
 *
 * Primero ProductValidator::validateStore() valida y después el
 * controller crea este DTO. El DTO NO valida, no busca productos en la
 * base, no aplica reglas del negocio y no responde HTTP.
 * ==================================================================
 */
class CreateProductDTO
{
    // Las propiedades tipadas documentan qué clase de dato transportamos.
    private string $name;
    private string $description;
    private float $price;
    private int $stock;
    private string $category;

    public function __construct(array $data)
    {
        // trim() elimina espacios al comienzo y al final.
        $this->name = trim($data['nombre']);

        // La descripción es opcional: ?? usa '' cuando no fue enviada.
        $this->description = trim($data['descripcion'] ?? '');

        // (float) y (int) son CASTS: convierten explícitamente el tipo.
        $this->price = (float) $data['precio'];
        $this->stock = (int) $data['stock'];
        $this->category = trim($data['categoria']);
    }

    // Cada getter devuelve un dato ya limpio y con su tipo definitivo.
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
