<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\User;
use PDO;

/**
 * REPOSITORIO DE USUARIOS (ACCESO A DATOS)
 * ==============================================================================
 * WHAT: Ejecuta consultas preparadas (Prepared Statements) con PDO contra la
 *       tabla `usuarios` y mapea los resultados hacia la entidad User.
 * WHY:  Aísla por completo el SQL del resto de la aplicación. Previene inyección
 *       SQL mediante parámetros vinculados nombrados (`:email`, `:id`).
 * ==============================================================================
 */
class UserRepository extends Repository
{
    /**
     * Busca un usuario por su dirección de email.
     */
    public function findByEmail(string $email): ?User
    {
        $sql = 'SELECT id, nombre, email, clave_hash, rol, activo FROM usuarios WHERE email = :email LIMIT 1';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':email', trim($email), PDO::PARAM_STR);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row === false ? null : $this->buildUser($row);
    }

    /**
     * Busca un usuario por su clave primaria ID.
     */
    public function findById(int $id): ?User
    {
        $sql = 'SELECT id, nombre, email, clave_hash, rol, activo FROM usuarios WHERE id = :id LIMIT 1';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $row = $stmt->fetch();

        return $row === false ? null : $this->buildUser($row);
    }

    /**
     * Inserta un nuevo usuario en la base de datos con contraseña ya encriptada.
     */
    public function create(string $name, string $email, string $passwordHash, string $role = 'usuario'): User
    {
        $sql = 'INSERT INTO usuarios (nombre, email, clave_hash, rol, activo)
                VALUES (:nombre, :email, :clave_hash, :rol, 1)';

        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':nombre', $name, PDO::PARAM_STR);
        $stmt->bindValue(':email', $email, PDO::PARAM_STR);
        $stmt->bindValue(':clave_hash', $passwordHash, PDO::PARAM_STR);
        $stmt->bindValue(':rol', $role, PDO::PARAM_STR);
        $stmt->execute();

        $newId = (int) $this->db->lastInsertId();

        return $this->findById($newId) ?? new User($newId, $name, $email, $passwordHash, $role, true);
    }

    /**
     * Hidrata una fila de la base de datos (array) en un objeto de dominio User.
     *
     * @param array<string, mixed> $row
     */
    private function buildUser(array $row): User
    {
        return new User(
            (int) $row['id'],
            (string) $row['nombre'],
            (string) $row['email'],
            (string) $row['clave_hash'],
            (string) $row['rol'],
            (bool) $row['activo']
        );
    }
}
