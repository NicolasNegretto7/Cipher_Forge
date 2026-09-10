-- Migración incremental para Cipher Forge
-- Compatible con MySQL 8.0 (no usa ADD COLUMN IF NOT EXISTS).
-- Consulta information_schema antes de cada ALTER para ser idempotente.
USE cipher_forge;

-- ── usuarios: campos de verificación de correo ──────────────────
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'usuarios' AND COLUMN_NAME = 'codigo_verificacion');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE usuarios ADD COLUMN codigo_verificacion VARCHAR(10) DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'usuarios' AND COLUMN_NAME = 'codigo_expiracion');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE usuarios ADD COLUMN codigo_expiracion DATETIME DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── fotografos: campos de perfil ────────────────────────────────
-- ── multimedia: campos de moderación y auditoría ────────────────
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'multimedia' AND COLUMN_NAME = 'aprobado');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE multimedia ADD COLUMN aprobado BOOLEAN NOT NULL DEFAULT TRUE',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'multimedia' AND COLUMN_NAME = 'creado_en');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE multimedia ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ── favoritos: CC-15 redirige favoritos de multimedia a colecciones ─────────
-- Antes: favorito_id referencia multimedia.id_multimedia (favoritos por archivo).
-- Ahora: favorito_id referencia colecciones.id (colección pública completa).
-- Los registros existentes apuntaban a archivos multimedia y su semántica
-- cambió, por lo tanto se descartan antes de redefinir la clave foránea.
DELETE FROM favoritos;

SET @fk_a_colecciones = (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'favoritos'
      AND CONSTRAINT_NAME = 'favoritos_ibfk_2' AND REFERENCED_TABLE_NAME = 'colecciones');
-- MySQL 8.0 rechaza reutilizar el nombre de la misma FK en un solo ALTER:
-- primero se elimina la antigua (a multimedia) y luego se crea la nueva (a colecciones).
SET @sql1 = IF(@fk_a_colecciones = 0,
    'ALTER TABLE favoritos DROP FOREIGN KEY favoritos_ibfk_2, DROP INDEX favorito_id',
    'SELECT 1');
PREPARE stmt FROM @sql1; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql2 = IF(@fk_a_colecciones = 0,
    'ALTER TABLE favoritos ADD CONSTRAINT favoritos_ibfk_2
        FOREIGN KEY (favorito_id) REFERENCES colecciones(id) ON DELETE CASCADE',
    'SELECT 1');
PREPARE stmt FROM @sql2; EXECUTE stmt; DEALLOCATE PREPARE stmt;
