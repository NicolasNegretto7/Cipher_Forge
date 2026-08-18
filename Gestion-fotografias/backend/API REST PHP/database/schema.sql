-- Esquema relacional para la plataforma Cipher_Forge
CREATE DATABASE IF NOT EXISTS `cipher_forge`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `cipher_forge`;

-- Tabla de Usuarios con soporte de roles
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('fotografo', 'cliente') NOT NULL DEFAULT 'cliente',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tokens de Autenticación Bearer (Sesiones sin estado / Stateless API)
CREATE TABLE IF NOT EXISTS `auth_tokens` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `token_hash` CHAR(64) NOT NULL UNIQUE, -- SHA-256 del token plano entregado al cliente
    `expires_at` DATETIME NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_auth_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_token_hash` (`token_hash`),
    INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Colecciones / Galerías de fotos (Uso de UUID para prevenir ataques IDOR)
CREATE TABLE IF NOT EXISTS `collections` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `uuid` CHAR(36) NOT NULL UNIQUE, -- Identificador no predecible para acceso público o compartido
    `user_id` INT UNSIGNED NOT NULL, -- Creador / Fotógrafo
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `is_private` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_collections_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_collections_uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Metadatos de Imágenes subidas
CREATE TABLE IF NOT EXISTS `images` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `collection_id` INT UNSIGNED NOT NULL,
    `filename` VARCHAR(255) NOT NULL, -- Nombre físico en disco (generado con hash/uuid)
    `original_name` VARCHAR(255) NOT NULL, -- Nombre original al subir
    `mime_type` VARCHAR(50) NOT NULL, -- image/jpeg o image/png
    `size_bytes` INT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_images_collection` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Registro de descargas de clientes (Auditoría / Historial)
CREATE TABLE IF NOT EXISTS `downloads` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `collection_id` INT UNSIGNED NOT NULL,
    `downloaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_downloads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_downloads_collection` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuarios de prueba iniciales
-- Contraseña para ambos: "Password123!" (Hasheada con Argon2id)
INSERT INTO `users` (`name`, `email`, `password_hash`, `role`) VALUES
('Fotógrafo Principal', 'fotografo@cipherforge.com', '$argon2id$v=19$m=65536,t=4,p=1$dmw2bW8xeWtuNjAwMDAwMA$W3x4016QeG5Gq59vH1M+i96rZ/j5L1B7tB7k8i1u6vM', 'fotografo'),
('Cliente Ejemplo', 'cliente@cipherforge.com', '$argon2id$v=19$m=65536,t=4,p=1$dmw2bW8xeWtuNjAwMDAwMA$W3x4016QeG5Gq59vH1M+i96rZ/j5L1B7tB7k8i1u6vM', 'cliente')
ON DUPLICATE KEY UPDATE `id`=`id`;
