CREATE DATABASE IF NOT EXISTS cipher_forge;
USE cipher_forge;

CREATE TABLE usuarios(
id VARCHAR(36) NOT NULL PRIMARY KEY DEFAULT (UUID()),
nombre_completo VARCHAR(50) NOT NULL,
email VARCHAR(60) NOT NULL UNIQUE,
telefono VARCHAR(30),
password_hash VARCHAR(255) NOT NULL,
rol ENUM('fotografo', 'cliente') NOT NULL 

);

CREATE TABLE colecciones(
id VARCHAR(36) NOT NULL PRIMARY KEY DEFAULT (UUID()),
fotografo_id VARCHAR(36) NOT NULL, 
tipo_visibilidad ENUM('privada', 'publica') NOT NULL DEFAULT 'privada',
titulo VARCHAR(40),
descripcion VARCHAR(90),
creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (fotografo_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE multimedia (
id_multimedia VARCHAR(36) NOT NULL PRIMARY KEY DEFAULT (UUID()) ,
url_original VARCHAR(90) NOT NULL,
coleccion_id VARCHAR(36) NOT NULL,
vista_previa VARCHAR(255) NOT NULL,
tamanio BIGINT UNSIGNED NOT NULL,
es_invitado BOOLEAN NOT NULL DEFAULT FALSE,
tipo ENUM('videos', 'imagenes') NOT NULL,
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);


CREATE TABLE favoritos (

usuarios_id VARCHAR(36) NOT NULL,
favoritos_id VARCHAR(36) NOT NULL,

PRIMARY KEY (usuarios_id, favoritos_id),
FOREIGN KEY (usuarios_id) REFERENCES usuarios(id) ON DELETE CASCADE,
FOREIGN KEY (favoritos_id) REFERENCES multimedia (id_multimedia) ON DELETE CASCADE
);





