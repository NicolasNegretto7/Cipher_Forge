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
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'fotografos' AND COLUMN_NAME = 'biografia');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE fotografos ADD COLUMN biografia TEXT DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cipher_forge' AND TABLE_NAME = 'fotografos' AND COLUMN_NAME = 'especialidad');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE fotografos ADD COLUMN especialidad VARCHAR(60) DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

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
