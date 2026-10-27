# Manual completo: mover Cipher Forge a Ubuntu Server y usar el QR desde el celular

**Proyecto:** Gestion-fotografias / Cipher Forge  
**Última actualización:** 26/10/2026  
**Objetivo:** mover el stack completo desde Windows + Docker Desktop a un Ubuntu Server, conservar la base de datos, las fotos/videos y los respaldos, y dejar el QR funcionando para un celular conectado a la misma WiFi.

**Tiempo estimado:** 2 a 4 horas. Docker ya está instalado; la mayor parte del tiempo suele ser la transferencia de fotos/videos.

**Nivel:** intermedio. El manual está pensado para que lo hagas vos, siguiendo los pasos en orden y verificando el resultado de cada etapa.

> **Tu entorno (importante):** la VM de VirtualBox `Ubuntu-Server-Lab` tiene el adaptador 1 en **NAT**, no en Bridged. El celular **no** llega a la IP interna de la VM (`10.0.2.50`). Llega a la PC Windows por la IP de la WiFi y el puerto reenviado:
>
> ```text
> http://IP_WINDOWS:8080
> ```
>
> En tu caso, `IP_WINDOWS` es `10.244.239.215` (verificalo con `ipconfig`; puede cambiar si no reservás la IP). El port forwarding de VirtualBox traduce `host 8080 -> guest 80`. El SSH está en `127.0.0.1:2222` y se usa solo desde Windows. La variante **Bridged** está documentada en la sección 8.6 y en el apéndice B, por si algún día cambiás el adaptador.

---

## 0. Qué vas a lograr

Al final vas a tener esta arquitectura:

```text
Celular / PC en la misma WiFi
            |
            |  http://IP_WINDOWS:8080
            v
  PC Windows (WiFi)
  VirtualBox NAT: host 8080 -> guest 10.0.2.50:80
  Firewall de Windows: permitir TCP 8080
            |
            v
  Ubuntu Server (VM)
  IP interna NAT: 10.0.2.50 (no se usa desde el celular)

  Nginx :80
    /  -> redirige a /lading-page/paginaprincipal.html
    /lading-page/... -> landing estática
    /frontend-cliente/...  -> archivos estáticos
    /frontend-fotografo/... -> archivos estáticos
    /auth, /colecciones, /multimedia, /qr, ... -> proxy

  Docker Compose
    app     (PHP + Apache)  -> 127.0.0.1:8080
    worker  (backups + limpieza)
    db      (MySQL 8.0)     -> solo red interna
    mailpit (correo de desarrollo, solo localhost)

  Volúmenes Docker: db_data, uploads_data
  Carpeta del host: backend/backups/
```

El celular y la PC entran por `http://IP_WINDOWS:8080`. VirtualBox reenvía ese puerto al puerto 80 de la VM, donde está Nginx. `http://IP_WINDOWS:8080/` redirige a la landing (`/lading-page/paginaprincipal.html`); desde ahí se entra al frontend de cliente o de fotógrafo. El QR contiene `http://IP_WINDOWS:8080/frontend-cliente/pages/colaborativo.html?token=...`, no `localhost` ni `10.0.2.50`.

> **Si algún día pasás a Bridged:** la VM tendrá una IP de la LAN, Nginx se accede directo en `http://IP_UBUNTU` (puerto 80) y no necesitás el puerto 8080 de Windows. El resto del manual es igual; cambiá las URLs y `FRONTEND_URL`.

> La carpeta se llama `lading-page` (con una sola “d”), tal como está en el proyecto. No la renombres sin actualizar los enlaces.

> **Alcance:** este manual mueve el stack completo. Si solo querés mover MySQL y dejar el backend en Windows, la migración de datos es parecida, pero el problema del QR no se resuelve y la sesión con cookies puede fallar entre hosts distintos. Para este proyecto conviene mover todo.

### Convenciones usadas en el manual

Reemplazá estos valores por los tuyos:

| Placeholder | Significado | Ejemplo |
|---|---|---|
| `IP_WINDOWS` | IP de la PC Windows en la WiFi; es la que usa el celular | `10.244.239.215` |
| `PUERTO_PUBLICO` | Puerto del port forwarding de Nginx en VirtualBox | `8080` |
| `IP_VM` | IP interna de la VM en la red NAT; **no** se usa desde el celular | `10.0.2.50` |
| `USUARIO` | Usuario de Ubuntu con permisos de `sudo` | `ivan` |
| `RUTA` | Carpeta del proyecto en Ubuntu | `/opt/cipher-forge/Gestion-fotografias` |
| `PASSWORD_APP` | Contraseña nueva para el usuario MySQL de la app | `CipherApp_2026_xxx` |
| `PASSWORD_ROOT` | Contraseña nueva para el root de MySQL | `CipherRoot_2026_xxx` |

En las URLs, lo que escribís desde el celular o desde otra PC es `http://IP_WINDOWS:PUERTO_PUBLICO`. En tu caso: `http://10.244.239.215:8080`. La IP `IP_VM` (`10.0.2.50`) solo existe dentro de la red NAT de VirtualBox.

Los comandos de Windows van en **PowerShell**. Los de Ubuntu van en **bash**. Para entrar a Ubuntu desde Windows, usá el forward de SSH:

```powershell
ssh -p 2222 USUARIO@127.0.0.1
```

---

## 1. Antes de tocar nada

### 1.1 Inventario de lo que hay que mover

| Componente | Dónde está hoy | Cómo se mueve |
|---|---|---|
| Base de datos | Volumen Docker `backend_db_data` | Dump lógico con `mysqldump` |
| Fotos y videos | Volumen Docker `backend_uploads_data` | Copia de la carpeta `/var/www/html/uploads` |
| Respaldos `.sql` | Carpeta `backend/backups/` del proyecto | Copia normal de archivos |
| Código | Carpeta `Gestion-fotografias/` | Copia normal de archivos |
| Configuración | `backend/.env` y `backend/docker-compose.yml` | Se recrea en Ubuntu |
| Correos de verificación | Mailpit | Se consulta por túnel SSH; no se publica a la LAN |

### 1.2 Requisitos

- Ubuntu Server 22.04 o 24.04 en la VM `Ubuntu-Server-Lab`, con acceso `sudo` y SSH.
- Docker Engine + Docker Compose plugin. **En tu caso ya están instalados**; el manual incluye la verificación.
- Nginx instalado en Ubuntu.
- VirtualBox con el adaptador 1 en NAT y la regla de port forwarding `Nginx` (`host 8080 -> guest 80`).
- La PC Windows encendida durante la demo: es la puerta de entrada del celular.
- Espacio en disco suficiente: al menos el doble del tamaño actual de `uploads`, más la base y los respaldos.
- La PC con Windows y el stack actual funcionando.
- Un celular con cámara y navegador, conectado a la **misma WiFi que la PC Windows**.
- Windows 10/11 con cliente SSH (`ssh -V`). Si no lo tiene, se puede usar WinSCP o un pendrive.

### 1.3 Decisiones que tenés que tomar antes

1. **Dirección pública estable.** En tu caso la URL la define la IP de Windows (`IP_WINDOWS`) y el puerto `8080`. Reservá esa IP en el router o en el DHCP para que el QR no deje de funcionar. La VM puede seguir en NAT con IP interna `10.0.2.50`; esa IP no se usa desde el celular.
2. **¿Dominio o solo IP?** Para la demo en LAN alcanza con `http://IP_WINDOWS:8080`. Si el servidor va a estar en internet, conviene un dominio y HTTPS; al final hay una sección sobre eso.
3. **Port forwarding de VirtualBox.** La regla `Nginx` debe quedar `host 8080 -> guest 80`. La regla `SSH` queda en `127.0.0.1:2222 -> guest 22` y se usa solo desde Windows.
4. **Contraseñas nuevas.** No reutilices `cipher_password` ni la clave de desarrollo. Anotá `PASSWORD_ROOT` y `PASSWORD_APP` en un lugar seguro.
5. **Ventana de mantenimiento.** Durante la exportación no debe haber usuarios subiendo fotos ni creando datos, porque el dump es una foto del momento.

### 1.4 Reglas de oro

- **No uses `docker compose down -v`** en Windows hasta terminar y validar la migración. Ese comando borra los volúmenes `backend_db_data` y `backend_uploads_data`.
- **No copies la carpeta `/var/lib/mysql` con MySQL corriendo.** Se puede corromper. Usá `mysqldump`.
- **No borres el stack de Windows** hasta que el de Ubuntu esté probado. Mientras tanto, Windows es tu plan de rollback.
- **No dejes MySQL (`3306`) ni Mailpit (`8025`) abiertos a internet.** En este manual quedan solo en localhost o en la red interna de Docker.
- **Un solo 8080 a la vez.** En tu PC, Docker Desktop y VirtualBox comparten el puerto 8080 (IPv6 vs IPv4). No tengas las dos apps publicadas al mismo tiempo para no confundir `localhost:8080` con `127.0.0.1:8080`.

---

## 2. Preparar el Ubuntu Server

### 2.1 Verificar la red y el port forwarding (tu caso: NAT)

Tu VM no está en Bridged: el adaptador 1 está en **NAT**. La VM tiene una IP interna (`10.0.2.50`) que **el celular no puede alcanzar**. El celular habla con la PC Windows, y VirtualBox reenvía el puerto.

**Paso 1 — IP de Windows (la que usa el celular).** En PowerShell:

```powershell
ipconfig
```

Buscá la IP de la interfaz Wi-Fi. En tu caso es `10.244.239.215`. Anotá también la máscara: es `/22`, no `/24`. Si podés, reservá esa IP en el router para que no cambie.

**Paso 2 — Entrar a Ubuntu.** El SSH de la VM está bindeado a `127.0.0.1:2222` (solo desde Windows):

```powershell
ssh -p 2222 USUARIO@127.0.0.1
```

**Paso 3 — Ver la IP interna de la VM.** Dentro de Ubuntu:

```bash
hostname -I
```

Debe mostrar `10.0.2.50`. Esa IP solo sirve dentro de VirtualBox; **no la pongas en el QR ni en `FRONTEND_URL`**. Si muestra otra IP (por ejemplo `10.0.2.15`), actualizá el `Guest IP` de la regla `Nginx` para que coincida, o configurá `10.0.2.50` como IP fija en netplan.

**Paso 4 — Ajustar la regla Nginx en VirtualBox.** En la GUI: Settings → Network → Adapter 1 → Advanced → Port Forwarding. La regla `Nginx` debe quedar así:

| Campo | Valor |
|---|---|
| Name | `Nginx` |
| Protocol | `TCP` |
| Host IP | vacío (todas las interfaces) |
| Host Port | `8080` |
| Guest IP | `10.0.2.50` |
| Guest Port | `80` |

El `Guest Port` actual es `8080`; cambialo a `80`. La regla hoy es `Nginx,tcp,,8080,10.0.2.50,8080` y tiene que quedar `Nginx,tcp,,8080,10.0.2.50,80`. Si lo dejás en `8080`, Nginx tendría que escuchar en `8080` y chocaría con el puerto interno de Docker (`127.0.0.1:8080`).

> Las reglas `SSH` (`127.0.0.1:2222`) y `phpMyAdmin` (`127.0.0.1:8081`) quedan como están. Solo cambia el `Guest Port` de la regla `Nginx`.

> Si la VM está corriendo, VirtualBox puede pedir reiniciarla para aplicar el cambio. Guardá la regla y reiniciá la VM si el puerto no responde.

Si preferís hacerlo por consola, con la VM apagada:

```powershell
$vbox = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
& $vbox modifyvm "Ubuntu-Server-Lab" --natpf1 delete "Nginx"
& $vbox modifyvm "Ubuntu-Server-Lab" --natpf1 "Nginx,tcp,,8080,10.0.2.50,80"
```

> Si cambiás la IP interna de la VM, actualizá el `Guest IP` de la regla. Si cambiás el `Host Port`, actualizá también `FRONTEND_URL` y los QR.

**Paso 5 — Firewall de Windows.** La regla de VirtualBox ya está permitida en el perfil `Public`. Si el celular no entra, comprobá que el puerto 8080 esté permitido (PowerShell como administrador):

```powershell
New-NetFirewallRule -DisplayName "Cipher Forge Nginx 8080" `
  -Direction Inbound -Protocol TCP -LocalPort 8080 `
  -Action Allow -Profile Public -RemoteAddress LocalSubnet
```

> La WiFi `Ceibal-5GHz` está en perfil **Public**. No la cambies a Private solo para esto; la regla de firewall alcanza.

> **Ojo con el puerto 8080 en Windows:** Docker Desktop ya lo está usando en IPv6 y VirtualBox lo usa en IPv4. Por eso `127.0.0.1:8080` va al forward de Ubuntu, pero `localhost:8080` puede resolver a Docker y mostrarte la app vieja. Para probar Ubuntu usá siempre `127.0.0.1:8080` o `IP_WINDOWS:8080`, y no tengas las dos apps corriendo al mismo tiempo.

**Alternativa Bridged:** si cambiás el adaptador 1 a Bridged, la VM obtiene una IP de la LAN y el celular entra directo a `http://IP_UBUNTU` por el puerto 80. En ese caso no uses el 8080 de Windows ni el `10.0.2.50`.

Si el Ubuntu es un VPS:

- La IP será pública. El celular no necesita estar en la misma WiFi; entrará por internet.
- Usá dominio y HTTPS. No publiques MySQL ni Mailpit.

### 2.2 Actualizar el sistema e instalar lo básico

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg openssh-server nginx unzip rsync
```

Verificá que Nginx quedó instalado:

```bash
nginx -v
```

Todavía no lo configures; primero migramos los datos.

> Si ya usás Nginx para otro sitio, no borres su configuración sin revisar. El paso 6.2 asume un Nginx limpio: hacé un backup de `/etc/nginx/sites-enabled/` antes de tocar nada.

### 2.3 Verificar Docker (ya instalado en tu caso)

En tu caso Docker ya está instalado. Comprobá la versión y que arranque con el sistema:

```bash
docker --version
docker compose version
sudo systemctl is-enabled docker
```

Probá que tu usuario pueda usarlo sin `sudo`:

```bash
docker ps
```

> Si `docker ps` da `permission denied`, ejecutá `sudo usermod -aG docker $USER`, cerrá la sesión SSH (`exit`), volvé a entrar con `ssh -p 2222 USUARIO@127.0.0.1` y repetí `docker ps`.

Si Docker no estuviera instalado, estos son los pasos desde el repositorio oficial:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Habilitar Docker al arranque y dar permiso a tu usuario:

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**Cerrá la sesión SSH y volvé a entrar** para que el cambio de grupo tenga efecto. Desde Ubuntu:

```bash
exit
```

Desde PowerShell:

```powershell
ssh -p 2222 USUARIO@127.0.0.1
```

Verificá:

```bash
docker run --rm hello-world
docker compose version
```

### 2.4 Crear la carpeta del proyecto

```bash
sudo mkdir -p /opt/cipher-forge
sudo chown -R $USER:$USER /opt/cipher-forge
```

La carpeta final va a quedar en:

```text
/opt/cipher-forge/Gestion-fotografias/
```

### 2.5 Zona horaria (opcional, recomendado)

Para que los respaldos y los logs tengan la hora correcta:

```bash
sudo timedatectl set-timezone America/Montevideo
timedatectl
```

---

## 3. Exportar todo desde Windows

### 3.1 Verificar el stack actual y anotar los conteos

En PowerShell:

```powershell
cd "C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias\backend"

docker compose ps
```

Anotá los conteos actuales. Te van a servir para comparar después de la restauración:

```powershell
& docker compose exec db mysql -ucipher_user -pcipher_password -e "SELECT COUNT(*) FROM cipher_forge.usuarios; SELECT COUNT(*) FROM cipher_forge.multimedia; SELECT COUNT(*) FROM cipher_forge.colecciones;"
```

> Si tu contraseña de `cipher_user` no es `cipher_password`, cambiá el valor. La contraseña por defecto del proyecto es `cipher_password`.

Anotá también el tamaño de `uploads`:

```powershell
docker compose exec -T app sh -c 'du -sh /var/www/html/uploads'
```

### 3.2 Detener la aplicación y el worker

Esto evita que se escriban datos nuevos mientras se genera el dump:

```powershell
docker compose stop app worker
```

La base (`db`) sigue corriendo. No la detengas.

> A partir de acá, no uses la aplicación de Windows para crear colecciones, subir fotos ni registrarte. Si necesitás volver a usarla antes de terminar la migración, tenés que repetir el dump antes del corte final.

> **Puerto 8080 compartido:** Docker Desktop y VirtualBox se reparten el 8080 (IPv6 vs IPv4). Al detener `app` liberás el lado de Docker; el forward de Ubuntu sigue en IPv4. No tengas las dos apps publicadas al mismo tiempo y, para probar Ubuntu, usá `127.0.0.1:8080` o `IP_WINDOWS:8080`.

### 3.3 Generar el dump de la base

El dump se genera **dentro del contenedor** y después se copia al host. Así evitamos el problema de encoding de PowerShell, que puede guardar el `.sql` en UTF-16 y romper la importación.

```powershell
& docker compose exec db bash -c 'MYSQL_PWD=cipher_password mysqldump -ucipher_user --single-transaction --routines --triggers --no-tablespaces --databases cipher_forge > /tmp/cipher_forge.sql'
docker compose cp db:/tmp/cipher_forge.sql .\cipher_forge_migracion.sql
```

Verificá que el archivo exista y tenga tamaño razonable:

```powershell
Get-Item .\cipher_forge_migracion.sql | Select-Object Name,Length,LastWriteTime
Get-Content .\cipher_forge_migracion.sql -TotalCount 15
```

El archivo debe empezar con comentarios de `mysqldump` y contener `CREATE DATABASE` / `USE cipher_forge`.

### 3.4 Exportar fotos y videos

El contenido real de `uploads` está en el volumen `backend_uploads_data`, no en la carpeta `backend\uploads` del proyecto. Copialo desde el contenedor:

```powershell
New-Item -ItemType Directory -Force .\uploads_export | Out-Null
docker compose cp app:/var/www/html/uploads/. .\uploads_export
```

Verificá cantidad de archivos y tamaño:

```powershell
$archivos = Get-ChildItem .\uploads_export -Recurse -File
"Archivos: $($archivos.Count)"
"Tamaño GB: {0:N2}" -f (($archivos | Measure-Object Length -Sum).Sum / 1GB)
```

Si el número es 0 y vos sabés que hay fotos, revisá que hayas copiado desde `app` y no desde la carpeta vacía del host.

### 3.5 Respaldos

Los respaldos `.sql` están en:

```text
C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias\backend\backups\
```

No los borres: van a viajar junto con el proyecto. Verificalos:

```powershell
Get-ChildItem .\backups | Select-Object Name,Length,LastWriteTime
```

### 3.6 Transferir a Ubuntu

Podés usar `scp`, WinSCP o un pendrive. Como el SSH de tu VM está en `127.0.0.1:2222`, usá `-p` en `ssh` y `-P` en `scp`:

```powershell
# Crear una carpeta de transferencia FUERA del web root
ssh -p 2222 USUARIO@127.0.0.1 "mkdir -p /opt/cipher-forge/transfer"

scp -P 2222 -r "C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias" USUARIO@127.0.0.1:/opt/cipher-forge/
scp -P 2222 .\cipher_forge_migracion.sql USUARIO@127.0.0.1:/opt/cipher-forge/transfer/
scp -P 2222 -r .\uploads_export USUARIO@127.0.0.1:/opt/cipher-forge/transfer/
```

> `ssh` usa `-p` minúscula; `scp` usa `-P` mayúscula. El destino es `127.0.0.1` porque la regla SSH de VirtualBox está bindeada a localhost. Si algún día usás Bridged, el destino pasa a ser `USUARIO@IP_UBUNTU` sin puerto.

> Si `uploads_export` pesa muchos GB, la red NAT de VirtualBox puede ser lenta. Un pendrive o una carpeta compartida de VirtualBox suele ser más rápido.

> El dump y `uploads_export` van a `/opt/cipher-forge/transfer/`, **fuera** de la carpeta que sirve Nginx. Si los dejás dentro de `Gestion-fotografias`, las fotos exportadas podrían quedar accesibles por HTTP.

> **Ojo con `scp -r`:** si `/opt/cipher-forge/Gestion-fotografias` ya existe, `scp` puede crear una subcarpeta duplicada (`Gestion-fotografias/Gestion-fotografias`). Verificá con `ls -la /opt/cipher-forge/Gestion-fotografias` antes de seguir.

> El `scp -r` también copia el `backend/.env` de Windows. Ese archivo está lleno de comentarios y no tiene las variables necesarias; en el paso 4.2 lo vas a reemplazar por completo. No lo reutilices.

La carpeta en Ubuntu debe quedar así:

```text
/opt/cipher-forge/
├── Gestion-fotografias/
│   ├── backend/
│   │   ├── backups/
│   │   ├── database/
│   │   ├── public/
│   │   ├── src/
│   │   ├── docker-compose.yml
│   │   └── ...
│   ├── frontend-cliente/
│   ├── frontend-fotografo/
│   ├── lading-page/
│   └── docs/
└── transfer/
    ├── cipher_forge_migracion.sql
    └── uploads_export/
```

Protegé la carpeta de transferencia (desde PowerShell, contra Ubuntu):

```powershell
ssh -p 2222 USUARIO@127.0.0.1 "chmod 700 /opt/cipher-forge/transfer"
```

### 3.7 Dejar Windows detenido

Dejá `app` y `worker` detenidos hasta terminar la migración. Si los volvés a levantar y se generan datos nuevos, esos datos no van a estar en el dump de Ubuntu. En ese caso, repetí el dump antes del corte final.

Windows queda como respaldo para rollback. No borres sus volúmenes todavía.

---

## 4. Configurar el proyecto en Ubuntu

### 4.1 Verificar la transferencia

```bash
cd /opt/cipher-forge/Gestion-fotografias
ls -la
ls -la backend/backups
du -sh /opt/cipher-forge/transfer/uploads_export
ls -lh /opt/cipher-forge/transfer/cipher_forge_migracion.sql
```

Comprobá que existan:

- `backend/docker-compose.yml`
- `backend/backups/`
- `/opt/cipher-forge/transfer/cipher_forge_migracion.sql`
- `/opt/cipher-forge/transfer/uploads_export/` con archivos

### 4.2 Crear el archivo `.env`

El `.env` real no se versiona. Si copiaste la carpeta completa, el `.env` de Windows también viajó, pero está lleno de comentarios y no tiene las variables que necesita Compose en Ubuntu. Reemplazá todo su contenido:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
nano .env
```

Borrá todo lo que haya y pegá:

```env
# Base de datos
MYSQL_ROOT_PASSWORD=PASSWORD_ROOT
MYSQL_DATABASE=cipher_forge
MYSQL_USER=cipher_user
MYSQL_PASSWORD=PASSWORD_APP

# Firma de los JWT
JWT_SECRET=PEGAR_AQUI_EL_RESULTADO_DE_OPENSSL

# URL pública del frontend tal como la ve el celular.
# Tu caso (NAT): IP de Windows + puerto público del port forwarding.
# Si usás Bridged: http://IP_UBUNTU (sin puerto).
FRONTEND_URL=http://IP_WINDOWS:8080
```

> En tu caso, reemplazá `IP_WINDOWS` por `10.244.239.215`: `FRONTEND_URL=http://10.244.239.215:8080`. **No uses `http://10.0.2.50` ni `http://localhost`**: el celular no puede alcanzar la IP interna de la VM.

> Reemplazá `PASSWORD_ROOT` y `PASSWORD_APP` por contraseñas reales antes de guardar. No dejes los textos de ejemplo.

> **No cambies `MYSQL_DATABASE=cipher_forge`.** `database/schema.sql` y `database/migration.sql` asumen ese nombre. Si lo cambiás, la app y el esquema van a apuntar a bases distintas.

> Usá contraseñas con letras, números y guiones bajos. Si incluís `#`, `$`, espacios o comillas, el archivo `.env` de Compose puede interpretarlas mal. El `JWT_SECRET` generado en hexadecimal no tiene ese problema.

Generá el `JWT_SECRET` con:

```bash
openssl rand -hex 32
```

Copiá el resultado y pegalo en `.env`. No dejes el texto `PEGAR_AQUI_EL_RESULTADO_DE_OPENSSL`.

> Si cambiás `JWT_SECRET`, las sesiones viejas dejan de valer y los usuarios tienen que volver a iniciar sesión. No se pierde ninguna cuenta ni contraseña de la aplicación.

Protegé el archivo:

```bash
chmod 600 .env
```

### 4.3 Corregir `docker-compose.yml`

El `docker-compose.yml` actual tiene un problema para una instalación nueva: no pasa `MYSQL_PASSWORD` al servicio `db` ni `DB_PASS` a `app`/`worker`. Hoy funciona en Windows porque el volumen ya estaba inicializado, pero en un volumen nuevo de Ubuntu MySQL no va a inicializar correctamente.

Reemplazá el contenido de `backend/docker-compose.yml` por este:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:dev
    container_name: cipher_forge_app
    restart: unless-stopped
    ports:
      # Solo accesible desde Ubuntu. Nginx es el que publica al exterior.
      - "127.0.0.1:8080:80"
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - FRONTEND_URL=${FRONTEND_URL:?define FRONTEND_URL en .env}
      - SMTP_HOST=mailpit
      - SMTP_PORT=1025
      - MAIL_FROM=no-reply@cipherforge.local
      - MAIL_FROM_NAME=Cipher Forge
      - COOKIE_NAME=cipher_forge_token
      - COOKIE_SECURE=false
      - COOKIE_SAMESITE=Strict
      - JWT_SECRET=${JWT_SECRET:?define JWT_SECRET en .env}
    depends_on:
      - db
      - mailpit

  worker:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:dev
    container_name: cipher_forge_worker
    restart: unless-stopped
    command: php cron-backup.php --loop
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - BACKUP_INTERVAL_SEG=86400
      - PURGE_INTERVAL_SEG=3600
    depends_on:
      - db

  mailpit:
    image: axllent/mailpit:latest
    container_name: cipher_forge_mail
    restart: unless-stopped
    ports:
      # Solo localhost. Para verlo desde Windows, usá un túnel SSH.
      - "127.0.0.1:8025:8025"
      - "127.0.0.1:1025:1025"

  db:
    image: mysql:8.0
    container_name: cipher_forge_db
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:?define MYSQL_ROOT_PASSWORD en .env}
      - MYSQL_DATABASE=${MYSQL_DATABASE:-cipher_forge}
      - MYSQL_USER=${MYSQL_USER:-cipher_user}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
    volumes:
      - db_data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql

volumes:
  db_data:
  uploads_data:
```

Cambios importantes respecto al archivo original:

- `app` y `worker` reciben `DB_PASS` desde `MYSQL_PASSWORD`.
- `db` recibe `MYSQL_PASSWORD`.
- `JWT_SECRET` y `FRONTEND_URL` se leen desde `.env`.
- `app` queda escuchando solo en `127.0.0.1:8080`; Nginx lo proxya.
- `db` ya no publica `3306` a la LAN.
- `mailpit` queda solo en localhost.
- Todos los servicios tienen `restart: unless-stopped`.

Validá la sintaxis y que las variables estén definidas:

```bash
docker compose config --quiet
```

Si no muestra errores, está bien. Si dice que falta una variable, revisá `.env`.

### 4.4 Permisos de archivos

Nginx necesita leer los archivos del frontend. El contenedor necesita escribir en `backups` y en el volumen de uploads.

```bash
cd /opt/cipher-forge/Gestion-fotografias
sudo chmod -R a+rX .
sudo chmod 600 backend/.env
sudo chown -R 33:33 backend/backups
sudo chmod -R 775 backend/backups
```

El `a+rX` permite que Nginx lea los archivos, pero después volvemos a dejar `.env` en `600` para que no sea legible por otros usuarios del sistema.

`backend/backups` queda owned por `www-data` (UID/GID 33) **antes** de arrancar el worker, para que pueda escribir el primer respaldo. El UID 33 es `www-data` en la imagen de PHP/Apache.

Los uploads se corrigen después de restaurarlos, porque el `docker-entrypoint.sh` ajusta el volumen al arrancar.

---

## 5. Restaurar la base, los uploads y los respaldos

### 5.1 Levantar solo la base

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose up -d db
docker compose logs -f db
```

Esperá hasta ver un mensaje parecido a:

```text
[Server] /usr/sbin/mysqld: ready for connections.
```

Salí de los logs con `Ctrl+C` (el contenedor sigue corriendo).

Comprobá que la base responde:

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SHOW DATABASES;"'
```

Debe aparecer `cipher_forge`.

> Si el volumen `db_data` ya existía de una prueba anterior, MySQL no vuelve a ejecutar `schema.sql`. Para empezar de cero **antes** de importar datos reales, podés borrar solo ese volumen:
>
> ```bash
> docker compose down
> docker volume rm backend_db_data
> docker compose up -d db
> ```
>
> No lo hagas si ya importaste la base real: perderías los datos.

### 5.2 Importar el dump

El dump se generó con `--databases`, así que incluye `CREATE DATABASE` y `USE`. Se importa como root:

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot' < ../../transfer/cipher_forge_migracion.sql
```

Si tu dump no incluyera `CREATE DATABASE`, importalo indicando la base:

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot cipher_forge' < ../../transfer/cipher_forge_migracion.sql
```

Verificá los conteos:

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SELECT COUNT(*) AS usuarios FROM cipher_forge.usuarios; SELECT COUNT(*) AS multimedia FROM cipher_forge.multimedia; SELECT COUNT(*) AS colecciones FROM cipher_forge.colecciones;"'
```

Tienen que coincidir con los que anotaste en el paso 3.1.

### 5.3 Levantar la aplicación y el worker

```bash
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 app
docker compose logs --tail=100 worker
```

El `docker-entrypoint.sh` va a:

- crear las carpetas de uploads,
- esperar a MySQL,
- ejecutar `database/migration.sql` de forma idempotente.

Si `app` reinicia en loop, mirá los logs. Lo más común es una contraseña de DB que no coincide o un `.env` incompleto.

> Al arrancar, el worker genera un respaldo inmediato y rota: conserva solo los últimos 3. Si querés guardar los backups viejos que trajiste de Windows, copialos a otro lado antes de este paso. Los originales siguen en el proyecto de Windows.

### 5.4 Restaurar fotos y videos

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose cp ../../transfer/uploads_export/. app:/var/www/html/uploads
docker compose exec -T app chown -R www-data:www-data /var/www/html/uploads
docker compose exec -T app sh -c 'du -sh /var/www/html/uploads; find /var/www/html/uploads -type f | wc -l'
```

Compará el tamaño y la cantidad con lo que anotaste en Windows.

### 5.5 Verificar permisos de respaldos

```bash
ls -ld backups
```

Debe mostrar `www-data www-data` (o `33 33`). Si copiaste archivos nuevos después del paso 4.4, volvé a aplicar:

```bash
sudo chown -R 33:33 backups
sudo chmod -R 775 backups
```

El UID 33 es `www-data` en la imagen de PHP/Apache.

### 5.6 Generar un respaldo de prueba

```bash
docker compose exec -T app php cron-backup.php
ls -lh backups
docker compose logs --tail=50 worker
```

Tiene que aparecer un archivo nuevo `backup_cipher_forge_FECHA.sql` y una línea de `[OK]` en los logs. Si falla por permisos, revisá el paso 5.5.

---

## 6. Configurar Nginx

### 6.1 Crear el sitio

```bash
sudo nano /etc/nginx/sites-available/cipher-forge
```

Contenido:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /opt/cipher-forge/Gestion-fotografias;
    index index.html;

    # El proyecto no tiene index.html en la raíz: la landing está en lading-page/.
    location = / {
        return 302 /lading-page/paginaprincipal.html;
    }

    # Permite subir videos de hasta 800 MB (con margen).
    client_max_body_size 900m;
    client_body_timeout 600s;

    # No servir código, respaldos, documentación ni archivos ocultos.
    location ~ ^/(backend|docs)(/|$) { deny all; }
    location ~ /\. { deny all; }
    location ~* \.(env|sql|md|yml|yaml|ini|log|sh|properties)$ { deny all; }

    # Rutas de la API definidas en backend/routes.php.
    # Se excluye /sistema/* a propósito: esos endpoints son administrativos.
    location ~ ^/(auth|fotografos?|colecciones|multimedia|invitaciones|hashtags|favoritos|colaborativo|qr|api)(/|$) {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        # $http_host conserva el puerto 8080 que ve el celular.
        # Con $host se perdería y algunas URLs absolutas saldrían sin puerto.
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        proxy_request_buffering off;
    }

    # Endpoints administrativos: se deniegan por completo en Nginx.
    # Los respaldos se generan por CLI (docker compose exec -T app php cron-backup.php).
    location ^~ /sistema { deny all; }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Qué hace esta configuración:

- Sirve la landing y los dos frontends como archivos estáticos.
- Redirige `/` a `/lading-page/paginaprincipal.html` (el proyecto no tiene `index.html` en la raíz).
- Manda las rutas de la API al contenedor `app` en `127.0.0.1:8080`.
- No expone `/backend`, `/docs`, `.env`, `.sql`, `.md`, etc.
- No publica `/sistema/*`: se deniega por completo. Para respaldos usá la CLI del paso 5.6 o 10.2.
- Permite subidas grandes y timeouts largos para videos.

> **En tu caso NAT:** Nginx debe escuchar en el puerto **80** dentro de la VM. No cambies `listen 80`; la traducción `host 8080 -> guest 80` la hace VirtualBox. El celular nunca llega directamente a este puerto.

### 6.2 Activar el sitio

> Si ya tenés otros sitios en Nginx, no borres `default` ni sobrescribas configuraciones a ciegas. Hacé un backup:
>
> ```bash
> sudo cp -a /etc/nginx/sites-enabled /root/nginx-sites-enabled-backup
> ```

```bash
sudo ln -sf /etc/nginx/sites-available/cipher-forge /etc/nginx/sites-enabled/cipher-forge
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

Si `nginx -t` da error, no recargues: corregí el archivo y volvé a probar.

### 6.3 Probar desde Ubuntu

```bash
curl -I http://127.0.0.1/
curl -I -L http://127.0.0.1/
curl -I http://127.0.0.1/lading-page/paginaprincipal.html
curl -I http://127.0.0.1/frontend-cliente/pages/login.html
curl -I http://127.0.0.1/frontend-fotografo/pages/login.html
curl -I http://127.0.0.1/frontend-cliente/services/config.js
curl -s http://127.0.0.1/api/ping
curl -I http://127.0.0.1/backend/.env
curl -I http://127.0.0.1/sistema/backups
```

Resultados esperados:

- `/`: `302 Found` con `Location: /lading-page/paginaprincipal.html`.
- `/` con `-L`: `200 OK` (la landing).
- `/lading-page/paginaprincipal.html`, las dos páginas de login y `config.js`: `200 OK`.
- `/api/ping`: respuesta JSON del backend.
- `/backend/.env`: `403 Forbidden`.
- `/sistema/backups`: `403 Forbidden` (lo bloquea Nginx).

> Estas pruebas son **dentro de Ubuntu**. Desde Windows o el celular, cambiá `http://127.0.0.1` por `http://IP_WINDOWS:8080` (sección 8.3).

### 6.4 Si aparece `502 Bad Gateway`

Significa que Nginx no puede hablar con el contenedor. Revisá:

```bash
docker compose ps
docker compose logs --tail=100 app
curl -s http://127.0.0.1:8080/api/ping
```

El puerto del compose debe ser `127.0.0.1:8080:80`. Si lo cambiaste, ajustá `proxy_pass`.

### 6.5 Si aparece `413 Request Entity Too Large`

Aumentá `client_max_body_size` en Nginx y verificá `backend/php.ini`:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
grep -E 'upload_max_filesize|post_max_size' php.ini
```

Los valores del proyecto ya están preparados para 800 MB de video.

---

## 7. Arreglar el QR para el celular

### 7.1 Por qué falla hoy

`QrGenerator.php` no tiene el problema: genera un QR estándar a partir de un texto. El texto se arma en `ColaborativoController::armarUrlColaborativo()` usando `FRONTEND_URL`.

Hoy `FRONTEND_URL` vale `http://localhost:5501/Gestion-fotografias`. Entonces el QR contiene:

```text
http://localhost:5501/Gestion-fotografias/frontend-cliente/pages/colaborativo.html?token=...
```

Cuando el celular escanea `localhost`, lo interpreta como **el propio celular**, no como tu PC. Por eso no abre nada.

### 7.2 Confirmar `FRONTEND_URL`

En `backend/.env` tiene que estar la URL pública, tal como la escribe el celular:

```env
FRONTEND_URL=http://IP_WINDOWS:8080
```

En tu caso:

```env
FRONTEND_URL=http://10.244.239.215:8080
```

Sí, **incluye el puerto 8080**, porque el celular entra por el puerto público de Windows y VirtualBox lo traduce al 80 de la VM. Si usarás **Bridged**, sería sin puerto:

```env
FRONTEND_URL=http://192.168.1.50
```

Si usás un dominio, sería:

```env
FRONTEND_URL=https://cipher.tudominio.com
```

> No uses `http://10.0.2.50` ni `http://localhost`. El QR se genera con este valor; si está mal, el celular no va a poder abrirlo.

### 7.3 Ajustar los dos `config.js`

En Ubuntu, editá:

- `frontend-cliente/services/config.js`
- `frontend-fotografo/services/config.js`

Dejá el contenido así:

```js
// El frontend y la API se sirven desde el mismo origen a través de Nginx.
export const API_URL = "";
```

Con `API_URL = ""`, un `fetch("/auth/login")` va a `http://IP_WINDOWS:8080/auth/login`, que Nginx manda al backend. No hay CORS y la cookie de sesión funciona.

> Si volvés a desarrollar con Live Server en Windows, usá `API_URL = "http://localhost:8080"` **con la VM apagada**, o `http://127.0.0.1:8080` si el stack de Windows está publicado en IPv4. Con la VM prendida, `localhost:8080` puede resolver a Ubuntu. Para el servidor Ubuntu, siempre `""`.

### 7.4 Recrear el contenedor para que lea el nuevo `.env`

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose up -d --force-recreate app worker
docker compose logs --tail=50 app
```

### 7.5 Generar un QR nuevo

1. Entrá al frontend del fotógrafo:

   ```text
   http://IP_WINDOWS:8080/frontend-fotografo/pages/login.html
   ```

2. Iniciá sesión. El panel abre en `http://IP_WINDOWS:8080/frontend-fotografo/pages/panel.html`.
3. Entrá a una colección.
4. Generá el QR colaborativo o el QR de acceso.
5. Copiá el enlace que muestra el modal.

El enlace debe verse así:

```text
http://IP_WINDOWS:8080/frontend-cliente/pages/colaborativo.html?token=...
```

o, para acceso permanente:

```text
http://IP_WINDOWS:8080/frontend-cliente/pages/tuscoleccionescliente.html?invitacion=...
```

**No debe contener `localhost`, `127.0.0.1` ni `10.0.2.50`.**

### 7.6 Los QR viejos no se actualizan solos

Un QR ya impreso o generado antes del cambio sigue conteniendo `localhost`. Hay que regenerarlo o reimprimirlo. El token puede seguir siendo válido; lo que cambia es la URL codificada.

### 7.7 Alternativa sin Nginx (solo para pruebas, no aplica a tu NAT)

> En tu caso **saltá esta sección**. Con NAT necesitarías reglas de port forwarding adicionales y el puerto 8080 del host ya está ocupado por Nginx.

Si todavía no querés usar Nginx, podés servir el frontend y el backend en el **mismo Ubuntu** usando dos puertos. No sirve si el frontend queda en Windows y el backend en Ubuntu: la cookie `SameSite=Strict` no viaja entre hosts distintos.

- En `backend/.env` (solo si usás Bridged): `FRONTEND_URL=http://IP_UBUNTU:5501/Gestion-fotografias`
- En los dos `config.js`:

  ```js
  const host = window.location.hostname || "localhost";
  export const API_URL = `${window.location.protocol}//${host}:8080`;
  ```

- Abrí los puertos `5501` y `8080` en el firewall.
- Serví la carpeta `Gestion-fotografias` con un servidor estático que escuche en `0.0.0.0:5501`. Por ejemplo, desde esa carpeta:

  ```bash
  python3 -m http.server 5501 --bind 0.0.0.0
  ```

Esto funciona, pero es más frágil: dependés de dos puertos, de CORS y de que el firewall esté bien configurado. Para el Ubuntu Server se recomienda Nginx.

---

## 8. Red, firewall y WiFi

### 8.1 Firewall de Ubuntu

Si usás `ufw`:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status
```

> En tu caso NAT, UFW solo protege la VM. El puerto que ve el celular es el **8080 de Windows**; ese lo controla el Firewall de Windows y la regla de VirtualBox del paso 2.1. No abras `8080` en UFW: el forward llega al puerto `80` de la VM.

No abras `3306` (MySQL) ni `8025` (Mailpit) a la LAN. Si necesitás depurar, abrilos solo temporalmente y cerralos después.

Si más adelante usás HTTPS:

```bash
sudo ufw allow 443/tcp
```

### 8.2 Verificar que Nginx escucha en todas las interfaces

```bash
sudo ss -tlnp | grep ':80'
```

Debe aparecer `0.0.0.0:80` o `*:80`, no solo `127.0.0.1:80`.

> Esto es **dentro de la VM**. El celular no llega a `0.0.0.0:80`; llega a `IP_WINDOWS:8080` y VirtualBox traduce al 80 de la VM.

### 8.3 Probar desde Windows y desde otra PC

Primero, en la PC Windows, contra el puerto reenviado:

```powershell
curl.exe -I -L http://127.0.0.1:8080/
curl.exe -I http://127.0.0.1:8080/lading-page/paginaprincipal.html
curl.exe -I http://127.0.0.1:8080/frontend-cliente/pages/login.html
curl.exe -I http://127.0.0.1:8080/frontend-fotografo/pages/login.html
```

Si eso funciona, probá desde otra PC o el celular usando la IP de la WiFi:

```powershell
curl.exe -I -L http://IP_WINDOWS:8080/
curl.exe -I http://IP_WINDOWS:8080/lading-page/paginaprincipal.html
curl.exe -I http://IP_WINDOWS:8080/frontend-cliente/pages/login.html
curl.exe -I http://IP_WINDOWS:8080/frontend-fotografo/pages/login.html
```

> `127.0.0.1:8080` funciona **solo en la PC Windows**. Para probar desde otra PC de la LAN, repetí los comandos cambiando `127.0.0.1` por `IP_WINDOWS`. Para el celular, seguí al paso 8.4.

Si funciona desde otra PC pero no desde el celular, el problema es la red WiFi, el firewall del celular o el aislamiento de clientes.

### 8.4 Probar desde el celular

1. Conectá el celular a la **misma WiFi** que la PC Windows (no la VM: la VM está en NAT).
2. Abrí el navegador.
3. Entrá a:

   ```text
   http://IP_WINDOWS:8080/
   ```

   Debe redirigir a `http://IP_WINDOWS:8080/lading-page/paginaprincipal.html`.

4. Desde la landing, probá los dos accesos:

   ```text
   http://IP_WINDOWS:8080/frontend-fotografo/pages/login.html
   http://IP_WINDOWS:8080/frontend-cliente/pages/login.html
   ```

5. Generá un QR nuevo desde el panel del fotógrafo (en la PC) y abrí el enlace en el celular. También podés probar el acceso permanente con `?invitacion=...`.

### 8.5 Si el celular no puede entrar

Revisá en este orden:

1. **La VM está prendida y la regla Nginx activa.** En VirtualBox: `host 8080 -> guest 10.0.2.50:80`. Si cambiaste el guest port a 80, reiniciá la VM si el puerto no responde.
2. **Firewall de Windows.** El perfil de la WiFi es **Public**. Verificá que el puerto 8080 esté permitido (paso 2.1). La prueba desde otra PC de la LAN ayuda a aislar el problema.
3. **IP correcta.** `ipconfig` en Windows: la IP de WiFi puede cambiar por DHCP. El celular debe usar esa IP, no `10.0.2.50` ni `127.0.0.1`.
4. **Misma subred.** Tu red es `/22` (máscara `255.255.252.0`), no `/24`. Compará IP y máscara: el celular y Windows deben estar en el mismo rango. No alcanza con mirar los primeros tres octetos.
5. **Aislamiento de clientes.** Muchos routers de instituciones, hoteles y redes de invitados tienen “AP isolation” o “client isolation”. Eso impide que dos dispositivos de la misma WiFi se hablen. En ese caso, la afirmación de tu profesor es correcta en teoría, pero la red lo bloquea.
6. **Red de invitados.** Si el celular está en la red “Guest” y la PC en la red principal, están en VLANs distintas.
7. **VPN en el celular.** Una VPN puede mandar el tráfico por otro lado. Desactivala para la prueba.
8. **Nginx/UFW dentro de Ubuntu.** En la VM: `curl -I http://127.0.0.1/`, `sudo systemctl status nginx`, `sudo ufw status`.
9. **IP interna de la VM.** Si `hostname -I` ya no muestra `10.0.2.50`, actualizá el `Guest IP` de la regla Nginx.

Si el WiFi de la institución aísla clientes, tenés estas alternativas:

- Usar el **hotspot del celular** y conectar la PC Windows a ese hotspot. Cambia la IP de Windows; actualizá `FRONTEND_URL` y regenerá el QR.
- Usar un router propio en el que vos controles la red.
- Usar un túnel (Cloudflare Tunnel, Tailscale, ngrok) o publicar el servidor con dominio y HTTPS. Para una demo en LAN, el hotspot o un router propio es lo más simple.

### 8.6 Si el Ubuntu es una VM

- **Tu caso:** NAT + port forwarding. Es válido y **no hace falta cambiar a Bridged**.
- Ventajas: la VM no está expuesta directamente; la PC Windows hace de puerta y vos controlás qué puerto se publica.
- Limitaciones: Windows debe estar encendido y la VM corriendo; el rendimiento de red es menor que Bridged; la IP pública es la de Windows y puede cambiar por DHCP; el celular no puede usar `10.0.2.50`.
- Si usás **Bridged**: la VM tiene una IP de la LAN, el celular entra directo a `http://IP_UBUNTU` por el puerto 80 y no necesitás la regla 8080. En ese caso cambiá `FRONTEND_URL` y regenerá los QR.
- Si usás **NAT sin port forwarding**: el celular no puede entrar. No alcanza con estar en la misma WiFi.

### 8.7 Si el Ubuntu es un VPS

- El celular no necesita la misma WiFi.
- Configurá un dominio y HTTPS. Para LAN, el manual usa HTTP y `COOKIE_SECURE=false`; en internet, cambiá a `COOKIE_SECURE=true` y `FRONTEND_URL=https://tu-dominio`.
- Abrí solo `80` y `443`. No expongas MySQL ni Mailpit.

---

## 9. Corte final y pruebas de aceptación

### 9.1 Probar todo en Ubuntu antes de apagar Windows

Con el **stack de Docker de Windows** detenido (no apagues la PC: la VM y el port forwarding la necesitan), probá desde Ubuntu y desde el celular:

- [ ] `docker compose ps` muestra `app`, `worker`, `db` y `mailpit` arriba.
- [ ] `http://IP_WINDOWS:8080/` redirige a la landing y carga.
- [ ] `http://IP_WINDOWS:8080/lading-page/paginaprincipal.html` carga.
- [ ] `http://IP_WINDOWS:8080/frontend-cliente/pages/login.html` carga.
- [ ] `http://IP_WINDOWS:8080/frontend-fotografo/pages/login.html` carga.
- [ ] Podés iniciar sesión con un usuario existente.
- [ ] Se ven las colecciones y las fotos existentes.
- [ ] Podés subir una imagen de prueba.
- [ ] Podés generar un QR nuevo.
- [ ] El enlace del QR contiene `IP_WINDOWS` y `:8080`, no `localhost` ni `10.0.2.50`.
- [ ] El celular abre el enlace del QR.
- [ ] El celular puede subir una foto.
- [ ] La foto aparece en moderación.
- [ ] El worker genera un respaldo en `backend/backups/`.
- [ ] Los conteos de la DB coinciden con los de Windows.

### 9.2 Corte definitivo

Cuando todo funcione:

1. Dejá el stack de Windows detenido (`docker compose stop`).
2. Avisá a los usuarios que la URL cambió.
3. Regenerá e imprimí los QR que se usaban en eventos.
4. Guardá una copia del dump y de `uploads_export` en un disco externo y verificá que se pueda leer.
5. No borres los volúmenes de Windows hasta tener unos días de funcionamiento estable en Ubuntu.

### 9.3 Limpiar la carpeta de transferencia

`/opt/cipher-forge/transfer` contiene una copia completa de la base (usuarios, correos, hashes de contraseñas) y de las fotos. No la dejes en el servidor después de validar.

1. Verificá que la copia externa del paso 9.2 esté completa.
2. Borrá la carpeta:

```bash
sudo rm -rf /opt/cipher-forge/transfer
```

3. Verificá que la app sigue funcionando: abrí `http://IP_WINDOWS:8080/` y probá un login.

> Los `.sql` de `backend/backups/` también contienen datos personales. No los subas a Git ni los dejes accesibles por HTTP; Nginx ya bloquea `/backend`.

### 9.4 Rollback

Si algo sale mal en Ubuntu, primero liberá el puerto 8080 de Windows. Lo más simple es apagar la VM:

```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" controlvm "Ubuntu-Server-Lab" acpipowerbutton
```

Después volvé a levantar el stack de Windows:

```powershell
cd "C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias\backend"
docker compose start app worker
```

> Si dejás la VM prendida, `localhost:8080` puede seguir apuntando a Ubuntu. En ese caso cambiá temporalmente el `Host Port` de la regla `Nginx` a otro valor (por ejemplo `8082`) antes de levantar Windows.

Los volúmenes de Windows siguen intactos porque no ejecutaste `down -v`. Eso sí: los datos creados en Ubuntu después del corte no van a estar en Windows.

---

## 10. Respaldos: qué hace el sistema y qué falta

### 10.1 Qué hace el worker

El servicio `worker` ejecuta:

```bash
php cron-backup.php --loop
```

Cada 24 horas:

- genera un `.sql` de la base en `backend/backups/`,
- registra el respaldo en la tabla `backups`,
- rota y conserva las últimas 3 copias,
- cada hora purga los archivos colaborativos no aprobados con más de 24 horas.

El respaldo de la base **no incluye fotos ni videos**. Los uploads están en el volumen `uploads_data` y hay que respaldarlos aparte.

### 10.2 Verificar el respaldo

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose exec -T app php cron-backup.php
ls -lh backups
docker compose logs --tail=50 worker
```

También podés consultar la tabla:

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SELECT id_backup, nombre_backup, fecha_backup FROM cipher_forge.backups ORDER BY fecha_backup DESC;"'
```

### 10.3 Copiar los respaldos fuera del servidor

El backup en el mismo disco no protege contra un fallo del disco. Copiá la carpeta `backups/` a otro equipo o a un disco externo. Primero creá las carpetas y dale permisos a tu usuario:

```bash
sudo mkdir -p /srv/backups/cipher-forge/db /srv/backups/cipher-forge/uploads /srv/backups/cipher-forge/db-completo
sudo chown -R $USER:$USER /srv/backups/cipher-forge

rsync -a /opt/cipher-forge/Gestion-fotografias/backend/backups/ /srv/backups/cipher-forge/db/
```

Y los uploads:

```bash
docker run --rm \
  -v backend_uploads_data:/data \
  -v /srv/backups/cipher-forge/uploads:/backup \
  alpine sh -c 'tar czf /backup/uploads_$(date +%F_%H-%M).tar.gz -C /data .'

sudo chown -R $USER:$USER /srv/backups/cipher-forge/uploads
```

> Verificá el nombre real del volumen con `docker volume ls | grep uploads`. Si el proyecto se llama `backend`, debería ser `backend_uploads_data`.

> Los backups `.sql` contienen datos personales (usuarios, correos, hashes). Copialos a un lugar con permisos restringidos y no los subas a un repositorio.

### 10.4 Restaurar un backup de la app en una base de prueba

Los backups que genera la app **excluyen la tabla `backups`**. Para probarlos en una base temporal:

> En los comandos siguientes, reemplazá `FECHA` por el nombre real del backup. Podés verlo con `ls backups/`.

> **No ejecutes `database/schema.sql` directamente sobre `cipher_forge_prueba`.** Ese archivo empieza con `CREATE DATABASE cipher_forge; USE cipher_forge;`, así que terminaría creando las tablas en la base real. Para la prueba, importá el backup y creá a mano la tabla `backups` que falta.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend

# Crear base de prueba
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "CREATE DATABASE IF NOT EXISTS cipher_forge_prueba CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"'

# Importar el backup de la app (no trae USE cipher_forge, así que va a la base indicada)
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot cipher_forge_prueba' < backups/backup_cipher_forge_FECHA.sql

# Crear la tabla que el backup excluye a propósito
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot cipher_forge_prueba -e "CREATE TABLE IF NOT EXISTS backups (id_backup INT NOT NULL PRIMARY KEY AUTO_INCREMENT, ruta_backup VARCHAR(100) NOT NULL, nombre_backup VARCHAR(100) NOT NULL, fecha_backup TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);"'

# Verificar
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SELECT COUNT(*) FROM cipher_forge_prueba.usuarios; SELECT COUNT(*) FROM cipher_forge_prueba.multimedia;"'

# Borrar la base de prueba
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "DROP DATABASE cipher_forge_prueba;"'
```

### 10.5 Restauración de emergencia de la base real

Esto **borra la base actual**. Hacelo solo si es una emergencia y ya tenés el backup verificado.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend

docker compose stop app worker

docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "DROP DATABASE IF EXISTS cipher_forge; CREATE DATABASE cipher_forge CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"'
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot cipher_forge' < database/schema.sql
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot cipher_forge' < backups/backup_cipher_forge_FECHA.sql

docker compose start app worker
```

> Este procedimiento no recupera el historial de la tabla `backups` (la app la excluye de sus backups). Los archivos `.sql` siguen en `backups/`; si necesitás conservar el historial, usá el dump completo del paso 10.6.

### 10.6 Recomendación: backup completo adicional

Para tener un backup que incluya también la tabla `backups`, generá un `mysqldump` completo fuera del ciclo de la app:

```bash
sudo mkdir -p /srv/backups/cipher-forge/db-completo
sudo chown -R $USER:$USER /srv/backups/cipher-forge
cd /opt/cipher-forge/Gestion-fotografias/backend

docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqldump -uroot --single-transaction --routines --triggers --no-tablespaces --databases cipher_forge' > /srv/backups/cipher-forge/db-completo/cipher_forge_$(date +%F_%H-%M).sql
```

Podés programarlo con `cron` en Ubuntu. Lo ideal es tener:

- backup diario de la app,
- backup completo semanal,
- copia de uploads,
- y una copia fuera del servidor.

---

## 11. Operación y mantenimiento

### 11.1 Comandos del día a día

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend

# Ver estado
docker compose ps

# Ver logs
docker compose logs -f app
docker compose logs -f worker
docker compose logs -f db

# Reiniciar
docker compose restart app worker

# Detener sin borrar datos
docker compose stop

# Volver a levantar
docker compose start
```

### 11.2 Actualizar el código

> No copies el `.env` de Windows. Si usás `scp -r` o `rsync`, excluilo; si no, volvé a crear el `.env` en Ubuntu con los valores del paso 4.2. En tu caso NAT, `scp` va con `-P 2222` y destino `USUARIO@127.0.0.1`.

1. Copiá los archivos nuevos al servidor (sin borrar `.env`, `backups/` ni los volúmenes).
2. Reconstruí:

```bash
docker compose up -d --build
docker compose logs --tail=100 app
```

La migración de base se ejecuta sola al arrancar (`migration.sql`).

### 11.3 Cambiar la IP o el dominio

Hay tres casos distintos en tu setup NAT:

1. **Cambia la IP de Windows (`IP_WINDOWS`).** Actualizá `FRONTEND_URL` en `backend/.env`, recreá `app` y regenerá los QR. La regla de VirtualBox no cambia.
2. **Cambia la IP interna de la VM (`10.0.2.50`).** Actualizá el `Guest IP` de la regla `Nginx` en VirtualBox. `FRONTEND_URL` no cambia.
3. **Pasás a Bridged o a un dominio.** Actualizá `FRONTEND_URL` (sin puerto en Bridged), recreá `app` y regenerá los QR.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose up -d --force-recreate app
```

Si usás HTTPS, cambiá `COOKIE_SECURE=true` y `FRONTEND_URL=https://...`.

### 11.4 Reinicio del servidor

Con `restart: unless-stopped`, los contenedores vuelven solos cuando arranca la VM. Pero en tu caso hay dos capas:

- Si reiniciás **solo Ubuntu** (`sudo reboot`), la VM vuelve y los contenedores arrancan solos. Volvé a entrar con `ssh -p 2222 USUARIO@127.0.0.1`.
- Si reiniciás **Windows**, la VM **no arranca sola** salvo que configures autostart en VirtualBox. Abrila manualmente antes de esperar que el celular funcione.

Verificá:

```bash
docker compose ps
sudo systemctl status nginx
```

> El celular depende de que Windows esté encendido, la VM corriendo y el port forwarding activo. Si Windows se suspende, el QR deja de funcionar.

### 11.5 No hacer

- No ejecutes `docker compose down -v` en producción: borra DB y uploads.
- No borres `backend/backups/` sin copiarlo antes.
- No expongas `3306` ni `8025` a internet.
- No uses `localhost`, `127.0.0.1` ni `10.0.2.50` en `FRONTEND_URL` ni en el QR.
- No cambies el `Guest Port` de la regla Nginx a `8080` sin cambiar también el puerto de Nginx o el de Docker: chocarían.

---

## 12. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| El celular no abre `http://IP_WINDOWS:8080/` | VM apagada, regla NAT sin `guest 80`, firewall de Windows, IP equivocada o aislamiento de clientes | Revisar que la VM esté corriendo, la regla `host 8080 -> guest 80`, el firewall en perfil Public, `ipconfig` y la subred |
| Desde Windows funciona `http://127.0.0.1:8080/` pero el celular no | Firewall de Windows, IP de WiFi equivocada o aislamiento de clientes | Crear/verificar la regla TCP 8080 para `LocalSubnet`; probar desde otra PC; revisar AP isolation |
| `http://IP_WINDOWS:8080/` devuelve 404 | Falta el `location = /` o no existe `lading-page/paginaprincipal.html` | Revisar la config de Nginx y `ls /opt/cipher-forge/Gestion-fotografias/lading-page` |
| `Connection reset` al abrir el puerto | Nginx no escucha en 80 o el `Guest Port` sigue en 8080 | `sudo ss -tlnp | grep ':80'`; corregir la regla NAT a guest 80 |
| `ssh` da `Connection refused` | Falta `-p 2222` o usaste la IP de la VM | `ssh -p 2222 USUARIO@127.0.0.1` desde Windows |
| Después de reiniciar Windows no funciona nada | La VM no arranca sola | Abrir VirtualBox y arrancar `Ubuntu-Server-Lab`; opcionalmente configurar autostart |
| Todos los usuarios reciben 429 al iniciar sesión | El backend ve a todos como la misma IP porque Nginx proxya; el rate limit es compartido | Esperar 5 minutos. Para una demo, agregar `RATE_LIMIT_ENABLED=0` al entorno de `app` y recrear el contenedor |
| La página abre pero el login falla | `API_URL` mal, Nginx no proxya la API, cookie/CORS | Revisar `config.js`, `nginx -t`, `docker compose logs app` |
| Las fotos o videos no cargan | Nginx no proxya `/multimedia` o faltan uploads | Revisar `nginx -t`, `docker compose logs app` y probar `curl -I http://127.0.0.1/multimedia/1/vista-previa` (un `401` también confirma que Nginx lo proxea; un `404` indica que la ruta no llega al backend) |
| El QR abre `localhost` o `10.0.2.50` | `FRONTEND_URL` viejo o QR generado antes del cambio | Corregir `.env`, recrear `app`, generar QR nuevo |
| `502 Bad Gateway` | `app` no está corriendo o el puerto no coincide | `docker compose ps`, `curl -s http://127.0.0.1:8080/api/ping` |
| `413 Request Entity Too Large` | Nginx o PHP con límite bajo | `client_max_body_size 900m`, revisar `php.ini` |
| `504 Gateway Timeout` | Video grande o procesamiento lento | Aumentar `proxy_read_timeout` y `max_execution_time` |
| `Access denied for user` | `MYSQL_PASSWORD` y `DB_PASS` no coinciden | Revisar `.env` y `docker compose config` |
| MySQL no arranca en un volumen nuevo | Falta `MYSQL_ROOT_PASSWORD` o `MYSQL_PASSWORD` | Completar `.env` y usar el compose del paso 4.3 |
| Las fotos dan 404 | No se restauró `uploads` o faltan permisos | Revisar `docker compose cp`, `chown`, `du -sh uploads` |
| El worker no genera backups | Permisos de `backend/backups` | `sudo chown -R 33:33 backups` |
| El QR dice “caducado” | El token colaborativo dura 24 horas | Generar uno nuevo desde el panel |
| Mailpit no se ve desde Windows | Está bindeado a `127.0.0.1` en Ubuntu | Túnel SSH: `ssh -p 2222 -L 8025:127.0.0.1:8025 USUARIO@127.0.0.1` y abrir `http://localhost:8025` |

### Cómo leer los correos de verificación con Mailpit

En Windows:

```powershell
ssh -p 2222 -L 8025:127.0.0.1:8025 USUARIO@127.0.0.1
```

Dejá esa terminal abierta y entrá a:

```text
http://localhost:8025
```

Así ves los correos sin exponer Mailpit a la LAN.

---

## 13. Checklist final

### Migración

- [ ] Anoté los conteos de usuarios, multimedia y colecciones en Windows.
- [ ] Generé `cipher_forge_migracion.sql` y verifiqué que no está vacío.
- [ ] Exporté `uploads_export` con las fotos y videos.
- [ ] Copié `backend/backups/`.
- [ ] Copié el proyecto a `/opt/cipher-forge/Gestion-fotografias`.
- [ ] Creé `backend/.env` con contraseñas nuevas y `JWT_SECRET`.
- [ ] Reemplacé `docker-compose.yml` por la versión corregida.
- [ ] `docker compose config --quiet` no da errores.
- [ ] Levanté `db` y esperé “ready for connections”.
- [ ] Importé el dump.
- [ ] Los conteos coinciden con Windows.
- [ ] Levanté `app` y `worker`.
- [ ] Restauré `uploads` y verifiqué cantidad/tamaño.
- [ ] Dejé `backend/backups` owned por `33:33` antes de arrancar el worker.
- [ ] Ajusté permisos de `backups`.

### Nginx y QR

- [ ] La regla `Nginx` de VirtualBox apunta a `guest 10.0.2.50:80`.
- [ ] El firewall de Windows permite TCP 8080 en el perfil Public.
- [ ] `http://IP_WINDOWS:8080/` redirige a `/lading-page/paginaprincipal.html` y carga.
- [ ] `http://IP_WINDOWS:8080/lading-page/paginaprincipal.html` carga.
- [ ] `http://IP_WINDOWS:8080/frontend-cliente/pages/login.html` carga.
- [ ] `http://IP_WINDOWS:8080/frontend-fotografo/pages/login.html` carga.
- [ ] `/backend/.env` devuelve 403.
- [ ] `/sistema/backups` devuelve 403 desde la LAN.
- [ ] `FRONTEND_URL=http://IP_WINDOWS:8080`.
- [ ] `API_URL = ""` en los dos `config.js`.
- [ ] Generé un QR nuevo.
- [ ] El enlace del QR contiene `IP_WINDOWS` y `:8080`, no `localhost` ni `10.0.2.50`.
- [ ] El celular, en la misma WiFi, abre el QR.
- [ ] El celular puede subir una foto.
- [ ] La foto aparece en moderación.

### Operación

- [ ] El worker genera respaldos.
- [ ] Hay una copia de los respaldos fuera del servidor.
- [ ] Hay una copia de `uploads` fuera del servidor.
- [ ] Probé reiniciar Ubuntu y el stack volvió solo.
- [ ] Probé reiniciar Windows, arranqué la VM y el stack volvió.
- [ ] Guardé el dump y `uploads_export` en un disco externo.
- [ ] Borré `/opt/cipher-forge/transfer` después de guardar la copia externa.
- [ ] No borré los volúmenes de Windows todavía.

---

## Apéndice A: comandos rápidos

### Windows: exportar

```powershell
cd "C:\Users\Iván Sandoval\Desktop\Cipher_Forge\Gestion-fotografias\backend"

docker compose stop app worker

& docker compose exec db bash -c 'MYSQL_PWD=cipher_password mysqldump -ucipher_user --single-transaction --routines --triggers --no-tablespaces --databases cipher_forge > /tmp/cipher_forge.sql'
docker compose cp db:/tmp/cipher_forge.sql .\cipher_forge_migracion.sql

New-Item -ItemType Directory -Force .\uploads_export | Out-Null
docker compose cp app:/var/www/html/uploads/. .\uploads_export
```

### Windows: SSH y SCP (tu caso NAT)

```powershell
ssh -p 2222 USUARIO@127.0.0.1

scp -P 2222 -r "C:\ruta\al\proyecto" USUARIO@127.0.0.1:/opt/cipher-forge/
scp -P 2222 archivo.sql USUARIO@127.0.0.1:/opt/cipher-forge/transfer/
```

> `ssh` usa `-p` minúscula; `scp` usa `-P` mayúscula. Para Mailpit: `ssh -p 2222 -L 8025:127.0.0.1:8025 USUARIO@127.0.0.1`.

### Ubuntu: restaurar

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend

docker compose up -d db
docker compose logs -f db

docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot' < ../../transfer/cipher_forge_migracion.sql

sudo chown -R 33:33 backups
sudo chmod -R 775 backups

docker compose up -d --build

docker compose cp ../../transfer/uploads_export/. app:/var/www/html/uploads
docker compose exec -T app chown -R www-data:www-data /var/www/html/uploads
```

### Ubuntu: verificar

```bash
docker compose ps
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SELECT COUNT(*) FROM cipher_forge.usuarios; SELECT COUNT(*) FROM cipher_forge.multimedia; SELECT COUNT(*) FROM cipher_forge.colecciones;"'
docker compose exec -T app php cron-backup.php
ls -lh backups
```

### Ubuntu: Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl status nginx
curl -I -L http://127.0.0.1/
curl -I http://127.0.0.1/lading-page/paginaprincipal.html
curl -I http://127.0.0.1/frontend-cliente/pages/login.html
curl -s http://127.0.0.1/api/ping
```

### Windows: probar el port forwarding

```powershell
curl.exe -I -L http://127.0.0.1:8080/
curl.exe -I -L http://IP_WINDOWS:8080/
curl.exe -I http://IP_WINDOWS:8080/frontend-cliente/pages/login.html
```

> Si `127.0.0.1:8080` funciona pero `IP_WINDOWS:8080` no, revisá el Firewall de Windows y el perfil Public.

### Ubuntu: firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status
```

### Windows: firewall para el 8080

```powershell
New-NetFirewallRule -DisplayName "Cipher Forge Nginx 8080" `
  -Direction Inbound -Protocol TCP -LocalPort 8080 `
  -Action Allow -Profile Public -RemoteAddress LocalSubnet
```

### Ubuntu: logs

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose logs -f app
docker compose logs -f worker
docker compose logs -f db
```

---

## Apéndice B: preguntas frecuentes

### ¿Puedo dejar Windows y Ubuntu funcionando a la vez?

No con la misma base “viva”. Podés tener Windows como respaldo detenido, pero si ambos reciben escrituras vas a tener dos bases distintas. Hacé el corte en una ventana de mantenimiento.

### ¿Puedo mover solo MySQL a Ubuntu?

Sí, pero no te lo recomiendo para este proyecto. En tu caso NAT tendrías que agregar otro port forwarding para `3306` y exponerlo en la PC, con el riesgo que eso implica. La app tendría que conectarse a `DB_HOST=IP_WINDOWS` y el QR seguiría dependiendo de que el celular llegue al frontend/backend; además, la cookie `SameSite=Strict` puede fallar si el frontend y el backend quedan en hosts distintos.

### ¿Funciona con el adaptador en NAT?

Sí, siempre que configures **port forwarding** y el firewall de Windows lo permita. En tu caso:

- La regla `Nginx` debe ser `host 8080 -> guest 10.0.2.50:80`.
- El celular usa `http://IP_WINDOWS:8080`.
- La VM puede seguir en NAT; no hace falta pasarla a Bridged.
- La PC Windows debe estar encendida y la VM corriendo.
- El rendimiento de red es menor que en Bridged, pero para una demo alcanza.

Si el port forwarding está en `guest 8080` y Nginx escucha en `80`, el celular va a recibir `Connection reset`. Corregí el `Guest Port` a `80`.

### ¿Puedo usar la IP en vez de un dominio?

Sí, para la LAN alcanza. En tu caso la URL es `http://IP_WINDOWS:8080`. Si el servidor va a estar en internet, usá dominio y HTTPS.

### ¿Por qué el QR no puede usar `localhost`?

Porque `localhost` significa “este dispositivo”. En el celular, `localhost` es el celular, no el servidor. Tampoco sirve `10.0.2.50`: esa es la IP interna de la VM en la red NAT y el celular no tiene ruta hacia ella. Siempre tiene que ser la IP de Windows en la WiFi (`IP_WINDOWS`) o un dominio.

### ¿Qué pasa si cambia la IP del servidor?

Hay dos IPs distintas:

- Si cambia la **IP de Windows** (`IP_WINDOWS`), el QR viejo deja de funcionar. Actualizá `FRONTEND_URL`, recreá `app` y generá QR nuevos. Reservá la IP en el router para evitarlo.
- Si cambia la **IP interna de la VM** (`10.0.2.50`), actualizá el `Guest IP` de la regla Nginx en VirtualBox. `FRONTEND_URL` no cambia.

### ¿Dónde quedan las fotos?

En el volumen Docker `backend_uploads_data`, montado en `/var/www/html/uploads`. No están dentro del `.sql` de la base. Hay que respaldarlas aparte.

### ¿Dónde quedan los respaldos?

En `backend/backups/`, que es una carpeta del host montada dentro del contenedor. Sobrevive a reinicios y a `docker compose down` (si no usás `-v`).

### ¿Puedo borrar `backend/uploads` del proyecto?

Esa carpeta del host no es la que usa la app cuando el volumen está montado. La app usa `uploads_data`. No la borres por si acaso; simplemente no es la fuente de verdad.

### ¿Qué hago si el WiFi de la institución aísla clientes?

Usá el hotspot del celular, un router propio, o un túnel/dominio. No es un problema del código: es una restricción de la red.
