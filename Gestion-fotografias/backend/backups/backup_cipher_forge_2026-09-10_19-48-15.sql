-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-10 19:48:15
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
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('23', '25', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('51', '39', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('53', '41', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('56', '44', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('59', '47', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('61', '49', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('63', '51', '1', '1');

-- --------------------------------------------------------
-- Estructura de tabla `clientes`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `clientes`;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL,
  `politicas_aceptadas` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_cliente`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `clientes`
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('2', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('4', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('8', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('10', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('12', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('15', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('19', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('21', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('23', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('26', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('28', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('38', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('40', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('43', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('46', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('49', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('51', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('53', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('56', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('59', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('61', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('63', '0');
INSERT INTO `clientes` (`id_cliente`, `politicas_aceptadas`) VALUES ('64', '1');

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
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '24');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '24');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '38');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '38');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '40');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '40');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '43');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '43');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '46');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '46');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '48');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '48');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '50');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '50');

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
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('24', '22', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-04 20:02:26');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('25', '22', 'privada', 'Album Privado Test', 'Privada', '2026-09-04 20:02:26');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('26', '29', 'publica', 'Coleccion Tiny', 'test pequenas', '2026-09-07 23:33:27');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('27', '30', 'publica', 'Coleccion Tiny', 'test pequenas', '2026-09-07 23:33:59');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('28', '31', 'publica', 'Fatal Col', NULL, '2026-09-07 23:35:41');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('29', '32', 'publica', 'Fatal Col', NULL, '2026-09-07 23:36:16');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('30', '33', 'publica', 'Fatal Col', NULL, '2026-09-07 23:37:22');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('31', '34', 'publica', 'Bomb Col', NULL, '2026-09-07 23:38:38');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('32', '35', 'publica', 'Bomb Col 2', NULL, '2026-09-07 23:40:03');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('33', '36', 'publica', 'Coleccion Tiny', 'test pequenas', '2026-09-07 23:40:08');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('34', '44', 'privada', 'D', NULL, '2026-09-10 16:14:41');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('35', '47', 'privada', 'A', NULL, '2026-09-10 16:17:01');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('36', '47', 'publica', 'B', NULL, '2026-09-10 16:17:01');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('37', '48', 'privada', 'Evento Verif', NULL, '2026-09-10 16:17:48');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('38', '50', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 18:18:08');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('39', '50', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 18:18:08');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('40', '52', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 18:19:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('41', '52', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 18:19:51');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('42', '54', 'publica', 'Q Col', NULL, '2026-09-10 18:20:41');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('43', '55', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 18:21:24');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('44', '55', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 18:21:24');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('45', '57', 'publica', 'Q2', NULL, '2026-09-10 18:21:57');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('46', '58', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 18:25:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('47', '58', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 18:25:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('48', '60', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 19:31:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('49', '60', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 19:31:50');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('50', '62', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 19:48:06');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('51', '62', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 19:48:07');

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
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('1', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('3', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('5', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('6', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('7', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('9', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('11', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('13', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('14', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('16', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('17', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('18', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('20', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('22', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('24', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('25', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('27', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('29', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('30', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('31', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('32', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('33', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('34', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('35', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('36', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('37', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('39', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('41', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('42', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('44', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('45', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('47', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('48', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('50', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('52', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('54', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('55', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('57', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('58', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('60', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('62', '1');

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
  `consentimiento_ts` datetime DEFAULT NULL,
  PRIMARY KEY (`id_multimedia`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '1', 'uploads/originals/f047a5087d491e10cc2cac98e8f4c27f.png', '8', 'uploads/previews/2e29d188cfc2c03e3c94405f45de8776.jpg', '3359', '0', '1', 'imagen', '2026-09-04 19:36:58', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '2', 'uploads/originals/dcc25aa711e5c082d60d0b04b5f54db0.png', '19', 'uploads/previews/9b840e01e082746dd7682a6e34a6bee8.jpg', '1462', '0', '1', 'imagen', '2026-09-04 19:55:21', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '4', 'uploads/originals/73db00da2a1a2823b2e9f0c3a8ca0af0.png', '25', 'uploads/previews/c519219ca521213120d83b7b652d93d7.jpg', '1462', '0', '1', 'imagen', '2026-09-04 20:02:31', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado', 'Aporte colaborativo de invitado', '5', 'uploads/originals/00d81b1d964a2baa03960133efb19114.png', '24', 'uploads/previews/4e32f4dab99fba0fa94d9d70c7762eec.jpg', '1462', '1', '1', 'imagen', '2026-09-04 20:02:33', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '7', 'uploads/originals/54d88dd10b77268b8b69b125d83ef005.png', '27', 'uploads/previews/32e300b22c4bd2df3d2ce51d12590867.jpg', '70', '0', '1', 'imagen', '2026-09-07 23:34:00', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '8', 'uploads/originals/960522c68027de818f78699fe2e9a26e.png', '33', 'uploads/previews/a837a4e5fe514b53228aec557258feff.jpg', '70', '0', '1', 'imagen', '2026-09-07 23:40:08', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '9', 'uploads/originals/2221bedd06b5693f266bafa3a9d2a0f8.jpg', '37', 'uploads/previews/e7da91b05bf5069c3f177c06aea62b14.jpg', '5429', '0', '1', 'imagen', '2026-09-10 16:17:48', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES (NULL, NULL, '10', 'uploads/originals/78184dde31afde0ace2d6aa537ba9a1b.mp4', '37', 'uploads/previews/6fb2d86e19a5269a6a35dd423c1effb8.mp4', '16211', '0', '1', 'video', '2026-09-10 16:17:48', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Test', 'Aporte colaborativo de invitado', '11', 'uploads/originals/ae138c684b3d4a66c2dc9973178b74eb.jpg', '37', 'uploads/previews/0ae5be61be00349957240a002945d29b.jpg', '5429', '1', '0', 'imagen', '2026-09-10 16:17:48', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '13', 'uploads/originals/4b759e67c0f85e8e6ae749a987271d1a.jpg', '39', 'uploads/previews/287104c560b0bf9e86bf2775896ca6da.jpg', '415', '0', '1', 'imagen', '2026-09-10 18:18:12', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '14', 'uploads/originals/2b09710042aade38a3d18aa460afbab0.jpg', '38', 'uploads/previews/3b8edc5a4a882ebd16e805918f4e9c5b.jpg', '415', '1', '1', 'imagen', '2026-09-10 18:18:15', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '18', 'uploads/originals/bbe2994acda81bb900b69905ed5b17f4.jpg', '41', 'uploads/previews/9aeb884d0ec05c68b3ee15f06ac19c27.jpg', '415', '0', '1', 'imagen', '2026-09-10 18:19:58', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '19', 'uploads/originals/fd396a4dabffd2f1ebd65efee48a3704.jpg', '40', 'uploads/previews/1c8bb031e8e3c1c622913cf597855b19.jpg', '415', '1', '1', 'imagen', '2026-09-10 18:20:00', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '24', 'uploads/originals/d405449dbfd43ae0208f4e211567920f.jpg', '44', 'uploads/previews/ac72412a4f10ed2d45de9d0fafdc9376.jpg', '415', '0', '1', 'imagen', '2026-09-10 18:21:28', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '25', 'uploads/originals/989bc1e96f20adf1f9157dab6561049e.jpg', '43', 'uploads/previews/8cbefc8a59ed6c0e9af0e8a016feb6cb.jpg', '415', '1', '1', 'imagen', '2026-09-10 18:21:30', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '30', 'uploads/originals/6acd351920fdc23a411ace59b721dbc7.jpg', '47', 'uploads/previews/d07de413310ec51cea6d7d28af5a35c7.jpg', '415', '0', '1', 'imagen', '2026-09-10 18:25:54', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '31', 'uploads/originals/da0d8f3c71027844e0bd1f94824bacae.jpg', '46', 'uploads/previews/22e48817425837d1e3cf897375b2060b.jpg', '415', '1', '1', 'imagen', '2026-09-10 18:25:56', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '35', 'uploads/originals/c44708ca18a1c9914d8834ac75b19009.jpg', '49', 'uploads/previews/81129ae51e3e750143e45e29a9b315ca.jpg', '415', '0', '1', 'imagen', '2026-09-10 19:31:54', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '36', 'uploads/originals/b1158d1cc0ea8080e8c90f86c1d96d80.jpg', '48', 'uploads/previews/2ad78f51e77a85c08358f19bf12a4cd8.jpg', '415', '1', '1', 'imagen', '2026-09-10 19:31:56', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Titulo Actualizado', 'Nueva descripcion', '39', 'uploads/originals/72ba1161d7c49265ba9b84c145f7acbf.jpg', '50', 'uploads/previews/7f69941e203b0491d54cbf71b850787e.jpg', '415', '0', '1', 'imagen', '2026-09-10 19:48:09', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Foto privada', NULL, '40', 'uploads/originals/dff10f90179d6e15ad3a042405da7390.jpg', '51', 'uploads/previews/64aa017d5e7c6eda4dd2506780b9fb39.jpg', '415', '0', '1', 'imagen', '2026-09-10 19:48:10', NULL);
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`, `consentimiento_ts`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '41', 'uploads/originals/83419fad365d60f0b2dbcdfdca368359.jpg', '50', 'uploads/previews/b85da37b2b7020c91f8d29452e92e97a.jpg', '415', '1', '1', 'imagen', '2026-09-10 19:48:12', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('18', '252c039bfea895ade582bafd0fe503fa0bbc6489', '25', '2026-09-04 20:02:29', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('19', '32e7922005afc503d9b4219328bef30157579fdb', '24', '2026-09-04 20:02:32', 'colaborativo', '2026-09-05 20:02:32');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('20', '7403de54f6f0c5ac3279998724e939a9178938aa', '37', '2026-09-10 16:17:48', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('21', '2f16996589a5d96a7290e824e1a259d677702c32', '37', '2026-09-10 16:17:48', 'colaborativo', '2026-09-11 16:17:48');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('22', '6bcd1f578373b4fd6c7910a64c365d292129c59b', '39', '2026-09-10 18:18:10', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('23', '8accb6b511228c40c757bec172e11f0a2e8e47c2', '38', '2026-09-10 18:18:14', 'colaborativo', '2026-09-11 18:18:14');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('24', '9ad9c76b7d75e7714c258967a47c2dbf366a7ca8', '41', '2026-09-10 18:19:53', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('25', '505a4c3274b5ba1076feb24f0861a1a9a9d94ba5', '40', '2026-09-10 18:19:59', 'colaborativo', '2026-09-11 18:19:59');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('26', '45578247012bffb8968516a647ff4243c2149663', '42', '2026-09-10 18:20:41', 'colaborativo', '2026-09-11 18:20:41');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('27', 'c11c0a0027c55604f98268269ce756c8cf4d01f3', '44', '2026-09-10 18:21:25', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('28', '57679bed9746e9c41e1a538f140b0e449cce9a17', '43', '2026-09-10 18:21:29', 'colaborativo', '2026-09-11 18:21:29');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('29', 'e42b7006d49a85c56654b21cb0c216857f39a29f', '45', '2026-09-10 18:21:58', 'colaborativo', '2026-09-11 18:21:58');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('30', '002087108f2117d14ed98c8ebc3dbb93028d3921', '47', '2026-09-10 18:25:51', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('31', '28e94480fc7f8cdf2546ae4c4bed8dfc2e3be268', '46', '2026-09-10 18:25:55', 'colaborativo', '2026-09-11 18:25:55');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('32', '501fd3c3136f71baef3d2e5bdc17f88d05afac06', '49', '2026-09-10 19:31:52', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('33', '1a6340107bb6d0daba10edb8647099a8d1ee319b', '48', '2026-09-10 19:31:55', 'colaborativo', '2026-09-11 19:31:55');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('34', 'fc1469e1aa9363123e11128b30df466c9604f6d9', '51', '2026-09-10 19:48:08', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('35', '1def80cd62da2a3344f4803919bc3b19da3d22c7', '50', '2026-09-10 19:48:11', 'colaborativo', '2026-09-11 19:48:11');

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
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('22', 'Fotografo Test Actualizado', 'foto170222@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$DWi3y8l7nLJBLRBoyjYgz.LkoCux7RoqwH2PfpJVAzjTU/TYYmH6S', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('23', 'Cliente Test', 'cliente170222@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$VAUhswB7H1KdCjB.M15KKu0KTpvxxho.VXNMfxCgWsI/CvLcjMCqq', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('24', 'Foto Test', 'foto_153053_4613@test.dev', NULL, '0', '638074', '2026-09-07 19:30:53', '$2y$10$uVNAr9Z4JPgkzGPD2sr0FeSdw70URr6wsLlRHGWXVZ6VQ9tXVmEs2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('25', 'Foto Test', 'foto_153104_7925@test.dev', NULL, '1', NULL, NULL, '$2y$10$VCySX1fDK7rCCXex0TrKseLqJCs74dORFUhvYVJqrSmQ1l1bGfa/O', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('26', 'Cliente Test', 'cliente_153104_7925@test.dev', NULL, '1', NULL, NULL, '$2y$10$spv3aUZo1w1lPx5u/ZfRQOZ3N17SI0/9BJyj10g.C2HSBD.4vs3ce', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('27', 'Foto Test', 'foto_203250_1239@test.dev', NULL, '1', NULL, NULL, '$2y$10$ZfYos1FtV4VTg.8clPZApe8Ke7aqz.jb2ay9KtEp7FUj3mogBqOxW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('28', 'Cliente Test', 'cliente_203250_1239@test.dev', NULL, '1', NULL, NULL, '$2y$10$FtqLi7IC6KtUoq3n54inUOCgkOd4Y.AxrAmniB2OKMWZThfMwd0iG', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('29', 'Tiny Test', 'tiny_203327_4486@test.dev', NULL, '1', NULL, NULL, '$2y$10$1rE5YPW.JYfm0RP5LUERZOE2fuTClUmGSvw56dMOG.VNc6YAHmmyi', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('30', 'Tiny Test', 'tiny_203359_6534@test.dev', NULL, '1', NULL, NULL, '$2y$10$pgZrvRYwHZVaN32bKrFPQem60PFoBg4d7vCHWpfdENLkSS9xiXU4K', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('31', 'Fatal Test', 'fatal_203540_3140@test.dev', NULL, '1', NULL, NULL, '$2y$10$Va1kYo8b7w3zEIP1uO.bBOHj8qY1ud4ymV29/PXFvyKSla0.u8iWK', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('32', 'Fatal Test', 'fatal_203615_2650@test.dev', NULL, '1', NULL, NULL, '$2y$10$Pb7/3ZewTbXSm4LkYtRKa.pf4Hp1jrZtxH5DzcaHZ/YVWRh.cSDHW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('33', 'Fatal Test', 'fatal_203722_3102@test.dev', NULL, '1', NULL, NULL, '$2y$10$kmkxJZ9XDw7TehYCmd3KP.dy5.QalR7FhcGC3bWCYgPQq1zl0lV4K', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('34', 'Bomb Test', 'bomb_203838_5156@test.dev', NULL, '1', NULL, NULL, '$2y$10$xOG402qmDj/g15uXSTcr5uTq61RossdjazEAnl5g5BtWcozq2gywW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('35', 'Bomb Test 2', 'bomb2_204002_6503@test.dev', NULL, '1', NULL, NULL, '$2y$10$PGL2fhlp/C3gPZI.nbOfhu8YQI2DSdYfC9jwoVbTEM8A8ej.Wd73m', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('36', 'Tiny Test', 'tiny_204008_7958@test.dev', NULL, '1', NULL, NULL, '$2y$10$rpBKutSTRKm3NCnzrkFiz.GAvAN9EnkdNdsEXBH0CKJ3i19OT7be.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('37', 'Foto Test', 'foto_204008_3072@test.dev', NULL, '1', NULL, NULL, '$2y$10$DQborKxL9t/DI1jzPVwT3OYiM.ofkgJOlzInQiIXV062nTz1Lpd5G', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('38', 'Cliente Test', 'cliente_204008_3072@test.dev', NULL, '1', NULL, NULL, '$2y$10$MoSLM0bNwy3A7ocE2h1fqOF8wpTuXEaDQPePyWmy1AMzRuCyPhf5.', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('39', 'Foto Test', 'foto_131232_7973@test.dev', NULL, '1', NULL, NULL, '$2y$10$c8VevjlBGP26WsEhY0JsPeqEzLP92MAE9uzyg0fv7dvEYRufOsJ3e', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('40', 'Cliente Test', 'cliente_131232_7973@test.dev', NULL, '1', NULL, NULL, '$2y$10$Givaw5ID7Cmo0/TSL/qQ3Ox9ZphU7OjPx.nIq2YHyIcHlZE7QxJLi', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('41', 'Foto Verif', 'v_131334_5769@test.dev', NULL, '0', '493787', '2026-09-10 17:13:35', '$2y$10$2stjyGiNNufx8h/dP.Fqg.9agrY/5wBNjymbA40zEzLUcNMf1mWdu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('42', 'Foto Verif', 'v_131412_7610@test.dev', NULL, '1', NULL, NULL, '$2y$10$i6GAngwvOfScTZVFtChBRubZRizfhp95/pcfpyq.9/4gS35.wWFxS', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('43', 'Cliente Verif', 'c_v_131412_7610@test.dev', NULL, '1', NULL, NULL, '$2y$10$ALbS4gBiQjHVIgVZHY9tweO/rdnpKl4ofMPlnzVaxXRDuYigN972W', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('44', 'Debug Foto', 'd_131440_2073@test.dev', NULL, '1', NULL, NULL, '$2y$10$YcsWA0O9yepIqmKAMjei7eIdiGC.e2g.Hke10BExxLwpdN/yvKNiy', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('45', 'Foto Verif', 'v_131544_4414@test.dev', NULL, '1', NULL, NULL, '$2y$10$.SY38bhfyor.rblieq5eeuZaZS5KRxCjcjeW24MWK0gN4zocJT2p.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('46', 'Cliente Verif', 'c_v_131544_4414@test.dev', NULL, '1', NULL, NULL, '$2y$10$Fe.x0alFyMgZHwMWeJ22Uu59jbEHWgjKPZlaHADzu/IZWxNEv6TxS', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('47', 'E Foto', 'e_131700_7924@test.dev', NULL, '1', NULL, NULL, '$2y$10$dD0MRlT2zhbRWLhKJ3.pXurEuuAO5mVb.UfDyDMETnOhPIyNJbb46', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('48', 'Foto Verif', 'v_131746_9478@test.dev', NULL, '1', NULL, NULL, '$2y$10$1M2nVoR39xTPHvotQZXIduR98q25A.nVXt9tcSXR6QOF.HucISfyy', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('49', 'Cliente Verif', 'c_v_131746_9478@test.dev', NULL, '1', NULL, NULL, '$2y$10$oudp4qvWiKHBVh4rSDXfQ.toYrPySbKpdtNlqwIuQMafMgsMpbgHG', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('50', 'Fotografo Test Actualizado', 'foto151804@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$0L5Hccu7X56KpV0od3IJNezciPPgdDQY3NL55qjts1HdENaJrRqma', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('51', 'Cliente Test', 'cliente151804@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$qQsXboftgiqXWDmQDH5yrupfI0uJB1mvb/i.D4.NGz0dtvau3gr2u', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('52', 'Fotografo Test Actualizado', 'foto151947@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$121r8rO6rSHpuF7o6OWae.CkX8q1aRCEKyOsQwpbPP7QxJfQYBKMG', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('53', 'Cliente Test', 'cliente151947@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$XwIqq0rqeoQYzVcsVuvFoeQTVKhLUtMHrl.dUElGbj9Fjryudt2Yi', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('54', 'Q Foto', 'q_152038_8094@test.dev', NULL, '1', NULL, NULL, '$2y$10$p5TiyGI1AP6Lxgq4JogWu.2OeHcCr/7BV2Pj1tWof7eFQPx.Csywy', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('55', 'Fotografo Test Actualizado', 'foto152120@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$x4ueAnOlrVCsXZMXXM7Fdept97fDE0WEZvtoYTWmno32aKenlvbH.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('56', 'Cliente Test', 'cliente152120@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$16hRqn.GLsEr7V8ouuE8EeKbV0T.R21zbtENYKL365JZqurAwazoe', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('57', 'Q2 Foto', 'qq_152155_5203@test.dev', NULL, '1', NULL, NULL, '$2y$10$GEQ.RRyLvfVqJXFxWbQ8QOGUstfHLHnES/01Ydh.WpPB5wXZSEHE.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('58', 'Fotografo Test Actualizado', 'foto152543@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$OC7Kb47OwNbg9ZXgMhUyi.9PSgOYeyRsdpFXioGXaOUHhyf1XxJW6', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('59', 'Cliente Test', 'cliente152543@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$oqTYPBspwbKZRYxfSjQ2T.h0QwcWUNFOL15kRKsJ6IYsucVnBVs1y', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('60', 'Fotografo Test Actualizado', 'foto163145@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$1I6XhMJgdli/nIsPjIMoBuMlnWrPbeZ7BOB.vanrOv85VmBL/KEze', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('61', 'Cliente Test', 'cliente163145@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$QixTGsqAc4NyBbLamgwfBuKSs9bpcvQN5dw8sJa8fmgRyXzy5XMEC', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('62', 'Fotografo Test Actualizado', 'foto164802@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$oMjhHs8r5HB.7/ixdWh7du1T3f9Ijklqj5E1OjCmp9WdhPiYj5Tlu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('63', 'Cliente Test', 'cliente164802@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$gnZk1AdMnnZf.Ngpkcy5rOVninDf//yS32FTxZenn33CnRlwURRQu', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('64', 'Cliente Consent', 'cliconsent164804511@test.com', NULL, '1', NULL, NULL, '$2y$10$6FmJvK9Wb3oChTFRIgimheNXEqPoafNJGsoPAhwIDJ9hEB5IPS82O', 'cliente');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
