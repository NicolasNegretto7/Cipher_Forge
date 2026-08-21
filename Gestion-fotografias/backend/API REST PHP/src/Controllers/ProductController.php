<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Response;
use App\DTOs\CreateProductDTO;
use App\DTOs\SellProductDTO;
use App\DTOs\UpdateProductDTO;
use App\Services\ProductService;
use App\Validators\ProductValidator;

/**
 * CONTROLADOR DE PRODUCTOS
 * ==============================================================================
 * WHAT: Gestiona las peticiones HTTP del catálogo de productos y ventas de inventario.
 * WHY:  Adopta los métodos estándar REST (index, show, store, update, destroy, sell),
 *       aplica validación temprana con ProductValidator, mapea a DTOs y delega
 *       al servicio ProductService.
 * ==============================================================================
 */
class ProductController extends Controller
{
    private ProductService $service;

    public function __construct(?ProductService $service = null)
    {
        $this->service = $service ?? new ProductService();
    }

    /**
     * GET /productos
     * GET /productos?categoria=audio
     */
    public function index(): void
    {
        $category = $_GET['categoria'] ?? null;

        $errors = ProductValidator::validateIndex($category);
        if (count($errors) > 0) {
            Response::error('Revisá los parámetros de búsqueda.', 400, $errors);
        }

        $products = $this->service->getAll($category);

        Response::success($products, 'Listado de productos obtenido.');
    }

    /**
     * GET /productos/{id}
     */
    public function show(mixed $id = null): void
    {
        $errors = ProductValidator::validateShow($id);
        if (count($errors) > 0) {
            Response::error('Revisá el ID del producto.', 400, $errors);
        }

        $product = $this->service->getById((int) $id);

        Response::success($product, 'Producto encontrado.');
    }

    /**
     * POST /productos (Requiere sesión 'auth')
     */
    public function store(): void
    {
        $data = $this->requestData();

        // 1. Validar formato de entrada
        $errors = ProductValidator::validateStore($data);
        if (count($errors) > 0) {
            Response::error('Revisá los datos ingresados.', 400, $errors);
        }

        // 2. DTO
        $dto = new CreateProductDTO($data);

        // 3. Reglas de negocio en el servicio
        $product = $this->service->create($dto);

        Response::success($product, 'Producto creado exitosamente.', 201);
    }

    /**
     * PUT /productos/{id} (Requiere sesión 'auth')
     */
    public function update(mixed $id = null): void
    {
        $data = $this->requestData();

        // 1. Validar ID y campos recibidos
        $errors = ProductValidator::validateUpdate($id, $data);
        if (count($errors) > 0) {
            Response::error('Revisá los datos a modificar.', 400, $errors);
        }

        // 2. DTO
        $dto = new UpdateProductDTO($data);

        // 3. Modificación en el servicio
        $product = $this->service->update((int) $id, $dto);

        Response::success($product, 'Producto actualizado exitosamente.');
    }

    /**
     * DELETE /productos/{id} (Requiere rol 'admin')
     */
    public function destroy(mixed $id = null): void
    {
        $errors = ProductValidator::validateDestroy($id);
        if (count($errors) > 0) {
            Response::error('Revisá el ID del producto.', 400, $errors);
        }

        $this->service->delete((int) $id);

        Response::success(null, 'Producto eliminado correctamente.');
    }

    /**
     * POST /productos/{id}/vender (Requiere sesión 'auth')
     */
    public function sell(mixed $id = null): void
    {
        $data = $this->requestData();

        // 1. Validar ID y cantidad a vender
        $errors = ProductValidator::validateSell($id, $data);
        if (count($errors) > 0) {
            Response::error('Revisá los datos de la venta.', 400, $errors);
        }

        // 2. DTO
        $dto = new SellProductDTO($data);

        // 3. Descontar stock y registrar venta en el servicio
        $sale = $this->service->sell((int) $id, $dto);

        Response::success($sale, 'Venta registrada exitosamente.');
    }
}
