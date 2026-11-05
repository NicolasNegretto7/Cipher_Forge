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

        // 3. Extraer y validar hashtags opcionales (array o string separado por comas) (H-09)
        $hashtags = [];
        if (isset($data['hashtags'])) {
            $rawHashtags = is_array($data['hashtags'])
                ? $data['hashtags']
                : explode(',', (string) $data['hashtags']);
            $hashtags = $this->coleccionValidator->validateHashtags($rawHashtags);
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
     * GET /colecciones/mias
     * Lista las colecciones del fotógrafo autenticado (H09 / CC-33).
     */
    public function listarMias(): void
    {
        $colecciones = $this->coleccionService->listarMias();
        Response::success($colecciones, 'Tus colecciones.');
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
     * Filtro opcional de búsqueda parcial: ?hashtag=palabra (HU27).
     * Cada palabra enviada se compara contra el nombre del hashtag y se exige que
     * todas aparezcan (coincidencia parcial, sin distinguir mayúsculas), de modo que
     * "bod" encuentra "bodas" y no hace falta escribir el nombre exacto.
     */
    public function listarHashtags(): void
    {
        $request  = new Request();
        $busqueda = $request->getQuery('hashtag');

        if ($busqueda !== null && !is_scalar($busqueda)) {
            Response::error('Error de validación.', 400, ['El filtro de hashtags debe ser un texto.']);
        }

        $tags = $this->coleccionService->listarHashtags();

        $palabras = $this->palabrasDeBusquedaHashtags(is_string($busqueda) ? $busqueda : '');

        if ($palabras === []) {
            Response::success($tags, 'Listado de hashtags disponibles.');
        }

        $filtrados = array_values(array_filter(
            $tags,
            static function (array $tag) use ($palabras): bool {
                $nombre = mb_strtolower((string) ($tag['nombre_hashtags'] ?? ''));
                foreach ($palabras as $palabra) {
                    if (mb_strpos($nombre, $palabra) === false) {
                        return false;
                    }
                }
                return true;
            }
        ));

        Response::success($filtrados, 'Hashtags que coinciden con la búsqueda.');
    }

    /**
     * Normaliza el término de búsqueda de GET /hashtags en palabras válidas.
     * Separa por espacios, quita el '#' inicial de cada palabra y valida el conjunto
     * de caracteres y la longitud (VARCHAR(40) en schema.sql). Si el término no es
     * válido responde 400 y detiene el flujo (mismo convenio que los validadores).
     *
     * @return string[]
     */
    private function palabrasDeBusquedaHashtags(string $busqueda): array
    {
        $palabras = [];

        foreach (preg_split('/\s+/u', trim($busqueda)) ?: [] as $palabra) {
            $limpia = mb_strtolower(ltrim($palabra, '#'));
            if ($limpia === '') {
                continue;
            }

            if (mb_strlen($limpia) > 40) {
                Response::error('Error de validación.', 400, ['Cada palabra del filtro de hashtags puede tener como máximo 40 caracteres.']);
            }

            if (preg_match('/^[\p{L}\p{N}_-]+$/u', $limpia) !== 1) {
                Response::error('Error de validación.', 400, ['El filtro de hashtags solo admite letras, números, guiones y guiones bajos.']);
            }

            $palabras[] = $limpia;
        }

        return $palabras;
    }

    /**
     * PUT /colecciones/{id}
     * Actualiza metadatos, visibilidad y hashtags de una colección existente (HU26).
     */
    public function actualizar(string $id): void
    {
        $request = new Request();
        $data    = $request->getBody();

        // H-04: Validar longitud de campos (título máx 60, descripción máx 90) antes de persistir
        $camposValidados = $this->coleccionValidator->validateUpdate($data);

        $hashtags = null;
        if (array_key_exists('hashtags', $data)) {
            $rawHashtags = is_array($data['hashtags'])
                ? $data['hashtags']
                : explode(',', (string) $data['hashtags']);
            $hashtags = $this->coleccionValidator->validateHashtags($rawHashtags);
        }

        $coleccion = $this->coleccionService->actualizar((int) $id, $camposValidados, $hashtags);
        Response::success($coleccion, 'Colección actualizada correctamente.');
    }

    /**
     * DELETE /colecciones/{id}
     * Elimina una colección y todos sus recursos asociados.
     */
    public function eliminar(string $id): void
    {
        $this->coleccionService->eliminar((int) $id);
        Response::success(null, 'Colección eliminada correctamente.');
    }

    /**
     * PUT /colecciones/{id}/hashtags
     * Actualiza los hashtags de una colección existente (HU26).
     */
    public function actualizarHashtags(string $id): void
    {
        $request = new Request();
        $data    = $request->getBody();

        $hashtags = [];
        if (isset($data['hashtags'])) {
            $rawHashtags = is_array($data['hashtags'])
                ? $data['hashtags']
                : explode(',', (string) $data['hashtags']);
            $hashtags = $this->coleccionValidator->validateHashtags($rawHashtags);
        }

        $coleccion = $this->coleccionService->actualizar((int) $id, [], $hashtags);
        Response::success($coleccion, 'Hashtags actualizados correctamente.');
    }
}
