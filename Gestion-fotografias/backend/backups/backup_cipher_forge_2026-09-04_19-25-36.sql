-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-04 19:25:36
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Estructura de tabla `acceso_colecciones`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `acceso_colecciones`;
CREATE TABLE `acceso_colecciones` (
  `usuario_id` int NOT NULL,
  `coleccion_id` int NOT NULL,
  `permitir_alta_calidad` tinyint(1) DEFAULT '0',
  `permitir_buena_calidad` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`usuario_id`,`coleccion_id`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `acceso_colecciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `acceso_colecciones_ibfk_2` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `clientes`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `clientes`;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL,
  PRIMARY KEY (`id_cliente`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `clientes`
INSERT INTO `clientes` (`id_cliente`) VALUES ('2');
INSERT INTO `clientes` (`id_cliente`) VALUES ('4');
INSERT INTO `clientes` (`id_cliente`) VALUES ('8');

-- --------------------------------------------------------
-- Estructura de tabla `coleccion_hashtags`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `coleccion_hashtags`;
CREATE TABLE `coleccion_hashtags` (
  `id_hashtags` int NOT NULL,
  `coleccion_id` int NOT NULL,
  PRIMARY KEY (`id_hashtags`,`coleccion_id`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `coleccion_hashtags_ibfk_1` FOREIGN KEY (`id_hashtags`) REFERENCES `hashtags` (`id_hashtags`) ON DELETE CASCADE,
  CONSTRAINT `coleccion_hashtags_ibfk_2` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `colecciones`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `colecciones`;
CREATE TABLE `colecciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fotografo_id` int NOT NULL,
  `tipo_visibilidad` enum('privada','publica') NOT NULL DEFAULT 'privada',
  `titulo` varchar(60) DEFAULT NULL,
  `descripcion` varchar(90) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fotografo_id` (`fotografo_id`),
  CONSTRAINT `colecciones_ibfk_1` FOREIGN KEY (`fotografo_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `colecciones`
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('1', '1', 'privada', 'Boda Martín y Sofía', 'Ceremonia religiosa y fiesta', '2026-09-02 18:24:01');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('2', '1', 'publica', 'Boda Martín y Sofía', 'Ceremonia religiosa y fiesta', '2026-09-02 18:24:18');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('3', '1', 'privada', 'testing', 'tested', '2026-09-02 19:24:07');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('4', '6', 'privada', 'Boda Test', 'Privada', '2026-09-03 19:04:32');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('5', '6', 'publica', 'Boda Publica', 'Publica', '2026-09-03 19:08:48');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('6', '7', 'privada', 'Privada Final', NULL, '2026-09-03 19:13:43');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('7', '7', 'privada', 'Privada Final4', NULL, '2026-09-03 19:14:32');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('8', '9', 'privada', 'Boda', NULL, '2026-09-03 19:32:19');

-- --------------------------------------------------------
-- Estructura de tabla `favoritos`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `favoritos`;
CREATE TABLE `favoritos` (
  `usuario_id` int NOT NULL,
  `favorito_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`favorito_id`),
  KEY `favorito_id` (`favorito_id`),
  CONSTRAINT `favoritos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `favoritos_ibfk_2` FOREIGN KEY (`favorito_id`) REFERENCES `multimedia` (`id_multimedia`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `fotografos`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `fotografos`;
CREATE TABLE `fotografos` (
  `id_fotografo` int NOT NULL,
  `politicas_aceptadas` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_fotografo`),
  CONSTRAINT `fotografos_ibfk_1` FOREIGN KEY (`id_fotografo`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `fotografos`
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('1', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('3', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('5', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('6', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('7', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('9', '0');

-- --------------------------------------------------------
-- Estructura de tabla `hashtags`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `hashtags`;
CREATE TABLE `hashtags` (
  `nombre_hashtags` varchar(40) NOT NULL,
  `id_hashtags` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_hashtags`),
  UNIQUE KEY `nombre_hashtags` (`nombre_hashtags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `multimedia`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `multimedia`;
CREATE TABLE `multimedia` (
  `titulo` varchar(60) DEFAULT NULL,
  `descripcion` varchar(90) DEFAULT NULL,
  `id_multimedia` int NOT NULL AUTO_INCREMENT,
  `ruta_original` varchar(255) NOT NULL,
  `coleccion_id` int NOT NULL,
  `vista_previa` varchar(255) NOT NULL,
  `tamanio` bigint unsigned NOT NULL,
  `es_invitado` tinyint(1) NOT NULL DEFAULT '0',
  `tipo` enum('video','imagen') NOT NULL,
  PRIMARY KEY (`id_multimedia`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '1', 'uploads/originals/9f290ddfb6bc77a01f983561ae241f16.jpg', '4', 'uploads/previews/32d1b0569a9b60198960a99c812d3e53.jpg', '2024', '0', 'imagen');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '2', 'uploads/originals/85eabd23e46f645176ee72d95eb7912b.jpg', '5', 'uploads/previews/6b7a9d9d5ba2ba5c43797e014df4ed59.jpg', '2024', '0', 'imagen');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '3', 'uploads/originals/81d5d0cb6fd57095ed6ac6cb10cb8950.mp4', '5', 'uploads/previews/a72ce48df743ee403d42d952f6610120.mp4', '104840', '0', 'video');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '4', 'uploads/originals/57c4228aa2fd631fcce1b77ef7e1f2f8.jpg', '5', 'uploads/previews/bef07835e4d7e05cccd194038b21a213.jpg', '2024', '0', 'imagen');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '5', 'uploads/originals/b87ff149cf0a2d9bc95878cde8f977ad.jpg', '7', 'uploads/previews/9e0a64e452ffa9fbc8a3eec5202bfcf7.jpg', '2024', '0', 'imagen');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `tipo`) VALUES (NULL, NULL, '6', 'uploads/originals/bdd174f1cfad3a20b95ef617db3130e0.png', '8', 'uploads/previews/856ea86690440b251e9d00f04a7fc6b7.jpg', '1042642', '0', 'imagen');

-- --------------------------------------------------------
-- Estructura de tabla `qr_tokens`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `qr_tokens`;
CREATE TABLE `qr_tokens` (
  `id_token` int NOT NULL AUTO_INCREMENT,
  `token` varchar(100) NOT NULL,
  `coleccion_id` int NOT NULL,
  `creacion_token` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo` enum('colaborativo','acceso') DEFAULT NULL,
  `expiracion` datetime DEFAULT NULL,
  PRIMARY KEY (`id_token`),
  UNIQUE KEY `token` (`token`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `qr_tokens_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `solicitudes_descarga`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `solicitudes_descarga`;
CREATE TABLE `solicitudes_descarga` (
  `id_solicitud` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `coleccion_id` int NOT NULL,
  `solicitud` enum('pendiente','aprobada','rechazada') DEFAULT 'pendiente',
  `calidad_descarga` enum('buena','alta') NOT NULL,
  PRIMARY KEY (`id_solicitud`),
  KEY `coleccion_id` (`coleccion_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `solicitudes_descarga_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `solicitudes_descarga_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla `usuarios`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre_completo` varchar(90) NOT NULL,
  `email` varchar(60) NOT NULL,
  `telefono` varchar(30) DEFAULT NULL,
  `email_verificado` tinyint(1) NOT NULL DEFAULT '0',
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('fotografo','cliente') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `usuarios`
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('1', 'Lemuel Swec', 'fotografo@test.com', '+59899123456', '0', '$2y$10$5C/V8lJLlam61uFBASf1dOr4CtkKR9v1QVf.Y3QbPkKRkxoNNymCK', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('2', 'Lemuel Swec', 'cliente@test.com', NULL, '0', '$2y$10$BlmG9YusTwGbUsmG36XJa.vvSC1w2hoG2b1kyLKbWw79E1NgQ3UZC', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('3', 'Ivan sandoval', 'sfds@gmail.com', NULL, '0', '$2y$10$YoGbhtd.a8OFra0vSyQxkOa4ZBoV2yVFpbJL4uTbI8Ke9tG069Rde', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('4', 'dfss', 'fdnpiu@gmali.com', NULL, '0', '$2y$10$gVItpiv8ZbZ4wUki3eIGLO2HqB4ODDhYtS8zd0a.bmUteveWMcrM6', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('5', 'dfssjh', 'rexrtxct@gmail.com', NULL, '0', '$2y$10$nZbX.96oWwy9ZCVbxuxN7e3h0v5YlO176GcZgs/ou5AiBr.lylWd2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('6', 'Fotografo Test', 'foto@test.com', NULL, '0', '$2y$10$WJneWLtkzFJp0KN0HUoAf.W6gahMkHH/ds2WsJMq1HctghQAWkaey', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('7', 'Foto Final', 'final_foto@test.com', NULL, '0', '$2y$10$xsdS/MT2hHTvOVVaXZ0sJ.U54H1E9S5cZDgi/ryieBG2Ew/MZuqkS', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('8', 'Cliente Final', 'final_cliente@test.com', NULL, '0', '$2y$10$xl6QY/FHf75t65PCIAIgQujQXejZzABVzi0GpLDProi0jUt0I195C', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `password_hash`, `rol`) VALUES ('9', 'Fotografo Prueba', 'prueba@test.com', NULL, '0', '$2y$10$KfVzceISmO0eO34TXvg0guZBOggOlU/MXNvpXedu9GSu3jSYfrC2u', 'fotografo');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
