<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\Product;
use PDO;

/**
 * REPOSITORIO DE PRODUCTOS (ACCESO A DATOS)
 * ==============================================================================
 * WHAT: Realiza las operaciones CRUD contra la tabla `productos` mediante PDO.
 * WHY:  Mantiene create() y update() explícitos con sus sentencias SQL separadas
 *       (INSERT y UPDATE) usando parámetros vinculados para total seguridad.
 * ==============================================================================
 */
class ProductRepository extends Repository
{
    /**
     * Recupera todos los productos, con soporte opcional de filtro por categoría.
     *
     * @param string|null $category
     * @return Product[]
     */
    public function findAll(?string $category = null): array
    {
        if ($category === null) {
            $sql = 'SELECT id, nombre, descripcion, precio, stock, categoria, activo FROM productos ORDER BY id ASC';
            $stmt = $this->db->prepare($sql);
            $stmt->execute();
        } else {
            $sql = 'SELECT id, nombre, descripcion, precio, stock, categoria, activo 
                    FROM productos 
                    WHERE categoria = :categoria 
                    ORDER BY id ASC';
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(':categoria', $category, PDO::PARAM_STR);
            $stmt->execute();
        }

        $products = [];
        foreach ($stmt->fetchAll() as $row) {
            $products[] = $this->buildProduct($row);
        }

        return $products;
    }

    /**
     * Busca un producto por su clave primaria ID.
     */
    public function findById(int $id): ?Product
    {
        $sql = 'SELECT id, nombre, descripcion, precio, stock, categoria, activo 
                FROM productos 
                WHERE id = :id 
                LIMIT 1';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row === false ? null : $this->buildProduct($row);
    }

    /**
     * Busca un producto por su nombre exacto (para evitar duplicados).
     */
    public function findByName(string $name): ?Product
    {
        $sql = 'SELECT id, nombre, descripcion, precio, stock, categoria, activo 
                FROM productos 
                WHERE LOWER(nombre) = LOWER(:nombre) 
                LIMIT 1';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':nombre', trim($name), PDO::PARAM_STR);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row === false ? null : $this->buildProduct($row);
    }

    /**
     * Inserta un producto nuevo en la base de datos y asigna su ID autonumérico.
     */
    public function create(Product $product): Product
    {
        $sql = 'INSERT INTO productos (nombre, descripcion, precio, stock, categoria, activo)
                VALUES (:nombre, :descripcion, :precio, :stock, :categoria, 1)';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':nombre', $product->getName(), PDO::PARAM_STR);
        $stmt->bindValue(':descripcion', $product->getDescription(), PDO::PARAM_STR);
        $stmt->bindValue(':precio', $product->getPrice());
        $stmt->bindValue(':stock', $product->getStock(), PDO::PARAM_INT);
        $stmt->bindValue(':categoria', $product->getCategory(), PDO::PARAM_STR);
        $stmt->execute();

        $product->setId((int) $this->db->lastInsertId());

        return $product;
    }

    /**
     * Actualiza los datos de un producto existente.
     */
    public function update(Product $product): Product
    {
        $sql = 'UPDATE productos
                   SET nombre = :nombre,
                       descripcion = :descripcion,
                       precio = :precio,
                       stock = :stock,
                       categoria = :categoria
                 WHERE id = :id';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':nombre', $product->getName(), PDO::PARAM_STR);
        $stmt->bindValue(':descripcion', $product->getDescription(), PDO::PARAM_STR);
        $stmt->bindValue(':precio', $product->getPrice());
        $stmt->bindValue(':stock', $product->getStock(), PDO::PARAM_INT);
        $stmt->bindValue(':categoria', $product->getCategory(), PDO::PARAM_STR);
        $stmt->bindValue(':id', $product->getId(), PDO::PARAM_INT);
        $stmt->execute();

        return $product;
    }

    /**
     * Elimina físicamente un producto de la base de datos.
     */
    public function delete(int $id): void
    {
        $sql = 'DELETE FROM productos WHERE id = :id';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
    }

    /**
     * Convierte una fila asociativa en una instancia del modelo Product.
     *
     * @param array<string, mixed> $row
     */
    private function buildProduct(array $row): Product
    {
        return new Product(
            (int) $row['id'],
            (string) $row['nombre'],
            (string) ($row['descripcion'] ?? ''),
            (float) $row['precio'],
            (int) $row['stock'],
            (string) $row['categoria'],
            (bool) ($row['activo'] ?? true)
        );
    }
}
