<?php

declare(strict_types=1);

namespace App\Repositories;

use Config\Database;
use PDO;

/**
 * Repositorio de persistencia para colecciones y galerías de fotos.
 * 
 * Implementa consultas con UUID (prevención IDOR) y filtrado de visibilidad por rol.
 */
class CollectionRepository
{
    private PDO $db;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? (new Database())->getConnection();
    }

    /**
     * Obtiene las colecciones visibles para el usuario según su rol y privacidad.
     * 
     * Regla de visibilidad:
     * - Fotógrafo: ve todas las colecciones.
     * - Cliente / No autenticado: ve únicamente colecciones públicas (is_private = 0) o creadas por él.
     */
    public function findAllAccessible(?int $userId, ?string $role): array
    {
        if ($role === 'fotografo') {
            $sql = "SELECT c.id, c.uuid, c.title, c.description, c.is_private, c.created_at, u.name AS author_name,
                           COUNT(i.id) AS total_images
                    FROM collections c
                    INNER JOIN users u ON u.id = c.user_id
                    LEFT JOIN images i ON i.collection_id = c.id
                    GROUP BY c.id
                    ORDER BY c.id DESC";
            $stmt = $this->db->query($sql);
            return $stmt->fetchAll();
        }

        // Cliente o anónimo
        $sql = "SELECT c.id, c.uuid, c.title, c.description, c.is_private, c.created_at, u.name AS author_name,
                       COUNT(i.id) AS total_images
                FROM collections c
                INNER JOIN users u ON u.id = c.user_id
                LEFT JOIN images i ON i.collection_id = c.id
                WHERE c.is_private = 0";

        if ($userId !== null) {
            $sql .= " OR c.user_id = :userId";
        }

        $sql .= " GROUP BY c.id ORDER BY c.id DESC";

        $stmt = $this->db->prepare($sql);
        if ($userId !== null) {
            $stmt->bindValue(':userId', $userId, PDO::PARAM_INT);
        }
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function findByUuid(string $uuid): ?array
    {
        $sql = "SELECT c.id, c.uuid, c.user_id, c.title, c.description, c.is_private, c.created_at, u.name AS author_name
                FROM collections c
                INNER JOIN users u ON u.id = c.user_id
                WHERE c.uuid = :uuid 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':uuid', $uuid, PDO::PARAM_STR);
        $stmt->execute();

        $collection = $stmt->fetch();
        return $collection ?: null;
    }

    public function create(string $uuid, int $userId, string $title, ?string $description, bool $isPrivate): int
    {
        $sql = "INSERT INTO collections (uuid, user_id, title, description, is_private) 
                VALUES (:uuid, :user_id, :title, :description, :is_private)";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':uuid', $uuid, PDO::PARAM_STR);
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':title', trim($title), PDO::PARAM_STR);
        $stmt->bindValue(':description', $description !== null ? trim($description) : null, $description === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':is_private', $isPrivate ? 1 : 0, PDO::PARAM_INT);

        $stmt->execute();
        return (int) $this->db->lastInsertId();
    }

    public function update(int $id, string $title, ?string $description, bool $isPrivate): bool
    {
        $sql = "UPDATE collections 
                SET title = :title, 
                    description = :description, 
                    is_private = :is_private 
                WHERE id = :id";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->bindValue(':title', trim($title), PDO::PARAM_STR);
        $stmt->bindValue(':description', $description !== null ? trim($description) : null, $description === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':is_private', $isPrivate ? 1 : 0, PDO::PARAM_INT);

        return $stmt->execute();
    }

    public function delete(int $id): bool
    {
        $sql = "DELETE FROM collections WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }
}
