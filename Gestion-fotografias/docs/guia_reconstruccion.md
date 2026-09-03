# Guía Paso a Paso para la Reconstrucción de la Infraestructura

Este documento proporciona el instructivo descriptivo paso a paso para desplegar, inicializar y reconstruir desde cero el entorno completo de **Cipher_Forge** en cualquier máquina host (Windows, Linux o macOS) con fines de desarrollo o evaluación tribunalicia de UTU.

---

## 1. Requisitos Previos

Antes de comenzar, asegúrate de contar con el siguiente software instalado y en ejecución en el equipo anfitrión:

1. **Docker Desktop:** Versión 24.0 o superior (con el motor Docker activo y soporte para Docker Compose v2).
2. **Git:** Para clonar el repositorio y gestionar versiones.
3. **Puertos locales libres:**
   * **8080:** Para la interfaz web del servidor Apache / Backend API.
   * **3306:** Para el servicio de base de datos MySQL.
   *(Asegúrate de que herramientas como XAMPP, WampServer o servicios locales de MySQL estén detenidos para evitar conflictos de puertos).*

---

## 2. Paso a Paso para la Puesta en Marcha

### Paso 1: Obtener el Código Fuente
Abre una terminal (PowerShell en Windows o Bash en Linux/macOS) y clona el repositorio del proyecto:

```bash
git clone https://github.com/NicolasNegretto7/Cipher_Forge.git
cd Cipher_Forge/Gestion-fotografias/backend
```

### Paso 2: Validar Archivos de Configuración
Verifica que en el directorio actual (`Gestion-fotografias/backend`) existan los archivos fundamentales:
* `Dockerfile` (receta del contenedor de aplicación).
* `docker-compose.yml` (orquestador de contenedores).
* `database/schema.sql` (script DDL de tablas iniciales).

### Paso 3: Construcción e Inicio de Contenedores
Ejecuta la orden de construcción y levantamiento en modo desacoplado (*detached*):

```bash
docker compose up --build -d
```

> **¿Qué ocurre internamente?**
> 1. Docker descarga la imagen oficial de `mysql:8.0` y la imagen base `php:8.2-apache`.
> 2. Compila en Debian las librerías `ffmpeg`, `libpng`, `libjpeg`, `libfreetype`, `libzip` y extensiones PHP (`gd`, `pdo_mysql`, `zip`).
> 3. Crea la red puente interna del proyecto.
> 4. Inicializa el contenedor `cipher_forge_db` y monta `schema.sql` en `/docker-entrypoint-initdb.d/`.
> 5. Inicializa el contenedor `cipher_forge_app` conectándolo a la base de datos mediante el host `db`.

### Paso 4: Comprobación del Estado de los Contenedores
Verifica que ambos contenedores se encuentren en estado `Up`:

```bash
docker compose ps
```

*Salida esperada:*
```text
NAME               IMAGE                   COMMAND                  SERVICE   STATUS   PORTS
cipher_forge_app   backend-app             "docker-php-entrypoi…"   app       Up       0.0.0.0:8080->80/tcp
cipher_forge_db    mysql:8.0               "docker-entrypoint.s…"   db        Up       0.0.0.0:3306->3306/tcp
```

### Paso 5: Verificación de la Base de Datos
Para confirmar que el script `schema.sql` se ejecutó correctamente y las tablas fueron creadas, consulta el contenedor de MySQL:

```bash
docker exec -it cipher_forge_db mysql -u cipher_user -pcipher_password -e "USE cipher_forge; SHOW TABLES;"
```

*Deberás observar las 11 tablas del sistema:* `acceso_colecciones`, `backups`, `clientes`, `coleccion_hashtags`, `colecciones`, `favoritos`, `fotografos`, `hashtags`, `multimedia`, `qr_tokens`, `usuarios`.

### Paso 6: Prueba de Conectividad con la API
Abre un navegador web o ejecuta `curl` para verificar el endpoint de diagnóstico del backend:

```bash
curl http://localhost:8080/api/ping
```

*Respuesta esperada (HTTP 200 OK):*
```json
{
  "status": "success",
  "message": "pong",
  "timestamp": 1725379200
}
```

---

## 3. Comprobación y Uso de los Portales Frontend

Los archivos del frontend son aplicaciones web cliente servidas de forma estática o consumibles directamente:
1. **Portal Fotógrafo:** Abre en el navegador el archivo `frontend-fotografo/index.html` (o `pages/login.html`). Permite el registro como rol Fotógrafo, login y administración de colecciones.
2. **Portal Cliente:** Abre en el navegador el archivo `frontend-cliente/index.html` (o `pages/logincliente.html`). Permite explorar colecciones públicas, ingresar a privadas mediante token y realizar descargas directas en Buena o Alta calidad.

---

## 4. Comandos de Diagnóstico y Mantenimiento

### Ver Logs en Vivo
Si un endpoint o servicio presenta comportamientos inesperados, revisa los logs de los contenedores en tiempo real:

```bash
# Logs del backend Apache/PHP
docker compose logs -f app

# Logs del motor MySQL
docker compose logs -f db
```

### Ingresar a la Consola de un Contenedor
Para inspeccionar archivos generados o ejecutar comandos dentro de Linux:

```bash
# Shell interactiva en el backend
docker exec -it cipher_forge_app bash

# Shell interactiva en la base de datos
docker exec -it cipher_forge_db bash
```

### Detener los Servicios
Para pausar la ejecución conservando los datos persistidos en los volúmenes:

```bash
docker compose stop
```

Para volver a levantarlos rápidamente:

```bash
docker compose start
```

---

## 5. Reconstrucción Limpia desde Cero (Reset Total)

Si deseas resetear completamente el estado de la base de datos y archivos multimedia para reiniciar pruebas o realizar una demostración limpia:

```bash
# 1. Detener contenedores y destruir volúmenes persistentes de Docker
docker compose down -v

# 2. Reconstruir imágenes forzando descarga sin caché y reiniciar
docker compose up --build -d
```
