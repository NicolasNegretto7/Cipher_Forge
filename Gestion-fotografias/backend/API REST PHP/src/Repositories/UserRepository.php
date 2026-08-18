<?php

declare(strict_types=1);

namespace App\Repositories;

use Config\Database;
use PDO;

/**
 * Repositorio para gestión de usuarios y tokens de autenticación Bearer.
 */
class UserRepository
{
    private PDO $db;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? (new Database())->getConnection();
    }

    public function findByEmail(string $email): ?array
    {
        $sql = "SELECT id, name, email, password_hash, role, created_at 
                FROM users 
                WHERE LOWER(email) = LOWER(:email) 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':email', trim($email), PDO::PARAM_STR);
        $stmt->execute();

        $user = $stmt->fetch();
        return $user ?: null;
    }

    public function findById(int $id): ?array
    {
        $sql = "SELECT id, name, email, role, created_at 
                FROM users 
                WHERE id = :id 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $user = $stmt->fetch();
        return $user ?: null;
    }

    public function create(string $name, string $email, string $passwordHash, string $role): int
    {
        $sql = "INSERT INTO users (name, email, password_hash, role) 
                VALUES (:name, :email, :password_hash, :role)";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':name', trim($name), PDO::PARAM_STR);
        $stmt->bindValue(':email', trim($email), PDO::PARAM_STR);
        $stmt->bindValue(':password_hash', $passwordHash, PDO::PARAM_STR);
        $stmt->bindValue(':role', $role, PDO::PARAM_STR);

        $stmt->execute();
        return (int) $this->db->lastInsertId();
    }

    public function createAuthToken(int $userId, string $tokenHash, string $expiresAt): bool
    {
        $sql = "INSERT INTO auth_tokens (user_id, token_hash, expires_at) 
                VALUES (:user_id, :token_hash, :expires_at)";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':token_hash', $tokenHash, PDO::PARAM_STR);
        $stmt->bindValue(':expires_at', $expiresAt, PDO::PARAM_STR);

        return $stmt->execute();
    }

    public function findUserByToken(string $tokenHash): ?array
    {
        $sql = "SELECT u.id, u.name, u.email, u.role, t.expires_at 
                FROM auth_tokens t
                INNER JOIN users u ON u.id = t.user_id
                WHERE t.token_hash = :token_hash 
                  AND t.expires_at > NOW() 
                LIMIT 1";

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':token_hash', $tokenHash, PDO::PARAM_STR);
        $stmt->execute();

        $result = $stmt->fetch();
        return $result ?: null;
    }

    public function deleteAuthToken(string $tokenHash): bool
    {
        $sql = "DELETE FROM auth_tokens WHERE token_hash = :token_hash";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':token_hash', $tokenHash, PDO::PARAM_STR);
        return $stmt->execute();
    }
}
