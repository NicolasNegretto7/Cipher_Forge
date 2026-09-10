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
     * $consentimientoTs (CF-15): fecha en que el invitado aceptó el tratamiento de sus datos
     * (nombre_invitado) conforme a la Ley 18.331; null si no se capturó el consentimiento.
     */
    public function create(MultimediaDto $dto, string $rutaOriginal, string $vistaPrevia, int $tamanio, bool $aprobado = true, ?string $consentimientoTs = null): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO multimedia (coleccion_id, titulo, descripcion, ruta_original, vista_previa, tamanio, tipo, es_invitado, aprobado, consentimiento_ts)
             VALUES (:coleccion_id, :titulo, :descripcion, :ruta_original, :vista_previa, :tamanio, :tipo, :es_invitado, :aprobado, :consentimiento_ts)'
        );

        $stmt->execute([
            'coleccion_id'      => $dto->coleccionId,
            'titulo'            => $dto->titulo,
            'descripcion'       => $dto->descripcion,
            'ruta_original'     => $rutaOriginal,
            'vista_previa'      => $vistaPrevia,
            'tamanio'           => $tamanio,
            'tipo'              => $dto->tipo,
            'es_invitado'       => (int) $dto->esInvitado,
            'aprobado'          => (int) $aprobado,
            'consentimiento_ts' => $consentimientoTs,
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
                    m.vista_previa, m.tamanio, m.tipo, m.es_invitado, m.aprobado, m.creado_en,
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
     * Retorna todos los archivos multimedia aprobados de una colección (para una galería).
     */
    public function findByColeccionId(int $coleccionId, bool $soloAprobados = true): array
    {
        $filtroAprobados = $soloAprobados ? 'AND aprobado = 1' : '';
        $stmt = $this->pdo->prepare(
            "SELECT id_multimedia, coleccion_id, titulo, descripcion, vista_previa, tamanio, tipo, es_invitado, aprobado, creado_en
             FROM multimedia
             WHERE coleccion_id = :coleccion_id {$filtroAprobados}
             ORDER BY id_multimedia DESC"
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);

        return $stmt->fetchAll();
    }

    /**
     * Calcula la suma total de bytes consumidos por un fotógrafo en todas sus colecciones (HU16).
     */
    public function espacioUsadoPorFotografo(int $fotografoId): int
    {
        $stmt = $this->pdo->prepare(
            'SELECT COALESCE(SUM(m.tamanio), 0) AS total_bytes
             FROM multimedia m
             INNER JOIN colecciones c ON c.id = m.coleccion_id
             WHERE c.fotografo_id = :fotografo_id'
        );
        $stmt->execute(['fotografo_id' => $fotografoId]);
        return (int) $stmt->fetchColumn();
    }

    /**
     * Elimina un registro de multimedia por su ID (HU6).
     */
    public function delete(int $id): bool
    {
        $stmt = $this->pdo->prepare('DELETE FROM multimedia WHERE id_multimedia = :id');
        return $stmt->execute(['id' => $id]);
    }

    /**
     * Actualiza metadatos básicos y opcionalmente reasigna la colección (HU22).
     */
    public function actualizarMetadatos(int $id, string $titulo, ?string $descripcion, ?int $nuevaColeccionId = null): bool
    {
        if ($nuevaColeccionId !== null) {
            $stmt = $this->pdo->prepare(
                'UPDATE multimedia
                 SET titulo = :titulo, descripcion = :descripcion, coleccion_id = :coleccion_id
                 WHERE id_multimedia = :id'
            );
            return $stmt->execute([
                'titulo'       => $titulo,
                'descripcion'  => $descripcion,
                'coleccion_id' => $nuevaColeccionId,
                'id'           => $id,
            ]);
        }

        $stmt = $this->pdo->prepare(
            'UPDATE multimedia
             SET titulo = :titulo, descripcion = :descripcion
             WHERE id_multimedia = :id'
        );
        return $stmt->execute([
            'titulo'      => $titulo,
            'descripcion' => $descripcion,
            'id'          => $id,
        ]);
    }

    /**
     * Lista archivos subidos por invitados que están pendientes de moderación (HU12).
     */
    public function listarPendientes(int $coleccionId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id_multimedia, coleccion_id, titulo, descripcion, vista_previa, tamanio, tipo, creado_en
             FROM multimedia
             WHERE coleccion_id = :coleccion_id AND es_invitado = 1 AND aprobado = 0
             ORDER BY id_multimedia ASC'
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);
        return $stmt->fetchAll();
    }

    /**
     * Aprueba un conjunto de archivos multimedia colaborativos (HU12).
     */
    public function aprobarMultiples(array $ids, int $coleccionId): int
    {
        if (empty($ids)) {
            return 0;
        }

        $inClause = implode(',', array_map('intval', $ids));
        $stmt = $this->pdo->prepare(
            "UPDATE multimedia
             SET aprobado = 1
             WHERE coleccion_id = :coleccion_id AND id_multimedia IN ({$inClause})"
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);
        return $stmt->rowCount();
    }

    /**
     * Retorna las rutas de archivos de un lote de IDs para su eliminación física en disco (HU12 / HU6).
     */
    public function obtenerRutasPorIds(array $ids, int $coleccionId): array
    {
        if (empty($ids)) {
            return [];
        }

        $inClause = implode(',', array_map('intval', $ids));
        $stmt = $this->pdo->prepare(
            "SELECT id_multimedia, ruta_original, vista_previa
             FROM multimedia
             WHERE coleccion_id = :coleccion_id AND id_multimedia IN ({$inClause})"
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);
        return $stmt->fetchAll();
    }

    /**
     * Busca y elimina archivos colaborativos no aprobados con más de 24 horas de antigüedad (RF15 / HU12).
     * Retorna los registros eliminados para permitir desvincular sus archivos físicos.
     */
    public function purgarNoAprobadosExpirados(): array
    {
        // 1. Obtener los archivos que han superado las 24 horas
        $stmt = $this->pdo->prepare(
            'SELECT id_multimedia, ruta_original, vista_previa
             FROM multimedia
             WHERE es_invitado = 1 AND aprobado = 0 AND creado_en < (NOW() - INTERVAL 24 HOUR)'
        );
        $stmt->execute();
        $expirados = $stmt->fetchAll();

        if (empty($expirados)) {
            return [];
        }

        // 2. Eliminar registros de la base de datos
        $ids = array_column($expirados, 'id_multimedia');
        $inClause = implode(',', array_map('intval', $ids));
        $this->pdo->exec("DELETE FROM multimedia WHERE id_multimedia IN ({$inClause})");

        return $expirados;
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
