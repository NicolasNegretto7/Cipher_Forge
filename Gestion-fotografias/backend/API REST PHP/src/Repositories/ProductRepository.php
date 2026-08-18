<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\Product;
use Config\Database;
use PDO;

/**
 * Repositorio de acceso a datos para la entidad Product.
 * 
 * Gestiona consultas SQL puras utilizando PDO con Prepared Statements (sentencias preparadas)
 * para evitar inyecciones SQL y garantizar la persistencia de datos.
 */
class ProductRepository
{
    private PDO $db;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? (new Database())->getConnection();
    }

    /**
     * Recupera todos los productos, con soporte opcional de búsqueda por nombre.
     * 
     * @param string|null $search Término opcional de búsqueda.
     * @param int $limit Límite de resultados (paginación).
     * @param int $offset Desplazamiento de resultados.
     * @return Product[] Lista de objetos Product.
     */
    public function findAll(?string $search = null, int $limit = 50, int $offset = 0): array
    {
        $sql = "SELECT id, name, description, price, stock, created_at, updated_at FROM products";
        $params = [];

        if ($search !== null && trim($search) !== '') {
            $sql .= " WHERE name LIKE :search OR description LIKE :searchDesc";
            $params[':search'] = '%' . trim($search) . '%';
            $params[':searchDesc'] = '%' . trim($search) . '%';
        }

        $sql .= " ORDER BY id DESC LIMIT :limit OFFSET :offset";

        $stmt = $this->db->prepare($sql);

        // Enlaza parámetros de texto
        foreach ($params as $key => $val) {
            $stmt->bindValue($key, $val, PDO::PARAM_STR);
        }

        // Enlaza límites numéricos explícitamente como enteros
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

        $stmt->execute();
        $rows = $stmt->fetchAll();

        $products = [];
        foreach ($rows as $row) {
            $products[] = Product::fromArray($row);
        }

        return $products;
    }

    /**
     * Busca un producto por su clave primaria ID.
     * 
     * @param int $id Identificador único del producto.
     * @return Product|null Objeto Product si existe, null en caso contrario.
     */
    public function findById(int $id): ?Product
    {
        $sql = "SELECT id, name, description, price, stock, created_at, updated_at 
                FROM products 
                WHERE id = :id 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $row = $stmt->fetch();
        if (!$row) {
            return null;
        }

        return Product::fromArray($row);
    }

    /**
     * Busca un producto por su nombre exacto (útil para validar duplicados).
     * 
     * @param string $name Nombre a buscar.
     * @param int|null $excludeId ID que se ignora en la búsqueda (durante updates).
     * @return Product|null
     */
    public function findByName(string $name, ?int $excludeId = null): ?Product
    {
        $sql = "SELECT id, name, description, price, stock, created_at, updated_at 
                FROM products 
                WHERE LOWER(name) = LOWER(:name)";

        if ($excludeId !== null) {
            $sql .= " AND id != :excludeId";
        }

        $sql .= " LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':name', trim($name), PDO::PARAM_STR);

        if ($excludeId !== null) {
            $stmt->bindValue(':excludeId', $excludeId, PDO::PARAM_INT);
        }

        $stmt->execute();
        $row = $stmt->fetch();

        return $row ? Product::fromArray($row) : null;
    }

    /**
     * Inserta un nuevo producto en la base de datos.
     * 
     * @param Product $product Entidad con los datos a persistir.
     * @return int ID autonumérico generado por MySQL.
     */
    public function create(Product $product): int
    {
        $sql = "INSERT INTO products (name, description, price, stock) 
                VALUES (:name, :description, :price, :stock)";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':name', $product->getName(), PDO::PARAM_STR);
        $stmt->bindValue(':description', $product->getDescription(), $product->getDescription() === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':price', $product->getPrice());
        $stmt->bindValue(':stock', $product->getStock(), PDO::PARAM_INT);

        $stmt->execute();

        return (int) $this->db->lastInsertId();
    }

    /**
     * Actualiza los datos de un producto existente.
     * 
     * @param Product $product Entidad con los datos modificados.
     * @return bool True si se ejecutó con éxito.
     */
    public function update(Product $product): bool
    {
        $sql = "UPDATE products 
                SET name = :name, 
                    description = :description, 
                    price = :price, 
                    stock = :stock 
                WHERE id = :id";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $product->getId(), PDO::PARAM_INT);
        $stmt->bindValue(':name', $product->getName(), PDO::PARAM_STR);
        $stmt->bindValue(':description', $product->getDescription(), $product->getDescription() === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':price', $product->getPrice());
        $stmt->bindValue(':stock', $product->getStock(), PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Elimina físicamente un registro por su ID.
     * 
     * @param int $id ID del producto a eliminar.
     * @return bool True si una fila fue afectada.
     */
    public function delete(int $id): bool
    {
        $sql = "DELETE FROM products WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }
}
