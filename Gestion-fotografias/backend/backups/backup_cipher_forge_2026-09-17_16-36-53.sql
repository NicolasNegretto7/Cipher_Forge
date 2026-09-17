-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-17 16:36:53
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Estructura de tabla `acceso_colecciones`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `acceso_colecciones`;
CREATE TABLE `acceso_colecciones` (
  `usuario_id` int NOT NULL,
  `coleccion_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`coleccion_id`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `acceso_colecciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `acceso_colecciones_ibfk_2` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `acceso_colecciones`
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`) VALUES ('6', '5');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`) VALUES ('6', '6');

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
INSERT INTO `clientes` (`id_cliente`) VALUES ('6');

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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `colecciones`
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('1', '1', 'privada', 'df', 'ddddddd', '2026-09-14 23:35:52');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('3', '2', 'privada', 'we', NULL, '2026-09-15 17:42:26');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('4', '2', 'privada', 'asd', NULL, '2026-09-15 18:09:28');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('5', '3', 'privada', 'ds', NULL, '2026-09-15 18:24:54');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('6', '4', 'privada', 'erer', NULL, '2026-09-16 15:47:33');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('7', '4', 'privada', 'nig', NULL, '2026-09-16 17:58:47');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('8', '8', 'privada', 'as', NULL, '2026-09-16 18:16:55');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('9', '8', 'privada', 'goty', NULL, '2026-09-16 18:36:33');

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
  CONSTRAINT `favoritos_ibfk_2` FOREIGN KEY (`favorito_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
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
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('1', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('2', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('3', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('4', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('5', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('7', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('8', '1');

-- --------------------------------------------------------
-- Estructura de tabla `hashtags`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `hashtags`;
CREATE TABLE `hashtags` (
  `nombre_hashtags` varchar(40) NOT NULL,
  `id_hashtags` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_hashtags`),
  UNIQUE KEY `nombre_hashtags` (`nombre_hashtags`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `hashtags`
INSERT INTO `hashtags` (`nombre_hashtags`, `id_hashtags`) VALUES ('as', '1');

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
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-139-buena (1).mp4', NULL, '1', 'uploads/originals/aaa8a2b798673564110bcc24c7d70623.mp4', '1', 'uploads/previews/5b6517659fea3f40d8f6610e83ab24f6.mp4', 'uploads/standard/427f73134f6f45c6bdbead66eb640829.jpg', '685877', '0', '1', 'video', '2026-09-14 23:36:03');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta (1).jpg', NULL, '2', 'uploads/originals/597bd455cc5257eaa1f429cf11168f36.jpg', '1', 'uploads/previews/04ef223c5c536c3045d54cb5275e0dc1.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-14 23:36:03');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena (1).jpg', NULL, '3', 'uploads/originals/dcc8aeb67db138b918fe61ce269501d0.jpg', '1', 'uploads/previews/ed339dbed8899a08645a42c5661f8b2a.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-14 23:36:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta.jpg', NULL, '4', 'uploads/originals/d6a30dfb40a195ea9aeb44b53fc73a36.jpg', '1', 'uploads/previews/85ff76bda8ebe23dba3e17f568a8fe03.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-14 23:36:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena.jpg', NULL, '5', 'uploads/originals/474022664f41a928d340411e8076492f.jpg', '1', 'uploads/previews/565da0c45a78d661b311df0f2ad9c917.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-14 23:36:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('clip_1.787.767.729.202.mp4', NULL, '19', 'uploads/originals/e0ae9965f7ed52cc0158ff3d9c7f8994.mp4', '3', 'uploads/previews/9dffc761f4fdf5aecc0af3c4c67f65af.mp4', 'uploads/standard/bfb6de64625d6ba0a747b80a58ff4568.jpg', '24184154', '0', '1', 'video', '2026-09-15 18:08:01');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-139-buena (1).mp4', NULL, '20', 'uploads/originals/f6f95d88338ca58073e1b9e312ce8f17.mp4', '5', 'uploads/previews/7ded2e3e85b2a2ae293c0f7602b6dfd9.mp4', 'uploads/standard/4dcaa4d567697e2a02dd8430dc366226.jpg', '685877', '0', '1', 'video', '2026-09-15 18:25:05');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta (1).jpg', NULL, '21', 'uploads/originals/c1141d98ba7d9b2635b4802d4f49bb29.jpg', '5', 'uploads/previews/b6f6e1cde0aa87979a6600f2f751e2b9.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-15 18:25:05');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-139-buena (1).mp4', NULL, '22', 'uploads/originals/312ce95e4ae338475ab020026ec2ebdf.mp4', '6', 'uploads/previews/a37a0668fe373a5234d975f23084a7f8.mp4', 'uploads/standard/a3e003272cdeb1b87b1b3e5e1e0d398e.jpg', '685877', '0', '1', 'video', '2026-09-16 15:47:45');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta (1).jpg', NULL, '23', 'uploads/originals/eb53f852b9535b64e3f782e57829a46a.jpg', '6', 'uploads/previews/ea6b05d69a078e332e641b72eb964e1b.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-16 15:47:45');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena (1).jpg', NULL, '24', 'uploads/originals/ce163d508f4b03d2f27f74922d138b0e.jpg', '6', 'uploads/previews/1320773b50e59be061161c253d2ed438.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-16 15:47:45');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta.jpg', NULL, '25', 'uploads/originals/8e0fe9012b9004b633f2ff599013089e.jpg', '6', 'uploads/previews/91e1c8f441818d5941ccfbfe22c55ea1.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-16 15:47:45');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena.jpg', NULL, '26', 'uploads/originals/b6957042d18d86c6f6d88654c5db3db3.jpg', '6', 'uploads/previews/6153f81edd618890d731d0fe7e4a0c72.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-16 15:47:46');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-139-alta.mp4', NULL, '27', 'uploads/originals/d7128c1ca1439264e8084c5330dd0625.mp4', '6', 'uploads/previews/88084947fb9b9d9e38a85e514b714d53.mp4', 'uploads/standard/8d6868b11744edc46d88b873c018b2d5.jpg', '24184154', '0', '1', 'video', '2026-09-16 15:47:49');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta (1).jpg', NULL, '29', 'uploads/originals/e0c0401cac42c9e406f62b0ab1d6e148.jpg', '7', 'uploads/previews/8e85f02649819fec2734ba75cd69324c.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-16 17:59:02');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena (1).jpg', NULL, '30', 'uploads/originals/c481ecf2b50a0ea249100516c9ba2db7.jpg', '7', 'uploads/previews/f33e69a6da5a0c3d8190ca982be08866.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-16 17:59:02');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('hhhhhh', 'Aporte colaborativo de invitado', '31', 'uploads/originals/19268f817f28f2b307720ad74f38c09d.jpg', '7', 'uploads/previews/72183eb037ce52eb41e50cf059167197.jpg', NULL, '325679', '1', '1', 'imagen', '2026-09-16 18:03:26');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-139-buena (1).mp4', NULL, '33', 'uploads/originals/69ca086367760c78d7c42455767fee54.mp4', '8', 'uploads/previews/7aa033b6b673b0d8f369e48eba685548.mp4', 'uploads/standard/1e3065159b74c6b0a27b6f251970f91d.jpg', '685877', '0', '1', 'video', '2026-09-16 18:17:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta (1).jpg', NULL, '34', 'uploads/originals/f0727052986adef48a0353e84628cdb4.jpg', '8', 'uploads/previews/72c794f2f2fe9db30157175c6f97e194.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-16 18:17:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena (1).jpg', NULL, '35', 'uploads/originals/63e8989956d63fe87467daa286b892c3.jpg', '8', 'uploads/previews/01f7ee0bec2a2c30c7f6bebb4ef05519.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-16 18:17:04');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-alta.jpg', NULL, '36', 'uploads/originals/fffd9087a83a6654733de6515169804c.jpg', '8', 'uploads/previews/7787f892626d3a661e9e547a000d3a11.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-16 18:17:05');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('cipherforge-138-buena.jpg', NULL, '37', 'uploads/originals/d1fb019cb074b70b11a2a1f850fe25f9.jpg', '8', 'uploads/previews/fceaf72fb8e824646f3fa2e90fe082e6.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-16 18:17:05');

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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `qr_tokens`
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('1', '57df3f466fb2036067e6db084d68badebfa2aff3', '1', '2026-09-14 23:36:54', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('2', 'b9299274eab972897401567ca7afd21bacffe8a1', '1', '2026-09-14 23:37:03', 'colaborativo', '2026-09-15 23:37:03');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('12', 'dfeae2b87e73c9198806c14ac77b187a1e60ee83', '3', '2026-09-15 17:42:56', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('13', '00a503b6fd5c36fb0cb31d06ab2047a45dd8d413', '3', '2026-09-15 17:43:05', 'colaborativo', '2026-09-16 17:43:05');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('14', 'ab338d38d258122c5939c5092e83240370b399f5', '3', '2026-09-15 18:06:03', 'colaborativo', '2026-09-16 18:06:03');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('15', '3e048e123df980adc2caa73190e96f6ba98d07f8', '3', '2026-09-15 18:07:09', 'colaborativo', '2026-09-16 18:07:09');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('16', '8f178d4bed65f013a762bc48b50183270455ed32', '4', '2026-09-15 18:09:37', 'colaborativo', '2026-09-16 18:09:37');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('17', 'a671f272ec685c2f8a7ed27e42190270374bacaa', '5', '2026-09-15 18:25:08', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('18', '849ce24e5d557c4b30458607d2b2fd617b00838e', '4', '2026-09-15 21:35:32', 'colaborativo', '2026-09-16 21:35:32');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('19', 'e52ce690fd59eea39489cb6389d613be3c4730fe', '6', '2026-09-16 15:48:51', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('20', '8fc8ae1375db6a84adfdb48513e1bee82248243e', '7', '2026-09-16 17:59:10', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('21', 'e7703becc49056f1a50ae09ded3b0128af558c38', '7', '2026-09-16 17:59:54', 'colaborativo', '2026-09-17 17:59:54');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('22', '26d5bcbcf4d86d5ea68cc4b81e7f6ae2f1f7a525', '6', '2026-09-16 18:01:48', 'colaborativo', '2026-09-17 18:01:48');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('23', 'e4749c0ad47be3ed9983e6ad006329f19d88165a', '6', '2026-09-16 18:02:11', 'colaborativo', '2026-09-17 18:02:11');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('24', 'c1fc25e4bed18feb2cc31f92251618195c14e6f1', '6', '2026-09-16 18:02:22', 'colaborativo', '2026-09-17 18:02:22');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('25', 'ca2ebbfbe0355235313ee70dc62de0e8b2d8cbae', '7', '2026-09-16 18:02:38', 'colaborativo', '2026-09-17 18:02:38');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('26', '93b1b6634542d6a65dd791d8193f0640d4b5ea96', '8', '2026-09-16 18:17:08', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('27', 'ae071f505ede57e94bb12264f37ad1d93084d268', '8', '2026-09-16 18:19:30', 'colaborativo', '2026-09-17 18:19:30');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('28', 'f6407d953feacd06f6b498c7ab1a253568b9efbb', '8', '2026-09-16 18:31:42', 'colaborativo', '2026-09-17 18:31:42');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('29', '2c7553180582d724543edd36b49851f6b9074ae6', '8', '2026-09-16 18:33:50', 'colaborativo', '2026-09-17 18:33:50');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('30', '1d0d9a5b4ca45820cf6470c50b8a420e186154c3', '9', '2026-09-16 18:36:36', 'colaborativo', '2026-09-17 18:36:36');

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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `usuarios`
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('1', 'xd', 'migmail@gmail.com', NULL, '1', NULL, NULL, '$2y$10$yx8yMaDY0s4P2I5VNmO3uOWFsmoS9nUX4bzJVYaNa9N8FbUDcraYW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('2', 's', 'sfds@gmali.com', NULL, '1', NULL, NULL, '$2y$10$3LqGZu3szAMmbHrFtOjxgO5FZfkDkXOrirhgEFx0B3C0t3l9cdwUK', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('3', 'dfss', 'test00@gmail.com', NULL, '1', NULL, NULL, '$2y$10$22QFp5hGsovFSDYmdHe0kOHcQXjQEWEKW1PhaIhHVZI9wQzsTyfNW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('4', 'sd', 'ss@gmail.com', NULL, '1', NULL, NULL, '$2y$10$XHM0.aprvvtN4W.OcA4Sues8vy2a5AmafE6OcAer1l.EHrV13762u', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('5', 'ss', 'dd@gmail.com', NULL, '0', '181624', '2026-09-15 19:20:18', '$2y$10$VaX6vwGfeHUyP22tT1rXneOQlKiRefJmSGz/Y6cBYpLjCAG1Ln5kC', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('6', 'sd', 'ff@gmail.com', NULL, '1', NULL, NULL, '$2y$10$5IhcOcvm.a9jw0tHJETouOruBuBpOWmujMoa3yPJOhl6yZlCHkGpq', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('7', 's', '2232@gmail.com', NULL, '1', NULL, NULL, '$2y$10$McmldN5IYBe4312.eLMoLubeqbUg/en6bAyN7SX.QuxmnYd2pZUm2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('8', 'Ivan sandoval', 'test878@gmail.com', NULL, '1', NULL, NULL, '$2y$10$VMKUkyR40ZJ.FUOLm9x26OyWXzgflcPWJVhrskgrdbxzfY2V9rMt2', 'fotografo');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
