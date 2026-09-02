<?php
// QUÉ: Capa de persistencia para la entidad 'colecciones'.
// POR QUÉ: Aísla las sentencias SQL del servicio de colecciones permitiendo un mantenimiento desacoplado.

declare(strict_types=1);

namespace App\repository;

use App\dtos\CreateColeccionDto;
use PDO;

class ColeccionRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Inserta una nueva colección en la base de datos.
     * Retorna el identificador (ID) de la colección recién creada.
     */
    public function create(CreateColeccionDto $dto): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO colecciones (fotografo_id, titulo, tipo_visibilidad, descripcion)
             VALUES (:fotografo_id, :titulo, :tipo_visibilidad, :descripcion)'
        );

        $stmt->execute([
            'fotografo_id'     => $dto->fotografoId,
            'titulo'           => $dto->titulo,
            'tipo_visibilidad' => $dto->tipoVisibilidad,
            'descripcion'      => $dto->descripcion,
        ]);

        return (int) $this->pdo->lastInsertId();
    }

    /**
     * Obtiene los datos de una colección por su ID.
     */
    public function findById(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, fotografo_id, titulo, tipo_visibilidad, descripcion, creado_en
             FROM colecciones
             WHERE id = :id
             LIMIT 1'
        );
        $stmt->execute(['id' => $id]);

        $coleccion = $stmt->fetch();

        return $coleccion ?: null;
    }
}
