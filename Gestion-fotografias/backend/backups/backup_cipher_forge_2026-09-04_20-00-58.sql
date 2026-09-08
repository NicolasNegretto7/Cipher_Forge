-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-04 20:00:58
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

-- Volcado de datos para `acceso_colecciones`
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('2', '4', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('4', '6', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('8', '10', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('10', '12', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('12', '14', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('15', '17', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('19', '21', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('21', '23', '1', '1');

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
INSERT INTO `clientes` (`id_cliente`) VALUES ('10');
INSERT INTO `clientes` (`id_cliente`) VALUES ('12');
INSERT INTO `clientes` (`id_cliente`) VALUES ('15');
INSERT INTO `clientes` (`id_cliente`) VALUES ('19');
INSERT INTO `clientes` (`id_cliente`) VALUES ('21');

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

-- Volcado de datos para `coleccion_hashtags`
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '1');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '1');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '2');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '2');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '5');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '5');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '9');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '9');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '11');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '11');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '13');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '13');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '16');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '16');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '20');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '20');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '22');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '22');

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
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `colecciones`
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('1', '1', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:29:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('2', '1', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:29:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('3', '1', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:29:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('4', '1', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:29:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('5', '3', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:32:34');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('6', '3', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:32:35');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('7', '5', 'publica', 'Col Diag', NULL, '2026-09-04 19:35:38');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('8', '6', 'publica', 'Col Diag2', NULL, '2026-09-04 19:36:57');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('9', '7', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:37:18');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('10', '7', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:37:18');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('11', '9', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:39:45');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('12', '9', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:39:45');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('13', '11', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:43:30');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('14', '11', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:43:30');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('15', '13', 'publica', 'Debug Col', NULL, '2026-09-04 19:47:00');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('16', '14', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:50:46');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('17', '14', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:50:46');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('18', '16', 'publica', 'Debug Col', NULL, '2026-09-04 19:53:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('19', '17', 'publica', 'Debug Col', NULL, '2026-09-04 19:55:21');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('20', '18', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:55:31');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('21', '18', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:55:32');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('22', '20', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 19:58:47');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('23', '20', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 19:58:47');

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
  `biografia` text,
  `especialidad` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id_fotografo`),
  CONSTRAINT `fotografos_ibfk_1` FOREIGN KEY (`id_fotografo`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `fotografos`
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('1', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('3', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('5', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('6', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('7', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('9', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('11', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('13', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('14', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('16', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('17', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('18', '1', 'Especialista en bodas.', 'Bodas');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('20', '1', 'Especialista en bodas.', 'Bodas');

-- --------------------------------------------------------
-- Estructura de tabla `hashtags`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `hashtags`;
CREATE TABLE `hashtags` (
  `nombre_hashtags` varchar(40) NOT NULL,
  `id_hashtags` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_hashtags`),
  UNIQUE KEY `nombre_hashtags` (`nombre_hashtags`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `hashtags`
INSERT INTO `hashtags` (`nombre_hashtags`, `id_hashtags`) VALUES ('bodas', '1');
INSERT INTO `hashtags` (`nombre_hashtags`, `id_hashtags`) VALUES ('ceremonia', '2');

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
  `aprobado` tinyint(1) NOT NULL DEFAULT '1',
  `tipo` enum('video','imagen') NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_multimedia`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '1', 'uploads/originals/f047a5087d491e10cc2cac98e8f4c27f.png', '8', 'uploads/previews/2e29d188cfc2c03e3c94405f45de8776.jpg', '3359', '0', '1', 'imagen', '2026-09-04 19:36:58');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '2', 'uploads/originals/dcc25aa711e5c082d60d0b04b5f54db0.png', '19', 'uploads/previews/9b840e01e082746dd7682a6e34a6bee8.jpg', '1462', '0', '1', 'imagen', '2026-09-04 19:55:21');

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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `qr_tokens`
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('1', '066bf2144305f1acff595a89b15ce364fe7fad36', '4', '2026-09-04 19:29:05', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('2', '43a95feebd58b3cdf413d3e9c43321ddfd9d9b86', '2', '2026-09-04 19:29:37', 'colaborativo', '2026-09-05 19:29:37');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('3', 'e060ccc43bef9b206ca5059388b658847025b8ec', '2', '2026-09-04 19:29:38', 'colaborativo', '2026-09-05 19:29:38');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('4', 'aa8b302655e545e6b0b8567a52e3961187a315e7', '6', '2026-09-04 19:32:36', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('5', 'f3f7970f13f9b7710498747a6d59303b4d30e1fb', '5', '2026-09-04 19:33:39', 'colaborativo', '2026-09-05 19:33:39');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('6', 'e4087ef0cad630cb2b7e501e8497d478b863e272', '10', '2026-09-04 19:37:19', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('7', 'e580c220c96043cd0e9019d1c9055ae4ce186ee7', '9', '2026-09-04 19:38:23', 'colaborativo', '2026-09-05 19:38:23');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('8', '07a1b36878723d665ada06e9e61d3893514806a7', '12', '2026-09-04 19:39:46', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('9', 'd15f97ec46054df96efdf45642b2af7d05f1d6dc', '11', '2026-09-04 19:40:52', 'colaborativo', '2026-09-05 19:40:52');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('10', '467a21c2cfcc3e08aec02690023544a84ed5dc06', '14', '2026-09-04 19:43:32', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('11', '8c69808790bf233d07e5abd3f27bdf3297a8b2ad', '13', '2026-09-04 19:44:37', 'colaborativo', '2026-09-05 19:44:37');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('12', 'fbbd555d394712c091b05162be577e4eb7ac1f19', '17', '2026-09-04 19:50:47', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('13', '44d88e24ddd2b7d8f58a4f1f1841be6b079c6796', '16', '2026-09-04 19:51:52', 'colaborativo', '2026-09-05 19:51:52');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('14', '64aed2eed0309bd45f9a62ebdca6600db53964ca', '21', '2026-09-04 19:55:34', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('15', 'a5621aa657763c59f174edf3d305016673ee9b90', '20', '2026-09-04 19:56:38', 'colaborativo', '2026-09-05 19:56:38');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('16', '0ad4da41447d469c3494710bd043b4c38235c0a1', '23', '2026-09-04 19:58:49', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('17', 'fa07883d5c96a7d31afcaf3b83283b4b4598a51a', '22', '2026-09-04 19:59:54', 'colaborativo', '2026-09-05 19:59:54');

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
  `codigo_verificacion` varchar(10) DEFAULT NULL,
  `codigo_expiracion` datetime DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('fotografo','cliente') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `usuarios`
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('1', 'Fotografo Test Actualizado', 'foto162859@test.com', '+598 99 111 222', '0', '202921', '2026-09-04 20:28:59', '$2y$10$EQNO9BsYCrR92rqu3UpsbeyHqcCIo4XBcksmdg5db55kXXWjx/b52', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('2', 'Cliente Test', 'cliente162859@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$68AwFzIJjiwIXxyqGRNVDe21bAroYp47Tr3gpBW/8TiQA4By9CkQ6', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('3', 'Fotografo Test Actualizado', 'foto163231@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$l3gXY8ccQz/jfbIQj2NbMOm04HmqNChGN.iai4UF/qGu26FeUwLXG', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('4', 'Cliente Test', 'cliente163231@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$bkHdmXpnw9mBW5lMln0nVuq8kpzNtd6l9FFSU9nR7XJiOVG74WJO6', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('5', 'Diag Up', 'diagup163536@test.com', NULL, '0', '914466', '2026-09-04 20:35:36', '$2y$10$82UyO2hMlCSY6xMRMfxkwOH.LYdSdPjHPOhUjdmq0YMAtkhb0N7Ty', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('6', 'Diag Up', 'diagup163657@test.com', NULL, '0', '467474', '2026-09-04 20:36:57', '$2y$10$KiaPsJxOHYf.aJHsiPD/3uyXTnF2GnlH/iukDTdonOdUcNfZ54NnC', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('7', 'Fotografo Test Actualizado', 'foto163714@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$LIn.u6sHnnxZ99.GlvK3OuRkBOJZAt6o6Qv5rHbnSRzLEVF7MPq1G', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('8', 'Cliente Test', 'cliente163714@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$IUbzhcYIDXongmLvnUWbXOQbvCpojCmXFB8xHhefDHfVJY8GrhcPW', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('9', 'Fotografo Test Actualizado', 'foto163942@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$W6p6EH7obmr/1k6J5F0h0uYPiu5P719m7gYdxOUbZ2KEKQY8U4HX.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('10', 'Cliente Test', 'cliente163942@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$Gl20TBVvleE0XTsGQySoM.eGLZHnM/TudMUDt/VrBrJgjfXIECPta', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('11', 'Fotografo Test Actualizado', 'foto164325@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$4ZhX1TDfYnMxNpkAn6jMwOV9rDxjoqTMj1ytY8e6Jlz.KVXiVmCey', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('12', 'Cliente Test', 'cliente164325@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$B1TGWka5ZMt.ATcxJYCQx.rChtTa73JtWbkU8bSTJcpvIexslB6D2', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('13', 'Debug Test', 'dbg164659@test.com', NULL, '0', '220571', '2026-09-04 20:47:00', '$2y$10$wDTGwwX8ZK22FcvXXsc8/eOmxmoQP0DhNIhv9h9qWKTKHYRMISTAq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('14', 'Fotografo Test Actualizado', 'foto165042@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$nazuwhQWbp2L/xKcQGJe3OUJ1xeS6DbQoaecfn2qJDQC38TtPsNx2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('15', 'Cliente Test', 'cliente165042@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$Mf4dC4P48rk4jxR9o.eUWutVGrSxFxKBqYdYMrytV0ou.L3Vqmpr6', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('16', 'Debug Test', 'dbg165302@test.com', NULL, '0', '972028', '2026-09-04 20:53:03', '$2y$10$EeLEf4/Ts9tPgEaYmzKst.6znZoIAKbGpu8yafOqgZL2jr93rSUzq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('17', 'Debug Test', 'dbg165520@test.com', NULL, '0', '663950', '2026-09-04 20:55:20', '$2y$10$2V4f1JRO1YTb4DaypiZf8eZz/uLeyvaWsS6GqeoD5WKJo/6aJ76H.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('18', 'Fotografo Test Actualizado', 'foto165527@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$JT8iMtXPTkvDxUfkubEL0.FXiDC7Mx6fy7DFydXVkSMmk6a1r8Tu6', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('19', 'Cliente Test', 'cliente165527@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$wFYoU4Bj0na6GlWUDKC4LODD38Hljlikp9NuYb.pj8qTGe7n/gB/W', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('20', 'Fotografo Test Actualizado', 'foto165844@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$EJs.GCwiCu2ZENyOwver3OJ5j3ppO6OJD1na/HIpwzU0Av90HOFp.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('21', 'Cliente Test', 'cliente165844@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$lYI7RI5Mmo6F/1gPvk0cp.hgPMboVD4vKEafWAgllC/xAU0zL039.', 'cliente');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
