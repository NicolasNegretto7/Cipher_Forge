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
fotografo_id INT NOT NULL, 
tipo_visibilidad ENUM('privada', 'publica') NOT NULL,
titulo VARCHAR(40) NOT NULL,
descripcion VARCHAR(90),
creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (fotografo_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE imagenes (
coleccion_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
url_imagen VARCHAR(125) NOT NULL,

FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);

CREATE TABLE favoritos (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
favoritos_id INT NOT NULL,
url_imagen VARCHAR(125) NOT NULL,


FOREIGN KEY (favoritos_id) REFERENCES imagenes (coleccion_id),
FOREIGN KEY (url_imagen) REFERENCES imagenes (url_imagen)
);