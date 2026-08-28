<?php

/**
 * CLASE PRODUCT (producto)
 * ==================================================================
 * Igual que User, pero acá SÍ hacen falta SETTERS, porque un producto
 * se puede modificar (cambiarle el precio, el stock...).
 *
 * ¿Y por qué no hacer las propiedades públicas y listo?
 * Mirá el setStock() de más abajo: adentro del setter podemos poner
 * REGLAS. Así se vuelve imposible que un producto quede con stock
 * negativo, no importa quién intente modificarlo.
 *
 * Esa es la gracia del encapsulamiento: el objeto se cuida solo.
 * ==================================================================
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

    public function __construct($id, $name, $description, $price, $stock, $category, $active = true)
    {
        $this->id          = $id;
        $this->name        = $name;
        $this->description = $description;
        $this->price       = $price;
        $this->stock       = $stock;
        $this->category    = $category;
        $this->active      = $active;
    }

    // ------------------------------------------------------------------
    // GETTERS: para leer.
    // ------------------------------------------------------------------

    public function getId()
    {
        return $this->id;
    }

    public function getName()
    {
        return $this->name;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function getPrice()
    {
        return $this->price;
    }

    public function getStock()
    {
        return $this->stock;
    }

    public function getCategory()
    {
        return $this->category;
    }

    public function isActive()
    {
        return $this->active;
    }

    // ------------------------------------------------------------------
    // SETTERS: para modificar, pero CON REGLAS.
    // ------------------------------------------------------------------

    public function setId($id)
    {
        $this->id = $id;
    }

    public function setName($name)
    {
        $this->name = trim($name);
    }

    public function setDescription($description)
    {
        $this->description = trim($description);
    }

    public function setPrice($price)
    {
        // Regla: el precio nunca puede ser negativo.
        $this->price = max(0, (float) $price);
    }

    public function setStock($stock)
    {
        // Regla: el stock nunca puede ser negativo.
        // Si alguien manda -5, guardamos 0.
        $this->stock = max(0, (int) $stock);
    }

    public function setCategory($category)
    {
        $this->category = $category;
    }

    // ------------------------------------------------------------------
    // MÉTODOS PROPIOS
    // ------------------------------------------------------------------

    /**
     * Una regla del negocio que vive adentro del objeto.
     * El producto sabe si tiene stock; no hace falta preguntárselo
     * desde afuera con un if cada vez.
     */
    public function hasStock()
    {
        return $this->stock > 0;
    }

    /**
     * Convierte el objeto en arreglo, para mandarlo como JSON.
     *
     * (Los nombres de los campos van en español porque son el "contrato"
     * de nuestra API: es lo que ven los que la consumen.)
     */
    public function toArray()
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
