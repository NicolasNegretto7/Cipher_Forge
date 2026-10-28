-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: cipher_forge
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `cipher_forge`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cipher_forge` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `cipher_forge`;

--
-- Table structure for table `acceso_colecciones`
--

DROP TABLE IF EXISTS `acceso_colecciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acceso_colecciones` (
  `usuario_id` int NOT NULL,
  `coleccion_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`coleccion_id`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `acceso_colecciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `acceso_colecciones_ibfk_2` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `acceso_colecciones`
--

LOCK TABLES `acceso_colecciones` WRITE;
/*!40000 ALTER TABLE `acceso_colecciones` DISABLE KEYS */;
INSERT INTO `acceso_colecciones` VALUES (6,5);
/*!40000 ALTER TABLE `acceso_colecciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backups`
--

DROP TABLE IF EXISTS `backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backups` (
  `id_backup` int NOT NULL AUTO_INCREMENT,
  `ruta_backup` varchar(100) NOT NULL,
  `nombre_backup` varchar(100) NOT NULL,
  `fecha_backup` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_backup`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups`
--

LOCK TABLES `backups` WRITE;
/*!40000 ALTER TABLE `backups` DISABLE KEYS */;
INSERT INTO `backups` VALUES (21,'backups/backup_cipher_forge_2026-10-21_17-24-29.sql','backup_cipher_forge_2026-10-21_17-24-29.sql','2026-10-21 17:24:29'),(22,'backups/backup_cipher_forge_2026-10-22_15-33-23.sql','backup_cipher_forge_2026-10-22_15-33-23.sql','2026-10-22 15:33:23'),(23,'backups/backup_cipher_forge_2026-10-26_15-51-58.sql','backup_cipher_forge_2026-10-26_15-51-58.sql','2026-10-26 15:51:58');
/*!40000 ALTER TABLE `backups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL,
  PRIMARY KEY (`id_cliente`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (6),(10),(12),(13),(14),(15),(16),(17),(18),(19),(21);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coleccion_hashtags`
--

DROP TABLE IF EXISTS `coleccion_hashtags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coleccion_hashtags` (
  `id_hashtags` int NOT NULL,
  `coleccion_id` int NOT NULL,
  PRIMARY KEY (`id_hashtags`,`coleccion_id`),
  KEY `coleccion_id` (`coleccion_id`),
  CONSTRAINT `coleccion_hashtags_ibfk_1` FOREIGN KEY (`id_hashtags`) REFERENCES `hashtags` (`id_hashtags`) ON DELETE CASCADE,
  CONSTRAINT `coleccion_hashtags_ibfk_2` FOREIGN KEY (`coleccion_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coleccion_hashtags`
--

LOCK TABLES `coleccion_hashtags` WRITE;
/*!40000 ALTER TABLE `coleccion_hashtags` DISABLE KEYS */;
/*!40000 ALTER TABLE `coleccion_hashtags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `colecciones`
--

DROP TABLE IF EXISTS `colecciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `colecciones`
--

LOCK TABLES `colecciones` WRITE;
/*!40000 ALTER TABLE `colecciones` DISABLE KEYS */;
INSERT INTO `colecciones` VALUES (1,1,'privada','df','ddddddd','2026-09-14 23:35:52'),(3,2,'privada','we',NULL,'2026-09-15 17:42:26'),(4,2,'privada','asd',NULL,'2026-09-15 18:09:28'),(5,3,'privada','ds',NULL,'2026-09-15 18:24:54'),(8,8,'privada','as',NULL,'2026-09-16 18:16:55'),(9,8,'privada','goty',NULL,'2026-09-16 18:36:33'),(10,4,'privada','we',NULL,'2026-09-18 00:16:03'),(11,9,'privada','LodeMati','j','2026-10-19 19:40:41');
/*!40000 ALTER TABLE `colecciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favoritos`
--

DROP TABLE IF EXISTS `favoritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favoritos` (
  `usuario_id` int NOT NULL,
  `favorito_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`favorito_id`),
  KEY `favorito_id` (`favorito_id`),
  CONSTRAINT `favoritos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `favoritos_ibfk_2` FOREIGN KEY (`favorito_id`) REFERENCES `colecciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favoritos`
--

LOCK TABLES `favoritos` WRITE;
/*!40000 ALTER TABLE `favoritos` DISABLE KEYS */;
/*!40000 ALTER TABLE `favoritos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fotografos`
--

DROP TABLE IF EXISTS `fotografos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fotografos` (
  `id_fotografo` int NOT NULL,
  `politicas_aceptadas` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_fotografo`),
  CONSTRAINT `fotografos_ibfk_1` FOREIGN KEY (`id_fotografo`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fotografos`
--

LOCK TABLES `fotografos` WRITE;
/*!40000 ALTER TABLE `fotografos` DISABLE KEYS */;
INSERT INTO `fotografos` VALUES (1,1),(2,1),(3,1),(4,1),(5,0),(7,1),(8,1),(9,1),(11,0),(20,0);
/*!40000 ALTER TABLE `fotografos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hashtags`
--

DROP TABLE IF EXISTS `hashtags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hashtags` (
  `nombre_hashtags` varchar(40) NOT NULL,
  `id_hashtags` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id_hashtags`),
  UNIQUE KEY `nombre_hashtags` (`nombre_hashtags`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hashtags`
--

LOCK TABLES `hashtags` WRITE;
/*!40000 ALTER TABLE `hashtags` DISABLE KEYS */;
INSERT INTO `hashtags` VALUES ('<script>',8),('ass',2),('ass$',5),('ass1',4),('femboy',3),('sdbofubweubfouwebf%$#&*&@(*#@&*(*&^%@*',7),('ssadasd*$%&$',6);
/*!40000 ALTER TABLE `hashtags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multimedia`
--

DROP TABLE IF EXISTS `multimedia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multimedia`
--

LOCK TABLES `multimedia` WRITE;
/*!40000 ALTER TABLE `multimedia` DISABLE KEYS */;
INSERT INTO `multimedia` VALUES ('cipherforge-139-buena (1).mp4',NULL,1,'uploads/originals/aaa8a2b798673564110bcc24c7d70623.mp4',1,'uploads/previews/5b6517659fea3f40d8f6610e83ab24f6.mp4','uploads/standard/427f73134f6f45c6bdbead66eb640829.jpg',685877,0,1,'video','2026-09-14 23:36:03'),('cipherforge-138-alta (1).jpg',NULL,2,'uploads/originals/597bd455cc5257eaa1f429cf11168f36.jpg',1,'uploads/previews/04ef223c5c536c3045d54cb5275e0dc1.jpg',NULL,325679,0,1,'imagen','2026-09-14 23:36:03'),('cipherforge-138-buena (1).jpg',NULL,3,'uploads/originals/dcc8aeb67db138b918fe61ce269501d0.jpg',1,'uploads/previews/ed339dbed8899a08645a42c5661f8b2a.jpg',NULL,33383,0,1,'imagen','2026-09-14 23:36:04'),('cipherforge-138-alta.jpg',NULL,4,'uploads/originals/d6a30dfb40a195ea9aeb44b53fc73a36.jpg',1,'uploads/previews/85ff76bda8ebe23dba3e17f568a8fe03.jpg',NULL,325679,0,1,'imagen','2026-09-14 23:36:04'),('cipherforge-138-buena.jpg',NULL,5,'uploads/originals/474022664f41a928d340411e8076492f.jpg',1,'uploads/previews/565da0c45a78d661b311df0f2ad9c917.jpg',NULL,134137,0,1,'imagen','2026-09-14 23:36:04'),('clip_1.787.767.729.202.mp4',NULL,19,'uploads/originals/e0ae9965f7ed52cc0158ff3d9c7f8994.mp4',3,'uploads/previews/9dffc761f4fdf5aecc0af3c4c67f65af.mp4','uploads/standard/bfb6de64625d6ba0a747b80a58ff4568.jpg',24184154,0,1,'video','2026-09-15 18:08:01'),('cipherforge-139-buena (1).mp4',NULL,20,'uploads/originals/f6f95d88338ca58073e1b9e312ce8f17.mp4',5,'uploads/previews/7ded2e3e85b2a2ae293c0f7602b6dfd9.mp4','uploads/standard/4dcaa4d567697e2a02dd8430dc366226.jpg',685877,0,1,'video','2026-09-15 18:25:05'),('cipherforge-138-alta (1).jpg',NULL,21,'uploads/originals/c1141d98ba7d9b2635b4802d4f49bb29.jpg',5,'uploads/previews/b6f6e1cde0aa87979a6600f2f751e2b9.jpg',NULL,325679,0,1,'imagen','2026-09-15 18:25:05'),('cipherforge-139-buena (1).mp4',NULL,33,'uploads/originals/69ca086367760c78d7c42455767fee54.mp4',8,'uploads/previews/7aa033b6b673b0d8f369e48eba685548.mp4','uploads/standard/1e3065159b74c6b0a27b6f251970f91d.jpg',685877,0,1,'video','2026-09-16 18:17:04'),('cipherforge-138-alta (1).jpg',NULL,34,'uploads/originals/f0727052986adef48a0353e84628cdb4.jpg',8,'uploads/previews/72c794f2f2fe9db30157175c6f97e194.jpg',NULL,325679,0,1,'imagen','2026-09-16 18:17:04'),('cipherforge-138-buena (1).jpg',NULL,35,'uploads/originals/63e8989956d63fe87467daa286b892c3.jpg',8,'uploads/previews/01f7ee0bec2a2c30c7f6bebb4ef05519.jpg',NULL,33383,0,1,'imagen','2026-09-16 18:17:04'),('cipherforge-138-alta.jpg',NULL,36,'uploads/originals/fffd9087a83a6654733de6515169804c.jpg',8,'uploads/previews/7787f892626d3a661e9e547a000d3a11.jpg',NULL,325679,0,1,'imagen','2026-09-16 18:17:05'),('cipherforge-138-buena.jpg',NULL,37,'uploads/originals/d1fb019cb074b70b11a2a1f850fe25f9.jpg',8,'uploads/previews/fceaf72fb8e824646f3fa2e90fe082e6.jpg',NULL,134137,0,1,'imagen','2026-09-16 18:17:05'),('Screenshot 2026-08-27 123528.jpg',NULL,38,'uploads/originals/5149726bac0b6ebb0b452255565976d0.jpg',11,'uploads/previews/f440db82db77eb70a5ff9ecaa1aa2dfe.jpg',NULL,112066,0,1,'imagen','2026-10-19 19:42:53');
/*!40000 ALTER TABLE `multimedia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_tokens`
--

DROP TABLE IF EXISTS `qr_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_tokens`
--

LOCK TABLES `qr_tokens` WRITE;
/*!40000 ALTER TABLE `qr_tokens` DISABLE KEYS */;
INSERT INTO `qr_tokens` VALUES (1,'57df3f466fb2036067e6db084d68badebfa2aff3',1,'2026-09-14 23:36:54','acceso',NULL),(2,'b9299274eab972897401567ca7afd21bacffe8a1',1,'2026-09-14 23:37:03','colaborativo','2026-09-15 23:37:03'),(12,'dfeae2b87e73c9198806c14ac77b187a1e60ee83',3,'2026-09-15 17:42:56','acceso',NULL),(13,'00a503b6fd5c36fb0cb31d06ab2047a45dd8d413',3,'2026-09-15 17:43:05','colaborativo','2026-09-16 17:43:05'),(14,'ab338d38d258122c5939c5092e83240370b399f5',3,'2026-09-15 18:06:03','colaborativo','2026-09-16 18:06:03'),(15,'3e048e123df980adc2caa73190e96f6ba98d07f8',3,'2026-09-15 18:07:09','colaborativo','2026-09-16 18:07:09'),(16,'8f178d4bed65f013a762bc48b50183270455ed32',4,'2026-09-15 18:09:37','colaborativo','2026-09-16 18:09:37'),(17,'a671f272ec685c2f8a7ed27e42190270374bacaa',5,'2026-09-15 18:25:08','acceso',NULL),(18,'849ce24e5d557c4b30458607d2b2fd617b00838e',4,'2026-09-15 21:35:32','colaborativo','2026-09-16 21:35:32'),(26,'93b1b6634542d6a65dd791d8193f0640d4b5ea96',8,'2026-09-16 18:17:08','acceso',NULL),(27,'ae071f505ede57e94bb12264f37ad1d93084d268',8,'2026-09-16 18:19:30','colaborativo','2026-09-17 18:19:30'),(28,'f6407d953feacd06f6b498c7ab1a253568b9efbb',8,'2026-09-16 18:31:42','colaborativo','2026-09-17 18:31:42'),(29,'2c7553180582d724543edd36b49851f6b9074ae6',8,'2026-09-16 18:33:50','colaborativo','2026-09-17 18:33:50'),(30,'1d0d9a5b4ca45820cf6470c50b8a420e186154c3',9,'2026-09-16 18:36:36','colaborativo','2026-09-17 18:36:36'),(31,'e228c3b85d71ecda5a973c56117421bfe06deafe',11,'2026-10-19 19:44:57','colaborativo','2026-10-20 19:44:57');
/*!40000 ALTER TABLE `qr_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'xd','migmail@gmail.com',NULL,1,NULL,NULL,'$2y$10$yx8yMaDY0s4P2I5VNmO3uOWFsmoS9nUX4bzJVYaNa9N8FbUDcraYW','fotografo'),(2,'s','sfds@gmali.com',NULL,1,NULL,NULL,'$2y$10$3LqGZu3szAMmbHrFtOjxgO5FZfkDkXOrirhgEFx0B3C0t3l9cdwUK','fotografo'),(3,'dfss','test00@gmail.com',NULL,1,NULL,NULL,'$2y$10$22QFp5hGsovFSDYmdHe0kOHcQXjQEWEKW1PhaIhHVZI9wQzsTyfNW','fotografo'),(4,'sd','ss@gmail.com',NULL,1,NULL,NULL,'$2y$10$XHM0.aprvvtN4W.OcA4Sues8vy2a5AmafE6OcAer1l.EHrV13762u','fotografo'),(5,'ss','dd@gmail.com',NULL,0,'181624','2026-09-15 19:20:18','$2y$10$VaX6vwGfeHUyP22tT1rXneOQlKiRefJmSGz/Y6cBYpLjCAG1Ln5kC','fotografo'),(6,'sd','ff@gmail.com',NULL,1,NULL,NULL,'$2y$10$5IhcOcvm.a9jw0tHJETouOruBuBpOWmujMoa3yPJOhl6yZlCHkGpq','cliente'),(7,'s','2232@gmail.com',NULL,1,NULL,NULL,'$2y$10$McmldN5IYBe4312.eLMoLubeqbUg/en6bAyN7SX.QuxmnYd2pZUm2','fotografo'),(8,'Ivan sandoval','test878@gmail.com',NULL,1,NULL,NULL,'$2y$10$VMKUkyR40ZJ.FUOLm9x26OyWXzgflcPWJVhrskgrdbxzfY2V9rMt2','fotografo'),(9,'s','ll@gmail.com',NULL,1,NULL,NULL,'$2y$10$mSTzSSfIk0BkMXzNENgphOtAuI.oaVKM4UtZH/NrOv/SaQHI0eeUW','fotografo'),(10,'sdas','mm@gmail.com',NULL,1,NULL,NULL,'$2y$10$f4TT3PtvjspoxIAxDvIccuuPuHDLJm.UGVK/P1c82mFkKdi8pwdj6','cliente'),(11,'Foto Test','foto_143340_1700@test.dev',NULL,1,NULL,NULL,'$2y$10$PFet1JX51uC8QILIjZCugedIckP.hcPOFhilCaeuX1i6QgUAkaPRK','fotografo'),(12,'Cliente Test','cliente_143340_1700@test.dev',NULL,1,NULL,NULL,'$2y$10$ZIANzmA68CKw2IZoHVlZZexjL5T1rzQT0XRYbarwrU1LarDwIlZQm','cliente'),(13,'RL Test','rl_23954@test.dev',NULL,0,'137693','2026-10-21 18:36:42','$2y$10$Hee0aRL4TLs..r.FL/P9suYfXprxV9zAWGP9DNl8S7QmYpv5Awxs6','cliente'),(14,'RL Test','rl_10782@test.dev',NULL,0,'624077','2026-10-21 18:38:09','$2y$10$jH9irvrTGH3YeLGle3B0j.D5hno7CjtO5nD1pRnP0Xl7Vlq6dqOiS','cliente'),(15,'RL Test B','rlb_10782@test.dev',NULL,0,'269375','2026-10-21 18:38:11','$2y$10$5n7e/HspbN.oKt.RYPob6OPc2ogzya677s/3wdac0CR6pp/BqTRqG','cliente'),(16,'RL Test','rl_68285@test.dev',NULL,0,'757679','2026-10-21 18:45:02','$2y$10$r.WXviFpQ4CnKOETwZGIT.oZZOh56ihLtsMBtzDnGc1dpA4E8kuGO','cliente'),(17,'RL Test B','rlb_68285@test.dev',NULL,1,NULL,NULL,'$2y$10$CzZcQR3267U5wI2KkLMGYexaEYJV2ar8ZRdBorLXplINbFaRAKosa','cliente'),(18,'RL Test','rl_63250@test.dev',NULL,0,'100047','2026-10-21 18:46:35','$2y$10$jiIce3M8NW7h7DMpLxf2Z.uBdxQGE8rKvZFJOgYF7YMnSmiKnc6PS','cliente'),(19,'RL Test B','rlb_63250@test.dev',NULL,1,NULL,NULL,'$2y$10$uxeCR9wPi.ozPSEv6hWHPuyMjujvJWdUaTGhyi6nDI/JmnKda0wJa','cliente'),(20,'Foto Test','foto_144648_8157@test.dev',NULL,1,NULL,NULL,'$2y$10$/xmVmle5Uyp8EpTnCh0ADuT1xeuGIbUO4wCVOp8FRE.S2ferOybqy','fotografo'),(21,'Cliente Test','cliente_144648_8157@test.dev',NULL,1,NULL,NULL,'$2y$10$NgM9vrVcp367jMqyCxXOGeR8b7BxLMF6Y6buoXctpb.K84ctDA3x2','cliente');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'cipher_forge'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-26 18:28:57
