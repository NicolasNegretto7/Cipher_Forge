<?php
// QUÉ: Controlador para perfiles de fotógrafos, aceptación de políticas legales y cuotas de almacenamiento.
// POR QUÉ: Desacopla las operaciones exclusivas del rol fotógrafo de la autenticación general y de colecciones.
// CÓMO: Coordina AuthMiddleware, UserRepository y ColeccionRepository para validar identidad y emitir JSON.

declare(strict_types=1);

namespace App\controllers;

use App\middlewares\AuthMiddleware;
use App\Core\Config;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;
use App\repository\MultimediaRepository;
use App\repository\UserRepository;

class FotografoController
{
    private UserRepository       $userRepository;
    private MultimediaRepository $multimediaRepository;

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->userRepository       = new UserRepository($pdo);
        $this->multimediaRepository = new MultimediaRepository($pdo);
    }

    /**
     * POST /fotografos/aceptar-politicas
     * Formaliza la aceptación de políticas de privacidad y Ley 18.331 al primer login (HU31 / RF24).
     */
    public function aceptarPoliticas(): void
    {
        $usuario = $this->fotografoAutenticado();

        $this->userRepository->aceptarPoliticas((int) $usuario['id']);

        Response::success([
            'id'                  => $usuario['id'],
            'politicas_aceptadas' => true,
        ], 'Políticas de privacidad y Ley 18.331 aceptadas correctamente.');
    }

    /**
     * GET /fotografos
     * Directorio público general de fotógrafos y profesionales (HU18 / RF19).
     */
    public function directorio(): void
    {
        $fotografos = $this->userRepository->listarFotografos();
        Response::success($fotografos, 'Directorio de fotógrafos.');
    }

    /**
     * GET /fotografos/{id}
     * Perfil público de un fotógrafo específico con su biografía y colecciones (HU18).
     */
    public function perfil(string $id): void
    {
        $fotografo = $this->userRepository->obtenerPerfilFotografo((int) $id);

        if ($fotografo === null) {
            Response::error('El fotógrafo no existe.', 404);
        }

        Response::success($fotografo, 'Perfil del fotógrafo.');
    }

    /**
     * PUT /fotografo/perfil
     * Permite al fotógrafo autenticado editar sus datos de perfil profesional (HU18 / RF19).
     */
    public function actualizarPerfil(): void
    {
        $usuario = $this->fotografoAutenticado();
        $request = new Request();
        $data    = $request->getBody();

        $nombre = trim((string) ($data['nombre_completo'] ?? $usuario['nombre_completo']));
        if ($nombre === '') {
            Response::error('El nombre completo no puede estar vacío.', 400);
        }

        $telefono     = isset($data['telefono']) ? trim((string) $data['telefono']) : $usuario['telefono'];
        $biografia    = isset($data['biografia']) ? trim((string) $data['biografia']) : null;
        $especialidad = isset($data['especialidad']) ? trim((string) $data['especialidad']) : null;

        $this->userRepository->actualizarPerfilFotografo(
            (int) $usuario['id'],
            $nombre,
            $telefono,
            $biografia,
            $especialidad
        );

        Response::success([
            'id'              => $usuario['id'],
            'nombre_completo' => $nombre,
            'telefono'        => $telefono,
            'biografia'       => $biografia,
            'especialidad'    => $especialidad,
        ], 'Perfil actualizado exitosamente.');
    }

    /**
     * GET /fotografos/cuota
     * Consulta el espacio consumido, espacio libre y límite de 3 GB del fotógrafo (HU16 / RF17).
     */
    public function cuota(): void
    {
        $usuario = $this->fotografoAutenticado();

        $usado = $this->multimediaRepository->espacioUsadoPorFotografo((int) $usuario['id']);
        $total = Config::maxStorageBytes();
        $disponible = max(0, $total - $usado);
        $porcentaje = round(($usado / $total) * 100, 2);

        Response::success([
            'espacio_usado_bytes'      => $usado,
            'espacio_usado_mb'         => round($usado / (1024 * 1024), 2),
            'espacio_total_bytes'      => $total,
            'espacio_total_gb'         => round($total / (1024 * 1024 * 1024), 2),
            'espacio_disponible_bytes' => $disponible,
            'espacio_disponible_mb'    => round($disponible / (1024 * 1024), 2),
            'porcentaje_utilizado'     => $porcentaje,
        ], 'Estado de cuota de almacenamiento.');
    }

    private function fotografoAutenticado(): array
    {
        $usuario = AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión.', 401);
        }

        if ($usuario['rol'] !== 'fotografo') {
            Response::error('Acceso exclusivo para fotógrafos.', 403);
        }

        return $usuario;
    }
}
