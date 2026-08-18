<?php

declare(strict_types=1);

namespace App\Repositories;

use Config\Database;
use PDO;

/**
 * Repositorio de metadatos de imágenes.
 */
class ImageRepository
{
    private PDO $db;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? (new Database())->getConnection();
    }

    public function findByCollectionId(int $collectionId): array
    {
        $sql = "SELECT id, collection_id, filename, original_name, mime_type, size_bytes, created_at 
                FROM images 
                WHERE collection_id = :collectionId 
                ORDER BY id ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':collectionId', $collectionId, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function findById(int $id): ?array
    {
        $sql = "SELECT i.id, i.collection_id, i.filename, i.original_name, i.mime_type, i.size_bytes, i.created_at,
                       c.uuid AS collection_uuid, c.user_id AS owner_id, c.is_private
                FROM images i
                INNER JOIN collections c ON c.id = i.collection_id
                WHERE i.id = :id 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $image = $stmt->fetch();
        return $image ?: null;
    }

    public function create(int $collectionId, string $filename, string $originalName, string $mimeType, int $sizeBytes): int
    {
        $sql = "INSERT INTO images (collection_id, filename, original_name, mime_type, size_bytes) 
                VALUES (:collectionId, :filename, :originalName, :mimeType, :sizeBytes)";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':collectionId', $collectionId, PDO::PARAM_INT);
        $stmt->bindValue(':filename', $filename, PDO::PARAM_STR);
        $stmt->bindValue(':originalName', $originalName, PDO::PARAM_STR);
        $stmt->bindValue(':mimeType', $mimeType, PDO::PARAM_STR);
        $stmt->bindValue(':sizeBytes', $sizeBytes, PDO::PARAM_INT);

        $stmt->execute();
        return (int) $this->db->lastInsertId();
    }

    public function delete(int $id): bool
    {
        $sql = "DELETE FROM images WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }
}
