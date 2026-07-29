CREATE DATABASE IF NOT EXISTS cipher_forge;
USE cipher_forge;

CREATE TABLE usuarios(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
nombre_completo VARCHAR(60) NOT NULL,
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
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    coleccion_id INT NOT NULL,
    url_imagen VARCHAR(125) NOT NULL,

FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);

CREATE TABLE favoritos (

usuarios_id INT NOT NULL,
favoritos_id INT NOT NULL,

PRIMARY KEY (usuarios_id, favoritos_id),
FOREIGN KEY (usuarios_id) REFERENCES usuarios(id) ON DELETE CASCADE,
FOREIGN KEY (favoritos_id) REFERENCES imagenes (id) ON DELETE CASCADE
);

CREATE TABLE acceso_colecciones(
usuario_id INT NOT NULL,
coleccion_id INT NOT NULL,
permitira_alta_calidad BOOLEAN DEFAULT FALSE,

PRIMARY KEY(usuario_id, coleccion_id),
FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id)



);
