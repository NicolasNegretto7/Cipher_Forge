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

        // 3. Extraer hashtags opcionales (array o string separado por comas)
        $hashtags = [];
        if (isset($data['hashtags'])) {
            $hashtags = is_array($data['hashtags'])
                ? $data['hashtags']
                : explode(',', (string) $data['hashtags']);
        }

        // 4. Procesar lógica de creación y control de rol
        $coleccion = $this->coleccionService->create($dto, $hashtags);

        // 5. Retornar respuesta HTTP 201 Created
        Response::success($coleccion, 'Colección creada exitosamente.', 201);
    }

    /**
     * GET /colecciones/publicas
     * Lista colecciones públicas con soporte opcional de filtro por hashtag (HU24 / HU27).
     */
    public function listarPublicas(): void
    {
        $request = new Request();
        $hashtag = $request->getQuery('hashtag');

        $colecciones = $this->coleccionService->listarPublicas($hashtag ? (string) $hashtag : null);
        Response::success($colecciones, 'Colecciones públicas disponibles.');
    }

    /**
     * GET /colecciones/{id}
     * Retorna los detalles de una colección tras validar acceso si es privada (HU24 / HU20).
     */
    public function detalle(string $id): void
    {
        $coleccion = $this->coleccionService->obtenerDetalle((int) $id);
        Response::success($coleccion, 'Detalle de la colección.');
    }

    /**
     * POST /colecciones/{id}/qr-acceso
     * Genera o devuelve el enlace y código QR de acceso directo permanente (HU17 / RF16).
     */
    public function generarQrAcceso(string $id): void
    {
        $resultado = $this->coleccionService->obtenerQrAcceso((int) $id);
        Response::success($resultado, 'Enlace y código QR de acceso permanente generado.');
    }

    /**
     * GET /invitaciones/{token}
     * Valida el enlace de invitación para una colección privada antes de canjear (HU3 / RF5).
     */
    public function validarInvitacion(string $token): void
    {
        $estado = $this->coleccionService->validarInvitacion($token);
        Response::success($estado, 'Estado de la invitación.');
    }

    /**
     * POST /invitaciones/{token}/canjear
     * Desbloquea y otorga acceso a la colección privada al usuario autenticado (HU3 / RF5).
     */
    public function canjearInvitacion(string $token): void
    {
        $resultado = $this->coleccionService->canjearInvitacion($token);
        Response::success($resultado, 'Invitación canjeada con éxito. Ahora tienes acceso a la colección.');
    }

    /**
     * GET /hashtags
     * Lista todos los hashtags existentes con la cantidad de colecciones asociadas (HU27).
     */
    public function listarHashtags(): void
    {
        $tags = $this->coleccionService->listarHashtags();
        Response::success($tags, 'Listado de hashtags disponibles.');
    }
}
