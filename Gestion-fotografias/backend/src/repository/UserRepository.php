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

    /**
     * Guarda el código temporal de verificación de correo con fecha de expiración (HU21).
     */
    public function guardarCodigoVerificacion(string $email, string $codigo, string $expiracion): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE usuarios
             SET codigo_verificacion = :codigo, codigo_expiracion = :expiracion
             WHERE email = :email'
        );
        return $stmt->execute([
            'codigo'     => $codigo,
            'expiracion' => $expiracion,
            'email'      => $email,
        ]);
    }

    /**
     * Recupera el código de verificación y su expiración para un email (HU21).
     */
    public function obtenerCodigoVerificacion(string $email): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT codigo_verificacion, codigo_expiracion, email_verificado
             FROM usuarios
             WHERE email = :email
             LIMIT 1'
        );
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    /**
     * Marca el correo del usuario como verificado y limpia el código temporal (HU21).
     */
    public function marcarEmailVerificado(string $email): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE usuarios
             SET email_verificado = 1, codigo_verificacion = NULL, codigo_expiracion = NULL
             WHERE email = :email'
        );
        return $stmt->execute(['email' => $email]);
    }

    /**
     * Marca las políticas de privacidad y Ley 18.331 como aceptadas por el fotógrafo (HU31).
     */
    public function aceptarPoliticas(int $fotografoId): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE fotografos
             SET politicas_aceptadas = 1
             WHERE id_fotografo = :id'
        );
        return $stmt->execute(['id' => $fotografoId]);
    }

    /**
     * Retorna si el fotógrafo ha aceptado las políticas (HU31).
     */
    public function politicasAceptadas(int $fotografoId): bool
    {
        $stmt = $this->pdo->prepare(
            'SELECT politicas_aceptadas FROM fotografos WHERE id_fotografo = :id LIMIT 1'
        );
        $stmt->execute(['id' => $fotografoId]);
        $val = $stmt->fetchColumn();
        return $val !== false && (bool) $val;
    }

    /**
     * Actualiza la información de perfil profesional del fotógrafo (HU18).
     */
    public function actualizarPerfilFotografo(int $fotografoId, string $nombre, ?string $telefono): bool
    {
        $this->pdo->beginTransaction();
        try {
            // Actualizar tabla padre usuarios
            $stmtUser = $this->pdo->prepare(
                'UPDATE usuarios SET nombre_completo = :nombre, telefono = :telefono WHERE id = :id'
            );
            $stmtUser->execute([
                'nombre'   => $nombre,
                'telefono' => $telefono,
                'id'       => $fotografoId,
            ]);

            $this->pdo->commit();
            return true;
        } catch (\Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }

    /**
     * Directorio público de fotógrafos (HU18).
     */
    public function listarFotografos(): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT u.id, u.nombre_completo, u.email, u.telefono,
                    (SELECT COUNT(*) FROM colecciones c WHERE c.fotografo_id = u.id AND c.tipo_visibilidad = "publica") AS colecciones_publicas
             FROM usuarios u
             INNER JOIN fotografos f ON f.id_fotografo = u.id
             WHERE u.rol = "fotografo"
             ORDER BY u.nombre_completo ASC'
        );
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Perfil público detallado de un fotógrafo (HU18).
     */
    public function obtenerPerfilFotografo(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT u.id, u.nombre_completo, u.email, u.telefono
             FROM usuarios u
             INNER JOIN fotografos f ON f.id_fotografo = u.id
             WHERE u.id = :id AND u.rol = "fotografo"
             LIMIT 1'
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }
}
