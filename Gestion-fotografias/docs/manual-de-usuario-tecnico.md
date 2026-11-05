# Manual de usuario: poner Cipher Forge en la nube

**Para:** Lemuel Swec
**Qué vas a lograr:** pasar el proyecto desde el archivo `.zip` que te enviamos hasta tener la página web publicada en tu dominio, con HTTPS y con los servicios funcionando en un servidor en la nube.
**Tiempo estimado:** entre 2 y 4 horas de trabajo, más los tiempos de espera de Internet (DNS, certificado y correo). Si es tu primera vez, calculá medio día.
**Nivel:** no necesitás saber programar. Sí necesitás copiar y pegar comandos, prestar atención a los resultados y anotar contraseñas.

> **Antes de empezar:** este manual es para una **instalación nueva**, desde el `.zip`, sin datos que migrar. Si ya tenés fotos, usuarios o una base de datos funcionando en otro servidor, no sigas este manual: pedinos el manual de migración, porque hay que copiar y restaurar datos.

> **Regla de oro:** nunca ejecutes `docker compose down -v`. Ese comando borra la base de datos y las fotos. En este manual no se usa en ningún momento.

---

## Índice

1. [Requisitos previos](#1-requisitos-previos)
2. [Contratar y preparar los servicios](#2-contratar-y-preparar-los-servicios)
3. [Conectarte al servidor](#3-conectarte-al-servidor)
4. [Instalar Docker](#4-instalar-docker)
5. [Subir el proyecto al servidor](#5-subir-el-proyecto-al-servidor)
6. [Configurar el proyecto](#6-configurar-el-proyecto)
7. [Arrancar la base de datos y la aplicación](#7-arrancar-la-base-de-datos-y-la-aplicación)
8. [Configurar Nginx](#8-configurar-nginx)
9. [Configurar el dominio y el DNS](#9-configurar-el-dominio-y-el-dns)
10. [Activar HTTPS](#10-activar-https)
11. [Configurar el correo de producción](#11-configurar-el-correo-de-producción)
12. [Pruebas finales](#12-pruebas-finales)
13. [Copias de seguridad y mantenimiento](#13-copias-de-seguridad-y-mantenimiento)
14. [Solución de problemas](#14-solución-de-problemas)
15. [Datos para guardar y notas técnicas](#15-datos-para-guardar-y-notas-técnicas)

---

## 1. Requisitos previos

### 1.1 Lo que tenés que contratar

Antes de tocar el servidor, necesitás tres servicios. Los tres se contratan por Internet con tarjeta de crédito o débito.

1. **Un servidor en la nube (VPS).**
   Un VPS es una computadora encendida las 24 horas en un centro de datos, a la que te conectás por Internet. No es tu computadora personal. Para este proyecto alcanza con:
   - Sistema operativo **Ubuntu 24.04 LTS** (o 22.04 LTS).
   - **2 procesadores (vCPU)**, **4 GB de memoria RAM** y **80 GB de disco**.
   - Una **dirección IP pública** (una IPv4).
   - Acceso por **SSH** (explicado más abajo).

   Proveedores posibles: DigitalOcean, Hetzner, Vultr, Linode, AWS Lightsail, Azure o Google Cloud. Elegí uno que tenga panel web, consola de emergencia y firewall. El precio depende del proveedor; no contrates el plan más caro: con el plan chico o mediano alcanza.

2. **Un dominio.**
   Un dominio es el nombre de tu página, por ejemplo `cipherforge.com`. Se compra en un registrador de dominios (Namecheap, Cloudflare Registrar, GoDaddy, NIC Uruguay si termina en `.uy`). Necesitás tener acceso al panel donde se configuran los **registros DNS** (la “agenda” que dice a qué servidor apunta tu dominio).

3. **Un servicio de correo transaccional.**
   Es el servicio que entrega los correos de verificación a tus usuarios. **Mailpit no sirve para producción**: Mailpit es un buzón de prueba que solo funciona en tu computadora y no entrega correos a Internet. Para producción necesitás un proveedor real, por ejemplo Resend, Brevo, Mailgun, SendGrid o Amazon SES. En la sección 11 te explico cómo elegirlo y configurarlo.

### 1.2 Lo que tenés que tener instalado en tu computadora

- **Windows 10 u 11** (o Mac/Linux; los comandos de este manual son para Windows con PowerShell).
- **Cliente SSH.** En Windows 10/11 suele venir instalado. Lo verificás en el Paso 5.
- **Un editor de texto** (el Bloc de notas sirve) para anotar contraseñas y datos.
- **Opcional: WinSCP.** Es un programa con ventanas que sirve para arrastrar archivos a un servidor. Si no querés usar comandos para copiar el `.zip`, WinSCP es más fácil. Se descarga gratis desde `winscp.net`.
- **Un navegador actualizado** (Chrome, Edge, Firefox).
- **No necesitás instalar Docker en tu computadora.** Docker se instala en el servidor.

### 1.3 Datos que tenés que tener a mano

Antes de empezar, completá esta lista en un archivo de texto o en un gestor de contraseñas:

| Dato | Tu valor |
|---|---|
| Nombre del dominio | |
| Correo electrónico que usás a diario | |
| IP pública del servidor | |
| Usuario SSH que te dio el proveedor | |
| Contraseña SSH o ruta de la clave `.pem` | |
| Host SMTP del proveedor de correo | |
| Puerto SMTP | |
| Usuario SMTP | |
| Contraseña SMTP | |
| Correo desde el que vas a enviar (ej. `no-reply@tudominio.com`) | |

### 1.4 Cómo leer los comandos

En este manual vas a ver bloques de comandos. Cada bloque indica **dónde** se ejecuta:

- **EN TU COMPUTADORA (PowerShell):** abrís PowerShell en Windows y escribís ahí.
- **EN EL SERVIDOR (SSH):** primero te conectás al servidor (Paso 7) y escribís ahí.

Los textos en MAYÚSCULAS son **placeholders**: hay que reemplazarlos por tu dato. Por ejemplo, si tu dominio es `cipherforge.com`, donde dice `TU_DOMINIO` escribís `cipherforge.com`. No escribas los símbolos `<` ni `>`.

| Placeholder | Qué significa | Ejemplo |
|---|---|---|
| `TU_DOMINIO` | Tu dominio, sin `https://` y sin `www` | `cipherforge.com` |
| `IP_DEL_SERVIDOR` | La IP pública del VPS | `203.0.113.10` |
| `USUARIO_SSH` | El usuario que te dio el proveedor | `root` o `ubuntu` |
| `RUTA_DEL_ZIP` | Dónde está el `.zip` en tu computadora | `C:\Users\Lemuel\Downloads\Cipher_Forge.zip` |
| `TU_CORREO` | Tu correo real para las pruebas | `lemuel@gmail.com` |
| `CLAVE_ROOT` | Contraseña nueva para el administrador de la base | La generás en el Paso 19 |
| `CLAVE_APP` | Contraseña nueva para la aplicación | La generás en el Paso 19 |
| `CLAVE_JWT` | Clave secreta de las sesiones | La generás en el Paso 19 |
| `TU_HOST_SMTP` | Servidor de correo del proveedor | `smtp.resend.com` |
| `TU_PUERTO_SMTP` | Puerto SMTP | `587` |
| `TU_USUARIO_SMTP` | Usuario SMTP | Lo da el proveedor |
| `TU_CLAVE_SMTP` | Contraseña o API key SMTP | La da el proveedor |

### 1.5 Palabras que vas a ver

No hace falta memorizarlas. Las explico de nuevo cuando aparecen, pero tenerlas juntas ayuda:

- **Terminal o consola:** ventana donde escribís comandos y ves el resultado.
- **PowerShell:** la terminal de Windows.
- **Comando:** instrucción que escribís y ejecutás con Enter.
- **SSH:** forma segura de conectarte a otra computadora por Internet.
- **Servidor o VPS:** computadora remota que está siempre encendida.
- **Root / sudo:** usuario con permisos de administrador. `sudo` significa “ejecutar esto como administrador”.
- **IP:** número que identifica una computadora en Internet, por ejemplo `203.0.113.10`.
- **Dominio:** nombre fácil de recordar, por ejemplo `cipherforge.com`.
- **DNS:** “agenda” que traduce el dominio a la IP del servidor.
- **Registro A:** entrada de DNS que dice “este dominio apunta a esta IP”.
- **Docker:** programa que empaqueta y ejecuta aplicaciones en **contenedores**.
- **Contenedor:** como una caja aislada donde corre un programa. Si se rompe, no rompe el resto.
- **Imagen:** plantilla a partir de la cual se crea un contenedor.
- **Volumen:** disco virtual donde Docker guarda datos que deben sobrevivir a reinicios (la base y las fotos).
- **Docker Compose:** archivo (`docker-compose.yml`) que describe qué contenedores se levantan y cómo se conectan.
- **Nginx:** programa que recibe las visitas a tu dominio y las reparte: archivos estáticos por un lado, aplicación por otro.
- **Proxy inverso:** Nginx recibe la visita y la pasa al contenedor de la aplicación.
- **Puerto:** “puerta” numerada de una computadora. HTTP usa 80; HTTPS usa 443.
- **Firewall:** filtro que decide qué puertos están abiertos.
- **Variable de entorno:** valor de configuración que el programa lee al arrancar.
- **`.env`:** archivo de texto con contraseñas y configuración sensible. No se comparte.
- **Base de datos / MySQL:** lugar organizado donde se guardan usuarios, colecciones y metadatos.
- **Respaldo o backup:** copia de seguridad de los datos.
- **SMTP:** protocolo que se usa para enviar correo.
- **API:** forma en que dos programas se comunican.
- **HTTPS / TLS:** versión cifrada de la web; el candado del navegador.
- **Certbot / Let’s Encrypt:** herramienta y servicio que entregan certificados HTTPS gratis.
- **SPF, DKIM y DMARC:** registros de DNS que demuestran que tus correos son legítimos.
- **Mailpit:** buzón falso para desarrollo. **No se usa en producción.**
- **ZIP:** archivo comprimido que contiene el proyecto.
- **Nano:** editor de texto simple que funciona dentro de la terminal.
- **Worker:** programa que ejecuta tareas automáticas, como los respaldos.
- **Error 502 / 413 / 504:** códigos de error de la web. Los explico en la sección 14.

---

## 2. Contratar y preparar los servicios

### Paso 1. Contratar el VPS

**Dónde:** en el panel web del proveedor que elijas.

1. Creá una cuenta en el proveedor.
2. Creá un servidor nuevo con estas opciones:
   - Distribución: **Ubuntu 24.04 LTS** (o 22.04 LTS).
   - Plan: **2 vCPU, 4 GB de RAM, 80 GB de disco**.
   - Ubicación: la más cercana a Uruguay (por ejemplo, São Paulo o Miami).
   - Acceso: **clave SSH** (recomendado) o contraseña de root.
3. Cuando el servidor esté creado, anotá:
   - La **IP pública**.
   - El **usuario SSH** (puede ser `root` o `ubuntu`).
   - La **contraseña** o la **clave `.pem`** que te dio el proveedor.

**Deberías ver:** en el panel, el servidor en estado “Running” o “Encendido”, con una IP pública.

> **Si elegiste clave SSH:** guardá el archivo `.pem` en una carpeta segura. Lo vas a usar para conectarte. No lo pierdas: sin la clave no podés entrar, salvo que uses la consola de emergencia del proveedor.

### Paso 2. Configurar el firewall del proveedor

**Dónde:** en el panel del proveedor, sección “Firewall” o “Security Group”.

Dejá abiertas solo estas entradas:

| Puerto | Protocolo | Para qué |
|---|---|---|
| 22 | TCP | Conectarte por SSH |
| 80 | TCP | HTTP (primer acceso y certificado) |
| 443 | TCP | HTTPS (la web segura) |

Si el proveedor te pide una regla de salida, dejá salir todo (o al menos HTTP, HTTPS, DNS y el puerto SMTP que uses, normalmente 587). Docker, las actualizaciones y el correo necesitan salir a Internet.

**Deberías ver:** tres reglas de entrada activas (22, 80, 443). No abras 3306 (MySQL), 8025 ni 1025 (Mailpit).

### Paso 3. Contratar el dominio

**Dónde:** en el registrador de dominios que elijas.

1. Buscá un nombre disponible y compralo.
2. Entrá al panel de **DNS** del dominio. Ahí vas a crear los registros en el Paso 34.
3. Anotá el dominio exacto, sin `https://` y sin `www`. Por ejemplo: `cipherforge.com`.

**Deberías ver:** el dominio listado como activo en el panel del registrador.

> **Si usás Cloudflare:** por ahora dejá el registro en modo **“DNS only”** (nube gris), no en “Proxied” (nube naranja). Así Certbot puede validar el dominio sin complicaciones. Después, si querés, podés activar el proxy.

### Paso 4. Contratar el servicio de correo

**Dónde:** en el panel web del proveedor de correo que elijas.

1. Creá la cuenta.
2. Buscá la sección **“Domains”**, **“Senders”** o **“SMTP”**.
3. Agregá tu dominio (`TU_DOMINIO`). El proveedor te va a mostrar unos registros DNS (SPF y DKIM). **No los cargues todavía**: los vas a cargar en el Paso 44, cuando ya tengas el dominio funcionando.
4. Anotá el **host SMTP**, el **puerto**, el **usuario** y la **contraseña** que te da el proveedor. Si el proveedor solo ofrece “API” y no “SMTP”, no sirve para este proyecto: elegí otro.

**Deberías ver:** una pantalla con los datos SMTP y una advertencia de que el dominio está “pendiente de verificación”. Es normal.

### Paso 5. Preparar tu computadora

**Dónde:** en tu computadora.

1. Abrí **PowerShell**: botón Inicio, escribí `PowerShell` y abrí la aplicación.
2. Verificá que SSH esté instalado:

```powershell
ssh -V
```

**Deberías ver:** algo parecido a `OpenSSH_for_Windows_8.9p1`. Si dice “no se reconoce como un comando”, instalá el cliente SSH desde **Configuración → Aplicaciones → Características opcionales → Agregar una característica → Cliente OpenSSH**. Después volvé a abrir PowerShell.

3. Si vas a usar WinSCP, descargalo e instalalo desde `winscp.net`.
4. Creá un archivo de texto llamado `datos-cipher-forge.txt` y completá la tabla del punto 1.3.

**Punto de control:** si `ssh -V` muestra una versión y tenés tus datos anotados, seguí. Si no, andá a la sección 14.

---

## 3. Conectarte al servidor

### Paso 6. Verificar que estás en PowerShell

**Dónde:** en tu computadora.

Si cerraste la ventana, abrila de nuevo: botón Inicio, escribí `PowerShell` y abrí la aplicación. Asegurate de que sea **PowerShell** y no el “Símbolo del sistema” (CMD), porque los comandos de este manual son para PowerShell. Vas a ver un texto parecido a:

```text
PS C:\Users\Lemuel>
```

Ese texto se llama **prompt** y significa que la terminal está lista para recibir comandos.

### Paso 7. Conectarte por SSH

**Dónde:** en tu computadora (PowerShell).

Si tu proveedor te dio **contraseña**:

```powershell
ssh USUARIO_SSH@IP_DEL_SERVIDOR
```

Si tu proveedor te dio una **clave `.pem`**:

```powershell
ssh -i "C:\ruta\a\tu_clave.pem" USUARIO_SSH@IP_DEL_SERVIDOR
```

Reemplazá `C:\ruta\a\tu_clave.pem` por la ruta real. Si la ruta tiene espacios, dejá las comillas.

La primera vez te va a preguntar si confiás en el servidor. Escribí `yes` y presioná Enter. Si te pide contraseña, escribila y presioná Enter. **La contraseña no se muestra en pantalla mientras la escribís**; es normal.

**Deberías ver:** un prompt parecido a `lemuel@servidor:~$` o `root@servidor:~#`. Eso significa que ya estás dentro del servidor.

> **Si `sudo` no existe** porque ya estás como `root`, no pasa nada: podés ejecutar los comandos sin la palabra `sudo`. Si `sudo` existe, usalo tal como está en el manual.

### Paso 8. Actualizar el sistema

**Dónde:** en el servidor (SSH).

```bash
sudo apt update
sudo apt upgrade -y
```

**Deberías ver:** muchas líneas de texto y, al final, algo parecido a `0 upgraded, 0 newly installed`. Si aparece una pregunta, presioná Enter para aceptar la opción predeterminada.

### Paso 9. Instalar las herramientas básicas

**Dónde:** en el servidor (SSH).

```bash
sudo apt install -y ca-certificates curl gnupg unzip rsync nginx ufw nano openssl
```

Verificá que Nginx y `unzip` quedaron instalados:

```bash
nginx -v
unzip -v
```

**Deberías ver:** la versión de Nginx (por ejemplo `nginx version: nginx/1.24.0`) y la versión de `unzip`.

### Paso 10. Configurar la zona horaria

**Dónde:** en el servidor (SSH).

```bash
sudo timedatectl set-timezone America/Montevideo
timedatectl
```

**Deberías ver:** `Time zone: America/Montevideo (-03, -0300)`.

### Paso 11. Crear la carpeta del proyecto

**Dónde:** en el servidor (SSH).

```bash
sudo mkdir -p /opt/cipher-forge
sudo chown -R $USER:$USER /opt/cipher-forge
```

Verificá:

```bash
ls -ld /opt/cipher-forge
```

**Deberías ver:** una línea con tu usuario como dueño de la carpeta.

**Punto de control:** si estás dentro del servidor, actualizaste el sistema y creaste la carpeta, seguí. Si no, andá a la sección 14.

---

## 4. Instalar Docker

### Paso 12. Instalar Docker desde el repositorio oficial

**Dónde:** en el servidor (SSH).

Copiá y pegá **todo** este bloque, de una sola vez:

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

**Deberías ver:** al final, algo parecido a `Setting up docker-compose-plugin` sin errores en rojo.

### Paso 13. Habilitar Docker y dar permiso a tu usuario

**Dónde:** en el servidor (SSH).

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

Ahora **cerrá la sesión SSH y volvé a entrar** para que el permiso tenga efecto:

```bash
exit
```

**Dónde:** en tu computadora (PowerShell). Volvé a conectarte con el mismo comando del Paso 7:

```powershell
ssh USUARIO_SSH@IP_DEL_SERVIDOR
```

Si usás clave:

```powershell
ssh -i "C:\ruta\a\tu_clave.pem" USUARIO_SSH@IP_DEL_SERVIDOR
```

### Paso 14. Verificar Docker

**Dónde:** en el servidor (SSH).

```bash
docker --version
docker compose version
docker run --rm hello-world
```

**Deberías ver:**
- La versión de Docker.
- La versión de Docker Compose.
- Un mensaje que empieza con `Hello from Docker!`.

**Punto de control:** si viste `Hello from Docker!`, Docker funciona. Si dice `permission denied`, cerraste y volviste a entrar mal, o el grupo no se aplicó: repetí el Paso 13. Si no, andá a la sección 14.

---

## 5. Subir el proyecto al servidor

### Paso 15. Copiar el `.zip` al servidor

**Dónde:** en tu computadora (PowerShell).

Si usás contraseña:

```powershell
scp "RUTA_DEL_ZIP" USUARIO_SSH@IP_DEL_SERVIDOR:/tmp/
```

Si usás clave:

```powershell
scp -i "C:\ruta\a\tu_clave.pem" "RUTA_DEL_ZIP" USUARIO_SSH@IP_DEL_SERVIDOR:/tmp/
```

Reemplazá `RUTA_DEL_ZIP` por la ruta real del archivo. Por ejemplo:

```powershell
scp "C:\Users\Lemuel\Downloads\Cipher_Forge.zip" root@203.0.113.10:/tmp/
```

**Deberías ver:** una barra de progreso que llega al 100 %. Si el archivo pesa mucho, puede tardar varios minutos.

> **Alternativa con WinSCP:** abrí WinSCP, conectate con la IP, el usuario y la contraseña o clave. En el panel izquierdo buscá el `.zip`; en el derecho entrá a `/tmp`; arrastrá el archivo. Es equivalente a `scp`.

### Paso 16. Descomprimir el proyecto

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge
unzip /tmp/Cipher_Forge.zip
ls -la
```

**Deberías ver:** una carpeta llamada `Gestion-fotografias` (o `Cipher_Forge`, que contiene `Gestion-fotografias`).

Si no ves `Gestion-fotografias` directamente, buscá dónde quedó:

```bash
find /opt/cipher-forge -maxdepth 3 -type d -name "Gestion-fotografias"
```

El comando te va a devolver una ruta. Si es distinta de `/opt/cipher-forge/Gestion-fotografias`, mové la carpeta:

```bash
sudo mv RUTA_QUE_DEVOLVIO_FIND /opt/cipher-forge/
```

Por ejemplo, si devolvió `/opt/cipher-forge/Cipher_Forge/Gestion-fotografias`, ejecutá:

```bash
sudo mv /opt/cipher-forge/Cipher_Forge/Gestion-fotografias /opt/cipher-forge/
```

Después entrá:

```bash
cd /opt/cipher-forge/Gestion-fotografias
ls
```

**Deberías ver:** `backend`, `frontend-cliente`, `frontend-fotografo`, `lading-page` y `docs`.

> La carpeta se llama `lading-page` (con una sola “d”), tal como viene en el proyecto. No la renombres: los enlaces dependen de ese nombre.

### Paso 17. Verificar la estructura

**Dónde:** en el servidor (SSH).

```bash
test -f backend/docker-compose.yml && echo "OK compose"
test -f frontend-cliente/pages/login.html && echo "OK cliente"
test -f frontend-fotografo/pages/login.html && echo "OK fotografo"
test -f lading-page/paginaprincipal.html && echo "OK landing"
```

**Deberías ver:** cuatro líneas `OK`.

### Paso 18. Borrar los respaldos de prueba que vienen en el `.zip`

**Dónde:** en el servidor (SSH).

```bash
rm -f backend/backups/backup_cipher_forge_*.sql
ls -la backend/backups
```

**Deberías ver:** solo el archivo `.htaccess` (y ningún `.sql`).

> **Importante:** los `.sql` que vienen en el `.zip` son respaldos de prueba del entorno de desarrollo y pueden contener datos de otras personas. En una instalación nueva no deben quedar. Si estás migrando datos reales, **no ejecutes este paso** y usá el manual de migración.

**Limpieza opcional (solo instalación nueva):** la carpeta `backend/uploads_export/` contiene fotos de prueba de la migración y este despliegue no la usa. Si no vas a migrar fotos reales, podés borrarla:

```bash
rm -rf backend/uploads_export
```

También podés borrar la clave vieja de desarrollo `backend/uploads/.jwt_secret` (la app usa `JWT_SECRET` del `.env`):

```bash
rm -f backend/uploads/.jwt_secret
```

> **No borres `uploads_export` si tu intención es migrar fotos reales.** En ese caso, pará y usá el manual de migración.

**Punto de control:** si la carpeta `/opt/cipher-forge/Gestion-fotografias` existe, tiene `backend`, los dos frontends y la landing, seguí. Si no, andá a la sección 14.

---

## 6. Configurar el proyecto

### Paso 19. Generar las contraseñas

**Dónde:** en el servidor (SSH).

Vas a generar tres claves nuevas. No reutilices contraseñas viejas ni las de desarrollo.

```bash
echo "CLAVE_ROOT=$(openssl rand -hex 24)"
echo "CLAVE_APP=$(openssl rand -hex 24)"
echo "CLAVE_JWT=$(openssl rand -hex 32)"
```

**Deberías ver:** tres líneas parecidas a estas (cada una con letras y números distintos):

```text
CLAVE_ROOT=9f2c...
CLAVE_APP=4a71...
CLAVE_JWT=be03...
```

Copiá las tres y guardalas en tu archivo `datos-cipher-forge.txt`. Las vas a usar en el Paso 21.

> **Qué son:** `CLAVE_ROOT` es la contraseña del administrador de la base de datos; `CLAVE_APP` es la que usa la aplicación para conectarse; `CLAVE_JWT` es la clave que firma las sesiones de los usuarios. Si se filtra `CLAVE_JWT`, alguien podría falsificar sesiones. No las compartas.

### Paso 20. Hacer que los frontends hablen con el mismo servidor

**Dónde:** en el servidor (SSH).

Los dos frontends tienen un archivo `config.js` que indica a qué dirección del backend llamar. En producción, el frontend y el backend están en el mismo dominio, así que hay que dejarlo vacío. Ejecutá estos dos comandos:

```bash
cd /opt/cipher-forge/Gestion-fotografias
sed -i 's|export const API_URL = .*|export const API_URL = "";|' frontend-cliente/services/config.js
sed -i 's|export const API_URL = .*|export const API_URL = "";|' frontend-fotografo/services/config.js
```

Verificá:

```bash
grep -n "API_URL" frontend-cliente/services/config.js frontend-fotografo/services/config.js
```

**Deberías ver:** en los dos archivos, una línea con `export const API_URL = "";`.

> **Qué hace esto:** si dejás `http://127.0.0.1:8080`, el navegador de cada visitante va a intentar conectarse a **su propia computadora**, no al servidor, y la web no va a funcionar. Con `""`, las llamadas van al mismo dominio desde el que se cargó la página.

### Paso 21. Crear el archivo `.env`

**Dónde:** en el servidor (SSH).

El archivo `.env` guarda las contraseñas y la configuración. Se crea una sola vez y no se comparte.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
nano .env
```

Se va a abrir el editor `nano`. Borrá todo lo que haya con `Ctrl+K` varias veces y pegá este contenido:

```env
# Base de datos
MYSQL_ROOT_PASSWORD=CLAVE_ROOT
MYSQL_DATABASE=cipher_forge
MYSQL_USER=cipher_user
MYSQL_PASSWORD=CLAVE_APP

# Sesiones
JWT_SECRET=CLAVE_JWT

# URL pública. Al principio usamos HTTP; en el Paso 40 la cambiamos a HTTPS.
FRONTEND_URL=http://TU_DOMINIO
COOKIE_SECURE=false

# Correo de producción. Estos valores se completan en la sección 11.
SMTP_HOST=TU_HOST_SMTP
SMTP_PORT=587
SMTP_USER=TU_USUARIO_SMTP
SMTP_PASS='TU_CLAVE_SMTP'
MAIL_FROM=no-reply@TU_DOMINIO
MAIL_FROM_NAME=Cipher Forge
```

Reemplazá:
- `CLAVE_ROOT`, `CLAVE_APP` y `CLAVE_JWT` por las que generaste en el Paso 19.
- `TU_DOMINIO` por tu dominio, por ejemplo `cipherforge.com`.
- Los valores `SMTP_*` y `MAIL_FROM` los vas a reemplazar en la sección 11. Por ahora dejalos así.

Para guardar y salir de `nano`:
1. `Ctrl+O` (guardar).
2. `Enter` (confirmar el nombre).
3. `Ctrl+X` (salir).

Protegé el archivo para que solo tu usuario pueda leerlo:

```bash
chmod 600 .env
ls -l .env
```

**Deberías ver:** `-rw-------` al principio de la línea del archivo. Eso significa que solo tu usuario puede leerlo.

> **Si tu contraseña SMTP tiene `#`, `$`, espacios o comillas:** dejala entre comillas simples, como se muestra en `SMTP_PASS='...'`. Las claves que generaste con `openssl` son solo letras y números, así que no tienen ese problema.

### Paso 22. Reemplazar `docker-compose.yml` por la versión de producción

**Dónde:** en el servidor (SSH).

El archivo `docker-compose.yml` que viene en el `.zip` está pensado para desarrollo y usa Mailpit. En producción hay que reemplazarlo por este, que usa el correo real y no publica la base de datos a Internet.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
nano docker-compose.yml
```

Borrá todo con `Ctrl+K` y pegá exactamente esto:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:prod
    container_name: cipher_forge_app
    restart: unless-stopped
    ports:
      # Solo accesible desde el propio servidor. Nginx es el que publica al mundo.
      - "127.0.0.1:8080:8080"
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - TZ=America/Montevideo
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - FRONTEND_URL=${FRONTEND_URL:?define FRONTEND_URL en .env}
      - JWT_SECRET=${JWT_SECRET:?define JWT_SECRET en .env}
      - COOKIE_NAME=cipher_forge_token
      - COOKIE_SECURE=${COOKIE_SECURE:-true}
      - COOKIE_SAMESITE=Strict
      - SMTP_HOST=${SMTP_HOST:?define SMTP_HOST en .env}
      - SMTP_PORT=${SMTP_PORT:?define SMTP_PORT en .env}
      - SMTP_USER=${SMTP_USER:-}
      - SMTP_PASS=${SMTP_PASS:-}
      - MAIL_FROM=${MAIL_FROM:?define MAIL_FROM en .env}
      - MAIL_FROM_NAME=${MAIL_FROM_NAME:-Cipher Forge}
    depends_on:
      - db

  worker:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:prod
    container_name: cipher_forge_worker
    restart: unless-stopped
    command: php cron-backup.php --loop
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - TZ=America/Montevideo
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - BACKUP_INTERVAL_SEG=86400
      - PURGE_INTERVAL_SEG=3600
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: cipher_forge_db
    restart: unless-stopped
    environment:
      - TZ=America/Montevideo
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

Guardá con `Ctrl+O`, `Enter`, `Ctrl+X`.

Validá que el archivo esté bien escrito y que las variables existan:

```bash
docker compose config --quiet
```

**Deberías ver:** nada. Si no muestra ningún mensaje, está bien. Si dice `required variable ... is missing` o `define ... en .env`, revisá el Paso 21: falta una línea o quedó un placeholder mal escrito.

> **Qué hace este archivo:** levanta tres contenedores:
> - `app`: la aplicación PHP.
> - `worker`: el que hace los respaldos y limpia archivos temporales.
> - `db`: la base de datos MySQL.
>
> No incluye Mailpit. La base de datos no está publicada a Internet: solo la ve la aplicación. La aplicación solo escucha en `127.0.0.1:8080` (dentro del servidor); Nginx es el que la publica.

### Paso 23. Ajustar permisos de archivos

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias
sudo chmod -R a+rX .
sudo chmod 600 backend/.env
sudo chown -R 33:33 backend/backups
sudo chmod -R 775 backend/backups
```

Verificá:

```bash
ls -ld backend/backups
ls -l backend/.env
```

**Deberías ver:** `backend/backups` con dueño `33` o `www-data`, y `backend/.env` con permisos `-rw-------`.

**Punto de control:** si `docker compose config --quiet` no dio errores y los permisos se ven bien, seguí. Si no, andá a la sección 14.

---

## 7. Arrancar la base de datos y la aplicación

### Paso 24. Levantar solo la base de datos

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose up -d db
docker compose logs -f db
```

Vas a ver los mensajes de MySQL. Esperá hasta encontrar una línea parecida a:

```text
[Server] /usr/sbin/mysqld: ready for connections.
```

Cuando la veas, salí de los logs con `Ctrl+C`. El contenedor sigue corriendo.

Verificá que esté arriba:

```bash
docker compose ps
```

**Deberías ver:** el servicio `db` con estado `Up` (o `running`).

### Paso 25. Verificar que la base responde

**Dónde:** en el servidor (SSH).

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SHOW DATABASES;"'
```

**Deberías ver:** una lista con `cipher_forge` entre las bases de datos.

> Si no aparece `cipher_forge`, la base no terminó de inicializarse o el volumen quedó a medias. Mirá los logs con `docker compose logs --tail=100 db` y andá a la sección 14. No borres volúmenes sin leer esa sección.

### Paso 26. Levantar la aplicación y el worker

**Dónde:** en el servidor (SSH).

```bash
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 app
```

La primera vez, `--build` compila la imagen de PHP con FFmpeg y las extensiones. Puede tardar entre 2 y 10 minutos.

**Deberías ver:** `app`, `worker` y `db` con estado `Up`. En los logs de `app`, mensajes de migración completada y ningún error fatal.

Probá la API directamente en el servidor:

```bash
curl -s http://127.0.0.1:8080/api/ping
```

**Deberías ver:** un JSON parecido a:

```json
{"ok":true,"mensaje":"Conexión exitosa con el backend","datos":{"servidor":"Cipher_Forge Backend API","estado":"activo","hora":"..."}}
```

Si no responde, mirá `docker compose logs --tail=100 app` y andá a la sección 14.

### Paso 27. Verificar las tablas

**Dónde:** en el servidor (SSH).

```bash
docker compose exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "USE cipher_forge; SHOW TABLES;"'
```

**Deberías ver:** 11 tablas:

```text
acceso_colecciones
backups
clientes
coleccion_hashtags
colecciones
favoritos
fotografos
hashtags
multimedia
qr_tokens
usuarios
```

Si falta alguna, la migración no se aplicó. Revisá los logs de `app` y la sección 14.

### Paso 28. Generar un respaldo de prueba

**Dónde:** en el servidor (SSH).

```bash
docker compose exec -T app php cron-backup.php
ls -lh backups
```

**Deberías ver:** un archivo nuevo llamado `backup_cipher_forge_FECHA.sql` y una línea con `[OK]` en la salida del comando.

Si ves un error de permisos, repetí el Paso 23 y volvé a probar.

**Punto de control:** si la API responde, las 11 tablas existen y se generó un respaldo, la base y la aplicación están funcionando. Si no, andá a la sección 14.

---

## 8. Configurar Nginx

Nginx es el programa que recibe las visitas a tu dominio. Sirve los archivos del frontend y manda las llamadas de la API al contenedor `app`.

### Paso 29. Crear el sitio de Nginx

**Dónde:** en el servidor (SSH).

```bash
sudo nano /etc/nginx/sites-available/cipher-forge
```

Pegá este contenido. Reemplazá `TU_DOMINIO` por tu dominio (aparece dos veces en la línea `server_name`):

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name TU_DOMINIO www.TU_DOMINIO;

    root /opt/cipher-forge/Gestion-fotografias;
    index index.html;

    # Permite subir videos de hasta 800 MB (con margen).
    client_max_body_size 900m;
    client_body_timeout 600s;

    # La raíz redirige a la landing.
    location = / {
        return 302 /lading-page/paginaprincipal.html;
    }

    # No servir código, respaldos, documentación ni archivos ocultos.
    location ~ ^/(backend|docs)(/|$) { deny all; }
    location ~ /\. { deny all; }
    location ~* \.(env|sql|md|yml|yaml|ini|log|sh|properties)$ { deny all; }

    # Rutas de la API. Se excluye /sistema/* a propósito.
    location ~ ^/(auth|fotografos?|colecciones|multimedia|invitaciones|hashtags|favoritos|colaborativo|qr|api)(/|$) {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        # $http_host conserva el dominio y el puerto que ve el navegador.
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        proxy_request_buffering off;
    }

    # Endpoints administrativos: se deniegan por completo.
    location ^~ /sistema { deny all; }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Guardá con `Ctrl+O`, `Enter`, `Ctrl+X`.

> **Qué hace:** Nginx sirve la landing y los dos frontends como archivos estáticos. Cuando el navegador pide `/auth/login`, `/colecciones`, `/multimedia`, `/qr` o `/api/ping`, Nginx lo manda al contenedor `app` en `127.0.0.1:8080`. También bloquea `/backend`, `/docs`, `.env`, `.sql` y `/sistema`.

### Paso 30. Activar el sitio

**Dónde:** en el servidor (SSH).

```bash
sudo ln -sf /etc/nginx/sites-available/cipher-forge /etc/nginx/sites-enabled/cipher-forge
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

**Deberías ver:** dos líneas que dicen `syntax is ok` y `test is successful`.

Si `nginx -t` da un error, **no ejecutes** `systemctl reload nginx`: corregí el archivo del Paso 29 y volvé a probar. La sección 14 tiene los errores más comunes.

### Paso 31. Probar desde el propio servidor

**Dónde:** en el servidor (SSH).

```bash
curl -I http://127.0.0.1/
curl -I -L http://127.0.0.1/
curl -I http://127.0.0.1/lading-page/paginaprincipal.html
curl -I http://127.0.0.1/frontend-cliente/pages/login.html
curl -I http://127.0.0.1/frontend-fotografo/pages/login.html
curl -s http://127.0.0.1/api/ping
```

**Deberías ver:**
- La primera: `302 Found` con `Location: /lading-page/paginaprincipal.html`.
- La segunda: `200 OK`.
- Las tres siguientes: `200 OK`.
- La última: el JSON de la API con `"ok":true`.

Comprobá también que los archivos privados no se puedan leer desde Internet:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/backend/.env
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/sistema/backups
```

**Deberías ver:** `403` en las dos. Si ves `200`, **no sigas**: revisá la configuración del Paso 29 antes de publicar el sitio.

Si ves `502 Bad Gateway`, Nginx no puede hablar con el contenedor. Revisá `docker compose ps` y `curl -s http://127.0.0.1:8080/api/ping`; la sección 14 lo explica.

### Paso 32. Activar el firewall de Ubuntu

**Dónde:** en el servidor (SSH).

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
sudo ufw status
```

**Deberías ver:** reglas para `OpenSSH`, `Nginx Full` (80 y 443) y el estado `active`.

> Si tu proveedor tiene su propio firewall (Paso 2), dejalo también con 22, 80 y 443. No abras 3306, 8025 ni 1025.

### Paso 33. Probar desde tu computadora

**Dónde:** en tu computadora (PowerShell).

```powershell
curl.exe -I http://IP_DEL_SERVIDOR/
```

**Deberías ver:** `302 Found` o `200 OK`. Si no responde, revisá el firewall del proveedor y el de Ubuntu.

**Punto de control:** si desde tu computadora ves la redirección o un `200`, Nginx está publicando el sitio. Si no, andá a la sección 14.

---

## 9. Configurar el dominio y el DNS

El **DNS** es la agenda que traduce tu dominio (`cipherforge.com`) a la IP del servidor (`203.0.113.10`). Sin esto, el dominio no sabe a dónde ir.

### Paso 34. Crear los registros DNS

**Dónde:** en el panel de DNS de tu registrador de dominios.

Creá estos dos registros:

| Tipo | Nombre | Valor | TTL |
|---|---|---|---|
| A | `@` | `IP_DEL_SERVIDOR` | 300 (o automático) |
| A | `www` | `IP_DEL_SERVIDOR` | 300 (o automático) |

- El nombre `@` representa el dominio principal (`cipherforge.com`).
- El nombre `www` representa `www.cipherforge.com`.
- `TTL` es el tiempo que los servidores de Internet guardan el dato en memoria. 300 segundos (5 minutos) está bien.
- Si tu panel no acepta `@`, dejá el campo “Nombre” vacío o poné el dominio completo.

**Deberías ver:** los dos registros guardados en la lista del panel.

> **Si usás Cloudflare:** dejá los dos registros en modo **“DNS only”** (nube gris). Si están en “Proxied” (nube naranja), Certbot puede fallar al validar el dominio. Después de obtener el certificado podés activar el proxy si querés.

### Paso 35. Esperar la propagación del DNS

**Dónde:** en tu computadora (PowerShell), después de unos minutos.

La propagación tarda normalmente entre **5 y 30 minutos**, pero puede llegar a **24 o 48 horas** si tu registrador es lento. Esperá y repetí la verificación. **No avances al Paso 36 ni ejecutes Certbot (Paso 38) hasta que el DNS responda.**

Verificá:

```powershell
nslookup TU_DOMINIO
nslookup www.TU_DOMINIO
```

**Deberías ver:** en la respuesta, la `IP_DEL_SERVIDOR`. Puede aparecer más de una dirección; lo importante es que esté la tuya.

Si no aparece, esperá 10 minutos y repetí. Si pasaron 48 horas y sigue mal, revisá que los registros estén guardados y que el dominio use los nameservers correctos del registrador.

### Paso 36. Probar el dominio por HTTP

**Dónde:** en tu computadora (PowerShell).

```powershell
curl.exe -I -L http://TU_DOMINIO/
```

**Deberías ver:** `200 OK` y, si abrís `http://TU_DOMINIO` en el navegador, la landing de Cipher Forge.

**Punto de control:** si el dominio carga la landing por HTTP, seguí. Si no, andá a la sección 14.

---

## 10. Activar HTTPS

**HTTPS** es la versión cifrada de la web: la que muestra el candado en el navegador. Se activa con un certificado gratuito de **Let’s Encrypt**, usando una herramienta llamada **Certbot**.

### Paso 37. Instalar Certbot

**Dónde:** en el servidor (SSH).

```bash
sudo apt install -y certbot python3-certbot-nginx
```

**Deberías ver:** el paquete instalado sin errores.

### Paso 38. Obtener el certificado

**Dónde:** en el servidor (SSH).

```bash
sudo certbot --nginx -d TU_DOMINIO -d www.TU_DOMINIO
```

Certbot te va a hacer preguntas:
1. **Correo electrónico:** escribí tu correo real (sirve para avisos de vencimiento).
2. **Términos:** escribí `A` para aceptar.
3. **Compartir correo con Let’s Encrypt:** podés elegir `N` (no) o `Y` (sí).
4. **Redirigir HTTP a HTTPS:** elegí `2` (Redirect). Así todo el mundo usa la versión segura.

**Deberías ver:** un mensaje que dice `Congratulations! You have successfully enabled HTTPS` y las rutas de los certificados.

Si falla:
- `DNS problem: NXDOMAIN` → el DNS todavía no propagó. Esperá y repetí el Paso 35.
- `Timeout during connect` → el puerto 80 está bloqueado. Revisá el firewall del proveedor y `sudo ufw status`.
- `Could not automatically find a matching server block` → el `server_name` del Paso 29 no coincide con el dominio. Corregilo y repetí.

### Paso 39. Probar HTTPS

**Dónde:** en tu computadora (PowerShell).

```powershell
curl.exe -I https://TU_DOMINIO/
```

**Deberías ver:** `200 OK`. Abrí `https://TU_DOMINIO` en el navegador: tiene que aparecer el candado.

### Paso 40. Actualizar el `.env` para HTTPS

**Dónde:** en el servidor (SSH).

Ahora que el sitio es HTTPS, hay que decirle a la aplicación que use esa dirección y que las cookies viajen solo por conexiones seguras.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
nano .env
```

Cambiá estas dos líneas:

```env
FRONTEND_URL=https://TU_DOMINIO
COOKIE_SECURE=true
```

Guardá con `Ctrl+O`, `Enter`, `Ctrl+X`.

Recreá la aplicación para que lea los cambios:

```bash
docker compose up -d --force-recreate app worker
docker compose ps
```

**Deberías ver:** `app` y `worker` arriba, sin reinicios en loop.

> **Por qué:** `FRONTEND_URL` se usa para generar los enlaces de los QR y para validar el origen de las peticiones. `COOKIE_SECURE=true` hace que la cookie de sesión solo viaje por HTTPS. Si te equivocás en esta parte, el login puede fallar o el QR puede salir con `http://` o con una IP.

### Paso 41. Verificar que la renovación automática funciona

**Dónde:** en el servidor (SSH).

```bash
sudo certbot renew --dry-run
```

**Deberías ver:** `Congratulations, all simulated renewals succeeded`. Certbot renueva solo, dos veces al día; no tenés que hacer nada más.

**Punto de control:** si `https://TU_DOMINIO` tiene candado y el login funciona, seguí. Si no, andá a la sección 14.

---

## 11. Configurar el correo de producción

### Paso 42. Entender cómo envía correo el proyecto

**Dónde:** leé esta explicación antes de contratar el proveedor.

El proyecto envía correos con **SMTP**, no con una API. El código está en `backend/src/helpers/Mailer.php` y lee estas variables de entorno:

| Variable | Para qué sirve |
|---|---|
| `SMTP_HOST` | Dirección del servidor de correo del proveedor |
| `SMTP_PORT` | Puerto SMTP |
| `SMTP_USER` | Usuario SMTP |
| `SMTP_PASS` | Contraseña o clave SMTP |
| `MAIL_FROM` | Dirección desde la que sale el correo |
| `MAIL_FROM_NAME` | Nombre visible del remitente |

En desarrollo, el proyecto usa **Mailpit**, un buzón falso que corre en tu computadora y no entrega correos a Internet. **En producción Mailpit no sirve.** Por eso el `docker-compose.yml` del Paso 22 lo eliminó y usa un proveedor real.

> **Limitación importante de esta versión:** el `Mailer.php` actual abre una conexión SMTP **sin cifrado** (no usa TLS/STARTTLS). La mayoría de los proveedores modernos exigen cifrado en los puertos 587 o 465. Si tu proveedor lo exige, el envío va a fallar hasta que el equipo técnico aplique el cambio del Paso 47. Es un cambio pequeño, pero **no lo intentes hacer vos si no sabés programar**. Antes de contratar, preguntá al proveedor:
>
> - ¿Ofrecen SMTP además de API?
> - ¿Qué host y puerto tengo que usar?
> - ¿El puerto requiere TLS/STARTTLS?
> - ¿Permiten verificar un dominio propio con SPF y DKIM?
>
> Si el proveedor solo ofrece API, no sirve para este proyecto.

### Paso 43. Elegir el proveedor de correo

**Dónde:** en tu computadora, comparando opciones.

Criterios simples para elegir:

1. **Que tenga SMTP**, no solo API. Es el requisito número uno.
2. **Que permita verificar tu dominio** y te dé los registros SPF y DKIM.
3. **Que tenga un plan gratuito o barato** para empezar. Para este proyecto, unos cientos de correos por mes alcanzan.
4. **Que muestre registros de entrega** (para saber si un correo salió, rebotó o fue rechazado).
5. **Que tenga soporte** en español o inglés, por si algo falla.
6. **Que no te obligue a usar un remitente genérico**: el correo tiene que salir de `no-reply@TU_DOMINIO`, no de un Gmail.

Opciones habituales:

| Proveedor | Ventaja | A tener en cuenta |
|---|---|---|
| **Resend** | Fácil de configurar, buen panel | Requiere TLS en el puerto 587; puede necesitar el cambio del Paso 47 |
| **Brevo** | Plan gratuito generoso, buena entrega | Requiere TLS/STARTTLS |
| **Mailgun** | Muy usado, buenos logs | Requiere TLS; el plan gratuito es limitado |
| **SendGrid** | Conocido, buena documentación | Requiere TLS; a veces la entrega tarda en calentar |
| **Amazon SES** | Muy barato a escala | Empieza en “sandbox”: hay que pedir acceso a producción y explicar el uso |

Para empezar sin complicaciones, Resend o Brevo suelen ser los más simples. **No contrates Amazon SES si no querés lidiar con el pedido de salida del sandbox.**

**Deberías ver:** una cuenta creada y una pantalla con los datos SMTP (host, puerto, usuario y contraseña).

### Paso 44. Verificar el dominio en el proveedor de correo

**Dónde:** en el panel del proveedor de correo y en el panel de DNS de tu dominio.

1. En el proveedor, agregá tu dominio (`TU_DOMINIO`).
2. El proveedor te va a mostrar registros DNS. Normalmente son:
   - Un registro **SPF** (TXT en `@`).
   - Uno o más registros **DKIM** (TXT en un nombre parecido a `resend._domainkey` o `selector._domainkey`).
   - Opcionalmente, un registro **DMARC** (TXT en `_dmarc`).
3. Copiá esos registros **tal como te los da el proveedor** y cargalos en el panel de DNS de tu dominio.
4. Guardá y esperá. La verificación del dominio puede tardar entre **5 minutos y 24 horas**; los registros DNS pueden tardar hasta **48 horas** en propagarse.

**Qué significa cada uno:**
- **SPF:** una lista de servidores autorizados a enviar correo en nombre de tu dominio.
- **DKIM:** una firma digital que demuestra que el correo salió de tu dominio y no fue alterado.
- **DMARC:** una instrucción que les dice a los servidores de correo qué hacer si un mensaje no cumple SPF o DKIM. Empezá con `p=none` para observar, y más adelante podés endurecerlo.

> **Si ya tenías un registro SPF** (por ejemplo, porque usás ese dominio para correo normal), no crees un segundo SPF: agregá el proveedor dentro del mismo registro. Dos registros SPF en el mismo dominio hacen que la validación falle.

Verificá los registros desde tu computadora:

```powershell
nslookup -type=TXT TU_DOMINIO
nslookup -type=TXT SELECTOR._domainkey.TU_DOMINIO
```

En el segundo comando, reemplazá `SELECTOR` por el nombre que te dio el proveedor (por ejemplo, `resend`, `s1` o `mail`). Está en el nombre del registro DKIM que copiaste.

**Deberías ver:** un texto que incluye `v=spf1` y el proveedor, y una clave larga para DKIM. Si no aparece, esperá y repetí.

**Punto de control:** el proveedor tiene que mostrar el dominio como **“Verified”** o **“Verificado”**. Si no, no sigas: sin dominio verificado, los correos van a rebotar o caer en spam.

### Paso 45. Completar los datos SMTP en el `.env`

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
nano .env
```

Reemplazá estas líneas por los datos reales del proveedor. Ojo: a la izquierda va el **nombre fijo** de la variable; a la derecha va **tu dato**.

```env
SMTP_HOST=TU_HOST_SMTP
SMTP_PORT=TU_PUERTO_SMTP
SMTP_USER=TU_USUARIO_SMTP
SMTP_PASS='TU_CLAVE_SMTP'
MAIL_FROM=no-reply@TU_DOMINIO
MAIL_FROM_NAME=Cipher Forge
```

- `TU_HOST_SMTP`: por ejemplo `smtp.resend.com`.
- `TU_PUERTO_SMTP`: normalmente `587`.
- `TU_USUARIO_SMTP`: el usuario que da el panel (a veces es `resend`, `apikey` o tu correo).
- `TU_CLAVE_SMTP`: la clave o API key, **entre comillas simples**.

Por ejemplo, para un proveedor que usa `smtp.resend.com` en el puerto 587:

```env
SMTP_HOST=smtp.resend.com
SMTP_PORT=587
SMTP_USER=resend
SMTP_PASS='re_xxxxxxxxxxxxxxxxx'
MAIL_FROM=no-reply@cipherforge.com
MAIL_FROM_NAME=Cipher Forge
```

> Los valores exactos te los da **tu** proveedor. No copies los del ejemplo: son solo una muestra. El usuario SMTP no siempre es el correo; a veces es `resend`, `apikey` o el usuario que te indica el panel.

Guardá y recreá la aplicación:

```bash
docker compose up -d --force-recreate app worker
```

Verificá que las variables llegaron al contenedor:

```bash
docker compose exec -T app printenv | grep -E 'SMTP|MAIL_FROM'
```

**Deberías ver:** las seis variables con tus valores. Si no aparecen, el `docker-compose.yml` del Paso 22 no se guardó bien o el `.env` tiene un error de escritura.

### Paso 46. Probar el envío con un correo de prueba

**Dónde:** en el servidor (SSH).

Primero creá un pequeño script de prueba. Copiá **todo** el bloque, incluido `<?php` y `PHP` del final:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
cat > test-mail.php <<'PHP'
<?php
spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    if (strncmp($prefix, $class, strlen($prefix)) !== 0) {
        return;
    }
    $file = '/var/www/html/src/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

$destino = 'TU_CORREO';
$ok = App\helpers\Mailer::enviar(
    $destino,
    'Prueba de correo de Cipher Forge',
    'Este es un correo de prueba enviado desde el servidor.',
    '<p>Este es un correo de prueba enviado desde el servidor.</p>'
);

echo $ok ? "ENVIADO\n" : "ERROR\n";
$error = App\helpers\Mailer::lastError();
if ($error !== null) {
    echo $error . "\n";
}
PHP
```

Reemplazá `TU_CORREO` por tu correo real (dejá las comillas simples). Ejecutá:

```bash
docker compose exec -T app php /var/www/html/test-mail.php
```

**Deberías ver:** `ENVIADO`. Revisá tu bandeja de entrada (y la carpeta de spam). Si ves `ERROR` con un mensaje, anotá el mensaje y andá a la sección 14.

Cuando termines, borrá el script de prueba:

```bash
rm test-mail.php
```

### Paso 47. Si el proveedor exige cifrado (TLS)

**Dónde:** esta parte es para el equipo técnico, no para Lemuel.

Si el Paso 46 devuelve un error parecido a `No se pudo conectar al servidor SMTP`, `Respuesta SMTP inesperada` o el proveedor rechaza la conexión porque exige TLS, el `Mailer.php` actual no puede comunicarse con ese proveedor. Tenés dos caminos:

**Opción A (poco recomendada):** pedir al proveedor un puerto SMTP sin cifrado. Casi ningún proveedor serio lo ofrece, y enviar credenciales sin cifrado no es seguro. No lo hagas salvo que el proveedor lo autorice por escrito y sea un entorno controlado.

**Opción B (recomendada):** que el equipo técnico agregue soporte de **STARTTLS** al `Mailer.php`. El cambio es este: en `backend/src/helpers/Mailer.php`, dentro del método `enviar()`, después del primer `EHLO` y antes del bloque de `AUTH LOGIN`, insertar:

```php
// Si el proveedor usa STARTTLS (por ejemplo, puerto 587), cifrar la conexión.
if (in_array($port, [587, 2525], true)) {
    self::enviarComando($conn, 'STARTTLS');
    if (!self::leerRespuesta($conn, '220')) {
        return false;
    }
    if (!stream_socket_enable_crypto($conn, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
        self::$lastError = 'No se pudo iniciar TLS con el servidor SMTP.';
        return false;
    }
    self::enviarComando($conn, 'EHLO cipherforge.local');
    if (!self::leerRespuestaMultilinea($conn)) {
        return false;
    }
}
```

Después del cambio, reiniciá la aplicación y repetí el Paso 46:

```bash
docker compose restart app
docker compose exec -T app php /var/www/html/test-mail.php
```

> **Importante:** este cambio es una **propuesta técnica** y no está aplicado en el `.zip`. Que el equipo lo pruebe con el proveedor real antes de un evento. Si el proveedor usa el puerto **465** (SSL directo, no STARTTLS), este parche no alcanza: hay que usar el puerto **587** o hacer un cambio distinto. Usá 587 siempre que puedas.
>
> Si el proveedor solo ofrece API y no SMTP, este parche tampoco sirve: hay que cambiar el código para usar la API o elegir otro proveedor.

### Paso 48. Probar el flujo completo de verificación

**Dónde:** en tu computadora, con el navegador.

1. Abrí `https://TU_DOMINIO/frontend-fotografo/pages/registro.html`.
2. Registrate con un correo real que puedas abrir.
3. Revisá la bandeja de entrada. Deberías recibir un correo de **Cipher Forge** con un código de 6 dígitos.
4. Ingresá el código en la pantalla de verificación.
5. Iniciá sesión.

**Deberías ver:** el panel del fotógrafo, sin mensajes de “correo no verificado”.

Si no llega el correo:
- Revisá spam.
- Mirá `docker compose logs --tail=100 app` y buscá `No se pudo enviar el correo`.
- Revisá el Paso 46 y la sección 14.
- Si el correo no funciona pero necesitás desbloquear una cuenta para probar, **no la verifiques a mano en la base salvo que sepas lo que hacés**: pedí ayuda al equipo.

### Paso 49. Probar la entrega en Gmail y Outlook

**Dónde:** en tu computadora.

1. Registrate con un Gmail y con un Outlook.
2. Revisá que el correo llegue a la bandeja de entrada, no a spam.
3. Si cae en spam, revisá que SPF, DKIM y DMARC estén bien cargados y esperá 24–48 horas. Los dominios nuevos tardan en ganar reputación.
4. Revisá los logs del proveedor de correo: te dicen si el mensaje fue entregado, rebotado o marcado como spam.

**Punto de control:** si recibís el código en Gmail y Outlook, el correo de producción está funcionando. Si no, andá a la sección 14.

---

## 12. Pruebas finales

### Paso 50. Revisar que todos los servicios estén arriba

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose ps
```

**Deberías ver:** `cipher_forge_app`, `cipher_forge_worker` y `cipher_forge_db` con estado `Up` (o `running`). No debería aparecer `cipher_forge_mail`: Mailpit no se usa en producción.

Revisá los logs por errores:

```bash
docker compose logs --tail=100 app
docker compose logs --tail=100 worker
docker compose logs --tail=100 db
```

**Deberías ver:** mensajes normales, sin `fatal`, `error` repetidos ni reinicios en loop.

### Paso 51. Probar la web desde tu computadora

**Dónde:** en tu computadora (PowerShell).

```powershell
curl.exe -I -L https://TU_DOMINIO/
curl.exe -I https://TU_DOMINIO/lading-page/paginaprincipal.html
curl.exe -I https://TU_DOMINIO/frontend-cliente/pages/login.html
curl.exe -I https://TU_DOMINIO/frontend-fotografo/pages/login.html
curl.exe -s https://TU_DOMINIO/api/ping
```

**Deberías ver:** `200 OK` en las páginas y el JSON de la API con `"ok":true`.

Abrí en el navegador:
- `https://TU_DOMINIO/` → landing.
- `https://TU_DOMINIO/frontend-fotografo/pages/login.html` → login del fotógrafo.
- `https://TU_DOMINIO/frontend-cliente/pages/login.html` → login del cliente.

**Deberías ver:** las tres páginas con el candado de HTTPS.

### Paso 52. Probar el flujo completo

**Dónde:** en tu computadora y en un celular.

1. Registrate como fotógrafo con un correo real.
2. Verificá el correo con el código.
3. Iniciá sesión.
4. Creá una colección.
5. Subí una foto JPG (menos de 30 MB) y, si querés, un video MP4 (menos de 800 MB).
6. Generá el QR colaborativo o el QR de acceso.
7. Copiá el enlace del QR. **Tiene que empezar con `https://TU_DOMINIO/`**, no con `localhost`, `127.0.0.1` ni una IP.
8. Abrí ese enlace en el celular, usando **datos móviles** (no la misma WiFi), para comprobar que es público.
9. Subí una foto desde el celular.
10. Entrá a **Moderación** en el panel del fotógrafo y aprobá la foto.
11. Entrá como cliente, abrí la colección y descargá una foto.

**Deberías ver:** todo el flujo funciona, el QR abre desde el celular y la foto aparece en moderación.

> Si el QR abre `localhost` o una IP, revisá `FRONTEND_URL` en `.env` (Paso 40), recreá `app` con `docker compose up -d --force-recreate app` y generá un QR nuevo. Los QR viejos no se actualizan solos.

### Paso 53. Probar un reinicio del servidor

**Dónde:** en el servidor (SSH).

```bash
sudo reboot
```

La conexión SSH se va a cortar. Esperá **1 o 2 minutos** y volvé a conectarte con el comando del Paso 7.

Verificá:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose ps
sudo systemctl status nginx
```

**Deberías ver:** los tres contenedores arriba y Nginx `active (running)`. Con `restart: unless-stopped`, Docker los levanta solo al arrancar.

> Si después del reinicio no vuelven, revisá `sudo systemctl status docker` y los logs. La sección 14 lo explica.

### Paso 54. Revisión de seguridad antes de abrirlo al público

**Dónde:** en el servidor (SSH) y en tu cabeza.

Antes de mandar el enlace a tus clientes, verificá:

- [ ] El sitio abre con `https://` y candado.
- [ ] `http://` redirige a `https://`.
- [ ] La base de datos no está publicada a Internet (no hay puerto 3306 abierto).
- [ ] Mailpit no está instalado en producción.
- [ ] `.env` tiene permisos `600`.
- [ ] Las contraseñas son nuevas y están guardadas.
- [ ] Hay un respaldo generado y una copia fuera del servidor (sección 13).
- [ ] Probaste el registro, el correo, la subida y el QR.
- [ ] El equipo técnico revisó la lista de mejoras pendientes de `docs/infraestructura.md` (sección 6) antes de un evento grande.

> **Importante:** este manual deja el sitio funcionando con HTTPS, pero el proyecto tiene mejoras de seguridad que el equipo técnico debe revisar antes de manejar muchos datos personales. No las resuelvas vos: coordiná con nosotros. Ejemplos: límites de subida y cuotas, mensajes de error internos, tokens en URLs y pruebas de restauración de respaldos.

**Punto de control:** si el sitio abre con candado, el registro y el correo funcionan, el QR abre desde el celular y el servidor reinicia solo, la puesta en producción está terminada. Si algo falla, andá a la sección 14.

---

## 13. Copias de seguridad y mantenimiento

### Paso 55. Entender qué respalda el sistema

**Dónde:** leé esta explicación.

El contenedor `worker` ejecuta `php cron-backup.php --loop` y hace lo siguiente:

- Cada **24 horas** genera un respaldo `.sql` de la base en `backend/backups/`.
- Guarda solo las **últimas 3 copias**.
- Cada **hora** borra las fotos colaborativas no aprobadas que tengan más de 24 horas.

**El respaldo de la base no incluye las fotos ni los videos.** Las fotos viven en el volumen `uploads_data` y hay que respaldarlas aparte. Esto es importante: si solo guardás los `.sql`, perdés las fotos.

### Paso 56. Verificar que el respaldo se genera

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
ls -lh backups
docker compose logs --tail=50 worker
```

**Deberías ver:** archivos `backup_cipher_forge_FECHA.sql` y líneas de `[OK]` en los logs.

### Paso 57. Guardar una copia fuera del servidor

**Dónde:** en el servidor (SSH) y en tu computadora.

Una copia en el mismo servidor no sirve si el servidor se rompe. Tenés dos opciones:

**Opción A (la más fácil): snapshots del proveedor.**
En el panel del VPS, activá los **snapshots** o copias automáticas semanales. El proveedor guarda una imagen completa del servidor. Cuesta un poco más, pero no requiere comandos.

**Opción B: descargar los respaldos.**
1. Descargá la carpeta `backend/backups/` con WinSCP a tu computadora.
2. Guardala en un disco externo o en la nube.
3. Para las fotos, generá un archivo comprimido del volumen:

```bash
sudo mkdir -p /srv/backups/cipher-forge/uploads
sudo chown -R $USER:$USER /srv/backups/cipher-forge
docker volume ls | grep uploads
```

El último comando te muestra el nombre real del volumen. Normalmente es `backend_uploads_data`, pero puede ser `gestion-fotografias_uploads_data`. En el comando siguiente, reemplazá `backend_uploads_data` por el nombre que te haya aparecido:

```bash
docker run --rm \
  -v NOMBRE_REAL_DEL_VOLUMEN:/data \
  -v /srv/backups/cipher-forge/uploads:/backup \
  alpine sh -c 'tar czf /backup/uploads_$(date +%F_%H-%M).tar.gz -C /data .'
```

Por ejemplo, si el comando anterior mostró `backend_uploads_data`, usá exactamente ese nombre.

Ajustá el dueño del archivo para poder descargarlo con tu usuario:

```bash
sudo chown -R $USER:$USER /srv/backups/cipher-forge/uploads
```

**Deberías ver:** un archivo `.tar.gz` en `/srv/backups/cipher-forge/uploads/`. Descargalo con WinSCP.

> Los `.sql` contienen datos personales (usuarios, correos, hashes de contraseñas). No los subas a GitHub ni los dejes en una carpeta pública.

### Paso 58. Probar una restauración (con el equipo técnico)

**Dónde:** en el servidor, con ayuda técnica.

Una copia que nunca se restauró no está probada. **No restaures sobre la base real**: se borrarían los datos. El procedimiento seguro está en el manual de migración, sección 10.4. Pedinos que lo ejecutemos en una base de prueba antes de un evento importante.

**Deberías ver:** el equipo confirma que el respaldo se puede restaurar y que los datos coinciden. Si nadie lo probó, marcalo como **pendiente**.

### Paso 59. Actualizar el código en el futuro

**Dónde:** en tu computadora y en el servidor.

Cuando te enviemos una versión nueva:

1. Guardá una copia de `backend/.env`, de `backend/backups/`, de `backend/docker-compose.yml` y de los dos `services/config.js` (no los pisés).
2. Subí los archivos nuevos con WinSCP o `scp`, sin borrar ni reemplazar esos archivos. Si el `.zip` nuevo trae otro `docker-compose.yml`, **no lo copies**: el de producción es el del Paso 22. Si el equipo cambió el compose a propósito, te lo va a avisar.
3. Reconstruí:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose up -d --build
docker compose logs --tail=100 app
```

**Deberías ver:** los contenedores arriba y la web funcionando.

> No copies el `.env` de tu computadora al servidor: tiene otros valores. No borres `backups/`. Tampoco vuelvas a poner `API_URL = "http://127.0.0.1:8080"` en los `config.js`: en producción tiene que quedar `""`.

### Paso 60. Comandos del día a día

**Dónde:** en el servidor (SSH).

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend

# Ver estado
docker compose ps

# Ver logs en vivo (Ctrl+C para salir)
docker compose logs -f app
docker compose logs -f worker
docker compose logs -f db

# Reiniciar la aplicación y el worker
docker compose restart app worker

# Detener sin borrar datos
docker compose stop

# Volver a levantar
docker compose start
```

> **Nunca uses `docker compose down -v`.** Borra la base y las fotos. `docker compose down` (sin `-v`) no borra los volúmenes, pero tampoco es necesario para el día a día.

### Paso 61. Revisar el disco

**Dónde:** en el servidor (SSH).

```bash
df -h
docker system df
```

**Deberías ver:** espacio libre suficiente. Si el disco se llena, las subidas y la base pueden fallar. Borrá respaldos viejos (después de copiarlos) o ampliá el disco desde el panel del proveedor.

**Punto de control:** si tenés un respaldo fuera del servidor y sabés cómo reiniciar los servicios, el mantenimiento básico está cubierto. Si no, andá a la sección 14.

---

## 14. Solución de problemas

Esta sección está ordenada por síntoma. Buscá el mensaje que ves y seguí la solución. Si no encontrás tu caso, copiá el mensaje exacto y pedí ayuda con el contexto: qué paso estabas haciendo, qué comando ejecutaste y qué texto apareció.

### 14.1 No puedo conectarme por SSH

**Síntoma:** `Connection refused`, `Connection timed out` o `Permission denied`.

1. Verificá que el servidor esté encendido en el panel del proveedor.
2. Verificá la IP: puede haber cambiado si reiniciaste o recreaste el servidor.
3. Verificá el usuario: no es lo mismo `root` que `ubuntu`.
4. Si usás clave, revisá la ruta del archivo `.pem` y que sea la clave de **ese** servidor.
5. Si el proveedor bloquea el puerto 22, abrila en su firewall.
6. Si acabás de activar UFW y perdiste el acceso, entrá por la **consola de emergencia** del proveedor y ejecutá:

```bash
sudo ufw allow OpenSSH
sudo ufw reload
```

**Síntoma:** `UNPROTECTED PRIVATE KEY FILE` en Windows.

La clave `.pem` tiene permisos demasiado abiertos. La solución más simple es usar WinSCP, que la acepta, o ajustar permisos en PowerShell:

```powershell
icacls "C:\ruta\a\tu_clave.pem" /inheritance:r
icacls "C:\ruta\a\tu_clave.pem" /grant:r "$env:USERNAME:(R)"
```

### 14.2 Docker no funciona

**Síntoma:** `permission denied while trying to connect to the Docker daemon`.

Cerrá la sesión SSH y volvé a entrar. Si sigue, repetí:

```bash
sudo usermod -aG docker $USER
exit
```

Y volvé a conectarte. Verificá con `docker ps`.

**Síntoma:** `docker: command not found` o `docker compose: command not found`.

Docker no se instaló. Repetí el Paso 12 y verificá que no haya errores en rojo. Después:

```bash
sudo systemctl status docker
```

**Síntoma:** `port is already allocated`.

Otro programa está usando el puerto. Para ver qué lo usa:

```bash
sudo ss -tlnp | grep ':80'
sudo ss -tlnp | grep ':8080'
```

Si es un Nginx viejo o un contenedor de una prueba anterior, detenelo. No borres volúmenes.

### 14.3 La web no abre o da error

**Síntoma:** `502 Bad Gateway`.

Nginx está bien, pero no puede hablar con el contenedor `app`.

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose ps
docker compose logs --tail=100 app
curl -s http://127.0.0.1:8080/api/ping
```

Causas comunes:
- `app` no está corriendo: `docker compose up -d app`.
- El puerto del compose no es `127.0.0.1:8080:8080`: revisá el Paso 22.
- La aplicación reinicia en loop por una contraseña de base mal escrita: revisá `.env` y `docker compose logs app`.

**Síntoma:** `404 Not Found` en `https://TU_DOMINIO/`.

Revisá que exista `lading-page/paginaprincipal.html` y que Nginx tenga la redirección de la raíz:

```bash
ls /opt/cipher-forge/Gestion-fotografias/lading-page
sudo nginx -t
```

**Síntoma:** `413 Request Entity Too Large` al subir un video.

Nginx o PHP tienen un límite bajo. Revisá:

```bash
grep -E 'client_max_body_size|client_body_timeout' /etc/nginx/sites-available/cipher-forge
grep -E 'upload_max_filesize|post_max_size' /opt/cipher-forge/Gestion-fotografias/backend/php.ini
```

Deberían ser `900m` y `1G`. Si cambiás Nginx, recargá con `sudo systemctl reload nginx`. El `php.ini` se copia dentro de la imagen al construirla: si lo cambiás, reconstruí con `docker compose up -d --build app` (recrear solo no alcanza).

**Síntoma:** `504 Gateway Timeout`.

El video es muy grande o el procesamiento tarda. Revisá que Nginx tenga `proxy_read_timeout 600s` y `proxy_send_timeout 600s`, y que `php.ini` tenga `max_execution_time = 600`.

**Síntoma:** la página carga pero el login no hace nada.

1. Abrí la consola del navegador (F12) y mirá la pestaña **Network**.
2. Verificá que las llamadas vayan a `https://TU_DOMINIO/auth/...`, no a `127.0.0.1`.
3. Revisá `frontend-*/services/config.js`: debe decir `export const API_URL = "";`.
4. Revisá que `FRONTEND_URL` sea exactamente `https://TU_DOMINIO` (sin barra final).
5. Borrá las cookies del sitio y volvé a probar.

### 14.4 La base de datos falla

**Síntoma:** `Access denied for user 'cipher_user'@...`.

Las contraseñas de `.env` no coinciden entre `db` y `app`. Revisá:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose config | grep -E 'MYSQL_PASSWORD|DB_PASS'
```

`MYSQL_PASSWORD` y `DB_PASS` tienen que ser la misma clave. Corregí `.env` y recreá:

```bash
docker compose up -d --force-recreate db app worker
```

> Si la base ya se inicializó con otra contraseña, cambiarla en `.env` no la cambia dentro de MySQL. En una instalación nueva, lo más limpio es empezar de cero **solo si no hay datos**: `docker compose down`, borrar el volumen `db_data` y volver a levantar. **No lo hagas si ya hay usuarios o fotos.** Si hay datos, pedí ayuda.

**Síntoma:** MySQL no arranca o reinicia en loop.

```bash
docker compose logs --tail=100 db
```

Causas comunes: falta `MYSQL_ROOT_PASSWORD` o `MYSQL_PASSWORD` en `.env`; el volumen quedó a medias; no hay espacio en disco (`df -h`).

### 14.5 HTTPS y DNS fallan

**Síntoma:** Certbot dice `DNS problem: NXDOMAIN`.

El dominio todavía no apunta al servidor. Esperá la propagación (Paso 35) y verificá con `nslookup TU_DOMINIO`. No ejecutes Certbot de nuevo hasta que el DNS responda.

**Síntoma:** Certbot dice `Timeout during connect`.

El puerto 80 está bloqueado. Revisá el firewall del proveedor y `sudo ufw status`. Si usás Cloudflare con proxy naranja, ponelo en “DNS only” y volvé a probar.

**Síntoma:** Certbot dice `404` o `Invalid response ... /.well-known/acme-challenge/...`.

La regla de Nginx que bloquea archivos ocultos puede estar interfiriendo con la validación. Solución temporal:

1. Abrí el sitio: `sudo nano /etc/nginx/sites-available/cipher-forge`.
2. Buscá la línea `location ~ /\. { deny all; }` y comentala poniendo `#` al principio.
3. Guardá y recargá: `sudo nginx -t && sudo systemctl reload nginx`.
4. Repetí el Paso 38.
5. Cuando el certificado esté emitido, volvé a poner la línea y recargá Nginx.

Si aun así falla, no insistas muchas veces seguidas: Let’s Encrypt limita los intentos por semana. Pedí ayuda con el mensaje exacto.

**Síntoma:** el navegador dice “No seguro” o el certificado es de otro dominio.

Puede haber un certificado viejo o el `server_name` no coincide. Revisá:

```bash
sudo nginx -t
sudo certbot certificates
```

Si el certificado no incluye tu dominio, repetí el Paso 38 con el dominio correcto.

**Síntoma:** `www.TU_DOMINIO` no funciona.

Falta el registro DNS de `www` o el certificado no incluye `www`. Creá el registro A o CNAME (Paso 34) y repetí Certbot con `-d TU_DOMINIO -d www.TU_DOMINIO`.

### 14.6 El correo no funciona

**Síntoma:** el registro dice que el correo no se envió, o no llega el código.

1. Mirá los logs:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose logs --tail=100 app | grep -i correo
```

2. Verificá las variables dentro del contenedor:

```bash
docker compose exec -T app printenv | grep -E 'SMTP|MAIL_FROM'
```

3. Probá el envío con el script del Paso 46.

**Síntoma:** `No se pudo conectar al servidor SMTP`.

- El `SMTP_HOST` o `SMTP_PORT` están mal.
- El proveedor bloquea la salida desde tu servidor.
- El proveedor exige TLS y el código no lo usa: aplicá el Paso 47 o usá un puerto sin cifrado solo si el proveedor lo autoriza.
- El firewall del proveedor bloquea la salida al puerto SMTP. Los puertos 25 suelen estar bloqueados; usá 587.

**Síntoma:** `535 Authentication failed` o `530 Authentication required`.

- `SMTP_USER` o `SMTP_PASS` están mal.
- El usuario SMTP no es tu correo: revisá el panel del proveedor (a veces es `resend`, `apikey` o un usuario generado).
- La clave tiene caracteres especiales y no está entre comillas simples en `.env`.

**Síntoma:** el correo llega a spam.

- SPF y DKIM no están bien cargados. Verificá con `nslookup -type=TXT`.
- El dominio es nuevo y no tiene reputación. Esperá y enviá correos de prueba con poca frecuencia.
- `MAIL_FROM` no coincide con el dominio verificado.
- Evitá asuntos y textos con mayúsculas, signos de exclamación o palabras de spam.

**Síntoma:** el correo llega a Gmail pero no a Outlook (o al revés).

Revisá los logs del proveedor. Puede ser reputación del dominio o una política del destinatario. Asegurate de tener DMARC y de que el dominio esté verificado.

### 14.7 El QR o la sesión fallan

**Síntoma:** el QR contiene `localhost`, `127.0.0.1` o una IP.

`FRONTEND_URL` está mal. Corregí `.env` (Paso 40), recreá `app` y generá un QR nuevo. Los QR viejos no se actualizan.

**Síntoma:** el QR abre el dominio pero el celular no puede subir la foto.

- El celular tiene que tener Internet (datos móviles o WiFi con salida).
- El enlace tiene que ser `https://TU_DOMINIO/...`.
- Revisá los logs de `app` mientras subís.
- Si el archivo es muy grande, puede superar el límite de 800 MB para video o 30 MB para imagen.

**Síntoma:** el login entra y sale solo, o la cookie no se guarda.

- `FRONTEND_URL` tiene que coincidir exactamente con la URL que usás (https, sin barra final).
- `COOKIE_SECURE=true` solo funciona con HTTPS. Si estás probando por HTTP, ponelo en `false` temporalmente.
- Borrá las cookies del sitio y volvé a probar.
- No mezcles `www.TU_DOMINIO` con `TU_DOMINIO`: elegí uno y usalo siempre. El manual usa `https://TU_DOMINIO`.

**Síntoma:** `429 Too Many Requests`.

Es el límite de intentos de login o registro. Esperá **5 minutos** y volvé a probar. No hagas clic muchas veces seguidas.

> Si les pasa a varias personas al mismo tiempo, es porque detrás de Nginx todos los visitantes aparecen con la misma IP y comparten el límite. No es un error de tu cuenta: esperá o pedí al equipo que revise los umbrales antes del evento.

### 14.8 Las fotos o los archivos fallan

**Síntoma:** las fotos dan `404` o no se ven.

- Revisá que el volumen `uploads_data` tenga archivos:

```bash
docker compose exec -T app sh -c 'du -sh /var/www/html/uploads; find /var/www/html/uploads -type f | wc -l'
```

- Revisá permisos. El contenedor corre como `www-data`, así que para cambiar el dueño hay que entrar como `root`:

```bash
docker compose exec -T --user root app chown -R www-data:www-data /var/www/html/uploads
docker compose exec -T --user root app chmod -R 775 /var/www/html/uploads
```

No uses `chown` sin `--user root`: va a fallar con `Operation not permitted`.

- Revisá los logs de `app`.

**Síntoma:** error de permisos al generar un respaldo.

```bash
cd /opt/cipher-forge/Gestion-fotografias
sudo chown -R 33:33 backend/backups
sudo chmod -R 775 backend/backups
docker compose exec -T app php cron-backup.php
```

**Síntoma:** `No space left on device`.

```bash
df -h
docker system df
```

Borrá respaldos viejos después de copiarlos, o ampliá el disco desde el panel del proveedor. No borres el volumen de uploads.

### 14.9 El servidor se queda sin acceso o sin espacio

**Síntoma:** no puedo entrar por SSH y la web tampoco responde.

Usá la **consola de emergencia** del proveedor (en el panel del VPS, “Console” o “VNC”). Desde ahí podés reiniciar, revisar `df -h` y recuperar el acceso.

**Síntoma:** después de reiniciar, la web no vuelve.

```bash
sudo systemctl status docker
sudo systemctl status nginx
cd /opt/cipher-forge/Gestion-fotografias/backend
docker compose ps
docker compose logs --tail=100 app
```

Si Docker no arranca, `sudo systemctl start docker`. Si Nginx no arranca, `sudo nginx -t` para ver el error de configuración.

### 14.10 Si nada de esto funciona

Copiá y guardá:
- El paso exacto donde estás.
- El comando que ejecutaste.
- El mensaje de error completo.
- La salida de `docker compose ps` y `docker compose logs --tail=100 app`.

Mandanos eso y lo revisamos. No borres volúmenes ni ejecutes `docker compose down -v` para “probar”: eso puede destruir los datos.

---

## 15. Datos para guardar y notas técnicas

### 15.1 Datos que tenés que guardar

Guardá en un lugar seguro (gestor de contraseñas o papel cerrado):

- Dominio y acceso al panel de DNS.
- IP del servidor, usuario SSH y clave o contraseña.
- `CLAVE_ROOT`, `CLAVE_APP` y `CLAVE_JWT`.
- Usuario y contraseña SMTP.
- Correo de `MAIL_FROM`.
- Dónde está el `.env` en el servidor: `/opt/cipher-forge/Gestion-fotografias/backend/.env`.
- Dónde están los respaldos: `/opt/cipher-forge/Gestion-fotografias/backend/backups/`.
- Fecha de la última prueba de restauración.
- Proveedor del VPS y del correo.

> No compartas el `.env` por WhatsApp, correo ni GitHub. Si alguien lo necesita, pasalo por un gestor de contraseñas.

### 15.2 Notas técnicas (para el equipo)

Este manual se basó en `docs/manual-migracion-serverubuntu.md`, adaptado de un laboratorio Ubuntu con VirtualBox/NAT a un VPS público con dominio y HTTPS. Las diferencias principales son:

1. **No hay VirtualBox, NAT ni port forwarding de Windows.** El servidor tiene IP pública y Nginx escucha en 80/443.
2. **El compose de producción usa `127.0.0.1:8080:8080`**, no `8080:80`. El `Dockerfile` actual escucha en el puerto **8080** dentro del contenedor (`Listen 8080`, `EXPOSE 8080`); el manual de migración muestra `8080:80` en su sección 4.3, que corresponde a una versión anterior. Si se copia tal cual, Nginx devuelve `502`.
3. **Se eliminó Mailpit** del compose de producción y se agregaron `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `MAIL_FROM` y `MAIL_FROM_NAME`. El `Mailer.php` actual solo habla SMTP sin TLS; el Paso 47 documenta el cambio necesario para STARTTLS.
4. **Se agregó DNS, Certbot y HTTPS**, que el manual de migración solo menciona conceptualmente (secciones 8.7 y 11.3). El manual de migración no trae los comandos de Certbot ni los tiempos de espera.
5. **Es una instalación nueva**, no una migración: no se importa dump ni `uploads_export`. Los respaldos de prueba que vienen en el `.zip` se borran en el Paso 18.
6. **`COOKIE_SECURE` y `FRONTEND_URL` se cambian en `.env`** (Pasos 21 y 40). El compose de producción los lee de ahí; el compose del manual de migración los tiene fijos en `false`/`mailpit`.
7. **`backend/.env.example` y el `.env` del repo no son la configuración efectiva**: el `.env` del repo solo tiene comentarios. El Compose actual exige `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `JWT_SECRET` y `FRONTEND_URL`; sin ellos, `docker compose up` falla a propósito.

**Pendientes de confirmar con el equipo/cliente:**

- Proveedor de correo definitivo y si requiere TLS (casi seguro que sí).
- Aplicación y prueba del parche STARTTLS del Paso 47.
- Prueba de restauración de un respaldo en una base de prueba.
- Copia off-site de `uploads` (snapshots o descarga periódica).
- Revisión de los hallazgos de seguridad de `docs/infraestructura.md`, sección 6, antes de un evento con muchos datos personales.
- Si el dominio va a usar `www` como canónico o solo el dominio principal. Este manual sirve ambos, pero `FRONTEND_URL` usa el principal.
- **Rate limiting detrás de Nginx:** `RateLimitMiddleware` usa `REMOTE_ADDR` y no confía en `X-Forwarded-For`. Detrás del proxy, todos los clientes aparecen como `127.0.0.1`, así que el límite “por IP” (por ejemplo, 20 intentos de login cada 5 minutos) es en realidad compartido por todos. Revisar los umbrales antes de un evento grande.
- **`docs/EMAIL_CONFIG.md` desactualizado:** dice que `codigo_verificacion` se devuelve en la respuesta JSON, pero `AuthService::register` devuelve `email_enviado`. En producción no hay que depender de ese código por API: la verificación funciona solo si el correo llega.
- **`docker-compose.yml` y `config.js` del repo son de desarrollo:** una actualización del `.zip` no debe pisar el compose de producción ni volver a poner `API_URL = "http://127.0.0.1:8080"` (ver Paso 59).

---

**Fin del manual.** Si llegaste hasta acá y el sitio abre con candado, el registro envía correos y el QR funciona desde un celular, ya está publicado. Guardá este documento y los datos del punto 15.1.