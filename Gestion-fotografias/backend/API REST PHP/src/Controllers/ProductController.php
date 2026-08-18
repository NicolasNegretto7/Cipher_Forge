<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Services\ProductService;
use InvalidArgumentException;
use RuntimeException;
use Throwable;

/**
 * Controlador REST para el recurso Productos.
 * 
 * Gestiona el ciclo HTTP: recibe datos de Request, interactúa con ProductService
 * y emite respuestas JSON formateadas con códigos de estado semánticos.
 */
class ProductController
{
    private ProductService $service;

    public function __construct(?ProductService $service = null)
    {
        $this->service = $service ?? new ProductService();
    }

    /**
     * GET /api/products
     * Lista productos con soporte de búsqueda y paginación.
     */
    public function index(Request $request): void
    {
        try {
            $search = $request->getQueryParam('search');
            $limit = (int) $request->getQueryParam('limit', 50);
            $offset = (int) $request->getQueryParam('offset', 0);

            $result = $this->service->getAllProducts($search, $limit, $offset);

            Response::success($result, 'Listado de productos obtenido exitosamente.', 200);
        } catch (Throwable $e) {
            Response::error('Error al consultar productos: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/products/{id}
     * Obtiene el detalle de un único producto por su ID.
     */
    public function show(Request $request, array $params): void
    {
        try {
            $id = (int) ($params['id'] ?? 0);
            $product = $this->service->getProductById($id);

            Response::success($product, 'Producto encontrado.', 200);
        } catch (InvalidArgumentException $e) {
            Response::error($e->getMessage(), 400);
        } catch (RuntimeException $e) {
            Response::error($e->getMessage(), 404);
        } catch (Throwable $e) {
            Response::error('Error interno del servidor: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/products
     * Crea un nuevo producto a partir de un cuerpo JSON.
     */
    public function store(Request $request): void
    {
        try {
            $body = $request->getBody();

            if (empty($body)) {
                Response::error('El cuerpo de la petición no contiene un JSON válido o está vacío.', 400);
            }

            $createdProduct = $this->service->createProduct($body);

            Response::success(
                $createdProduct,
                'Producto creado exitosamente.',
                201 // 201 Created es el código estándar REST para recursos nuevos
            );
        } catch (InvalidArgumentException $e) {
            $validationErrors = property_exists($e, 'validationErrors') ? $e->validationErrors : null;
            Response::error($e->getMessage(), 422, $validationErrors);
        } catch (Throwable $e) {
            Response::error('Error al registrar producto: ' . $e->getMessage(), 500);
        }
    }

    /**
     * PUT /api/products/{id}
     * Actualiza un producto existente.
     */
    public function update(Request $request, array $params): void
    {
        try {
            $id = (int) ($params['id'] ?? 0);
            $body = $request->getBody();

            if (empty($body)) {
                Response::error('Debe enviar campos a actualizar en el cuerpo JSON.', 400);
            }

            $updatedProduct = $this->service->updateProduct($id, $body);

            Response::success($updatedProduct, 'Producto actualizado exitosamente.', 200);
        } catch (InvalidArgumentException $e) {
            $validationErrors = property_exists($e, 'validationErrors') ? $e->validationErrors : null;
            Response::error($e->getMessage(), 422, $validationErrors);
        } catch (RuntimeException $e) {
            Response::error($e->getMessage(), 404);
        } catch (Throwable $e) {
            Response::error('Error al actualizar producto: ' . $e->getMessage(), 500);
        }
    }

    /**
     * DELETE /api/products/{id}
     * Elimina un producto por su ID.
     */
    public function destroy(Request $request, array $params): void
    {
        try {
            $id = (int) ($params['id'] ?? 0);
            $this->service->deleteProduct($id);

            Response::success(null, "Producto con ID {$id} eliminado correctamente.", 200);
        } catch (InvalidArgumentException $e) {
            Response::error($e->getMessage(), 400);
        } catch (RuntimeException $e) {
            Response::error($e->getMessage(), 404);
        } catch (Throwable $e) {
            Response::error('Error al eliminar producto: ' . $e->getMessage(), 500);
        }
    }
}
