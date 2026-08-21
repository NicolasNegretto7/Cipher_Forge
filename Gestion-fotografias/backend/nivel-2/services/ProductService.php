<?php

/**
 * SERVICE DE PRODUCTOS
 * ==================================================================
 * ACÁ VIVEN LAS REGLAS DEL NEGOCIO.
 *
 * "Regla del negocio" es una decisión del sistema, no de la
 * programación. Por ejemplo:
 *
 *   - no puede haber dos productos con el mismo nombre
 *   - no se puede vender más stock del que hay
 *   - no se puede borrar un producto que todavía tiene mercadería
 *
 * El service es el que decide si algo se puede hacer o no.
 * El controller solo recibe el pedido, y el repository solo guarda.
 * ==================================================================
 */
class ProductService
{
    private ProductRepository $repository;

    public function __construct()
    {
        $this->repository = new ProductRepository();
    }

    /** Devuelve la lista de productos, lista para mandar como JSON. */
    public function getAll($category = null)
    {
        $products = $this->repository->findAll($category);

        $list = [];

        foreach ($products as $product) {
            $list[] = $product->toArray();
        }

        return $list;
    }

    /** Devuelve un producto. Si no existe, corta con un 404. */
    public function getById($id)
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            // Response::error() contesta y TERMINA el programa,
            // así que lo que sigue no se ejecuta.
            Response::error('No existe el producto ' . $id, 404);
        }

        return $product->toArray();
    }

    /**
     * Crea un producto.
     *
     * REGLA: no puede haber dos productos con el mismo nombre.
     * CreateProductDTO es el tipo exigido por el parámetro $dto.
     */
    public function create(CreateProductDTO $dto)
    {
        // ->getName() lee el nombre privado y normalizado del DTO.
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

        $this->repository->create($product);

        return $product->toArray();
    }

    /**
     * Modifica los campos que hayan mandado.
     * UpdateProductDTO recuerda cuáles campos estaban presentes.
     */
    public function update($id, UpdateProductDTO $dto)
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            Response::error('No existe el producto ' . $id, 404);
        }

        // has() pregunta si el campo vino; get() obtiene su valor.
        // Solo tocamos lo que vino. Los setters protegen además al modelo.
        if ($dto->has('nombre')) {
            $product->setName($dto->get('nombre'));
        }

        if ($dto->has('descripcion')) {
            $product->setDescription($dto->get('descripcion'));
        }

        if ($dto->has('precio')) {
            $product->setPrice($dto->get('precio'));
        }

        if ($dto->has('stock')) {
            $product->setStock($dto->get('stock'));
        }

        if ($dto->has('categoria')) {
            $product->setCategory($dto->get('categoria'));
        }

        $this->repository->update($product);

        return $product->toArray();
    }

    /**
     * Elimina un producto.
     *
     * REGLA: no se puede borrar si todavía queda mercadería en stock.
     * Primero hay que venderla o darla de baja.
     */
    public function delete($id)
    {
        $product = $this->repository->findById($id);

        if ($product === null) {
            Response::error('No existe el producto ' . $id, 404);
        }

        if ($product->hasStock()) {
            Response::error(
                'No se puede borrar: todavía quedan ' . $product->getStock() . ' unidades en stock.',
                400
            );
        }

        $this->repository->delete($id);
    }

    /**
     * VENDER: el ejemplo más claro de para qué existe esta capa.
     * ------------------------------------------------------------------
     * Vender no es "guardar un dato": es una OPERACIÓN con reglas y con
     * varios pasos que tienen que pasar juntos.
     *
     * Este método no podría vivir en el controller, porque mañana la
     * venta la va a hacer también el sistema de la caja, o una app, o
     * un proceso que importa un archivo de pedidos. Todos van a llamar
     * a este mismo método.
     */
    public function sell($id, SellProductDTO $dto)
    {
        // El getter devuelve la cantidad entera transportada por el DTO.
        $quantity = $dto->getQuantity();

        $product = $this->repository->findById($id);

        // Regla 1: el producto tiene que existir.
        if ($product === null) {
            Response::error('No existe el producto ' . $id, 404);
        }

        // Regla 2: no se puede vender más de lo que hay.
        if ($product->getStock() < $quantity) {
            Response::error(
                'No hay stock suficiente. Quedan ' . $product->getStock() . ' unidades.',
                400
            );
        }

        // Si pasó todas las reglas: descontamos y guardamos.
        $product->setStock($product->getStock() - $quantity);

        $this->repository->update($product);

        return [
            'vendidas'      => (int) $quantity,
            'total_a_pagar' => $quantity * $product->getPrice(),
            'producto'      => $product->toArray(),
        ];
    }
}
