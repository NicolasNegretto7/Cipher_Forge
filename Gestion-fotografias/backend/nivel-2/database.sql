-- ======================================================================
-- database.sql
-- ======================================================================
-- Crea la base y las dos tablas que usa esta API, con los mismos datos
-- de prueba que antes vivían en mocks/*.json.
--
-- Cómo importarlo:
--
--   mysql -u root -p < database.sql          (línea de comandos)
--
-- o desde phpMyAdmin: Importar -> elegir este archivo -> Continuar.
--
-- Si tu base, usuario o contraseña son distintos a los de .env.example,
-- acordate de actualizar tu .env (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD).
-- ======================================================================

CREATE DATABASE IF NOT EXISTS utu_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE utu_demo;

-- ----------------------------------------------------------------------
-- Tabla usuarios
-- ----------------------------------------------------------------------
CREATE TABLE usuarios (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100)  NOT NULL,
    email      VARCHAR(150)  NOT NULL UNIQUE,
    clave_hash VARCHAR(255)  NOT NULL,
    rol        VARCHAR(20)   NOT NULL DEFAULT 'usuario',
    activo     TINYINT(1)    NOT NULL DEFAULT 1
);

-- ----------------------------------------------------------------------
-- Tabla productos
-- ----------------------------------------------------------------------
CREATE TABLE productos (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(150)   NOT NULL,
    descripcion TEXT,
    precio      DECIMAL(10, 2) NOT NULL,
    stock       INT            NOT NULL DEFAULT 0,
    categoria   VARCHAR(50)    NOT NULL,
    activo      TINYINT(1)     NOT NULL DEFAULT 1
);

-- ----------------------------------------------------------------------
-- Usuarios de prueba
-- La contraseña ya viene encriptada con password_hash() (bcrypt), tal
-- cual quedaría guardada de verdad: NUNCA se guarda en texto plano.
--
--   admin@utu.edu.uy  / admin123   (rol admin)
--   alumno@utu.edu.uy / alumno123  (rol usuario)
-- ----------------------------------------------------------------------
INSERT INTO usuarios (nombre, email, clave_hash, rol, activo) VALUES
('Ana Administradora', 'admin@utu.edu.uy',  '$2y$12$.Fvn3QkhSJip4AEcBNeH3eUFB67Y/zUXpnpVzHvNme3qcHV1zlwjm', 'admin',   1),
('Bruno Alumno',        'alumno@utu.edu.uy', '$2y$12$FGZYCw99rH7qj/G5O/OJm.Mc.AvsrevKOjufKCEbNEqEOZtXaQ3NS', 'usuario', 1);

-- ----------------------------------------------------------------------
-- Productos de ejemplo
-- ----------------------------------------------------------------------
INSERT INTO productos (nombre, descripcion, precio, stock, categoria, activo) VALUES
('Teclado mecánico',     'Teclado con luces y switches azules.',    2450.00,  12, 'perifericos',   1),
('Mouse inalámbrico',    'Mouse óptico con receptor USB.',           890.00,  34, 'perifericos',   1),
('Monitor 24 pulgadas',  'Monitor Full HD con HDMI.',                9800.00,  5, 'monitores',     1),
('Notebook 15 pulgadas', 'Notebook con 8 GB de RAM y disco SSD.',   38500.00,  0, 'computadoras',  1),
('Auriculares',          'Auriculares con micrófono.',               3200.00, 18, 'audio',         1);
