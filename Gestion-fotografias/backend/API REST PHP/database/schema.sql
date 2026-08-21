-- ==============================================================================
-- database/schema.sql — Base de Datos Relacional para la API REST Educativa
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `utu_demo`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `utu_demo`;

-- ------------------------------------------------------------------------------
-- Tabla: usuarios
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuarios` (
    `id`         INT AUTO_INCREMENT PRIMARY KEY,
    `nombre`     VARCHAR(100) NOT NULL,
    `email`      VARCHAR(150) NOT NULL UNIQUE,
    `clave_hash` VARCHAR(255) NOT NULL,
    `rol`        VARCHAR(20)  NOT NULL DEFAULT 'usuario',
    `activo`     TINYINT(1)   NOT NULL DEFAULT 1,
    `creado_el`  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- Tabla: productos
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `productos` (
    `id`          INT AUTO_INCREMENT PRIMARY KEY,
    `nombre`      VARCHAR(150)   NOT NULL,
    `descripcion` TEXT           NULL,
    `precio`      DECIMAL(10, 2) NOT NULL,
    `stock`       INT            NOT NULL DEFAULT 0,
    `categoria`   VARCHAR(50)    NOT NULL,
    `activo`      TINYINT(1)     NOT NULL DEFAULT 1,
    `creado_el`   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- Usuarios de prueba iniciales
-- Clave para admin:  "admin123"  (rol admin)
-- Clave para alumno: "alumno123" (rol usuario)
-- Hasheadas con password_hash() (Bcrypt)
-- ------------------------------------------------------------------------------
INSERT INTO `usuarios` (`nombre`, `email`, `clave_hash`, `rol`, `activo`) VALUES
('Ana Administradora', 'admin@utu.edu.uy',  '$2y$12$.Fvn3QkhSJip4AEcBNeH3eUFB67Y/zUXpnpVzHvNme3qcHV1zlwjm', 'admin',   1),
('Bruno Alumno',        'alumno@utu.edu.uy', '$2y$12$FGZYCw99rH7qj/G5O/OJm.Mc.AvsrevKOjufKCEbNEqEOZtXaQ3NS', 'usuario', 1)
ON DUPLICATE KEY UPDATE `id`=`id`;

-- ------------------------------------------------------------------------------
-- Productos de demostración iniciales
-- ------------------------------------------------------------------------------
INSERT INTO `productos` (`nombre`, `descripcion`, `precio`, `stock`, `categoria`, `activo`) VALUES
('Teclado mecánico',     'Teclado RGB con switches azules mecánicos.',      2450.00,  12, 'perifericos',   1),
('Mouse inalámbrico',    'Mouse óptico ergonómico con receptor USB 2.4G.',    890.00,  34, 'perifericos',   1),
('Monitor 24 pulgadas',  'Monitor Full HD 75Hz con entrada HDMI.',           9800.00,   5, 'monitores',     1),
('Notebook 15 pulgadas', 'Notebook con 8 GB RAM y disco SSD NVMe.',         38500.00,   0, 'computadoras',  1),
('Auriculares Gaming',   'Auriculares estéreo con micrófono cancelador.',    3200.00,  18, 'audio',         1)
ON DUPLICATE KEY UPDATE `id`=`id`;
