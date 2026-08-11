CREATE DATABASE IF NOT EXISTS cipher_forge;
USE cipher_forge;

CREATE TABLE usuarios(
id VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT,
nombre_completo VARCHAR(90) NOT NULL,
email VARCHAR(60) NOT NULL UNIQUE,
telefono VARCHAR(30),
email_verificado BOOLEAN DEFAULT FALSE,
password_hash VARCHAR(255) NOT NULL,
rol ENUM('fotografo', 'cliente') NOT NULL,
politicas_aceptadas BOOLEAN DEFAULT FALSE NOT NULL

);

CREATE TABLE colecciones(
id VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT,
fotografo_id VARCHAR(36) NOT NULL, 
tipo_visibilidad ENUM('privada', 'publica') NOT NULL DEFAULT 'privada',
titulo VARCHAR(60),
descripcion VARCHAR(90),
creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (fotografo_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


CREATE TABLE multimedia (
titulo VARCHAR(60),
descripcion VARCHAR(90),
id_multimedia VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT,
ruta_original VARCHAR(255) NOT NULL,
coleccion_id VARCHAR(36) NOT NULL,
vista_previa VARCHAR(255) NOT NULL,
tamanio INT UNSIGNED NOT NULL,
es_invitado BOOLEAN NOT NULL DEFAULT FALSE,
tipo ENUM('videos', 'imagenes') NOT NULL,
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);


CREATE TABLE favoritos (

usuario_id VARCHAR(36) NOT NULL,
favorito_id VARCHAR(36) NOT NULL,

PRIMARY KEY (usuario_id, favorito_id),
FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
FOREIGN KEY (favorito_id) REFERENCES multimedia (id_multimedia) ON DELETE CASCADE
);

CREATE TABLE acceso_colecciones (
usuario_id VARCHAR(36) NOT NULL,
coleccion_id VARCHAR(36) NOT NULL,
permitir_alta_calidad BOOLEAN DEFAULT FALSE,
permitir_buena_calidad BOOLEAN DEFAULT FALSE,


PRIMARY KEY (usuario_id, coleccion_id),
FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);

CREATE TABLE qr_tokens(
token VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT,
coleccion_id VARCHAR(36) NOT NULL,
creacion_token TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
tipo ENUM('colaborativo', 'acceso'),
expiracion DATETIME DEFAULT NULL,

FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE

);

CREATE TABLE solicitudes_descarga(
id_solicitud VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT,
usuario_id VARCHAR(36) NOT NULL,
coleccion_id VARCHAR(36) NOT NULL,
solicitud ENUM('pendiente','aprobada', 'rechazada') DEFAULT 'pendiente',
calidad_descarga ENUM('buena', 'alta') NOT NULL,
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE,
FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE hashtags(
nombre_hashtags VARCHAR(40) NOT NULL,
id_hashtags VARCHAR(36) NOT NULL PRIMARY KEY AUTO_INCREMENT


);

CREATE TABLE coleccion_hashtags(
id_hashtags VARCHAR(36) NOT NULL,
coleccion_id VARCHAR(36) NOT NULL,

PRIMARY KEY (id_hashtags, coleccion_id),
FOREIGN KEY (id_hashtags) REFERENCES hashtags(id_hashtags) ON DELETE CASCADE,
FOREIGN KEY (coleccion_id) REFERENCES colecciones(id) ON DELETE CASCADE
);

CREATE TABLE backups(
id_backup INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
archivo_backup INT UNSIGNED NOT NULL,
fecha_backup TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

);



