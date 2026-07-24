CREATE DATABASE IF NOT EXISTS cipher_forge;
USE cipher_forge;

CREATE TABLE usuarios(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nombre_completo VARCHAR(60) NOT NULL,
cedula VARCHAR(30) NOT NULL UNIQUE,
email VARCHAR(60) NOT NULL UNIQUE,
telefono VARCHAR(30) NOT NULL,
password_hash VARCHAR(255) NOT NULL,
rol ENUM('fotografo', 'cliente') NOT NULL 

);

CREATE TABLE colecciones(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
fotografo_id INT NOT NULL FOREIGN KEY (fotografo_id) REFERENCES usuarios(id) ON DELETE CASCADE,
tipo_visibilidad ENUM('privada', 'publica') NOT NULL,
titulo VARCHAR(40) NOT NULL,
descripcion VARCHAR(90) NOT NULL,
creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP


);