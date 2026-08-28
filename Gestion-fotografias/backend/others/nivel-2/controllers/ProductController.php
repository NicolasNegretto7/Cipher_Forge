<?php

/**
 * CONTROLLER DE PRODUCTOS  (hijo de Controller)
 * ==================================================================
 * MIRÁ LO CORTO QUE ES CADA MÉTODO.
 *
 * Es porque el controller hace solo su trabajo:
 *
 *   1. recibe los datos HTTP
 *   2. le pide la validación a ProductValidator
 *   3. crea un DTO para transportar los datos válidos
 *   4. le pasa la pelota al service
 *   5. contesta con Response::success()
 *
 * Fijate que acá NO aparece "¿está logueado?": eso ya lo resolvió el
 * AuthMiddleware antes de que este controller se instanciara (mirá
 * el último parámetro de cada ruta en routes.php).
 *
 * Las REGLAS (que el nombre no se repita, que no se venda más de lo
 * que hay) no están acá: están en ProductService.
 *
 * ------------------------------------------------------------------
 * LOS NOMBRES DE LOS MÉTODOS
 *
 * Son los que usa Laravel para un CRUD, así que conviene acostumbrarse:
 *
 *   index()   -> listar todos      GET    /productos
 *   show()    -> ver uno           GET    /productos/3
 *   store()   -> crear             POST   /productos
 *   update()  -> modificar         PUT    /productos/3
 *   destroy() -> borrar            DELETE /productos/3
 *
 * ------------------------------------------------------------------
 * ¿DÓNDE VALIDO CADA COSA? (la pregunta que siempre aparece)
 *
 *   En el VALIDATOR  -> que los datos VENGAN y tengan la forma
 *                       correcta: "falta el nombre", "el precio no
 *                       es un número".
 *
 *   En el DTO        -> limpiar y transportar los datos ya válidos.
 *
 *   En el SERVICE    -> las reglas del sistema: "ese nombre ya
 *                       existe", "no hay stock suficiente".
 *
 * Regla práctica: si para responder hay que ir a buscar datos,
 * es del service.
 * ==================================================================
 */
class ProductController extends Controller
{
    private ProductService $service;

    /**
     * El controller USA un service, y el service usa un repository.
     * Un objeto que tiene adentro otro objeto se llama COMPOSICIÓN.
     */
    public function __construct()
    {
        $this->service = new ProductService();
    }

    /**
     * GET /productos
     * GET /productos?categoria=audio
     *
     * Todos los métodos reciben $id porque el router siempre se lo
     * manda (vale null cuando la dirección no tiene un {id}).
     */
    public function index($id = null)
    {
        // Lo que viene después del "?" está en $_GET.
        // $_GET es un arreglo superglobal: PHP lo llena con el query string.
        // El operador ?? usa null y deja el filtro como opcional.
        $category = $_GET['categoria'] ?? null;

        // Cada endpoint llama a su propio método del validator.
        $errors = ProductValidator::validateIndex($category);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        $products = $this->service->getAll($category);

        Response::success($products);
    }

    /** GET /productos/3 */
    public function show($id = null)
    {
        $errors = ProductValidator::validateShow($id);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        $product = $this->service->getById($id);

        Response::success($product);
    }

    /**
     * POST /productos   (hay que estar logueado)
     */
    public function store($id = null)
    {
        $data = $this->requestData();

        // El validator trabaja con la entrada cruda y devuelve errores básicos.
        $errors = ProductValidator::validateStore($data);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        // new ejecuta el constructor del DTO, que normaliza los datos válidos.
        $dto = new CreateProductDTO($data);

        // El service recibe el DTO y se ocupa de las reglas de negocio.
        $product = $this->service->create($dto);

        Response::success($product, 'Producto creado.', 201);
    }

    /**
     * PUT /productos/3   (hay que estar logueado)
     * Se mandan solo los campos que se quieren cambiar.
     */
    public function update($id = null)
    {
        $data = $this->requestData();

        // validateUpdate también valida el ID incluido en la dirección.
        $errors = ProductValidator::validateUpdate($id, $data);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        // Este DTO conserva solamente los campos que el cliente quiere cambiar.
        $dto = new UpdateProductDTO($data);

        $product = $this->service->update($id, $dto);

        Response::success($product, 'Producto actualizado.');
    }

    /**
     * DELETE /productos/3   (solo administradores)
     */
    public function destroy($id = null)
    {
        $errors = ProductValidator::validateDestroy($id);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        $this->service->delete($id);

        Response::success(null, 'Producto eliminado.');
    }

    /**
     * POST /productos/3/vender   (hay que estar logueado)
     * Recibe: { "cantidad": 2 }
     *
     * Fijate que el controller no sabe NADA de cómo se vende:
     * no descuenta stock ni controla nada. Solo pasa el pedido.
     */
    public function sell($id = null)
    {
        $data = $this->requestData();

        // La venta tiene su propio validator porque recibe ID y cantidad.
        $errors = ProductValidator::validateSell($id, $data);

        if (count($errors) > 0) {
            Response::error('Revisá los datos.', 400, $errors);
        }

        // SellProductDTO lleva una cantidad entera hasta el service.
        $dto = new SellProductDTO($data);

        $sale = $this->service->sell($id, $dto);

        Response::success($sale, 'Venta registrada.');
    }
}
