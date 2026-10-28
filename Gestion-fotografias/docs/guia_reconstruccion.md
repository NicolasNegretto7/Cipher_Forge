# Guía Paso a Paso para la Reconstrucción de la Infraestructura

> **Convenciones de esta guía:** los bloques `LOCAL Windows` describen desarrollo/testing/evaluación UTU con Docker Desktop. Los bloques `SERVIDOR UBUNTU (Server Ubuntu Lab)` describen el entorno implementado en la VM `Ubuntu-Server-Lab` con Nginx y VirtualBox NAT; es una demo/laboratorio, no producción. Los bloques `PRODUCCIÓN` describen preparación para entorno real y **no están implementados**. Los bloques `COMPARTIDO` aplican a todos los entornos. Todo valor no confirmado figura como `PENDIENTE DE DEFINICIÓN`.
>
> **Referencia técnica:** el detalle de `Dockerfile`, `docker-compose.yml`, esquema SQL y respaldos vive en [infraestructura.md](infraestructura.md). Esta guía contiene pasos, no duplica ese detalle.
>
> **Alcance:** la Parte 1 describe hechos comprobados en el repositorio local. La Parte 2 describe prerrequisitos y brechas verificadas; no es una guía de despliegue ejecutable hasta que se resuelvan las decisiones pendientes (ver [Parte 2.6](#26-decisiones-pendientes-y-advertencias-producción) e [infraestructura.md, Sección 6](infraestructura.md#6-riesgos-restricciones-y-decisiones-pendientes)). La Parte 3 describe el entorno Ubuntu implementado como laboratorio, sin TLS ni dominio.
>
> **Índice de partes:**
> * [Parte 1 — Reconstrucción y ejecución local [LOCAL]](#parte-1--reconstrucción-y-ejecución-local-local)
> * [Parte 2 — Preparación y reconstrucción en producción [PRODUCCIÓN]](#parte-2--preparación-y-reconstrucción-en-producción-producción)
> * [Parte 3 — Reconstrucción en Server Ubuntu [SERVIDOR UBUNTU]](#parte-3--reconstrucción-en-server-ubuntu-servidor-ubuntu)

---

# Parte 1 — Reconstrucción y ejecución local [LOCAL]

Propósito original conservado: desplegar, inicializar y reconstruir desde cero el entorno completo de **Cipher_Forge** en máquina host (Windows, Linux o macOS) con fines de desarrollo o evaluación tribunalicia de UTU.

## 1. Requisitos previos [LOCAL]

1. **Docker Desktop:** versión 24.0 o superior, motor activo y soporte para Docker Compose v2.
2. **Git:** para clonar el repositorio y gestionar versiones.
3. **Servidor HTTP para el frontend:** VS Code Live Server (puerto `5501` según `.vscode/settings.json`). No usar doble clic sobre los HTML: todas las páginas usan `<script type="module">` (p. ej. `frontend-fotografo/index.html:62`, `frontend-cliente/index.html:62`) y `file://` bloquea los módulos ES.
4. **Puertos locales libres:**
   * **8080:** Apache / Backend API (`backend/docker-compose.yml:10`, `8080:80`).
   * **3306:** MySQL (`backend/docker-compose.yml:85`, `3306:3306`).
   * **8025:** interfaz web Mailpit (buzón de desarrollo).
   * **1025:** entrada SMTP usada por la app (`backend/docker-compose.yml:77-78`).
   *(Detén XAMPP, WampServer o MySQL locales para evitar conflictos).*

## 2. Puesta en marcha local [LOCAL]

### Paso 1: Obtener el código fuente

```bash
git clone https://github.com/NicolasNegretto7/Cipher_Forge.git
cd Cipher_Forge/Gestion-fotografias/backend
```

### Paso 2: Validar archivos de configuración

En `Gestion-fotografias/backend` deben existir:

* `Dockerfile` — receta del contenedor `php:8.2-apache` + FFmpeg + GD + `pdo_mysql` + `zip` (ver [infraestructura.md, Sección 2](infraestructura.md#2-especificación-del-dockerfile-backenddockerfile-compartido-con-notas-producción)).
* `docker-compose.yml` — orquestador de 4 servicios (ver [infraestructura.md, Sección 3](infraestructura.md#3-especificación-de-docker-compose-backenddocker-composeyml-local-y-servidor-ubuntu)).
* `database/schema.sql` — DDL de las 11 tablas iniciales (ver [infraestructura.md, Sección 4.1](infraestructura.md#41-esquema-backenddatabaseschemasql-compartido)).
* `database/migration.sql` — migración idempotente aplicada en cada arranque por `docker-entrypoint.sh:33-38`.
* `php.ini` — inyectado como `99-cipher-forge.ini` (`Dockerfile:26`).
* `docker-entrypoint.sh` — crea `uploads/originals,previews,standard` y aplica la migración.

### Paso 3: Construcción e inicio de contenedores

```bash
docker compose up --build -d
```

> **¿Qué ocurre internamente? [LOCAL — lógica compartida, valores solo-local]**
> 1. Descarga `mysql:8.0`, base `php:8.2-apache` y `axllent/mailpit`.
> 2. Compila `ffmpeg`, `libpng`, `libjpeg`, `libfreetype`, `libzip` y extensiones `gd`, `pdo_mysql`, `zip` (`backend/Dockerfile:5-18`).
> 3. Crea la red puente interna.
> 4. Inicializa `cipher_forge_db` y monta `database/schema.sql` en `/docker-entrypoint-initdb.d/` (solo primera vez del volumen).
> 5. Inicializa `cipher_forge_app` (`DB_HOST=db`, `SMTP_HOST=mailpit`, `FRONTEND_URL=http://localhost:5501/Gestion-fotografias` según `docker-compose.yml:15-40`).
> 6. Inicializa `cipher_forge_worker` (`php cron-backup.php --loop`, `BACKUP_INTERVAL_SEG=86400`, `PURGE_INTERVAL_SEG=3600`).
> 7. Inicializa `cipher_forge_mail` (Mailpit) para interceptar correos de verificación (CF-02 / RF18).
> 8. En cada arranque, `docker-entrypoint.sh` espera MySQL con `mysql --skip-ssl` y aplica `database/migration.sql`.

### Paso 4: Comprobación del estado

```bash
docker compose ps
```

*Salida esperada:*

```text
NAME                    IMAGE                   COMMAND                  SERVICE   STATUS   PORTS
cipher_forge_app        cipher-forge:dev        "docker-php-entrypoi…"   app       Up       0.0.0.0:8080->80/tcp
cipher_forge_db         mysql:8.0               "docker-entrypoint.s…"   db        Up       0.0.0.0:3306->3306/tcp
cipher_forge_worker     cipher-forge:dev        "php cron-backup.php …"  worker    Up
cipher_forge_mail       axllent/mailpit:latest  "/usr/local/bin/mail…"   mailpit   Up       0.0.0.0:8025->8025/tcp, 0.0.0.0:1025->1025/tcp
```

### Paso 5: Verificación de la base de datos

```bash
docker exec -it cipher_forge_db mysql -u cipher_user -p -e "USE cipher_forge; SHOW TABLES;"
```
*(El cliente pedirá la clave por prompt; no se incluye en claro. Credencial de desarrollo en `docker-compose.yml:87-90`, no usar en producción).*

*Las 11 tablas:* `acceso_colecciones`, `backups`, `clientes`, `coleccion_hashtags`, `colecciones`, `favoritos`, `fotografos`, `hashtags`, `multimedia`, `qr_tokens`, `usuarios` (`backend/database/schema.sql:3-87`).

> **Nota de trazabilidad:** tabla `usuarios` como padre de `fotografos` y `clientes` (decisión en `01-requerimientos.md Decisiones técnicas del equipo`; ERD en [02-modelado.md, Sección 2.1](02-modelado.md#21-diagrama-entidad-relación-mermaid-erd)).

### Paso 6: Prueba de conectividad con la API

> **Nota:** endpoint solo técnico de diagnóstico, fuera del alcance funcional. Sin RF asociado en `01-requerimientos.md`.

```bash
curl http://localhost:8080/api/ping
```

*Respuesta esperada (HTTP 200, `src/controllers/HomeController.php:13-20` vía `src/Core/Response.php:11-18`):*

```json
{
  "ok": true,
  "mensaje": "Conexión exitosa con el backend",
  "datos": {
    "servidor": "Cipher_Forge Backend API",
    "estado": "activo",
    "hora": "2026-09-07 12:00:00"
  }
}
```

> **Corrección respecto a versión anterior:** el body `{status,message,timestamp}` no corresponde al código. El formato real es `{ok,mensaje,datos}`.

## 3. Uso de los portales frontend [LOCAL]

Servir la carpeta `Cipher_Forge` con Live Server en `http://localhost:5501` y abrir por HTTP, nunca con doble clic. Usar `localhost` (no `127.0.0.1`) para que `SameSite=Strict` envíe la cookie de sesión (ver `backend/docker-compose.yml:20-24`, `src/helpers/CookieAuth.php:48-62`). Divergencia conocida: el README raíz indica `127.0.0.1:5500`, desactualizado frente a compose y `.vscode/settings.json`.

1. **Portal Fotógrafo:** `http://localhost:5501/Gestion-fotografias/frontend-fotografo/index.html` (registro rol fotógrafo, login, colecciones, subida JPG/MP4, QR, moderación).
2. **Portal Cliente:** `http://localhost:5501/Gestion-fotografias/frontend-cliente/index.html` (explorar públicas, invitación privada con canje, descargas Buena/Alta sin marca de agua).

Detalles verificados:

* Backend base en ambos frontends: `frontend-*/services/config.js:2` → `http://localhost:8080`. Si cambias host/puerto del backend, debes editar esos dos archivos (no hay mecanismo por entorno).
* URLs de QR codifican `FRONTEND_URL` (`src/controllers/ColaborativoController.php:354-424`). Valor efectivo local: `http://localhost:5501/Gestion-fotografias` (`docker-compose.yml:24`). El valor `http://127.0.0.1:5500/...` citado en versiones anteriores de `infraestructura.md` está desactualizado.
* Correo de verificación: abrir `http://localhost:8025` (Mailpit). Gmail/proveedores externos fuera de alcance (`backend/EMAIL_CONFIG.md`).
* Límites reales: imagen JPG ≤30 MB, video MP4 ≤800 MB (`src/validators/MultimediaValidator.php:15-17`); transporte PHP `900M/1G` (`backend/php.ini:10-13`).

## 4. Diagnóstico y mantenimiento local [LOCAL]

```bash
# Logs backend Apache/PHP
docker compose logs -f app

# Logs MySQL
docker compose logs -f db

# Shell backend
docker exec -it cipher_forge_app bash

# Shell BD
docker exec -it cipher_forge_db bash

# Pausar conservando volúmenes
docker compose stop

# Reanudar
docker compose start
```

## 5. Reconstrucción limpia desde cero [LOCAL]

```bash
# 1. Detener y destruir volúmenes (borra BD y uploads persistidos)
docker compose down -v

# 2. Reconstruir y reiniciar
docker compose up --build -d
```

> **Advertencia:** `docker compose down -v` borra el volumen de MySQL y el de uploads. No hay recuperación de fotos ni de base dentro de Docker. Los `.sql` de `backend/backups/` sobreviven en el host, pero los binarios de `uploads` no. En el Server Ubuntu, ver la advertencia de la [Parte 3.8](#38-advertencias-servidor-ubuntu).

## 6. Configuración efectiva local y advertencias [LOCAL]

| Variable / archivo | Valor local efectivo | Fuente |
|---|---|---|
| `DB_HOST/DB_NAME/DB_USER/DB_PASS/DB_PORT` | `db` / `cipher_forge` / `cipher_user` / (ver `docker-compose.yml:15-19,60-64`) / `3306` — credenciales de desarrollo, no usar en producción | `docker-compose.yml:15-19,60-64` |
| `FRONTEND_URL` | `http://localhost:5501/Gestion-fotografias` | `docker-compose.yml:24` |
| `SMTP_HOST/SMTP_PORT/MAIL_FROM/MAIL_FROM_NAME` | `mailpit` / `1025` / `no-reply@cipherforge.local` / `Cipher Forge` | `docker-compose.yml:28-31` |
| `COOKIE_NAME/COOKIE_SECURE/COOKIE_SAMESITE` | `cipher_forge_token` / `false` (HTTP) / `Strict` | `docker-compose.yml:35-37`, `src/helpers/CookieAuth.php:32-62` |
| `BACKUP_INTERVAL_SEG/PURGE_INTERVAL_SEG` | `86400` / `3600` | `docker-compose.yml:65-66` |
| `SISTEMA_ALLOWED_IPS` | No definida → regla por defecto no-pública | `docker-compose.yml:40`, `src/Core/Config.php:97-105` |
| `JWT_SECRET` | No definida → autogenerada en `uploads/.jwt_secret` | `src/Core/Config.php:17-37` |

> **Advertencias locales verificadas (no aptas para producción):**
> * `backend/.env` existe pero no tiene asignaciones activas y el código no lo carga (solo `getenv()`; sin dotenv). La configuración efectiva es `environment:` de compose. `backend/.env.example` además está incompleto (omite `SMTP_*` y `APP_ENV/APP_DEBUG`) y en todo caso es inerte sin dotenv.
> * Credenciales de desarrollo versionadas en compose (ver `docker-compose.yml:15-19,87-90`), no usar en producción.
> * Tres volcados `backend/backups/backup_cipher_forge_*.sql` están versionados en git pese a `backend/.gitignore:11` (`/backups/`). No subir respaldos con datos al repo.

---

# Parte 2 — Preparación y reconstrucción en producción [PRODUCCIÓN]

> **Estado:** escenario solicitado por el cliente, no implementado. Los requisitos vigentes declaran hosting/dominio en producción como excluido ([01-requerimientos.md, Sección 10](01-requerimientos.md#10-alcance-excluido-para-esta-primera-versión), `project_charter.md Alcance excluido`, restricción UTU). Esta parte define prerrequisitos, brechas y trabajo necesario. No sustituye una decisión de alcance. Todo lo no decidido figura como `PENDIENTE DE DEFINICIÓN`. Detalle técnico en [infraestructura.md, Secciones 5 y 6](infraestructura.md#5-arquitectura-y-requisitos-de-producción-producción--brechas-no-hechos).

## 2.1 Prerrequisitos [PRODUCCIÓN]

* Dominio, DNS y terminación TLS delante de Apache. Sin HTTPS no hay producción: el contenedor expone HTTP (`8080:80`) y `COOKIE_SECURE=false` es solo-local.
* Secretos fuera de imagen y repo: `JWT_SECRET`, `DB_*`, `SMTP_*`, `SISTEMA_ALLOWED_IPS`. Valores actuales de compose son de desarrollo.
* MySQL sin puerto público; persistencia gestionada con snapshots; respaldo off-site y restauración probada. Hoy solo hay 3 copias locales en `backend/backups/` (Windows) y un backup one-shot verificado en Ubuntu, sin restore ni off-site confirmados.
* Frontend estático con origen fijo; `API_URL` y `FRONTEND_URL` como parámetros de despliegue (hoy hardcodeadas en `frontend-*/services/config.js:2` en LOCAL; en Ubuntu se sirve por Nginx con `API_URL=""`).
* Proveedor SMTP real con TLS. `src/helpers/Mailer.php:91-146` solo habla SMTP plano; Mailpit no es transporte de producción. `PENDIENTE DE DEFINICIÓN`: proveedor, host, puerto, credenciales.
* Correcciones BLOQUEANTES previas (ver [infraestructura.md, Sección 6](infraestructura.md#6-riesgos-restricciones-y-decisiones-pendientes)): migración sin `DELETE`, CORS con lista cerrada (`public/index.php:80`), sin fuga de `$e->getMessage()` (`public/index.php:102`), sin JWT en `?token=` (`AuthMiddleware.php:87-90`), throttling en auth, validación de longitudes, paginación.

## 2.2 Configuración por entorno [COMPARTIDO → PRODUCCIÓN]

| Clave | LOCAL Windows (hecho) | SERVIDOR UBUNTU (hecho) | PRODUCCIÓN (requerido) |
|---|---|---|---|
| `FRONTEND_URL` | `http://localhost:5501/Gestion-fotografias` | `http://IP_WINDOWS:8080` (ejemplo actual: `http://10.244.239.215:8080`) | `PENDIENTE DE DEFINICIÓN` (origen HTTPS fijo) |
| `API_URL` frontends | `http://localhost:8080` en código | `""` en ambos `config.js`; mismo origen vía Nginx | `PENDIENTE DE DEFINICIÓN` (parámetro de despliegue, no edición manual) |
| `COOKIE_SECURE` | `false` | `false` (HTTP de laboratorio) | `true` (exige HTTPS) |
| `JWT_SECRET` | Ausente (autogenerado en `uploads/.jwt_secret`) | Definido en `backend/.env` (fuera del repo, permisos `600`) | `PENDIENTE DE DEFINICIÓN` (obligatorio, secreto gestionado) |
| `SISTEMA_ALLOWED_IPS` | Ausente (regla no-pública) | `/sistema/*` denegado en Nginx; backend no expuesto a la LAN | `PENDIENTE DE DEFINICIÓN` (CIDRs explícitos; tras proxy exigir `mod_remoteip` o auth) |
| SMTP | Mailpit `mailpit:1025` | Mailpit `127.0.0.1:1025`, UI por túnel SSH | `PENDIENTE DE DEFINICIÓN` (proveedor TLS; requiere cambio en `Mailer.php`) |

## 2.3 Preparación del servidor y despliegue [PRODUCCIÓN]

Sin comandos inventados. Procedimiento ejecutable `PENDIENTE DE DEFINICIÓN` hasta resolver P1-P10. Condiciones verificadas que el procedimiento deberá cumplir:

1. Sin bind mount `.:/var/www/html` en producción; imagen inmutable construida desde `Dockerfile`.
2. `restart` y healthcheck definidos para `app`. El Server Ubuntu ya tiene `restart: unless-stopped`, pero sigue sin healthcheck; en local `app` no tiene `restart`. `/api/ping` hoy no chequea BD.
3. Migración versionada con bloqueo o job único.
4. `AllowOverride` debe permitir `.htaccess` de `uploads/` y `backups/` (`Require all denied`), o migrar la denegación a configuración del servidor. En Ubuntu la denegación de `/backend` y extensiones sensibles ya está en Nginx.
5. `JWT_SECRET` compartido si hay réplicas; volumen `uploads_data` compartido o almacenamiento `PENDIENTE DE DEFINICIÓN`.

## 2.4 Comprobaciones posteriores [PRODUCCIÓN]

Reutilizar las comprobaciones de Parte 1 adaptadas al origen HTTPS real: `SHOW TABLES` (11 tablas), `GET /api/ping` con formato `{ok,mensaje,datos}`, `GET /fotografos/cuota` (fotógrafo 200 / cliente 403 / anónimo 401, `routes.php:32-34`), subida JPG/MP4 dentro de límites, QR con `FRONTEND_URL` de producción, correo real `PENDIENTE DE DEFINICIÓN`, restauración de respaldo `PENDIENTE DE DEFINICIÓN`.

## 2.5 Operación y mantenimiento [PRODUCCIÓN]

* Respaldos: `worker` (`cron-backup.php --loop`) + `POST /sistema/backup` restringido por `SistemaController::restringirALocal` + `SISTEMA_ALLOWED_IPS`. Tras proxy, validar `REMOTE_ADDR` o exigir auth. Detalle en [infraestructura.md, Sección 4.2](infraestructura.md#42-respaldo-diario-y-rotación-rnf5rnf6rnf7-compartido-en-lógica-local-y-servidor-ubuntu-en-almacenamiento) y [Sección 5.8](infraestructura.md#58-copias-de-seguridad-y-recuperación).
* Purga colaborativa 24h: `MultimediaService::purgarExpirados` + `POST /sistema/limpiar-colaborativos`.
* Logs/monitorización: hoy solo `docker compose logs` (más logs de Nginx en Ubuntu). Sin métricas ni alertas. `PENDIENTE DE DEFINICIÓN`.
* Reversión: `PENDIENTE DE DEFINICIÓN` (snapshot DB + volumen uploads + versión de imagen).

## 2.6 Decisiones pendientes y advertencias [PRODUCCIÓN]

Ver [infraestructura.md, Sección 6](infraestructura.md#6-riesgos-restricciones-y-decisiones-pendientes) (P1-P10): alcance, proveedor/entorno, dominios/mismo-site (`SameSite=Strict` exige mismo site), SMTP, volumen/retención, off-site/RPO-RTO, privacidad del directorio (`GET /fotografos` expone email/teléfono), secretos/TLS obligatorios, operador, modelo `/sistema/*`, criterios de aceptación. Ninguna tratada como aprobada.

---

# Parte 3 — Reconstrucción en Server Ubuntu [SERVIDOR UBUNTU]

> **Clasificación:** `SERVIDOR UBUNTU (Server Ubuntu Lab)` es el entorno implementado en la VM `Ubuntu-Server-Lab`. Se usa como demo/laboratorio en una LAN. **No es PRODUCCIÓN:** no tiene TLS, dominio, backups off-site confirmados ni alta disponibilidad.
>
> **Runbook completo:** [manual-migracion-serverubuntu.md](manual-migracion-serverubuntu.md). Esta parte ordena el trabajo y las verificaciones; no reemplaza el manual ni duplica cada comando.

## 3.1 Topología y requisitos [SERVIDOR UBUNTU]

| Elemento | Valor implementado |
|---|---|
| Host | Windows con VirtualBox; IP WiFi `10.244.239.215` |
| VM | `Ubuntu-Server-Lab`; IP NAT `10.0.2.50`; SSH `127.0.0.1:2222` |
| Entrada web | `http://10.244.239.215:8080` → port forwarding `8080` → `80` |
| Nginx | `:80` en la VM; estáticos + proxy a `127.0.0.1:8080` |
| Proyecto | `/opt/cipher-forge/Gestion-fotografias` |
| Datos | volúmenes `backend_db_data` y `backend_uploads_data` |
| Usuario SSH | `sysadmin` (en este entorno) |

Requisitos: VirtualBox con la VM encendida, Docker + Compose dentro de Ubuntu, Nginx, SSH con reenvío de puertos, celular y PC en la misma WiFi, puerto `8080` permitido en el firewall de Windows para `LocalSubnet`.

**Dependencia de Windows:** en NAT, Windows debe quedar encendido porque aporta la IP de la WiFi y el port forwarding. La VM por sí sola no es accesible desde el celular. La reserva DHCP de `10.244.239.215` y el autostart de la VM no están confirmados.

## 3.2 Exportar desde Windows [LOCAL → SERVIDOR UBUNTU]

1. Verificar el stack y anotar conteos (`colecciones`, `multimedia`, usuarios).
2. Detener `app` y `worker` para congelar escrituras.
3. Generar el dump con `mysqldump`: [manual, Sección 3.3](manual-migracion-serverubuntu.md#33-generar-el-dump-de-la-base).
4. Exportar `uploads/` (originales, previews, standard): [Sección 3.4](manual-migracion-serverubuntu.md#34-exportar-fotos-y-videos).
5. Copiar `backend/backups/` y conservar los backups viejos de Windows: [Sección 3.5](manual-migracion-serverubuntu.md#35-respaldos).
6. Transferir por `scp` a una carpeta fuera del web root: [Sección 3.6](manual-migracion-serverubuntu.md#36-transferir-a-ubuntu).

> No borrar los datos de Windows hasta completar el corte y las pruebas. El manual deja Windows detenido, no destruido ([Sección 3.7](manual-migracion-serverubuntu.md#37-dejar-windows-detenido)).

## 3.3 Configurar el proyecto en Ubuntu [SERVIDOR UBUNTU]

1. Verificar la transferencia: [manual, Sección 4.1](manual-migracion-serverubuntu.md#41-verificar-la-transferencia).
2. Crear `backend/.env` con `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `JWT_SECRET` y `FRONTEND_URL=http://IP_WINDOWS:8080`: [Sección 4.2](manual-migracion-serverubuntu.md#42-crear-el-archivo-env). Permisos `600`.
3. Aplicar el `docker-compose.yml` corregido: [Sección 4.3](manual-migracion-serverubuntu.md#43-corregir-docker-composeyml). **El repo local no tiene esta versión:** publica `app` solo en `127.0.0.1:8080`, no publica `db` ni Mailpit y toma los secretos desde `.env`.
4. Ajustar permisos: [Sección 4.4](manual-migracion-serverubuntu.md#44-permisos-de-archivos).

> El compose corregido y `API_URL=""` en los dos `config.js` están aplicados **solo en Ubuntu**, no en el repo local. Si se reconstruye la VM desde el repo tal cual, hay que repetir esos cambios.

## 3.4 Restaurar base, uploads y respaldos [SERVIDOR UBUNTU]

1. Levantar solo `db`: [manual, Sección 5.1](manual-migracion-serverubuntu.md#51-levantar-solo-la-base).
2. Importar el dump: [Sección 5.2](manual-migracion-serverubuntu.md#52-importar-el-dump).
3. Levantar `app` y `worker`: [Sección 5.3](manual-migracion-serverubuntu.md#53-levantar-la-aplicación-y-el-worker).
4. Restaurar fotos y videos: [Sección 5.4](manual-migracion-serverubuntu.md#54-restaurar-fotos-y-videos).
5. Verificar permisos de respaldos (`33:33`, `775`): [Sección 5.5](manual-migracion-serverubuntu.md#55-verificar-permisos-de-respaldos).
6. Generar un respaldo de prueba: [Sección 5.6](manual-migracion-serverubuntu.md#56-generar-un-respaldo-de-prueba).

## 3.5 Nginx, firewall y port forwarding [SERVIDOR UBUNTU]

1. Crear el sitio con `root /opt/cipher-forge/Gestion-fotografias`, redirección a la landing, estáticos y proxy de `/auth`, `/fotografos?`, `/colecciones`, `/multimedia`, `/invitaciones`, `/hashtags`, `/favoritos`, `/colaborativo`, `/qr` y `/api`: [manual, Sección 6.1](manual-migracion-serverubuntu.md#61-crear-el-sitio). La configuración fue verificada como idéntica a la del manual.
2. Activar el sitio: [Sección 6.2](manual-migracion-serverubuntu.md#62-activar-el-sitio).
3. Probar desde Ubuntu con `curl`: [Sección 6.3](manual-migracion-serverubuntu.md#63-probar-desde-ubuntu).
4. Abrir el firewall de Ubuntu solo para lo necesario: [Sección 8.1](manual-migracion-serverubuntu.md#81-firewall-de-ubuntu).
5. Configurar el port forwarding NAT `8080 → 80` y la regla de Windows: [Sección 2.1](manual-migracion-serverubuntu.md#21-verificar-la-red-y-el-port-forwarding-tu-caso-nat).
6. Probar desde Windows y desde el celular: [Sección 8.3](manual-migracion-serverubuntu.md#83-probar-desde-windows-y-desde-otra-pc) y [Sección 8.4](manual-migracion-serverubuntu.md#84-probar-desde-el-celular).

Nginx conserva el puerto público con `Host $http_host`; si se usa `$host`, el QR puede perder `:8080` y fallar. `client_max_body_size 900m` y timeouts de `600s` son necesarios para videos de hasta 800 MB.

## 3.6 QR y validación desde el celular [SERVIDOR UBUNTU]

1. Confirmar `FRONTEND_URL` en `backend/.env`: `http://IP_WINDOWS:8080`.
2. En `frontend-cliente/services/config.js` y `frontend-fotografo/services/config.js`, dejar `API_URL = ""` para que las llamadas vayan al mismo origen de Nginx.
3. Recrear el contenedor `app` para que lea el `.env`: [manual, Sección 7.4](manual-migracion-serverubuntu.md#74-recrear-el-contenedor-para-que-lea-el-nuevo-env).
4. Generar un QR nuevo: [Sección 7.5](manual-migracion-serverubuntu.md#75-generar-un-qr-nuevo). Los QR viejos no se actualizan.
5. Probar el escaneo desde un celular real conectado a la misma WiFi.

> **Validado el 28/10/2026:** el escaneo del QR desde un celular real funciona correctamente. La URL esperada es `http://10.244.239.215:8080/frontend-cliente/pages/colaborativo.html?token=...`. Si cambia la IP de Windows, hay que actualizar `FRONTEND_URL` y regenerar los QR.

## 3.7 Operación y mantenimiento [SERVIDOR UBUNTU]

| Tarea | Referencia |
|---|---|
| Ver estado, logs, reiniciar, detener sin borrar datos | [manual, Sección 11.1](manual-migracion-serverubuntu.md#111-comandos-del-día-a-día) |
| Actualizar código | [Sección 11.2](manual-migracion-serverubuntu.md#112-actualizar-el-código) |
| Cambiar IP o dominio | [Sección 11.3](manual-migracion-serverubuntu.md#113-cambiar-la-ip-o-el-dominio) |
| Reinicio del servidor | [Sección 11.4](manual-migracion-serverubuntu.md#114-reinicio-del-servidor) |
| Backup de la app y verificación | [Secciones 10.1-10.2](manual-migracion-serverubuntu.md#101-qué-hace-el-worker) |
| Copia off-site | [Sección 10.3](manual-migracion-serverubuntu.md#103-copiar-los-respaldos-fuera-del-servidor) |
| Restore de prueba | [Sección 10.4](manual-migracion-serverubuntu.md#104-restaurar-un-backup-de-la-app-en-una-base-de-prueba) |
| Backup completo adicional | [Sección 10.6](manual-migracion-serverubuntu.md#106-recomendación-backup-completo-adicional) |
| Mailpit por túnel SSH | `ssh -p 2222 -L 8025:127.0.0.1:8025 sysadmin@127.0.0.1` y abrir `http://localhost:8025` |

Estado de respaldos: backup one-shot ejecutado y verificado; ejecución programada del `worker` no confirmada; restore y off-site documentados pero no ejecutados. Detalle en [infraestructura.md, Sección 4.3](infraestructura.md#43-respaldos-en-el-server-ubuntu-estado-actual).

## 3.8 Advertencias [SERVIDOR UBUNTU]

> **`docker compose down -v` es destructivo:** borra la base y el volumen de uploads. Los `.sql` de `backend/backups/` sobreviven porque viven en el filesystem de la VM, pero las fotos no. No ejecutarlo sin backup verificado de base y uploads.
>
> **No es producción:** HTTP sin TLS, sin dominio, sin backups off-site confirmados, sin restore probado y sin autostart de VM confirmado. `PRODUCCIÓN` sigue sin implementar.
>
> **IP y DHCP:** `10.244.239.215` es la IP actual; la reserva DHCP no está confirmada. Si cambia, hay que actualizar `FRONTEND_URL`, el port forwarding y regenerar los QR.
>
> **Rate limit detrás de Nginx:** sin `X-Forwarded-For`/`real_ip`, la IP del cliente se ve como `127.0.0.1` y el límite de autenticación se comparte entre todos los usuarios.
>
> **`/sistema/*`:** se deniega en Nginx, no en la aplicación. Si se accede al backend sin pasar por Nginx, la protección no aplica.

## 3.9 Tabla comparativa de entornos

| Aspecto | LOCAL Windows | SERVIDOR UBUNTU (Server Ubuntu Lab) | PRODUCCIÓN |
|---|---|---|---|
| Estado | Implementado | Implementado como demo/laboratorio | No implementado |
| Entrada | Apache `:8080` | Windows `:8080` → NAT → Nginx `:80` → app `127.0.0.1:8080` | HTTPS con dominio |
| Frontend | Live Server `:5501`, `API_URL=http://localhost:8080` | Nginx sirve estáticos, `API_URL=""` | Origen fijo HTTPS |
| `FRONTEND_URL` | `http://localhost:5501/Gestion-fotografias` | `http://IP_WINDOWS:8080` | Dominio HTTPS |
| Base de datos | `db` con `3306` publicado | `db` sin puerto publicado | Gestionada, sin puerto público |
| Mailpit | Publicado en `8025/1025` | Solo `127.0.0.1`, túnel SSH | SMTP real con TLS |
| TLS | No | No | Obligatorio |
| Backups | 3 copias locales; sin restore probado | One-shot verificado; programado/off-site/restore no confirmados | Off-site + restore probado + RPO/RTO |
| QR | `localhost`, no sirve para celular | Validado desde celular el 28/10/2026 | Dominio HTTPS |

---

## Trazabilidad

* Requisitos: [01-requerimientos.md, Sección 9](01-requerimientos.md#9-alcance-incluido), [Sección 10](01-requerimientos.md#10-alcance-excluido-para-esta-primera-versión), [Sección 11](01-requerimientos.md#11-requerimientos-funcionales) y [Sección 12](01-requerimientos.md#12-requerimientos-no-funcionales) (RF/RNF, EP4/EP7), restricción UTU.
* Arquitectura/datos: [02-modelado.md, Sección 1](02-modelado.md#1-arquitectura-propuesta-del-sistema) y [Sección 2](02-modelado.md#2-modelado-de-datos-diagrama-entidad-relación); [infraestructura.md, Secciones 1-4](infraestructura.md#1-visión-general-de-la-infraestructura-compartido-en-lógica-local-en-valores).
* Seguridad/privacidad: [03-seguridad.md](03-seguridad.md) (STRIDE, Términos, PSI; [Sección 4.1](03-seguridad.md#41-protección-de-endpoints-de-administración-sistema-cf-08--cc-14) desactualizado sobre `/sistema/*`), Ley 18.331.
* Cambios: `08_control_de_cambios.md` CC-11 (worker), CC-14 (postergado `/sistema/*`), CC-16 (php.ini), CC-27 (30 MB); `09_control_de_cambios_tecnicos.md` CCT-11/CCT-16.
* Migración Ubuntu: [manual-migracion-serverubuntu.md](manual-migracion-serverubuntu.md) (runbook completo, Nginx, backup/restore y QR validado).
* Hallazgos: `backend/important.md` H01/H02/H09 resueltos, H03/H04/H10 con estado desactualizado; `backend/SISTEMA_LOCAL.md`; `backend/EMAIL_CONFIG.md`; `backend/Done.md`; `backend/FAILS-TESTED.md`.

> Estado documental: LOCAL Windows y SERVIDOR UBUNTU reflejan el código/configuración inspeccionados y las pruebas declaradas por el equipo; PRODUCCIÓN sigue siendo un conjunto de brechas no implementadas. Sin ejecución propia del stack Docker ni pruebas propias. La validación del QR desde un celular real (28/10/2026) fue reportada por el equipo.
