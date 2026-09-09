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
            'SELECT c.id, c.fotografo_id, c.titulo, c.tipo_visibilidad, c.descripcion, c.creado_en,
                    u.nombre_completo AS fotografo_nombre
             FROM colecciones c
             INNER JOIN usuarios u ON u.id = c.fotografo_id
             WHERE c.id = :id
             LIMIT 1'
        );
        $stmt->execute(['id' => $id]);

        $coleccion = $stmt->fetch();

        return $coleccion ?: null;
    }

    /**
     * Lista colecciones públicas con soporte opcional de filtro por hashtag (HU24 / HU27).
     */
    public function listarPublicas(?string $hashtag = null): array
    {
        $sql = 'SELECT c.id, c.fotografo_id, c.titulo, c.tipo_visibilidad, c.descripcion, c.creado_en,
                       u.nombre_completo AS fotografo_nombre,
                       (SELECT m.vista_previa FROM multimedia m WHERE m.coleccion_id = c.id AND m.aprobado = 1 ORDER BY m.id_multimedia ASC LIMIT 1) AS portada_preview,
                       (SELECT COUNT(*) FROM multimedia m WHERE m.coleccion_id = c.id AND m.aprobado = 1) AS total_archivos
                FROM colecciones c
                INNER JOIN usuarios u ON u.id = c.fotografo_id
                WHERE c.tipo_visibilidad = "publica"';

        $params = [];

        if ($hashtag !== null && trim($hashtag) !== '') {
            $limpio = ltrim(trim($hashtag), '#');
            $sql .= ' AND c.id IN (
                        SELECT ch.coleccion_id
                        FROM coleccion_hashtags ch
                        INNER JOIN hashtags h ON h.id_hashtags = ch.id_hashtags
                        WHERE h.nombre_hashtags = :hashtag
                    )';
            $params['hashtag'] = strtolower($limpio);
        }

        $sql .= ' ORDER BY c.id DESC';

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /**
     * Lista todas las colecciones creadas por un fotógrafo.
     */
    public function listarPorFotografo(int $fotografoId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT c.id, c.fotografo_id, c.titulo, c.tipo_visibilidad, c.descripcion, c.creado_en,
                    (SELECT COUNT(*) FROM multimedia m WHERE m.coleccion_id = c.id) AS total_archivos
             FROM colecciones c
             WHERE c.fotografo_id = :fotografo_id
             ORDER BY c.id DESC'
        );
        $stmt->execute(['fotografo_id' => $fotografoId]);
        return $stmt->fetchAll();
    }

    /**
     * Actualiza metadatos de una colección.
     */
    public function actualizar(int $id, string $titulo, ?string $descripcion, string $tipoVisibilidad): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE colecciones
             SET titulo = :titulo, descripcion = :descripcion, tipo_visibilidad = :visibilidad
             WHERE id = :id'
        );
        return $stmt->execute([
            'titulo'      => $titulo,
            'descripcion' => $descripcion,
            'visibilidad' => $tipoVisibilidad,
            'id'          => $id,
        ]);
    }

    /**
     * Sincroniza hashtags para una colección (HU26).
     */
    public function sincronizarHashtags(int $coleccionId, array $nombresHashtags): void
    {
        // Limpiar hashtags actuales
        $del = $this->pdo->prepare('DELETE FROM coleccion_hashtags WHERE coleccion_id = :id');
        $del->execute(['id' => $coleccionId]);

        foreach ($nombresHashtags as $tag) {
            $limpio = strtolower(ltrim(trim($tag), '#'));
            if ($limpio === '') continue;

            // Insertar o recuperar el hashtag
            $selectStmt = $this->pdo->prepare('SELECT id_hashtags FROM hashtags WHERE nombre_hashtags = :tag LIMIT 1');
            $selectStmt->execute(['tag' => $limpio]);
            $tagId = $selectStmt->fetchColumn();

            if (!$tagId) {
                $insertTag = $this->pdo->prepare('INSERT INTO hashtags (nombre_hashtags) VALUES (:tag)');
                $insertTag->execute(['tag' => $limpio]);
                $tagId = (int) $this->pdo->lastInsertId();
            }

            // Relacionar colección con el hashtag
            $insertRel = $this->pdo->prepare('INSERT IGNORE INTO coleccion_hashtags (id_hashtags, coleccion_id) VALUES (:hid, :cid)');
            $insertRel->execute(['hid' => $tagId, 'cid' => $coleccionId]);
        }
    }

    /**
     * Obtiene los hashtags asociados a una colección.
     */
    public function obtenerHashtags(int $coleccionId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT h.nombre_hashtags
             FROM hashtags h
             INNER JOIN coleccion_hashtags ch ON ch.id_hashtags = h.id_hashtags
             WHERE ch.coleccion_id = :coleccion_id'
        );
        $stmt->execute(['coleccion_id' => $coleccionId]);
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    /**
     * Lista todos los hashtags existentes con conteo de colecciones (HU27).
     */
    public function listarHashtags(): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT h.id_hashtags, h.nombre_hashtags, COUNT(ch.coleccion_id) AS total_colecciones
             FROM hashtags h
             LEFT JOIN coleccion_hashtags ch ON ch.id_hashtags = h.id_hashtags
             GROUP BY h.id_hashtags, h.nombre_hashtags
             ORDER BY total_colecciones DESC, h.nombre_hashtags ASC'
        );
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Crea un token de QR colaborativo con expiración para un evento (HU4).
     */
    public function crearTokenColaborativo(int $coleccionId, string $expiracion): array
    {
        $token = bin2hex(random_bytes(20));
        $stmt = $this->pdo->prepare(
            'INSERT INTO qr_tokens (token, coleccion_id, tipo, expiracion)
             VALUES (:token, :coleccion_id, "colaborativo", :expiracion)'
        );
        $stmt->execute([
            'token'        => $token,
            'coleccion_id' => $coleccionId,
            'expiracion'   => $expiracion,
        ]);

        return [
            'id_token'     => (int) $this->pdo->lastInsertId(),
            'token'        => $token,
            'coleccion_id' => $coleccionId,
            'tipo'         => 'colaborativo',
            'expiracion'   => $expiracion,
        ];
    }

    /**
     * Busca cualquier token en qr_tokens y obtiene los datos de su colección vinculada.
     */
    public function buscarToken(string $token): ?array
    {
        $stmt = $this->pdo->prepare(
            'SELECT qt.id_token, qt.token, qt.coleccion_id, qt.tipo, qt.expiracion,
                    c.titulo AS coleccion_titulo, c.tipo_visibilidad, c.fotografo_id
             FROM qr_tokens qt
             INNER JOIN colecciones c ON c.id = qt.coleccion_id
             WHERE qt.token = :token
             LIMIT 1'
        );
        $stmt->execute(['token' => $token]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    /**
     * Otorga acceso permanente a un cliente para ver y descargar una colección privada (HU3).
     */
    public function otorgarAcceso(int $usuarioId, int $coleccionId): bool
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO acceso_colecciones (usuario_id, coleccion_id, permitir_buena_calidad, permitir_alta_calidad)
             VALUES (:usuario_id, :coleccion_id, 1, 1)
             ON DUPLICATE KEY UPDATE permitir_buena_calidad = 1, permitir_alta_calidad = 1'
        );
        return $stmt->execute([
            'usuario_id'   => $usuarioId,
            'coleccion_id' => $coleccionId,
        ]);
    }

    /**
     * Obtiene las rutas de archivos (original y vista previa) de los multimedia de una colección.
     */
    public function obtenerRutasMultimediaDeColeccion(int $coleccionId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT ruta_original, vista_previa FROM multimedia WHERE coleccion_id = :id'
        );
        $stmt->execute(['id' => $coleccionId]);
        return $stmt->fetchAll();
    }

    /**
     * Elimina una colección junto con todas sus dependencias (multimedia, favoritos,
     * accesos, tokens QR, hashtags y hashtags huérfanos).
     */
    public function eliminarConDependencias(int $coleccionId): void
    {
        $this->pdo->beginTransaction();
        try {
            $stmt = $this->pdo->prepare(
                'DELETE FROM favoritos
                 WHERE favorito_id IN (SELECT id_multimedia FROM multimedia WHERE coleccion_id = :id)'
            );
            $stmt->execute(['id' => $coleccionId]);

            $stmt = $this->pdo->prepare('DELETE FROM acceso_colecciones WHERE coleccion_id = :id');
            $stmt->execute(['id' => $coleccionId]);

            $stmt = $this->pdo->prepare('DELETE FROM qr_tokens WHERE coleccion_id = :id');
            $stmt->execute(['id' => $coleccionId]);

            $stmt = $this->pdo->prepare('DELETE FROM coleccion_hashtags WHERE coleccion_id = :id');
            $stmt->execute(['id' => $coleccionId]);

            $stmt = $this->pdo->prepare(
                'DELETE FROM hashtags
                 WHERE id_hashtags NOT IN (SELECT id_hashtags FROM coleccion_hashtags)'
            );
            $stmt->execute();

            $stmt = $this->pdo->prepare('DELETE FROM multimedia WHERE coleccion_id = :id');
            $stmt->execute(['id' => $coleccionId]);

            $stmt = $this->pdo->prepare('DELETE FROM colecciones WHERE id = :id');
            $stmt->execute(['id' => $coleccionId]);

            $this->pdo->commit();
        } catch (\Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }
}
