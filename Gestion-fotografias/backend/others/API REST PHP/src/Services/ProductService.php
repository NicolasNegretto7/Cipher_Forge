<?php

declare(strict_types=1);

namespace App\Services;

use App\Core\Response;
use App\DTOs\CreateProductDTO;
use App\DTOs\SellProductDTO;
use App\DTOs\UpdateProductDTO;
use App\Models\Product;
use App\Repositories\ProductRepository;

/**
 * SERVICIO DE PRODUCTOS (REGLAS DE NEGOCIO)
 * ==============================================================================
 * WHAT: Contiene las reglas operativas y lógica de dominio del catálogo y ventas.
 * WHY:  Centraliza las reglas del sistema para que puedan ser reutilizadas desde
 *       la API REST, tareas programadas (CLI) u otros módulos sin duplicar lógica:
 *       - No se permiten dos productos con el mismo nombre.
 *       - No se puede vender más stock del disponible.
 *       - No se puede eliminar un producto si todavía tiene existencias en stock.
 * ==============================================================================
 */
class ProductService
{
    private ProductRepository $repository;

    public function __construct(?ProductRepository $repository = null)
    {
        $this->repository = $repository ?? new ProductRepository();
    }

    /**
     * Retorna el listado de productos serializados a array.
     *
     * @param string|null $category
     * @return array<int, array<string, mixed>>
     */
    public function getAll(?string $category = null): array
    {
        $products = $this->repository->findAll($category);

        $list = [];
        foreach ($products as $product) {
            $list[] = $product->toArray();
        }

        return $list;
    }

    /**
     * Obtiene un producto por su ID.
     *
     * @param int $id
     * @return array<string, mixed>
     */
    public function getById(int $id): array
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            Response::error("No existe el producto con ID {$id}.", 404);
        }

        return $product->toArray();
    }

    /**
     * Crea un producto nuevo previa validación de unicidad de nombre.
     *
     * @param CreateProductDTO $dto
     * @return array<string, mixed>
     */
    public function create(CreateProductDTO $dto): array
    {
        // Regla: No duplicar nombres de productos
        if ($this->repository->findByName($dto->getName()) !== null) {
            Response::error('Ya existe un producto con ese nombre.', 400);
        }

        $product = new Product(
            0,
            $dto->getName(),
            $dto->getDescription(),
            $dto->getPrice(),
            $dto->getStock(),
            $dto->getCategory()
        );

        $created = $this->repository->create($product);

        return $created->toArray();
    }

    /**
     * Modifica selectivamente los campos enviados de un producto.
     *
     * @param int $id
     * @param UpdateProductDTO $dto
     * @return array<string, mixed>
     */
    public function update(int $id, UpdateProductDTO $dto): array
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            Response::error("No existe el producto con ID {$id}.", 404);
        }

        if ($dto->has('nombre')) {
            $product->setName((string) $dto->get('nombre'));
        }

        if ($dto->has('descripcion')) {
            $product->setDescription((string) $dto->get('descripcion'));
        }

        if ($dto->has('precio')) {
            $product->setPrice((float) $dto->get('precio'));
        }

        if ($dto->has('stock')) {
            $product->setStock((int) $dto->get('stock'));
        }

        if ($dto->has('categoria')) {
            $product->setCategory((string) $dto->get('categoria'));
        }

        $updated = $this->repository->update($product);

        return $updated->toArray();
    }

    /**
     * Elimina un producto. Falla si todavía queda mercadería en stock.
     *
     * @param int $id
     */
    public function delete(int $id): void
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            Response::error("No existe el producto con ID {$id}.", 404);
        }

        // Regla de negocio: primero debe liquidarse o darse de baja el stock
        if ($product->hasStock()) {
            Response::error(
                "No se puede borrar: todavía quedan {$product->getStock()} unidades en stock.",
                400
            );
        }

        $this->repository->delete($id);
    }

    /**
     * Realiza la operación de venta descontando stock de forma atómica.
     *
     * @param int $id
     * @param SellProductDTO $dto
     * @return array<string, mixed>
     */
    public function sell(int $id, SellProductDTO $dto): array
    {
        $quantity = $dto->getQuantity();
        $product = $this->repository->findById($id);

        // Regla 1: El producto debe existir
        if ($product === null) {
            Response::error("No existe el producto con ID {$id}.", 404);
        }

        // Regla 2: Existencia de stock suficiente
        if ($product->getStock() < $quantity) {
            Response::error(
                "No hay stock suficiente. Quedan {$product->getStock()} unidades.",
                400
            );
        }

        // Aplicación del cambio de estado y persistencia
        $product->setStock($product->getStock() - $quantity);
        $this->repository->update($product);

        return [
            'vendidas'      => $quantity,
            'total_a_pagar' => $quantity * $product->getPrice(),
            'producto'      => $product->toArray(),
        ];
    }
}
