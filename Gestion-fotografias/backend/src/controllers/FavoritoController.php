<?php
// QUÉ: Controlador para la gestión de colecciones públicas favoritas.
// POR QUÉ: Permite a los usuarios armar su selección privada de colecciones
// públicas completas (HU23 / RF21, decisión CC-15: no hay favoritos por archivo).
// CÓMO: Valida que la colección exista y sea pública, y persiste en la tabla
// relacional 'favoritos' con favorito_id apuntando a colecciones.id.

declare(strict_types=1);

namespace App\controllers;

use App\middlewares\AuthMiddleware;
use App\Core\Database;
use App\Core\Response;
use App\repository\ColeccionRepository;
use PDO;

class FavoritoController
{
    private PDO $pdo;
    private ColeccionRepository $coleccionRepository;

    public function __construct()
    {
        $database = new Database();
        $this->pdo = $database->getConnection();
        $this->coleccionRepository = new ColeccionRepository($this->pdo);
    }

    /**
     * POST /favoritos/{id}
     * Marca una colección pública completa como favorita (HU23 / RF21, CC-15).
     */
    public function agregar(string $id): void
    {
        $usuario = $this->usuarioAutenticado();
        $idColeccion = (int) $id;

        $coleccion = $this->coleccionRepository->findById($idColeccion);
        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        // Solo se permite marcar como favorita una colección pública (RF21)
        if ($coleccion['tipo_visibilidad'] !== 'publica') {
            Response::error('Solo se pueden agregar a favoritos colecciones públicas.', 403);
        }

        $stmt = $this->pdo->prepare(
            'INSERT IGNORE INTO favoritos (usuario_id, favorito_id) VALUES (:uid, :fid)'
        );
        $stmt->execute([
            'uid' => $usuario['id'],
            'fid' => $idColeccion,
        ]);

        Response::success([
            'id_coleccion' => $idColeccion,
            'es_favorito'  => true,
        ], 'Colección agregada a favoritos.', 201);
    }

    /**
     * DELETE /favoritos/{id}
     * Quita una colección de la lista de favoritos del usuario (HU23 / RF21, CC-15).
     */
    public function quitar(string $id): void
    {
        $usuario = $this->usuarioAutenticado();
        $idColeccion = (int) $id;

        $stmt = $this->pdo->prepare(
            'DELETE FROM favoritos WHERE usuario_id = :uid AND favorito_id = :fid'
        );
        $stmt->execute([
            'uid' => $usuario['id'],
            'fid' => $idColeccion,
        ]);

        Response::success([
            'id_coleccion' => $idColeccion,
            'es_favorito'  => false,
        ], 'Colección quitada de favoritos.');
    }

    /**
     * GET /favoritos
     * Retorna las colecciones públicas favoritas del usuario autenticado,
     * una fila por colección (HU23 / RF21, CC-15).
     */
    public function listar(): void
    {
        $usuario = $this->usuarioAutenticado();

        $stmt = $this->pdo->prepare(
            'SELECT c.id AS id_coleccion, c.titulo, c.descripcion,
                    c.tipo_visibilidad, c.creado_en,
                    u.nombre_completo AS fotografo_nombre,
                    (SELECT m.vista_previa FROM multimedia m
                     WHERE m.coleccion_id = c.id AND m.aprobado = 1
                     ORDER BY CASE WHEN m.tipo = "imagen" THEN 0 ELSE 1 END, m.id_multimedia ASC
                     LIMIT 1) AS portada_preview,
                    (SELECT m.id_multimedia FROM multimedia m
                     WHERE m.coleccion_id = c.id AND m.aprobado = 1
                     ORDER BY CASE WHEN m.tipo = "imagen" THEN 0 ELSE 1 END, m.id_multimedia ASC
                     LIMIT 1) AS portada_id_multimedia,
                    (SELECT COUNT(*) FROM multimedia m
                     WHERE m.coleccion_id = c.id AND m.aprobado = 1) AS total_archivos
             FROM favoritos f
             INNER JOIN colecciones c ON c.id = f.favorito_id
             INNER JOIN usuarios u ON u.id = c.fotografo_id
             WHERE f.usuario_id = :uid
             ORDER BY c.id DESC'
        );
        $stmt->execute(['uid' => $usuario['id']]);
        $favoritos = $stmt->fetchAll();

        Response::success($favoritos, 'Lista de colecciones favoritas.');
    }

    private function usuarioAutenticado(): array
    {
        $usuario = AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión para gestionar tus favoritos.', 401);
        }
        return $usuario;
    }
}