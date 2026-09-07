<?php
// QUÉ: Controlador para la gestión de fotos y videos favoritos de colecciones públicas.
// POR QUÉ: Permite a los usuarios armar su selección personal y privada de contenidos de interés (HU23 / RF21).
// CÓMO: Valida que el contenido pertenezca a colecciones públicas y persiste en la tabla relacional 'favoritos'.

declare(strict_types=1);

namespace App\controllers;

use App\middlewares\AuthMiddleware;
use App\Core\Database;
use App\Core\Response;
use App\repository\MultimediaRepository;
use PDO;

class FavoritoController
{
    private PDO $pdo;
    private MultimediaRepository $multimediaRepository;

    public function __construct()
    {
        $database = new Database();
        $this->pdo = $database->getConnection();
        $this->multimediaRepository = new MultimediaRepository($this->pdo);
    }

    /**
     * POST /favoritos/{id}
     * Marca un archivo multimedia de una colección pública como favorito (HU23 / RF21).
     */
    public function agregar(string $id): void
    {
        $usuario = $this->usuarioAutenticado();
        $idMultimedia = (int) $id;

        $multimedia = $this->multimediaRepository->findById($idMultimedia);
        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        // Solo se permite marcar como favoritas fotos/videos de colecciones públicas (RF21)
        if ($multimedia['tipo_visibilidad'] !== 'publica') {
            Response::error('Solo se pueden agregar a favoritos contenidos de colecciones públicas.', 403);
        }

        $stmt = $this->pdo->prepare(
            'INSERT IGNORE INTO favoritos (usuario_id, favorito_id) VALUES (:uid, :fid)'
        );
        $stmt->execute([
            'uid' => $usuario['id'],
            'fid' => $idMultimedia,
        ]);

        Response::success([
            'id_multimedia' => $idMultimedia,
            'es_favorito'   => true,
        ], 'Elemento agregado a favoritos.', 201);
    }

    /**
     * DELETE /favoritos/{id}
     * Quita un archivo multimedia de la lista de favoritos del usuario (HU23 / RF21).
     */
    public function quitar(string $id): void
    {
        $usuario = $this->usuarioAutenticado();
        $idMultimedia = (int) $id;

        $stmt = $this->pdo->prepare(
            'DELETE FROM favoritos WHERE usuario_id = :uid AND favorito_id = :fid'
        );
        $stmt->execute([
            'uid' => $usuario['id'],
            'fid' => $idMultimedia,
        ]);

        Response::success([
            'id_multimedia' => $idMultimedia,
            'es_favorito'   => false,
        ], 'Elemento quitado de favoritos.');
    }

    /**
     * GET /favoritos
     * Retorna la lista privada de favoritos del usuario autenticado (HU23 / RF21).
     */
    public function listar(): void
    {
        $usuario = $this->usuarioAutenticado();

        $stmt = $this->pdo->prepare(
            'SELECT m.id_multimedia, m.coleccion_id, m.titulo, m.descripcion,
                    m.vista_previa, m.tamanio, m.tipo,
                    c.titulo AS coleccion_titulo,
                    u.nombre_completo AS fotografo_nombre
             FROM favoritos f
             INNER JOIN multimedia m ON m.id_multimedia = f.favorito_id
             INNER JOIN colecciones c ON c.id = m.coleccion_id
             INNER JOIN usuarios u ON u.id = c.fotografo_id
             WHERE f.usuario_id = :uid
             ORDER BY m.id_multimedia DESC'
        );
        $stmt->execute(['uid' => $usuario['id']]);
        $favoritos = $stmt->fetchAll();

        Response::success($favoritos, 'Lista de elementos favoritos.');
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
