<?php
// QUÉ: Lógica de negocio para la gestión de colecciones.
// POR QUÉ: Centraliza las reglas de negocio (ej. verificación estricta del rol 'fotografo') antes de persistir datos.

declare(strict_types=1);

namespace App\services;

use App\middlewares\AuthMiddleware;
use App\Core\Database;
use App\Core\Response;
use App\dtos\CreateColeccionDto;
use App\helpers\MediaProcessor;
use App\repository\ColeccionRepository;
use App\repository\MultimediaRepository;
use App\repository\UserRepository;

class ColeccionService
{
    private UserRepository       $userRepository;
    private ColeccionRepository  $coleccionRepository;
    private MultimediaRepository $multimediaRepository;

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->userRepository       = new UserRepository($pdo);
        $this->coleccionRepository  = new ColeccionRepository($pdo);
        $this->multimediaRepository = new MultimediaRepository($pdo);
    }

    /**
     * Valida permisos y registra una nueva colección, sincronizando hashtags si es pública (HU2 / HU26).
     */
    public function create(CreateColeccionDto $dto, array $hashtags = []): array
    {
        // 1. Verificar existencia del usuario fotógrafo
        $usuario = $this->userRepository->findById($dto->fotografoId);

        if ($usuario === null) {
            Response::error('El fotógrafo especificado no existe.', 404);
        }

        // 2. Verificar que el usuario tenga rol 'fotografo' (RF4 / HU2)
        if ($usuario['rol'] !== 'fotografo') {
            Response::error('Solo los usuarios con rol fotógrafo pueden crear colecciones.', 403);
        }

        // 3. Crear la colección en la base de datos
        $coleccionId = $this->coleccionRepository->create($dto);

        // 4. Si es pública y se enviaron hashtags, guardarlos (HU26)
        if ($dto->tipoVisibilidad === 'publica' && !empty($hashtags)) {
            $this->coleccionRepository->sincronizarHashtags($coleccionId, $hashtags);
        }

        // 5. Obtener los datos completos de la colección creada
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        $coleccion['hashtags'] = $this->coleccionRepository->obtenerHashtags($coleccionId);

        return $coleccion;
    }

    /**
     * Lista colecciones públicas con sus hashtags asociados (HU24 / HU27).
     */
    public function listarPublicas(?string $hashtag = null): array
    {
        $colecciones = $this->coleccionRepository->listarPublicas($hashtag);
        foreach ($colecciones as &$col) {
            $col['hashtags'] = $this->coleccionRepository->obtenerHashtags((int) $col['id']);
        }
        return $colecciones;
    }

    /**
     * Obtiene el detalle de una colección verificando visibilidad y control de acceso (HU20 / HU24).
     */
    public function obtenerDetalle(int $id): array
    {
        $coleccion = $this->coleccionRepository->findById($id);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        // Si es privada, validar que el usuario tenga acceso (HU20 / RF6)
        if ($coleccion['tipo_visibilidad'] === 'privada') {
            $usuario = AuthMiddleware::user();

            if ($usuario === null) {
                Response::error('Debes iniciar sesión para acceder a esta colección privada.', 401);
            }

            $esDueno = (int) $coleccion['fotografo_id'] === (int) $usuario['id'];
            $tieneAcceso = $this->multimediaRepository->tieneAcceso((int) $usuario['id'], $id);

            if (!$esDueno && !$tieneAcceso) {
                Response::error('No tienes permisos para acceder a esta colección privada.', 403);
            }
        }

        $coleccion['hashtags'] = $this->coleccionRepository->obtenerHashtags($id);
        return $coleccion;
    }

    /**
     * Valida un token de invitación privada y devuelve estado (HU3 / RF5).
     */
    public function validarInvitacion(string $token): array
    {
        $infoToken = $this->coleccionRepository->buscarToken($token);

        if ($infoToken === null || $infoToken['tipo'] !== 'acceso') {
            Response::error('El enlace de invitación es inválido o no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        $estaAutenticado = $usuario !== null;
        $tieneAcceso = $estaAutenticado
            ? ((int) $infoToken['fotografo_id'] === (int) $usuario['id'] ||
               $this->multimediaRepository->tieneAcceso((int) $usuario['id'], (int) $infoToken['coleccion_id']))
            : false;

        return [
            'token'            => $token,
            'coleccion_id'     => $infoToken['coleccion_id'],
            'coleccion_titulo' => $infoToken['coleccion_titulo'],
            'tipo_visibilidad' => $infoToken['tipo_visibilidad'],
            'autenticado'      => $estaAutenticado,
            'tiene_acceso'     => $tieneAcceso,
            'requiere_auth'    => !$estaAutenticado,
        ];
    }

    /**
     * Canjea el token de invitación para el usuario autenticado otorgando acceso permanente (HU3 / RF5).
     */
    public function canjearInvitacion(string $token): array
    {
        $infoToken = $this->coleccionRepository->buscarToken($token);

        if ($infoToken === null || $infoToken['tipo'] !== 'acceso') {
            Response::error('El enlace de invitación es inválido o no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión para desbloquear el acceso a esta colección.', 401);
        }

        $coleccionId = (int) $infoToken['coleccion_id'];
        $usuarioId   = (int) $usuario['id'];

        $this->coleccionRepository->otorgarAcceso($usuarioId, $coleccionId);

        $coleccion = $this->coleccionRepository->findById($coleccionId);
        $coleccion['hashtags'] = $this->coleccionRepository->obtenerHashtags($coleccionId);

        return [
            'coleccion' => $coleccion,
            'acceso_concedido' => true,
        ];
    }

    /**
     * Lista hashtags populares para filtrado y autocompletado (HU27).
     */
    public function listarHashtags(): array
    {
        return $this->coleccionRepository->listarHashtags();
    }

    /**
     * Actualiza los hashtags de una colección existente (HU26).
     * Verifica que el usuario autenticado sea el fotógrafo dueño.
     */
    public function actualizarHashtags(int $id, array $hashtags = []): array
    {
        $coleccion = $this->coleccionRepository->findById($id);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null || (int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede actualizar los hashtags.', 403);
        }

        $this->coleccionRepository->sincronizarHashtags($id, $hashtags);

        $coleccion['hashtags'] = $this->coleccionRepository->obtenerHashtags($id);
        return $coleccion;
    }

    /**
     * Actualiza metadatos, visibilidad y hashtags de una colección existente (HU26).
     * Verifica que el usuario autenticado sea el fotógrafo dueño.
     */
    public function actualizar(int $id, array $campos, ?array $hashtags = null): array
    {
        $coleccion = $this->coleccionRepository->findById($id);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null || (int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede modificar la colección.', 403);
        }

        $titulo = isset($campos['titulo']) && trim((string) $campos['titulo']) !== ''
            ? trim((string) $campos['titulo'])
            : (string) $coleccion['titulo'];

        $descripcion = array_key_exists('descripcion', $campos)
            ? trim((string) $campos['descripcion'])
            : ($coleccion['descripcion'] ?? null);

        $tipoVisibilidad = isset($campos['tipo_visibilidad']) && in_array($campos['tipo_visibilidad'], ['privada', 'publica'], true)
            ? (string) $campos['tipo_visibilidad']
            : (string) $coleccion['tipo_visibilidad'];

        $this->coleccionRepository->actualizar($id, $titulo, $descripcion, $tipoVisibilidad);

        if ($hashtags !== null) {
            $this->coleccionRepository->sincronizarHashtags($id, $hashtags);
        }

        $coleccionActualizada   = $this->coleccionRepository->findById($id);
        $coleccionActualizada['hashtags'] = $this->coleccionRepository->obtenerHashtags($id);
        return $coleccionActualizada;
    }

    /**
     * Elimina una colección y todos sus recursos asociados (multimedia, archivos, favoritos,
     * accesos, tokens QR y hashtags). Verifica que el usuario sea el fotógrafo dueño.
     */
    public function eliminar(int $id): void
    {
        $coleccion = $this->coleccionRepository->findById($id);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null || (int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede eliminar la colección.', 403);
        }

        foreach ($this->coleccionRepository->obtenerRutasMultimediaDeColeccion($id) as $fila) {
            foreach (['ruta_original', 'vista_previa'] as $clave) {
                if (!empty($fila[$clave])) {
                    $rutaAbsoluta = MediaProcessor::aRutaAbsoluta((string) $fila[$clave]);
                    if (file_exists($rutaAbsoluta)) {
                        @unlink($rutaAbsoluta);
                    }
                }
            }
        }

        $this->coleccionRepository->eliminarConDependencias($id);
    }
}
