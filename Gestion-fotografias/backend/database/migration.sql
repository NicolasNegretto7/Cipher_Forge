-- Migración incremental para Cipher Forge
USE cipher_forge;

-- Agregar campos de verificación de correo a usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS codigo_verificacion VARCHAR(10) DEFAULT NULL;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS codigo_expiracion DATETIME DEFAULT NULL;

-- Agregar campos de perfil a fotografos
ALTER TABLE fotografos ADD COLUMN IF NOT EXISTS biografia TEXT DEFAULT NULL;
ALTER TABLE fotografos ADD COLUMN IF NOT EXISTS especialidad VARCHAR(60) DEFAULT NULL;

-- Agregar campos de moderación y auditoría a multimedia
ALTER TABLE multimedia ADD COLUMN IF NOT EXISTS aprobado BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE multimedia ADD COLUMN IF NOT EXISTS creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
