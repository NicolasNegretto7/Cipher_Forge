-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-16 16:57:27
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
INSERT INTO `clientes` (`id_cliente`) VALUES ('20');
INSERT INTO `clientes` (`id_cliente`) VALUES ('21');
INSERT INTO `clientes` (`id_cliente`) VALUES ('24');
INSERT INTO `clientes` (`id_cliente`) VALUES ('46');
INSERT INTO `clientes` (`id_cliente`) VALUES ('55');
INSERT INTO `clientes` (`id_cliente`) VALUES ('57');

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
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('28', '44');

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
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `colecciones`
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('1', '1', 'publica', 'Hola', NULL, '2026-09-08 02:31:27');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('2', '1', 'publica', 'Hola', 'dddd', '2026-09-08 02:35:06');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('3', '1', 'publica', 'wenioss', 'aa', '2026-09-08 02:38:02');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('4', '4', 'publica', 'wenio', '2', '2026-09-08 20:39:38');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('5', '10', 'privada', 'wenio', '2', '2026-09-09 02:43:05');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('6', '10', 'publica', 'wenio', '2', '2026-09-09 02:43:09');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('7', '10', 'publica', 'wenio', '2', '2026-09-09 02:49:51');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('8', '10', 'privada', 'wenio', '2', '2026-09-09 03:06:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('9', '10', 'publica', 'wenio', '2', '2026-09-09 03:06:53');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('12', '10', 'publica', 'wenio', 'holaaa', '2026-09-09 04:27:18');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('13', '10', 'privada', 'wenio', 'holaaa', '2026-09-09 04:28:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('14', '10', 'publica', 'pao', 'a', '2026-09-09 04:29:59');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('39', '45', 'publica', 'Hola', 'wjojdjdjodjwjqjwdjljkljkl', '2026-09-10 18:45:14');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('40', '47', 'publica', 'm', 'm', '2026-09-10 19:04:32');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('41', '49', 'publica', 'edjededj', 'jiwdjiwdji', '2026-09-10 21:34:15');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('42', '49', 'publica', 'm', 'm', '2026-09-10 21:58:42');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('43', '49', 'publica', 'm', 'm', '2026-09-10 22:15:04');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('44', '53', 'publica', 'Mamamia', 'gy', '2026-09-13 23:47:58');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('46', '29', 'privada', 'wenio1', 'a', '2026-09-14 00:01:41');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('47', '56', 'privada', 'maaaa', 'a', '2026-09-14 23:48:59');

-- --------------------------------------------------------
-- Estructura de tabla `favoritos`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `favoritos`;
CREATE TABLE `favoritos` (
  `usuario_id` int NOT NULL,
  `favorito_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`favorito_id`),
  KEY `favoritos_ibfk_2` (`favorito_id`),
  CONSTRAINT `favoritos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `favoritos_ibfk_2` FOREIGN KEY (`favorito_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
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
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('1', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('2', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('3', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('4', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('6', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('10', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('11', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('16', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('17', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('29', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('43', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('44', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('45', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('47', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('48', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('49', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('52', '0', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('53', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('54', '1', NULL, NULL);
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`, `biografia`, `especialidad`) VALUES ('56', '1', NULL, NULL);

-- --------------------------------------------------------
-- Estructura de tabla `hashtags`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `hashtags`;
CREATE TABLE `hashtags` (
  `nombre_hashtags` varchar(40) NOT NULL,
  `id_hashtags` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_hashtags`),
  UNIQUE KEY `nombre_hashtags` (`nombre_hashtags`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `hashtags`
INSERT INTO `hashtags` (`nombre_hashtags`, `id_hashtags`) VALUES ('mamacita', '28');

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
  `poster` varchar(255) DEFAULT NULL,
  `tamanio` bigint unsigned NOT NULL,
  `es_invitado` tinyint(1) NOT NULL DEFAULT '0',
  `aprobado` tinyint(1) NOT NULL DEFAULT '1',
  `tipo` enum('video','imagen') NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_multimedia`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Hola', 'wjojdjdjodjwjqjwdjljkljkl', '44', 'uploads/originals/86754f8ab363a13d9c5583e26753f154.jpg', '39', 'uploads/previews/4482de548413b19a0234fa4d6106d2b6.jpg', NULL, '12112', '0', '1', 'imagen', '2026-09-10 18:45:14');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Juan', 'Aporte colaborativo de invitado', '45', 'uploads/originals/ca28a819f8537edb295ee4c24fb140ff.png', '39', 'uploads/previews/961b63804eb84b5c438027756af16717.jpg', NULL, '285', '1', '1', 'imagen', '2026-09-10 18:45:37');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('m', 'm', '46', 'uploads/originals/e4288be6214b72f9216ee246d558f94e.jpg', '40', 'uploads/previews/1a0f3a754a31b91bb8ec0142520fa887.jpg', NULL, '12112', '0', '1', 'imagen', '2026-09-10 19:04:32');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('edjededj', 'jiwdjiwdji', '47', 'uploads/originals/1f1e9020ca66fc8e4bd8671d334916bf.jpg', '41', 'uploads/previews/6a29e326fe9cbcc4b384ae95e12c04da.jpg', NULL, '12112', '0', '1', 'imagen', '2026-09-10 21:34:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('m', 'm', '48', 'uploads/originals/0344969440ec01c5c2585a83bd19aa6a.jpg', '42', 'uploads/previews/22b363931d22bdd64f0776bf2ace0cd1.jpg', NULL, '451736', '0', '1', 'imagen', '2026-09-10 21:58:43');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('m', 'm', '49', 'uploads/originals/6b98463d1a12167b51193f12f10c9812.jpg', '43', 'uploads/previews/98d6fc21ae5898ba7836a77c13e23d66.jpg', NULL, '223320', '0', '1', 'imagen', '2026-09-10 22:15:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('images.jpg', NULL, '50', 'uploads/originals/927728155798779ed7cca50833a437d6.jpg', '44', 'uploads/previews/6703b783f5d1888e158fa7aeaf062ba7.jpg', NULL, '13256', '0', '1', 'imagen', '2026-09-13 23:48:18');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('OIF.jpg', NULL, '52', 'uploads/originals/33271db18884c11f58169891c7014370.jpg', '46', 'uploads/previews/b263535d838dee992d75cd0c010c69a9.jpg', NULL, '26213', '0', '1', 'imagen', '2026-09-14 00:04:13');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('descarga-27-buena.jpg', NULL, '53', 'uploads/originals/4416f12bdaa58ee15a93e69d65ba2262.jpg', '47', 'uploads/previews/67a66193f3081f7e1692b0e0cdddba2b.jpg', NULL, '32064', '0', '1', 'imagen', '2026-09-14 23:50:27');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('mu.jpg', NULL, '54', 'uploads/originals/630e885125793cbf43a1ff64eb5c11b5.jpg', '47', 'uploads/previews/15100a17c4bc1477bf02ceac54294759.jpg', NULL, '482505', '0', '1', 'imagen', '2026-09-14 23:50:27');

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
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `qr_tokens`
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('2', '5b09810b2a13a823340b23427ab49821bbc0ee4d', '12', '2026-09-09 04:27:21', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('3', 'ac1867f68b0d0c79f3ef0f6b5bc7796941e44818', '13', '2026-09-09 04:28:06', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('4', 'a9bd732d0bffe00bac5afc0923e68c9ca9ea1f3e', '14', '2026-09-09 04:30:01', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('39', 'a9117a5222c90f43d6bdd2e8a9866be033bfff0a', '39', '2026-09-10 18:45:18', 'colaborativo', '2026-09-11 18:45:18');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('40', '5ff0db0e4ba1bf68099470026cd0451d81fb1947', '40', '2026-09-10 19:04:34', 'colaborativo', '2026-09-11 19:04:34');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('41', '706d87f61fd227b0c8595057879a26f197a12b8f', '40', '2026-09-10 19:07:16', 'colaborativo', '2026-09-11 19:07:16');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('42', '8de75ff17ce496d004241d927f7f2b658d8d1636', '41', '2026-09-10 21:34:17', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('43', 'a58d45b8d8ac9adf515fc45a111b3eceb88f6b80', '42', '2026-09-10 21:58:46', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('44', '21578b8e61dfdd243f2974c178eb8d5b54c48f79', '43', '2026-09-10 22:15:07', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('45', '39687b476b95717d3c5422b1d3ee232657b1830c', '46', '2026-09-14 00:01:43', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('46', 'd6c6aa15cdeae6ab15f3f000c488a876ddd5aaaf', '46', '2026-09-14 00:01:45', 'colaborativo', '2026-09-15 00:01:45');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('47', '7304dc72f1de7ff28b8c86562e7ceb15f643dad7', '46', '2026-09-14 00:01:52', 'colaborativo', '2026-09-15 00:01:52');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('48', 'd41eafdfc5daad613d9dc8cbd353772a870bcfd8', '46', '2026-09-14 00:04:16', 'colaborativo', '2026-09-15 00:04:16');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('49', '9572491013897a9f6f0eda92f19eff392d03d5f1', '47', '2026-09-14 23:49:01', 'colaborativo', '2026-09-15 23:49:01');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('50', 'a1156960f32e1f794fdb654b1eee1b8fd5d46032', '47', '2026-09-14 23:49:34', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('51', '6d569bace7c3766221c5d25d37868a90f5639b1d', '47', '2026-09-14 23:50:42', 'colaborativo', '2026-09-15 23:50:42');

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
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `usuarios`
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('1', 'aaaa', 'rkrkrkrk2223@gmail.com', NULL, '0', '389413', '2026-09-08 03:31:20', '$2y$10$oufS1yaHAqWAVjBMq3tqvuJugPL/qf7WoqkoVj7p3VJ/zHIB/xTdK', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('2', 'aaa', 'rkrkrkrk12@gmail.com', NULL, '0', '611784', '2026-09-08 03:44:45', '$2y$10$trYc0gloXtZta1bFAAvQJOdrxO2lHvimPttVOc/IWya/yI0BjJtsy', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('3', 'aaa', 'rkrkrkrk2@gmail.com', NULL, '0', '892552', '2026-09-08 21:09:37', '$2y$10$oKEA3fPtOkEWVIurQM79K.Ry9p/lbLUPEhzvPputtPMj2nQ7Wp97e', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('4', 'aaaabhola', 'rkrkrkrk1000@gmail.com', '09234851', '0', '832575', '2026-09-08 21:10:39', '$2y$10$5aXTSX33t9V9vXL65eZl6.IH.rkrNPcFZFod58jTriJhuR.uD1g2W', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('6', 'boom', 'rkrkrkrk2222@gmail.com', '0923485', '0', '673183', '2026-09-08 21:42:53', '$2y$10$AWCoJpzC8p.86R0KJfpn1eWIbBEwHEPkO3g/ZdSFpkiDN7I/6bKLe', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('10', 'aaaabhola', 'augustofernandez6276@gamil.com', '0923485', '1', NULL, NULL, '$2y$10$rpVnrn/R7qRFYtVfuTXcrO/aEuuvLHXIdZxkcnax8SiQfB5TB9Qrq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('11', 'Augusto', 'augustofernandez6277@gamil.com', '09234851', '1', NULL, NULL, '$2y$10$wJxhiiGcNrZa0QXRzn7C3.zE0NH9L8FCLC/SRbknOst.tiqUB6TtC', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('16', 'Prueba Conexion F', 'conncheck_fixed@gmail.com', NULL, '1', NULL, NULL, '$2y$10$0H0WAv8q9Yb1NwfD5Uq4ueMbtzbo3MUESXVCpHR.DBpz1rbaJT/J.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('17', 'Panel Check', 'panelcheck@gmail.com', NULL, '1', NULL, NULL, '$2y$10$TxjYkzzVyVkDn.9WVctdfeCH87b.rPAqVpLPVX2fadt/g1gRLtBYi', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('20', 'aaaa', 'rkrkrkrk222211@gmail.com', NULL, '1', NULL, NULL, '$2y$10$BJwgM440rTL6Yx7pzppmF.6MYhLuCbYluv3xQb7futki5/BFD.Q1e', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('21', 'Augusto', 'rkrkrkrk999@gmail.com', NULL, '1', NULL, NULL, '$2y$10$JqCWHj/zV82hF1DHKBW/qu.vmjWBfJjYQQGEWqGtfsaCctVyG1WAa', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('24', 'Augusto', 'rkrkrkrk13@gmail.com', '0923485', '1', NULL, NULL, '$2y$10$k2H8j8siaM5GlYdILaCi/usHsqlnWn3cBjsg7qmeQsxGaicTYEfhy', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('29', 'Augusto', 'rkrkrkrk@gmail.com', NULL, '1', NULL, NULL, '$2y$10$diJQ42339LE1AVatTksYpOUGmVjwFD3eZBWaypyAQuRIEllrjCN8e', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('43', 'ban', 'augustofernandez2@gmail.com', NULL, '1', NULL, NULL, '$2y$10$MliWLjGJ3AYQF8MwlNzvyuQCZQpmVXqkBtxtYkabRtjL0cTMlbmEq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('44', 'aaa', 'rkrkrkrk22222222@gmail.com', NULL, '1', NULL, NULL, '$2y$10$tMRfydp4WmMdVedtsKl8z.s3LxHk87o31XE9w6BQMWsfGKwYOmNaW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('45', 'aaa', 'rkrkrkrk22@gmail.com', NULL, '1', NULL, NULL, '$2y$10$kFFxzf8KEg4n70Bo4W.egeCqVBMm2j7nxOMjDLDRW0QyXvP.DXStq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('46', 'Augusto', 'rkrkrkrk8888@gmail.com', NULL, '1', NULL, NULL, '$2y$10$0s5BL4YMlHYcxKI1rZC.wupXsl8bLaRioLKDGpyXvAZrBKeUa0D3C', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('47', 'aaaa', 'rkrkrkrk8888727@gmail.com', NULL, '1', NULL, NULL, '$2y$10$FAiL3Vn/yVnJwcDDAeee8.ZChT6mpF86x9l1gcokjWruf0/KKZih6', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('48', 'ij', 'rkrkrkruhuhuhuihpuihk@gmail.com', NULL, '1', NULL, NULL, '$2y$10$duhb2uCEFk007TAcgCjWVO4NgjG7z8TBupqMHujAD1FwC5qdIWzBi', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('49', 'Augusto', 'rkrkrkrk22673@gmail.com', NULL, '1', NULL, NULL, '$2y$10$hZ/SXGNaEMbg7iRSk.atj.PsRcu3gVVHlMulSnIBdeY6SSEH.Xvoe', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('52', 'Augusto', 'augustofernandez1@gamil.com', NULL, '0', '605564', '2026-09-14 00:37:04', '$2y$10$Hlr19K8ad2b92lGY81wxTe2LGeAk3BNTIFIXZ7rhX1ibUc8g8HNQu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('53', 'aaaabhola', 'augustofernandez6271@gamil.com', NULL, '1', NULL, NULL, '$2y$10$/O7I/YCj2rjkhWY5KxOvIOBVV5VuqmgF3Zw2JJm12lLXda5740pjG', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('54', 'jks983', 'augustofernandez777@gamil.com', NULL, '1', NULL, NULL, '$2y$10$FhGoSKc02VEdaNz0Paz8jOqi68nUuMc/RbkD6BmqBDAqkiIawDk4q', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('55', 'jks983', 'augustofernandez111@gamil.com', NULL, '1', NULL, NULL, '$2y$10$hT67/rE/k7iqygEqVs64uOr1cDW34479QfonXRiAbu9zFAFnAY8eS', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('56', 'Mario1', 'rkrkrkrk2221@gmail.com', NULL, '1', NULL, NULL, '$2y$10$Sca2YEPrpJ6qZjwAji8RYucosXJWuVaf9PpKnB71rU03YE0CB9khu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('57', 'Augusto', 'rkrkrkrk1001@gmail.com', NULL, '1', NULL, NULL, '$2y$10$sz2/nlqg4tjjTv1sTYbAleKk.1VEa/SCf67J/R9TEXnpEudj3ACjq', 'cliente');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
