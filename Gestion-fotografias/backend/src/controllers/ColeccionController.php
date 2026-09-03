<?php
// QUÉ: Controlador que gestiona los endpoints relacionados con colecciones.
// POR QUÉ: Orquesta la entrada HTTP, delega la validación y la lógica de negocio, y retorna la respuesta JSON.

declare(strict_types=1);

namespace App\controllers;

use App\Core\Request;
use App\Core\Response;
use App\services\ColeccionService;
use App\validators\ColeccionValidator;

class ColeccionController
{
    private ColeccionService   $coleccionService;
    private ColeccionValidator $coleccionValidator;

    public function __construct()
    {
        $this->coleccionService   = new ColeccionService();
        $this->coleccionValidator = new ColeccionValidator();
    }

    /**
     * POST /colecciones
     * Crea una nueva colección y establece su tipo de visibilidad ('privada' o 'publica').
     */
    public function create(): void
    {
        // 1. Obtener cuerpo JSON de la petición
        $request = new Request();
        $data    = $request->getBody();

        // 2. Validar payload y generar DTO
        $dto = $this->coleccionValidator->validateCreate($data);

        // 3. Procesar lógica de creación y control de rol
        $coleccion = $this->coleccionService->create($dto);

        // 4. Retornar respuesta HTTP 201 Created
        Response::success($coleccion, 'Colección creada exitosamente.', 201);
    }
}
