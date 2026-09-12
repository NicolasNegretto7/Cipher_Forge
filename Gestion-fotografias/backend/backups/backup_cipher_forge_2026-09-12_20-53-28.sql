-- ========================================================
-- Respaldo Automático de Base de Datos - Cipher Forge
-- Generado el: 2026-09-12 20:53:28
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
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('66', '53', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('72', '56', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('75', '58', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('79', '60', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('107', '94', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('109', '95', '1', '1');
INSERT INTO `acceso_colecciones` (`usuario_id`, `coleccion_id`, `permitir_alta_calidad`, `permitir_buena_calidad`) VALUES ('111', '96', '1', '1');

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
INSERT INTO `clientes` (`id_cliente`) VALUES ('23');
INSERT INTO `clientes` (`id_cliente`) VALUES ('26');
INSERT INTO `clientes` (`id_cliente`) VALUES ('28');
INSERT INTO `clientes` (`id_cliente`) VALUES ('38');
INSERT INTO `clientes` (`id_cliente`) VALUES ('40');
INSERT INTO `clientes` (`id_cliente`) VALUES ('43');
INSERT INTO `clientes` (`id_cliente`) VALUES ('46');
INSERT INTO `clientes` (`id_cliente`) VALUES ('49');
INSERT INTO `clientes` (`id_cliente`) VALUES ('51');
INSERT INTO `clientes` (`id_cliente`) VALUES ('53');
INSERT INTO `clientes` (`id_cliente`) VALUES ('56');
INSERT INTO `clientes` (`id_cliente`) VALUES ('59');
INSERT INTO `clientes` (`id_cliente`) VALUES ('61');
INSERT INTO `clientes` (`id_cliente`) VALUES ('63');
INSERT INTO `clientes` (`id_cliente`) VALUES ('64');
INSERT INTO `clientes` (`id_cliente`) VALUES ('66');
INSERT INTO `clientes` (`id_cliente`) VALUES ('67');
INSERT INTO `clientes` (`id_cliente`) VALUES ('72');
INSERT INTO `clientes` (`id_cliente`) VALUES ('73');
INSERT INTO `clientes` (`id_cliente`) VALUES ('75');
INSERT INTO `clientes` (`id_cliente`) VALUES ('76');
INSERT INTO `clientes` (`id_cliente`) VALUES ('79');
INSERT INTO `clientes` (`id_cliente`) VALUES ('107');
INSERT INTO `clientes` (`id_cliente`) VALUES ('109');
INSERT INTO `clientes` (`id_cliente`) VALUES ('111');
INSERT INTO `clientes` (`id_cliente`) VALUES ('121');
INSERT INTO `clientes` (`id_cliente`) VALUES ('125');

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
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '52');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '52');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '55');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '55');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '57');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '57');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('1', '59');
INSERT INTO `coleccion_hashtags` (`id_hashtags`, `coleccion_id`) VALUES ('2', '59');

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
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('52', '65', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 19:48:23');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('53', '65', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 19:48:23');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('55', '71', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 19:51:37');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('56', '71', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 19:51:37');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('57', '74', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 20:03:07');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('58', '74', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 20:03:08');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('59', '78', 'publica', 'Album Publico Test', 'Foto publica', '2026-09-10 20:21:53');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('60', '78', 'privada', 'Album Privado Test', 'Privada', '2026-09-10 20:21:54');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('94', '106', 'privada', 'Coleccion E2E Privada', 'e2e', '2026-09-11 12:47:16');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('95', '108', 'privada', 'Coleccion E2E Privada', 'e2e', '2026-09-11 12:48:10');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('96', '110', 'privada', 'Coleccion E2E Privada', 'e2e', '2026-09-11 12:48:47');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('98', '112', 'publica', 'Coleccion H05 Video', 'h05', '2026-09-11 15:58:22');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('100', '114', 'publica', 'Coleccion H05B', 'h05b', '2026-09-11 17:40:38');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('101', '115', 'publica', 'Coleccion H05B', 'h05b', '2026-09-11 17:41:48');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('102', '116', 'publica', 'Coleccion H05B', 'h05b', '2026-09-11 17:52:47');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('103', '113', 'privada', 'diy', NULL, '2026-09-11 18:31:14');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('104', '113', 'privada', 'uh3u', NULL, '2026-09-11 18:45:37');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('106', '119', 'publica', 'H09 Publica A', NULL, '2026-09-11 18:57:29');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('107', '119', 'privada', 'H09 Privada B', NULL, '2026-09-11 18:57:29');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('108', '120', 'publica', 'H09 Publica A', NULL, '2026-09-11 18:58:23');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('109', '120', 'privada', 'H09 Privada B', NULL, '2026-09-11 18:58:23');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('112', '118', 'privada', 'df', NULL, '2026-09-11 19:02:08');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('113', '118', 'privada', 'goty', NULL, '2026-09-11 19:02:28');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('114', '122', 'privada', 'Solo videos', NULL, '2026-09-11 19:08:11');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('115', '122', 'publica', 'Solo imagen', NULL, '2026-09-11 19:08:13');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('116', '122', 'privada', 'Mixto video+imagen', NULL, '2026-09-11 19:08:14');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('117', '123', 'privada', 'Video-only', NULL, '2026-09-11 19:22:11');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('118', '124', 'privada', 'Video-only', NULL, '2026-09-11 19:22:27');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('119', '118', 'privada', 'LodeMati', NULL, '2026-09-11 19:26:05');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('120', '118', 'privada', 'goty', NULL, '2026-09-11 19:33:20');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('126', '82', 'privada', 'asd', NULL, '2026-09-11 21:53:57');
INSERT INTO `colecciones` (`id`, `fotografo_id`, `tipo_visibilidad`, `titulo`, `descripcion`, `creado_en`) VALUES ('127', '82', 'privada', 'fd', 'njin', '2026-09-11 21:56:34');

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
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('65', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('68', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('69', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('70', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('71', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('74', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('77', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('78', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('82', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('86', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('93', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('106', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('108', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('110', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('112', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('113', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('114', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('115', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('116', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('117', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('118', '1');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('119', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('120', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('122', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('123', '0');
INSERT INTO `fotografos` (`id_fotografo`, `politicas_aceptadas`) VALUES ('124', '0');

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
  `poster` varchar(255) DEFAULT NULL,
  `tamanio` bigint unsigned NOT NULL,
  `es_invitado` tinyint(1) NOT NULL DEFAULT '0',
  `aprobado` tinyint(1) NOT NULL DEFAULT '1',
  `tipo` enum('video','imagen') NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_multimedia`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=227 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcado de datos para `multimedia`
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '1', 'uploads/originals/f047a5087d491e10cc2cac98e8f4c27f.png', '8', 'uploads/previews/2e29d188cfc2c03e3c94405f45de8776.jpg', NULL, '3359', '0', '1', 'imagen', '2026-09-04 19:36:58');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '2', 'uploads/originals/dcc25aa711e5c082d60d0b04b5f54db0.png', '19', 'uploads/previews/9b840e01e082746dd7682a6e34a6bee8.jpg', NULL, '1462', '0', '1', 'imagen', '2026-09-04 19:55:21');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '4', 'uploads/originals/73db00da2a1a2823b2e9f0c3a8ca0af0.png', '25', 'uploads/previews/c519219ca521213120d83b7b652d93d7.jpg', NULL, '1462', '0', '1', 'imagen', '2026-09-04 20:02:31');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado', 'Aporte colaborativo de invitado', '5', 'uploads/originals/00d81b1d964a2baa03960133efb19114.png', '24', 'uploads/previews/4e32f4dab99fba0fa94d9d70c7762eec.jpg', NULL, '1462', '1', '1', 'imagen', '2026-09-04 20:02:33');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '7', 'uploads/originals/54d88dd10b77268b8b69b125d83ef005.png', '27', 'uploads/previews/32e300b22c4bd2df3d2ce51d12590867.jpg', NULL, '70', '0', '1', 'imagen', '2026-09-07 23:34:00');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '8', 'uploads/originals/960522c68027de818f78699fe2e9a26e.png', '33', 'uploads/previews/a837a4e5fe514b53228aec557258feff.jpg', NULL, '70', '0', '1', 'imagen', '2026-09-07 23:40:08');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '9', 'uploads/originals/2221bedd06b5693f266bafa3a9d2a0f8.jpg', '37', 'uploads/previews/e7da91b05bf5069c3f177c06aea62b14.jpg', NULL, '5429', '0', '1', 'imagen', '2026-09-10 16:17:48');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '10', 'uploads/originals/78184dde31afde0ace2d6aa537ba9a1b.mp4', '37', 'uploads/previews/6fb2d86e19a5269a6a35dd423c1effb8.mp4', NULL, '16211', '0', '1', 'video', '2026-09-10 16:17:48');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '13', 'uploads/originals/4b759e67c0f85e8e6ae749a987271d1a.jpg', '39', 'uploads/previews/287104c560b0bf9e86bf2775896ca6da.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 18:18:12');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '14', 'uploads/originals/2b09710042aade38a3d18aa460afbab0.jpg', '38', 'uploads/previews/3b8edc5a4a882ebd16e805918f4e9c5b.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 18:18:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '18', 'uploads/originals/bbe2994acda81bb900b69905ed5b17f4.jpg', '41', 'uploads/previews/9aeb884d0ec05c68b3ee15f06ac19c27.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 18:19:58');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '19', 'uploads/originals/fd396a4dabffd2f1ebd65efee48a3704.jpg', '40', 'uploads/previews/1c8bb031e8e3c1c622913cf597855b19.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 18:20:00');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '24', 'uploads/originals/d405449dbfd43ae0208f4e211567920f.jpg', '44', 'uploads/previews/ac72412a4f10ed2d45de9d0fafdc9376.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 18:21:28');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '25', 'uploads/originals/989bc1e96f20adf1f9157dab6561049e.jpg', '43', 'uploads/previews/8cbefc8a59ed6c0e9af0e8a016feb6cb.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 18:21:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '30', 'uploads/originals/6acd351920fdc23a411ace59b721dbc7.jpg', '47', 'uploads/previews/d07de413310ec51cea6d7d28af5a35c7.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 18:25:54');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '31', 'uploads/originals/da0d8f3c71027844e0bd1f94824bacae.jpg', '46', 'uploads/previews/22e48817425837d1e3cf897375b2060b.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 18:25:56');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '35', 'uploads/originals/c44708ca18a1c9914d8834ac75b19009.jpg', '49', 'uploads/previews/81129ae51e3e750143e45e29a9b315ca.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 19:31:54');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '36', 'uploads/originals/b1158d1cc0ea8080e8c90f86c1d96d80.jpg', '48', 'uploads/previews/2ad78f51e77a85c08358f19bf12a4cd8.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 19:31:56');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '40', 'uploads/originals/dff10f90179d6e15ad3a042405da7390.jpg', '51', 'uploads/previews/64aa017d5e7c6eda4dd2506780b9fb39.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 19:48:10');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '41', 'uploads/originals/83419fad365d60f0b2dbcdfdca368359.jpg', '50', 'uploads/previews/b85da37b2b7020c91f8d29452e92e97a.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 19:48:12');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '45', 'uploads/originals/ee4c4ec887f217d3cffa46af7b6533ec.jpg', '53', 'uploads/previews/c5074fedb58c315ceae587dbe938d184.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 19:48:27');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '46', 'uploads/originals/83c7b061b8a053ec76142f3a29e4aa10.jpg', '52', 'uploads/previews/4d120159c2584bef103ab2d7ebc03b42.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 19:48:29');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '51', 'uploads/originals/92ca4f305716046f8a6467c323479ad8.jpg', '56', 'uploads/previews/12f732ac3b1acaf08dac699b7e63db85.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 19:51:40');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '52', 'uploads/originals/c839c105a3b37303e5f4ae9951edb14c.jpg', '55', 'uploads/previews/24206ba7ca681c21bb2ecee5194883b5.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 19:51:41');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '56', 'uploads/originals/4049351baddc9558e1a2a8b9ce1ac8d3.jpg', '58', 'uploads/previews/278713d87d38d9648136ed676fe37380.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 20:03:12');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '57', 'uploads/originals/627b8b2cd9e22e42ce9a921d6d4f502a.jpg', '57', 'uploads/previews/618c71bcd493755aa96535d1bab2ebe9.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 20:03:13');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto >2MB', NULL, '60', 'uploads/originals/2508c9ac131380993c4e028c0427600d.jpg', '57', 'uploads/previews/7a12e839583b734f466897c2b2f06905.jpg', NULL, '3670016', '0', '1', 'imagen', '2026-09-10 20:03:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto privada', NULL, '62', 'uploads/originals/693ead3a8923c3c9e7a42853d51f845a.jpg', '60', 'uploads/previews/b2c1e6a6c758a0511ee295f4aa39aa05.jpg', NULL, '415', '0', '1', 'imagen', '2026-09-10 20:21:57');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado Prueba', 'Aporte colaborativo de invitado', '63', 'uploads/originals/08e568a2ae8e76de975285fe9ccc3748.jpg', '59', 'uploads/previews/be643af7e81f630d590bc2de1ee3fc6d.jpg', NULL, '415', '1', '1', 'imagen', '2026-09-10 20:21:59');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Foto >2MB', NULL, '66', 'uploads/originals/957e8bd0f7ab6dedbe9d90876c365a0e.jpg', '59', 'uploads/previews/e7c3143c3d57ff6b06033a8bc5f23e78.jpg', NULL, '3670016', '0', '1', 'imagen', '2026-09-10 20:22:02');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('TituloMultipartE2E', 'desc e2e', '130', 'uploads/originals/3fa3fd179db8acbb23727daa400bbb05.jpg', '95', 'uploads/previews/e325989b322098a0e74822b8322a0e78.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 12:48:10');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('TituloMultipartE2E', 'desc e2e', '132', 'uploads/originals/408d80202d4987a8c7c6a7f647a01f1f.jpg', '96', 'uploads/previews/acc306e78dd50d890513c0408d44ba6c.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 12:48:47');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('Invitado E2E', 'Aporte colaborativo de invitado', '133', 'uploads/originals/f044ccf70eae5361ed6113c5c8bf67fd.jpg', '96', 'uploads/previews/384141182b45f3424741a2c88e66aa27.jpg', NULL, '2530', '1', '1', 'imagen', '2026-09-11 12:48:47');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '137', 'uploads/originals/6acda33385b67086608fe9c9b94ccfe1.mp4', '98', 'uploads/previews/fa6771539f3c358f9abfa89b64cbd21e.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 15:58:23');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '140', 'uploads/originals/5f3ab20f40f17a56050ce474cd1ed423.jpg', '100', 'uploads/previews/acdad184cd1e6f088893efbc54d5f605.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 17:40:38');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '141', 'uploads/originals/02f7d62fbfa0814f0a35371bf5633364.mp4', '100', 'uploads/previews/594532114405b58903bed3b685e4d5ee.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 17:40:40');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '142', 'uploads/originals/ae14887c2f753a36e6e3e161e10eb769.jpg', '101', 'uploads/previews/c30eed86afe4882bfae4a510e361ddb6.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 17:41:49');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '143', 'uploads/originals/177808d55ce8dc83bd1df17f45f89e51.mp4', '101', 'uploads/previews/1f1b839ca501778ccdf28f7c437bd00a.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 17:41:51');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '144', 'uploads/originals/770432a3d2cb788d5fc3916c13838acc.jpg', '101', 'uploads/previews/c86805c3703f5103974cd1dc0ab8e4fd.jpg', NULL, '1317980', '0', '1', 'imagen', '2026-09-11 17:41:53');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '145', 'uploads/originals/c5422196a6a970833cebb187a9d03982.jpg', '102', 'uploads/previews/6dee50aa3803756f6202181e194794fd.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 17:52:47');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '146', 'uploads/originals/6184db15abe9adc1349ac8038d27e3ce.mp4', '102', 'uploads/previews/caccd387ea42676763a0b73409e83b26.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 17:52:49');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '147', 'uploads/originals/04c8dc27e3c70d881d886f3d69e36b8b.jpg', '102', 'uploads/previews/167a77d41e138c5a42ae9641cb864de9.jpg', NULL, '1317980', '0', '1', 'imagen', '2026-09-11 17:52:51');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('uh3u', NULL, '149', 'uploads/originals/6e4b5afc9e6bac7470be3317eff601c4.mp4', '104', 'uploads/previews/c8b951290ea9b23b938613a0d85afe84.mp4', NULL, '24184154', '0', '1', 'video', '2026-09-11 18:45:40');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('uh3u', NULL, '150', 'uploads/originals/ef6446edcfd51f6c0cea89a80eceb930.jpg', '104', 'uploads/previews/034266bdc5c4010774ca6cb5d0a94571.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 18:45:40');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('uh3u', NULL, '151', 'uploads/originals/4f09854478c9b1a1056c6591170db57a.jpg', '104', 'uploads/previews/42bcdacc7dd50c268cbb05da1a9d6d89.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-11 18:45:40');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '153', 'uploads/originals/e93e596381c7af675bc055c3f0d0478d.jpg', '106', 'uploads/previews/ed94714a3917ec5a0572b4b332254be5.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 18:57:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '154', 'uploads/originals/7d1fda0922bc899a06b6b4034998013c.jpg', '108', 'uploads/previews/cf37a3fbbbf69e4465462be49266593d.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 18:58:24');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('df', NULL, '158', 'uploads/originals/4eedc6fb500a7b881905cae1eec5e8aa.jpg', '112', 'uploads/previews/bb2b9e0b1cfe5afa3f4d956817a90701.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 19:02:08');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('goty', NULL, '159', 'uploads/originals/3eebff48b0c907e8b5519a178357a34d.jpg', '113', 'uploads/previews/b1a98b0e92abd3d5c007349562a649af.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 19:02:28');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('goty', NULL, '160', 'uploads/originals/42c112f71f7957102c0ade5ae343d99c.jpg', '113', 'uploads/previews/edcc78b81cf5d3712481432fb153f046.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 19:02:28');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '161', 'uploads/originals/e393260ee1a3e31abc34094240b047b6.mp4', '114', 'uploads/previews/fa7df62d2903ed33c713262b536dc939.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 19:08:13');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '162', 'uploads/originals/aaa3ae32ecdc0562e38151c9fa0f4711.jpg', '115', 'uploads/previews/5c2bd9549ea72b3c55ced34c6e2ea5bf.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 19:08:14');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '163', 'uploads/originals/c1ec8bdd4865bf2e12b30c5cb6f7ef53.mp4', '116', 'uploads/previews/9969de0debc2656558016ed0c33c1d65.mp4', NULL, '7443468', '0', '1', 'video', '2026-09-11 19:08:16');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '164', 'uploads/originals/dffaf68314c7c816cf0b7a0890caa135.jpg', '116', 'uploads/previews/1e4dbcb6d832fc23f35b21fea5826576.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 19:08:16');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '165', 'uploads/originals/0f285148fdac61dff91174993c0bcba7.mp4', '117', 'uploads/previews/ce559a4d27a531860c7435b077d6d9ac.mp4', 'uploads/standard/36cc869b87a3faf3f1fcad9596df3daa.jpg', '7443468', '0', '1', 'video', '2026-09-11 19:22:13');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '166', 'uploads/originals/e26ed2aaa31273781f9c92e754ea6f0b.mp4', '118', 'uploads/previews/a7d6d973265a7afd9343bd7bb68a791e.mp4', 'uploads/standard/c907a048bee565d7b52375e86ef818ea.jpg', '7443468', '0', '1', 'video', '2026-09-11 19:22:28');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES (NULL, NULL, '167', 'uploads/originals/5344822c489bf5e5cf9977354496d133.jpg', '118', 'uploads/previews/afb6333ba629c92461f1bc9877937cc4.jpg', NULL, '2530', '0', '1', 'imagen', '2026-09-11 19:22:29');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('LodeMati', NULL, '168', 'uploads/originals/49e10f2b4bc704230afe08e9dadae9c0.mp4', '119', 'uploads/previews/7686d7cafc8182a69b40cda9ba6ddc7a.mp4', 'uploads/standard/17c3e3f1f5e09bf4e0c771e91782b70d.jpg', '685877', '0', '1', 'video', '2026-09-11 19:26:07');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('goty', NULL, '169', 'uploads/originals/4be5d9ba0f432b7e9fa1cc2d4802d239.jpg', '120', 'uploads/previews/8bc490231293091da6b9c9d0a7fafb00.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 19:33:21');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('LodeMati', NULL, '170', 'uploads/originals/f6dc0f2d5b7cf9176ef28cd578bb5fe4.mp4', '119', 'uploads/previews/192f98bfa7719bdff11e4640e3d93736.mp4', 'uploads/standard/d1dbc7fc432820ba0d3a7c3dd25d4e53.jpg', '685877', '0', '1', 'video', '2026-09-11 19:35:09');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('LodeMati', NULL, '171', 'uploads/originals/dad5a07300e0c9017e04bcdf021e0bee.mp4', '119', 'uploads/previews/ce6716fb200726e5ab8a1a662af780f9.mp4', 'uploads/standard/2500c644cd5ecfb2d1ab6df14df9e281.jpg', '685877', '0', '1', 'video', '2026-09-11 19:35:21');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '180', 'uploads/originals/5394d277e5c87b21f8be91a6f80fa218.jpg', '126', 'uploads/previews/a24fec801337e12ea67984d844870af0.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-11 21:53:57');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '181', 'uploads/originals/dba456b72d311ad5e2a125d3dd080619.jpg', '126', 'uploads/previews/6423debc2501041e54e5bd92a0b31bf7.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:53:57');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '182', 'uploads/originals/8cce9df93c16c256a42ce75eac82ec86.jpg', '126', 'uploads/previews/3cbbc8f328fee5dfc819a53475bf30a0.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:53:57');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '183', 'uploads/originals/4714e0c8a6ea65e3f995eca70ce84d2e.mp4', '126', 'uploads/previews/b3ebbfd33e1366303832b14d1bec77a8.mp4', 'uploads/standard/38de8fa513eb5f0a70938aafbb1f4df0.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:00');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '184', 'uploads/originals/a7274839e8326a2ba0d2254799923f94.mp4', '126', 'uploads/previews/db477d4d1f1bff1f68ff777d156c33f1.mp4', 'uploads/standard/1365007197454c700bbbdc3c717f45b1.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:03');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '185', 'uploads/originals/02e5179191d68b405a7e6c65a20e53a9.mp4', '126', 'uploads/previews/3247f1ead974e42ff8848ba76ce81798.mp4', 'uploads/standard/53c1da8c8257955bc96bd77b8a09c59b.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:06');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '186', 'uploads/originals/5cc6f2d4a1112204369080329e875830.mp4', '126', 'uploads/previews/92c3a9c15167a1cfff15000630f50bc3.mp4', 'uploads/standard/7694ef6a6991c94078b69196b0c483a3.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:08');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '187', 'uploads/originals/162346d2ff13f29a471d9b61f5208882.jpg', '126', 'uploads/previews/c0704fb6fd8c2e0decda3202f7d9b358.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:08');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '188', 'uploads/originals/3f241ff48855c4bf12c9bda8af94a430.jpg', '126', 'uploads/previews/be6359b32b2edd98bdd01eda3d3deedd.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:54:09');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '189', 'uploads/originals/5f3f135fc2da2a32e4441c4b78264ed2.jpg', '126', 'uploads/previews/57b2724a81d267598dad6f39f5e2c8f1.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-11 21:54:11');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '190', 'uploads/originals/0a90eb85f0282c087d85e24bd74cecaa.jpg', '126', 'uploads/previews/92eda999a1bf5331ce1b1962a580fb42.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:11');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '191', 'uploads/originals/2b0838001cd58273963f13017686dd17.jpg', '126', 'uploads/previews/b6f7f72589a2a6bffddcd4af53becac2.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:54:11');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '192', 'uploads/originals/672ebc898e9e68a9c1ed03c932e38924.mp4', '126', 'uploads/previews/a107dc295f82113913857a521c2b92ae.mp4', 'uploads/standard/8b52a79c11cb88cfcf0c0a1be348d411.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:11');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '193', 'uploads/originals/e42bfb9a3f28bde006a6c3df8bc52875.mp4', '126', 'uploads/previews/d8a977a26c0690487400a12aa045d0c8.mp4', 'uploads/standard/43aa062d402766d1aa93c44ff802ace9.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '194', 'uploads/originals/fb55117898e2655a93d9673745202c0e.mp4', '126', 'uploads/previews/253840fe45dd920d95ae1c2ce30b6007.mp4', 'uploads/standard/cffd2ad31ad634518bcf8e1000e9517d.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '195', 'uploads/originals/05b9e2dd0e160027ac08c435792cd531.jpg', '126', 'uploads/previews/895d2a95af5c3e6cd9270aa63c3c4cb3.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '196', 'uploads/originals/6b7b42e43fcbffa60c0dda0c4168e787.jpg', '126', 'uploads/previews/e94f4cfdbf0954900ac6e012fa54dfa7.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:54:15');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '197', 'uploads/originals/ca8aea363824fdbfd7fdc08c478b0bc9.jpg', '126', 'uploads/previews/122973ddefa2742fb841d107bad114aa.jpg', NULL, '160130', '0', '1', 'imagen', '2026-09-11 21:54:16');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '198', 'uploads/originals/03524f9a442d4389b6e9532a68d96526.jpg', '126', 'uploads/previews/08c98d18d2dbd4abdd84469e68903e83.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:16');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '199', 'uploads/originals/d31883c3beae3b066f3d559759a0cbd3.jpg', '126', 'uploads/previews/cda8732e6eefe63e7564c92c2632136a.jpg', NULL, '2283322', '0', '1', 'imagen', '2026-09-11 21:54:17');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '200', 'uploads/originals/0156e0d26538fd56fe4aec91a90fc37c.jpg', '126', 'uploads/previews/e8c553fc521d6771952ad64bbca625cb.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:17');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '201', 'uploads/originals/a2c8a36e87346c858329e11e8433e04d.mp4', '126', 'uploads/previews/63528cb1c2efe00bb588e51410d04924.mp4', 'uploads/standard/c96c0e65a3cd91e74a7e1beda2ef3271.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:18');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '202', 'uploads/originals/0606e4f950b5325e4f6058ef0ed53b5f.mp4', '126', 'uploads/previews/2cced7b3f69f1d5a244601a9e2cbc5d8.mp4', 'uploads/standard/0bdef3c887f301ffdea8ff7a478ead01.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:21');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '203', 'uploads/originals/936cf9f95a246fad394875f093d1e7d4.mp4', '126', 'uploads/previews/e5c694cbbe4577a52c8fe0cb5d61a52d.mp4', 'uploads/standard/7c418904b1c7bd04ddce7201f6e84ff2.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:24');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '204', 'uploads/originals/359a05ff51c9f0856698bd849aaa3002.jpg', '126', 'uploads/previews/d4718e015f7b35d9c0a2a89f76a7c78c.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:24');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '205', 'uploads/originals/9d73db8bb9c42d6b68afe000800917f4.jpg', '126', 'uploads/previews/6d2131cfd072326cea9aa9f88c9c8514.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:54:24');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '206', 'uploads/originals/ff14fda518fa76b9b021c1645760af46.mp4', '126', 'uploads/previews/13a707a0b6ddfea8f43f2f1aa838705d.mp4', 'uploads/standard/871dcaae21883c5e3ba6ca168ab111d2.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:54:27');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '207', 'uploads/originals/e8212bd40de8bea6f7db31821922f3c7.mp4', '126', 'uploads/previews/d66b464846e04b463835c909b9c445ce.mp4', 'uploads/standard/2c3ffd0c3e18d14b123e03e0369d0da7.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:54:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '208', 'uploads/originals/99f7f5e4d0b6584e836f6bad2339940b.jpg', '126', 'uploads/previews/4c8c82c373f2fd2877f27d460babe8b2.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '209', 'uploads/originals/d6fc3368699079aa8a0d848af1e4c243.jpg', '126', 'uploads/previews/9f79743de7de0499bab0917aa9bec995.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:54:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '210', 'uploads/originals/4aed72b0f4a1e578886f7414f5a69db1.jpg', '126', 'uploads/previews/9b73b1405466f31d21149e7e2ff19dba.jpg', NULL, '160130', '0', '1', 'imagen', '2026-09-11 21:54:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '211', 'uploads/originals/b02cc75aabb1826ca123d375e6c25f44.jpg', '126', 'uploads/previews/28b675794fc436ecb09550bd477f2cb1.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:30');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '212', 'uploads/originals/99b9faf9330c07bfa7ee46905bd4f4c4.jpg', '126', 'uploads/previews/3983937df4764c42e8c6de65c7133e7e.jpg', NULL, '2283322', '0', '1', 'imagen', '2026-09-11 21:54:31');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('asd', NULL, '213', 'uploads/originals/7636e132d0d9c8573ea1751bd110f8bc.jpg', '126', 'uploads/previews/46aecae297f530e067cfa72ddafd86c0.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:54:31');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '214', 'uploads/originals/b7752191c54dc16a1af5fcde7c59220b.mp4', '127', 'uploads/previews/e037debc2b2dcc1a9b32ee5632f782de.mp4', 'uploads/standard/9cba13fc890d165d28981da3b051228e.jpg', '685877', '0', '1', 'video', '2026-09-11 21:56:36');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '215', 'uploads/originals/b7321f64cd77eb95bacadad03f71774b.jpg', '127', 'uploads/previews/31f35b6a1338b4e93202af4dc8cd858a.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:56:36');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '216', 'uploads/originals/f4a9fb3cc4150fc7faba35cb06297068.jpg', '127', 'uploads/previews/6da269901af0138f7f956c8ecc59a2e7.jpg', NULL, '33383', '0', '1', 'imagen', '2026-09-11 21:56:36');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '217', 'uploads/originals/2f66c1428e1a7b3e3043f73085f1759f.jpg', '127', 'uploads/previews/b5958be309687fbfe28ff91d3cdae186.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:56:36');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '218', 'uploads/originals/31cda2555343a15e758aeae7cfecdab1.jpg', '127', 'uploads/previews/9bc5d397c50f22fb39a0a540ee64ab9d.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:56:36');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '219', 'uploads/originals/371f180db3135eefb89663bc8434163d.mp4', '127', 'uploads/previews/c9f2558a41cbf03e3b5990ed13dfa084.mp4', 'uploads/standard/dbe42d6a7fdb07191d465843ee706526.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:56:39');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '220', 'uploads/originals/d8aecfd5d4f2a0b5d0b93e125db1afb2.mp4', '127', 'uploads/previews/8677cd1f7193a10ae8ae1d88ed9932cb.mp4', 'uploads/standard/61980df63142a72f48f2b19420bbbb64.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:56:42');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '221', 'uploads/originals/4672e77a1417821016b9e709920e8456.mp4', '127', 'uploads/previews/b02391188cc57fb24a7e29d0fad533eb.mp4', 'uploads/standard/67630791c8c86ff10cc3ddafe640d6c2.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:56:45');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '222', 'uploads/originals/8f36bfe3102496b5e667343e8a4a92c8.mp4', '127', 'uploads/previews/c6a262bc31c9d950946672b7fc881cec.mp4', 'uploads/standard/9cdaacab2aa52af8cfe335ab63de6a75.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:56:47');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '223', 'uploads/originals/82324d2c6d3a6349efbde0d7f80c8edb.jpg', '127', 'uploads/previews/ba23162d9d166e9e5ca77f0652b66aef.jpg', NULL, '325679', '0', '1', 'imagen', '2026-09-11 21:56:47');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '224', 'uploads/originals/e266d150378b5d499c2234ec3a589de4.jpg', '127', 'uploads/previews/38a7b74c75b46a344b15d189fdf0196e.jpg', NULL, '134137', '0', '1', 'imagen', '2026-09-11 21:56:48');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '225', 'uploads/originals/22b496a43c620b4c92c8999a00f242bf.mp4', '127', 'uploads/previews/d236c54269b404d39288c8716bc77c6c.mp4', 'uploads/standard/eff9d506fa9c7436670eb1f519b1f0bd.jpg', '24184154', '0', '1', 'video', '2026-09-11 21:56:51');
INSERT INTO `multimedia` (`titulo`, `descripcion`, `id_multimedia`, `ruta_original`, `coleccion_id`, `vista_previa`, `poster`, `tamanio`, `es_invitado`, `aprobado`, `tipo`, `creado_en`) VALUES ('fd', 'njin', '226', 'uploads/originals/33dde35ebbafce1fe1d0ccf33f145886.mp4', '127', 'uploads/previews/79eef8e8600ed54335cf6259bfcb8d5d.mp4', 'uploads/standard/5304b39088b20f86f6c24797e163bee9.jpg', '1613589', '0', '1', 'video', '2026-09-11 21:56:53');

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
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('36', '385408d68dd5a89534d25ae4f718e5b3141d8fbd', '53', '2026-09-10 19:48:25', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('37', '204c55657e1b01e454880921b8db990691abc9db', '52', '2026-09-10 19:48:28', 'colaborativo', '2026-09-11 19:48:28');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('39', '1e0519358ed26bda9b64dddcda95aa360592eaa3', '56', '2026-09-10 19:51:38', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('40', 'e0a070c7e4e9d3ba3e1247d1921d7beabbe5337f', '55', '2026-09-10 19:51:41', 'colaborativo', '2026-09-11 19:51:41');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('41', '928a265328218fe0a660b077cd167e1a770056f4', '58', '2026-09-10 20:03:09', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('42', 'aa12b6d47f144e8827b28aa45f148da6568a9ac8', '57', '2026-09-10 20:03:13', 'colaborativo', '2026-09-11 20:03:13');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('43', '498045b8827e2a949f744c0374089cb39fba48a8', '60', '2026-09-10 20:21:55', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('44', 'd5b200065ffe218cf53db3f93ebd758f671bf490', '59', '2026-09-10 20:21:58', 'colaborativo', '2026-09-11 20:21:58');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('66', '2d033e1610028605d302ce799bac5b1af6e10a79', '94', '2026-09-11 12:47:16', 'colaborativo', '2026-09-12 12:47:16');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('67', '289c2411fd4eecda5a9bed0db9ee3b51d8ab6f16', '94', '2026-09-11 12:47:16', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('68', '7022d9b5493f03deea28c00fb08adba9b813d82f', '95', '2026-09-11 12:48:10', 'colaborativo', '2026-09-12 12:48:10');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('69', '2d72dfb269afe1e37343b14ec7589a936cd5ebe2', '95', '2026-09-11 12:48:11', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('70', '998871c2028526843353a6e98ca01226da667c9e', '96', '2026-09-11 12:48:47', 'colaborativo', '2026-09-12 12:48:47');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('71', 'c68981cced98c655343a34311efc357eae1b3abf', '96', '2026-09-11 12:48:48', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('75', '5388aa9f15fc00d211d5b89c7a6749aef14338fd', '103', '2026-09-11 18:31:20', 'acceso', NULL);
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('76', 'a8e336dc06691694c6ecb550de9091eaad2a3a5e', '103', '2026-09-11 18:31:41', 'colaborativo', '2026-09-12 18:31:41');
INSERT INTO `qr_tokens` (`id_token`, `token`, `coleccion_id`, `creacion_token`, `tipo`, `expiracion`) VALUES ('78', 'd8d0a7f64c460c57d58ff9631b70b6957ace1cf4', '127', '2026-09-11 21:56:56', 'acceso', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=126 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('65', 'Fotografo Test Actualizado', 'foto164818@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$48u9gyRdLmmb1qJvI6NjTe74k9DoJn7bqc6hkYVUi1KlAh7hnqY/2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('66', 'Cliente Test', 'cliente164818@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$hprR.CELYl2bOrQZrF1TSuhvNQn77ljriVR5SCmMzFZyMH8XNknb2', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('67', 'Cliente Consent', 'cliconsent164820912@test.com', NULL, '1', NULL, NULL, '$2y$10$MCmgJZQUavjmpqYxk4beW.Rw/6PvxkW2ySeRIpSKueqwh7Ges133O', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('68', 'Foto CF15', 'cf15164932204@test.com', NULL, '1', NULL, NULL, '$2y$10$J4VN7b.AjaEVps0Pj4X0zu87KyRN1gwGBoE56DoYG5TkBRvswLpYW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('69', 'Dbg', 'dbg165024906@test.com', NULL, '0', '748736', '2026-09-10 20:50:25', '$2y$10$HZTVnrF3XRzuogwhDJ95p.DtiCHyW5JPn2OlU2SMHoRrvpd1XocWi', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('70', 'Foto CF15', 'cf15165119569@test.com', NULL, '1', NULL, NULL, '$2y$10$O54Ib8CF97D5OXoZq2Dy4Ofle82i/Vlq3iXpcjvGvB.V0LguPJJnG', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('71', 'Fotografo Test Actualizado', 'foto165134@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$Ncv78/RfVKO0R7PUHy7ah.vtfWdXCHA7ndW.gE6KN0UDeLRXc/XCm', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('72', 'Cliente Test', 'cliente165134@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$UnQbnlTCvTXM3cuguorqW.6czaM5cUuOFNy2TCtJU1EnbYnxovnkC', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('73', 'Cliente Consent', 'cliconsent165136111@test.com', NULL, '1', NULL, NULL, '$2y$10$PJ4eNJk6SxCettjr.Ddxx.JXkBxmBQ/NYuCWwPMyXzMiVaVs8P0Oi', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('74', 'Fotografo Test Actualizado', 'foto170301@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$wumxSEvOinNDnxJzkSLdK.Hm2YCPUcx3gPjdTq6AmC6Twe9cKSiiu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('75', 'Cliente Test', 'cliente170301@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$aJgKqcGvXDW/jumMPAxUvehINn7SsvkCC0GJce/AYv31yjeFU8Uoq', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('76', 'Cliente Consent', 'cliconsent170304600@test.com', NULL, '1', NULL, NULL, '$2y$10$EVH83v.7Fvf7.xrX.jXgn.P402vES8VIkwKI6VFfu4UVTfvgySur2', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('77', 's', 's@gmail.com', NULL, '1', NULL, NULL, '$2y$10$SXqUDRrSKJLS8BGFHl3i1.0UmJLJCHDoeQyWh6OqCoiOaZFHRFmdW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('78', 'Fotografo Test Actualizado', 'foto172150@test.com', '+598 99 111 222', '1', NULL, NULL, '$2y$10$MZVeGtEPTJDYQP/Z7CGoKuuqe4Q2Vo7KkIZfMdJTK6Kubsgup..uO', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('79', 'Cliente Test', 'cliente172150@test.com', '+598 99 222 333', '1', NULL, NULL, '$2y$10$tNwUa6fA8Fh3unzbPmL81ent2rGJSHly1K2waU7Pk5vUjnwRjaVWe', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('82', 'vlh', 'sfds@gmali.com', NULL, '1', NULL, NULL, '$2y$10$lQQebATNHgZ3tY3EZgveQuTxFk6ddIjdc1LzF6nLl4AlnuAn8JSHe', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('86', 'test', 'tested@gmail.com', NULL, '1', NULL, NULL, '$2y$10$MAZZfOvbsyh0MnflbEdHdOmUK2z/SGVXYvi2oGUQW./FwDCkKKA3e', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('93', 's', 'sd@gmail.com', NULL, '1', NULL, NULL, '$2y$10$.PKYWS/QQiJv6O9jvuqXseN8rKrUOcgqYL7DoB62uwCKpPcCj01Tm', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('106', 'Fotografo E2E', 'e2e_foto_20260911094715347@test.com', '099123456', '1', NULL, NULL, '$2y$10$MvP.Gp2oRCt1Ouz6gTKZoO6Ws/tAb8P3C0DfC3Ex6cI0CTkSj2Yxq', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('107', 'Cliente E2E', 'e2e_cli_20260911094715347@test.com', NULL, '1', NULL, NULL, '$2y$10$ecBAQptOpZa1hOWqp2AT8OnRN4TG8XvfdtkTg9qh3IUEYsxYEE5La', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('108', 'Fotografo E2E', 'e2e_foto_20260911094809824@test.com', '099123456', '1', NULL, NULL, '$2y$10$G.6GThyMb.Nx/Jmp/9HtJ.AUMGFId8tBEPErictYir11PIvL9WcJO', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('109', 'Cliente E2E', 'e2e_cli_20260911094809824@test.com', NULL, '1', NULL, NULL, '$2y$10$9j67Ek4EHO3ZQcOhKhLlxuphK1iB77c9fZMZZV8vY6Z3yFrQVXpQO', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('110', 'Fotografo E2E', 'e2e_foto_20260911094846519@test.com', '099123456', '1', NULL, NULL, '$2y$10$V19R4dbmHMbbdTv945rXdufx/Wqhf5TkjMHR2OfXTQnrfyd1c0z9.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('111', 'Cliente E2E', 'e2e_cli_20260911094846519@test.com', NULL, '1', NULL, NULL, '$2y$10$LcYBUAUvOytGS3EgcpxHJeYfSRzYF/ZdOGEA282CLDfbo7cCmy/DW', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('112', 'Fotografo H05', 'e2e_h05_20260911125821335@test.com', '099777888', '1', NULL, NULL, '$2y$10$QFLLpx7qzXxlOtUontjFY.EGkicXIpWcAwAFkMDW0PV8lctVQG7rG', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('113', 'testingaccount', 'testing12@gmail.com', NULL, '1', NULL, NULL, '$2y$10$agXJJO.7p7Hsnj/DISNd4.mfeZdJ1nHdMEW3KOAIsU3swYZQvm2zm', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('114', 'Fotografo H05B', 'e2e_h05b_20260911144037293@test.com', '099555666', '1', NULL, NULL, '$2y$10$8gjm6YRyf2bO72Q0Rs5cPefZmLMoP7oFwZUREotThUcTso3.fZG0O', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('115', 'Fotografo H05B', 'e2e_h05b_20260911144147482@test.com', '099555666', '1', NULL, NULL, '$2y$10$lHxw0vNhL7XlHhnVuD03Me4XVAu.qt1FHY9aaWNqkWw5jg8R8qgh2', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('116', 'Fotografo H05B', 'e2e_h05b_20260911145246206@test.com', '099555666', '1', NULL, NULL, '$2y$10$RJ/8SA9ZM4kLzRX8tpFl2O0x4VnkZm32XHxix/OTzr6n0R8RXO26.', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('117', 'test345', 'test34@gmail.com', NULL, '1', NULL, NULL, '$2y$10$8k8RjVdm4z8.Ckb2ea8mtuva3boZEcb1uwbANckXO/7baIWhukpBW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('118', 'tesd', 'tesd@gmail.com', NULL, '1', NULL, NULL, '$2y$10$wNKNtapbXj5LPDPVIUl6eO0O1eEVfwOSq0BMvIZHeKV8/W0AXIB1y', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('119', 'H09 Test', 'h09_155729_2471@test.dev', NULL, '1', NULL, NULL, '$2y$10$GEf92t85evMCQ/JJU.4M0OMZzFgswTymBQC.eMDIc3BZ1xMX3Td8G', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('120', 'H09 Test', 'h09_155822_8636@test.dev', NULL, '1', NULL, NULL, '$2y$10$ALEd2dI6igRxzXOf2/x06efsUmB30yJpCuMQzGRITvatYxeknWOui', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('121', 'Cli', 'h09cli_155822_8636@test.dev', NULL, '1', NULL, NULL, '$2y$10$VQ0wjZB5huuisSCoKoMOKeGlJs.DZ9iehEXocd5fDdE.5UsOmvWvq', 'cliente');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('122', 'H09B', 'h09b_160809_6293@test.dev', NULL, '1', NULL, NULL, '$2y$10$jo8K90PDP.ZpyQeDTErW5.vHt/8VArj.HGgFq.7wZpmYWC.n5EVDu', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('123', 'H35', 'h35_162211_9921@test.dev', NULL, '1', NULL, NULL, '$2y$10$EU6kx8LFdtUhtAuTg0eOdOdjgRoc6WJ21x24G4o3Q6C5grhK0uzzW', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('124', 'H35', 'h35_162226_4786@test.dev', NULL, '1', NULL, NULL, '$2y$10$FNyli36fqtChn0EOC1IDQOsnsjRMtGKlPWPqCJP3tpQKqdkbh.0Ny', 'fotografo');
INSERT INTO `usuarios` (`id`, `nombre_completo`, `email`, `telefono`, `email_verificado`, `codigo_verificacion`, `codigo_expiracion`, `password_hash`, `rol`) VALUES ('125', 'H35C', 'h35c_162226_4786@test.dev', NULL, '1', NULL, NULL, '$2y$10$VrACO396P58Ls3OhsPuOG.LJ/XH7QQsBtKMEbno3rQXtxmUfQVLYq', 'cliente');

SET FOREIGN_KEY_CHECKS = 1;
-- Fin del Respaldo
