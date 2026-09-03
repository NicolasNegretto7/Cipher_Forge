<?php
// QUÉ: Capa de persistencia para la entidad 'multimedia' y el control de acceso a colecciones.
// POR QUÉ: Aísla las sentencias SQL sobre multimedia y acceso_colecciones del servicio,
//          centralizando el acceso a datos y las consultas preparadas contra inyección SQL.

declare(strict_types=1);

namespace App\repository;

use App\dtos\MultimediaDto;
use PDO;

class MultimediaRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Inserta un registro multimedia y retorna el id generado.
     */
    public function create(MultimediaDto $dto, string $rutaOriginal, string $vistaPrevia, int $tamanio): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO multimedia (coleccion_id, titulo, descripcion, ruta_original, vista_previa, tamanio, tipo, es_invitado)
             VALUES (:coleccion_id, :titulo, :descripcion, :ruta_original, :vista_previa, :tamanio, :tipo, :es_invitado)'
        );

        $stmt->execute([
            'coleccion_id'  => $dto->coleccionId,
            'titulo'        => $dto->titulo,
            'descripcion'   => $dto->descripcion,
            'ruta_original' => $rutaOriginal,
            'vista_previa'  => $vistaPrevia,
            'tamanio'       => $tamanio,
            'tipo'          => $dto->tipo,
            'es_invitado'   => (int) $dto->esInvitado,
        ]);

        return (int) $this->pdo->lastInsertId();
    }

    /**
     * Retorna los datos de un archivo multimedia por su id (incluida su colección).
     */
    public function findById(int $id): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT m.id_multimedia, m.coleccion_id, m.titulo, m.descripcion, m.ruta_original,
                    m.vista_previa, m.tamanio, m.tipo, m.es_invitado,
                    c.tipo_visibilidad, c.fotografo_id
             FROM multimedia m
             INNER JOIN colecciones c ON c.id = m.coleccion_id
             WHERE m.id_multimedia = :id
             LIMIT 1'
        );
        $stmt->execute(['id' => $id]);

        return $stmt->fetch() ?: null;
    }

    /**
     * Retorna todos los archivos multimedia de una colección (para una galería).
     */
    public function findByColeccionId(int $coleccionId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id_multimedia, coleccion_id, titulo, descripcion, vista_previa, tamanio, tipo, es_invitado
             FROM multimedia
             WHERE coleccion_id = :coleccion_id
             ORDER BY id_multimedia DESC'
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);

        return $stmt->fetchAll();
    }

    /**
     * Verifica si un usuario tiene acceso registrado a una colección privada
     * (tabla acceso_colecciones).
     */
    public function tieneAcceso(int $usuarioId, int $coleccionId): bool
    {
        $stmt = $this->pdo->prepare(
            'SELECT 1 FROM acceso_colecciones WHERE usuario_id = :usuario_id AND coleccion_id = :coleccion_id LIMIT 1'
        );
        $stmt->execute(['usuario_id' => $usuarioId, 'coleccion_id' => $coleccionId]);

        return $stmt->fetch() !== false;
    }
}
