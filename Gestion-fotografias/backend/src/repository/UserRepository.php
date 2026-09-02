<?php
// QUÉ: Acceso a la tabla 'usuarios' y tablas hijas ('clientes', 'fotografos').
// POR QUÉ: Aísla las queries SQL del Service — si cambia el esquema,
//           solo se modifica este archivo.

declare(strict_types=1);

namespace App\repository;

use App\dtos\RegisterDto;
use PDO;

class UserRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Busca un usuario por su email.
     * Retorna un array asociativo con todos los campos o null si no existe.
     */
    public function findByEmail(string $email): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, nombre_completo, email, telefono, email_verificado, password_hash, rol
             FROM usuarios
             WHERE email = :email
             LIMIT 1'
        );
        $stmt->execute(['email' => $email]);

        $user = $stmt->fetch();

        // fetch() retorna false si no encuentra filas
        return $user ?: null;
    }

    /**
     * Busca un usuario por su ID.
     * Retorna un array asociativo con los datos del usuario o null si no existe.
     */
    public function findById(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, nombre_completo, email, telefono, email_verificado, rol
             FROM usuarios
             WHERE id = :id
             LIMIT 1'
        );
        $stmt->execute(['id' => $id]);

        $user = $stmt->fetch();

        return $user ?: null;
    }

    /**
     * Inserta un usuario en 'usuarios' y en la tabla hija según su rol.
     * Usa transacción para garantizar que ambas inserciones sean atómicas.
     * Retorna el ID del usuario creado.
     */
    public function create(RegisterDto $dto, string $hashedPassword): int
    {
        $this->pdo->beginTransaction();

        try {
            // 1. Insertar en tabla padre 'usuarios'
            $stmt = $this->pdo->prepare(
                'INSERT INTO usuarios (nombre_completo, email, telefono, password_hash, rol)
                 VALUES (:nombre_completo, :email, :telefono, :password_hash, :rol)'
            );

            $stmt->execute([
                'nombre_completo' => $dto->nombreCompleto,
                'email'           => $dto->email,
                'telefono'        => $dto->telefono,
                'password_hash'   => $hashedPassword,
                'rol'             => $dto->rol,
            ]);

            // lastInsertId() retorna el AUTO_INCREMENT generado por MySQL
            $userId = (int) $this->pdo->lastInsertId();

            // 2. Insertar en tabla hija según el rol
            if ($dto->rol === 'fotografo') {
                $childStmt = $this->pdo->prepare(
                    'INSERT INTO fotografos (id_fotografo) VALUES (:id)'
                );
            } else {
                $childStmt = $this->pdo->prepare(
                    'INSERT INTO clientes (id_cliente) VALUES (:id)'
                );
            }

            $childStmt->execute(['id' => $userId]);

            $this->pdo->commit();

            return $userId;
        } catch (\Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }
}
