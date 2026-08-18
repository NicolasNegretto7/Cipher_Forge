<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Product;
use App\Repositories\ProductRepository;
use InvalidArgumentException;
use RuntimeException;

/**
 * Capa de lógica de negocio para la gestión de productos.
 * 
 * Contiene reglas de dominio, validaciones de integridad y orquesta
 * el flujo de información antes de persistirlo en el repositorio.
 */
class ProductService
{
    private ProductRepository $repository;

    public function __construct(?ProductRepository $repository = null)
    {
        $this->repository = $repository ?? new ProductRepository();
    }

    /**
     * Obtiene una lista de productos paginada y filtrada.
     * 
     * @param string|null $search Término de búsqueda opcional.
     * @param int $limit Cantidad máxima de registros.
     * @param int $offset Punto de inicio.
     * @return array<string, mixed> Lista de productos y metadatos de consulta.
     */
    public function getAllProducts(?string $search = null, int $limit = 50, int $offset = 0): array
    {
        $limit = max(1, min($limit, 100)); // Limita entre 1 y 100 para proteger memoria
        $offset = max(0, $offset);

        $products = $this->repository->findAll($search, $limit, $offset);

        return [
            'items'  => $products,
            'count'  => count($products),
            'limit'  => $limit,
            'offset' => $offset,
        ];
    }

    /**
     * Busca y valida la existencia de un producto por ID.
     * 
     * @param int $id ID a consultar.
     * @return Product
     * @throws RuntimeException Si el recurso no existe.
     */
    public function getProductById(int $id): Product
    {
        if ($id <= 0) {
            throw new InvalidArgumentException("El ID del producto debe ser un entero positivo.");
        }

        $product = $this->repository->findById($id);
        if ($product === null) {
            throw new RuntimeException("Producto con ID {$id} no fue encontrado.");
        }

        return $product;
    }

    /**
     * Valida y crea un nuevo producto en el sistema.
     * 
     * @param array<string, mixed> $data Datos recibidos desde la petición.
     * @return Product Producto creado con su ID asignado.
     * @throws InvalidArgumentException Si los datos violan las reglas de validación.
     */
    public function createProduct(array $data): Product
    {
        $errors = $this->validateProductData($data, isCreate: true);
        if (!empty($errors)) {
            $exception = new InvalidArgumentException("Error de validación de datos.");
            // Adjuntamos los errores específicos para que el Controller los formatee
            $exception->validationErrors = $errors;
            throw $exception;
        }

        // Regla de negocio: No permitir nombres de productos duplicados
        $existing = $this->repository->findByName($data['name']);
        if ($existing !== null) {
            $exception = new InvalidArgumentException("Ya existe un producto registrado con el nombre '{$data['name']}'.");
            $exception->validationErrors = ['name' => 'El nombre del producto ya está en uso.'];
            throw $exception;
        }

        $product = Product::fromArray($data);
        $newId = $this->repository->create($product);

        return $this->repository->findById($newId)
            ?? throw new RuntimeException("Error al recuperar el producto recién creado.");
    }

    /**
     * Actualiza la información de un producto existente.
     * 
     * @param int $id ID del producto a modificar.
     * @param array<string, mixed> $data Nuevos datos.
     * @return Product Producto con los cambios aplicados.
     */
    public function updateProduct(int $id, array $data): Product
    {
        $existingProduct = $this->getProductById($id);

        $errors = $this->validateProductData($data, isCreate: false);
        if (!empty($errors)) {
            $exception = new InvalidArgumentException("Error de validación de datos.");
            $exception->validationErrors = $errors;
            throw $exception;
        }

        // Si se actualiza el nombre, verificar que no colisione con otro producto distinto
        if (isset($data['name']) && $data['name'] !== $existingProduct->getName()) {
            $duplicate = $this->repository->findByName($data['name'], excludeId: $id);
            if ($duplicate !== null) {
                $exception = new InvalidArgumentException("Ya existe otro producto con el nombre '{$data['name']}'.");
                $exception->validationErrors = ['name' => 'El nombre ya está registrado en otro producto.'];
                throw $exception;
            }
        }

        // Combinar datos existentes con los nuevos (Patch/Put seguro)
        $mergedData = [
            'id'          => $id,
            'name'        => $data['name'] ?? $existingProduct->getName(),
            'description' => array_key_exists('description', $data) ? $data['description'] : $existingProduct->getDescription(),
            'price'       => isset($data['price']) ? (float) $data['price'] : $existingProduct->getPrice(),
            'stock'       => isset($data['stock']) ? (int) $data['stock'] : $existingProduct->getStock(),
        ];

        $updatedEntity = Product::fromArray($mergedData);
        $this->repository->update($updatedEntity);

        return $this->repository->findById($id)
            ?? throw new RuntimeException("Error al recuperar el producto actualizado.");
    }

    /**
     * Elimina un producto previa comprobación de existencia.
     * 
     * @param int $id ID del producto.
     * @return bool
     */
    public function deleteProduct(int $id): bool
    {
        // Valida que el producto existe antes de intentar eliminarlo (lanza 404 si no existe)
        $this->getProductById($id);

        return $this->repository->delete($id);
    }

    /**
     * Valida tipos de datos, obligatoriedad y límites numéricos.
     * 
     * @param array<string, mixed> $data Datos de entrada.
     * @param bool $isCreate Indica si es operación de creación (campos obligatorios).
     * @return array<string, string> Mapa de errores [campo => mensaje].
     */
    private function validateProductData(array $data, bool $isCreate): array
    {
        $errors = [];

        if ($isCreate || array_key_exists('name', $data)) {
            $name = trim((string) ($data['name'] ?? ''));
            if ($name === '') {
                $errors['name'] = 'El nombre del producto es obligatorio.';
            } elseif (mb_strlen($name) < 3 || mb_strlen($name) > 150) {
                $errors['name'] = 'El nombre debe tener entre 3 y 150 caracteres.';
            }
        }

        if ($isCreate || array_key_exists('price', $data)) {
            if (!isset($data['price']) || !is_numeric($data['price'])) {
                $errors['price'] = 'El precio debe ser un número válido.';
            } elseif ((float) $data['price'] <= 0) {
                $errors['price'] = 'El precio debe ser mayor a 0.';
            }
        }

        if ($isCreate || array_key_exists('stock', $data)) {
            if (!isset($data['stock']) || !is_numeric($data['stock'])) {
                $errors['stock'] = 'El stock debe ser un número entero.';
            } elseif ((int) $data['stock'] < 0) {
                $errors['stock'] = 'El stock no puede ser negativo.';
            }
        }

        return $errors;
    }
}
