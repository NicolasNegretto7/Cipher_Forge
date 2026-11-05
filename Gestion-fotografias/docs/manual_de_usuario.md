# Manual de usuario: poner Cipher Forge en la nube (guía sencilla)

**Para:** personas que quieren instalar y publicar el sistema sin ser expertas en servidores.
**Qué vas a lograr:** pasar del archivo `.zip` que te enviamos a la página web publicada en tu dominio, con HTTPS y con los servicios funcionando.
**Cómo:** con un único archivo (`script.sh`) que hace por vos casi todo el trabajo pesado.

> Este manual NO reemplaza al **manual técnico** (`manual-de-usuario-tecnico.md`). Aquel explica cada comando en detalle, pensado para desarrolladores. Este explica el camino corto para el usuario final. Si algo se complica, al final tienes el enlace al manual técnico.

> **Regla de oro:** nunca escribas el comando `docker compose down -v`. Ese comando borra la base de datos y las fotos. En este manual no se usa en ningún momento.

---

## Índice

1. [Introducción](#1-introducción)
2. [Qué necesitas antes de empezar](#2-qué-necesitas-antes-de-empezar)
3. [Descargar y extraer el proyecto](#3-descargar-y-extraer-el-proyecto)
4. [Contratar y preparar los servicios](#4-contratar-y-preparar-los-servicios)
5. [Subir el proyecto al servidor](#5-subir-el-proyecto-al-servidor)
6. [Ejecutar el instalador](#6-ejecutar-el-instalador)
7. [Qué hace el instalador por vos](#7-qué-hace-el-instalador-por-vos)
8. [Qué tienes que hacer tú (fuera del script)](#8-qué-tienes-que-hacer-tú-fuera-del-script)
9. [Comprobar que todo funciona](#9-comprobar-que-todo-funciona)
10. [Solución de problemas frecuentes](#10-solución-de-problemas-frecuentes)
11. [Ayuda y documentación técnica](#11-ayuda-y-documentación-técnica)
12. [Datos que conviene guardar](#12-datos-que-conviene-guardar)

---

## 1. Introducción

Cipher Forge es un sistema para gestionar colecciones de fotografías. Permite que un fotógrafo se registre, cree colecciones, suba fotos y videos, y comparta accesos mediante un código QR. Los clientes pueden ver, filtrar y descargar las fotos que se les autoriza.

Este manual te enseña a **instalarlo en un servidor de Internet** (para que cualquiera pueda entrar desde su celular o computadora) con la menor intervención técnica posible. La idea es que **ejecutes un solo archivo** (`script.sh`) que automatiza las operaciones que el manual técnico lista paso por paso.

Algunas cosas **no se pueden automatizar** porque dependen de páginas web de terceros (contratar el servidor, el dominio y el correo, o crear los registros DNS). El script te avisa cuándo tienes que hacerlas. Todo lo demás lo hace solo.

### Palabras que vas a ver

No hace falta memorizarlas, pero tenerlas juntas ayuda:

- **Terminal o consola:** ventana donde se escriben instrucciones.
- **SSH:** forma segura de conectarte a otra computadora por Internet.
- **Servidor o VPS:** computadora encendida las 24 horas en un centro de datos.
- **Dominio:** el nombre de tu web, por ejemplo `cipherforge.com`.
- **DNS:** la "agenda" que traduce tu dominio a la dirección del servidor.
- **Docker:** programa que ejecuta la aplicación y la base de datos en cajas aisladas.
- **Nginx:** programa que recibe las visitas a tu dominio y las reparte.
- **HTTPS:** versión cifrada de la web (el candado del navegador).
- **SMTP:** el "correo saliente"; el sistema lo usa para enviar los códigos de verificación.
- **`.env`:** archivo de texto con las contraseñas y la configuración. No se comparte.

---

## 2. Qué necesitas antes de empezar

### En tu computadora

- Un navegador actualizado (Chrome, Edge o Firefox).
- Windows 10 u 11 (o Mac/Linux). Los ejemplos de este manual son para **Windows con PowerShell**.
- Un programa para copiar archivos al servidor. Puedes usar **WinSCP** (gratis, con ventanas, fácil) o la terminal.
- Un editor de texto (el Bloc de notas sirve) o un gestor de contraseñas para anotar datos.

### Lo que hay que contratar (por Internet, con tarjeta)

1. **Un servidor (VPS).** Recomendado: Ubuntu 24.04, 2 procesadores, 4 GB de memoria y 80 GB de disco. Proveedores: DigitalOcean, Hetzner, Vultr, Linode, AWS Lightsail.
2. **Un dominio.** Por ejemplo `cipherforge.com`. Necesitas acceso al panel de **DNS** del dominio.
3. **Un servicio de correo** (Resend, Brevo, Mailgun, SendGrid...). Ojo: **Mailpit no sirve** para producción. El proveedor debe ofrecer **SMTP** (no solo API) y darte host, puerto, usuario y contraseña.

> **Antes de contratar el correo, ten en cuenta:** esta versión envía por SMTP **sin cifrado TLS**. Algunos proveedores exigen TLS en el puerto 587 y el envío de prueba puede fallar hasta que el equipo técnico aplique el ajuste del **Paso 47** del manual técnico. Consúltalo con el equipo si vas a lanzar el sitio con usuarios reales.

### Datos que conviene tener a mano

| Dato | Ejemplo |
|---|---|
| Nombre del dominio | `cipherforge.com` |
| Correo tuyo de uso diario | `tu@correo.com` |
| IP pública del servidor | `203.0.113.10` |
| Usuario SSH | `root` o `ubuntu` |
| Contraseña SSH o archivo de clave `.pem` | (lo da el proveedor) |
| Datos SMTP | host, puerto, usuario y contraseña |

---

## 3. Descargar y extraer el proyecto

1. Descarga el archivo comprimido (`.zip`) que te enviamos. Suele quedar en tu carpeta **Descargas**, por ejemplo:
   `C:\Users\TuUsuario\Downloads\Cipher_Forge.zip`.
2. **No hace falta extraerlo en tu computadora.** Lo vamos a subir tal cual al servidor y se extrae allí (sección 6.2). Si prefieres, también puedes extraerlo en tu computadora.

---

## 4. Contratar y preparar los servicios

Estos pasos se hacen en las páginas web de cada proveedor. El script no puede hacerlos por ti.

### 4.1 Contratar el servidor (VPS)

Crea el servidor con:
- Sistema operativo: **Ubuntu 24.04 LTS** (o 22.04 LTS).
- Plan: **2 vCPU, 4 GB de RAM, 80 GB de disco**.
- Acceso: **clave SSH** (recomendado) o contraseña.

Anota la **IP pública**, el **usuario** y la **contraseña o archivo `.pem`**.

### 4.2 Abrir el firewall del proveedor

En el panel del proveedor, sección **Firewall** o **Security Group**, deja abiertas solo estas entradas:

| Puerto | Protocolo | Para qué |
|---|---|---|
| 22 | TCP | Conectarte por SSH |
| 80 | TCP | HTTP (primer acceso y certificado) |
| 443 | TCP | HTTPS (la web segura) |

No abras los puertos de la base de datos ni de Mailpit.

### 4.3 Contratar el dominio

Compra el dominio y entra al panel de **DNS**. Ahí vas a crear dos registros que apunten a la **IP del servidor**:

| Tipo | Nombre | Valor |
|---|---|---|
| A | `@` | `IP_DEL_SERVIDOR` |
| A | `www` | `IP_DEL_SERVIDOR` |

> **Consejo:** crea estos registros **cuanto antes**. El DNS puede tardar entre 5 minutos y 48 horas en propagarse, así que conviene hacerlo mientras instalas lo demás.
>
> **Si usas Cloudflare:** deja los registros en modo **"DNS only"** (nube gris), no en "Proxied" (nube naranja). Así el certificado de seguridad se puede instalar sin problemas.

### 4.4 Contratar el correo

Crea la cuenta en el proveedor de correo y agrega tu dominio. El proveedor te mostrará unos registros (**SPF** y **DKIM**): cárgalos en el panel de **DNS** de tu dominio. Anota el **host, puerto, usuario y contraseña SMTP**.

> El correo de verificación no llegará a tus usuarios hasta que el dominio esté **verificado** en el proveedor de correo. Esto puede tardar de unos minutos a 24 horas.

---

## 5. Subir el proyecto al servidor

Esta parte se hace **desde tu computadora**. Elige la opción que prefieras.

### Opción A - Con WinSCP (más fácil)

1. Abre WinSCP y conéctate con la IP, el usuario y la contraseña (o la clave `.pem`) del servidor.
2. En el panel derecho (el servidor), entra a la carpeta `/tmp`.
3. En el panel izquierdo (tu computadora), busca el archivo `Cipher_Forge.zip`.
4. Arrástralo al panel derecho para copiarlo a `/tmp`.

### Opción B - Con la terminal (PowerShell)

1. Abre **PowerShell**: botón Inicio, escribe `PowerShell` y ábrelo.
2. Comprueba que SSH funciona:

```powershell
ssh -V
```

3. Copia el `.zip` al servidor (reemplaza los datos):

```powershell
scp "C:\Users\TuUsuario\Downloads\Cipher_Forge.zip" TU_USUARIO@IP_DEL_SERVIDOR:/tmp/
```

Si usas clave `.pem`:

```powershell
scp -i "C:\ruta\a\tu_clave.pem" "C:\Users\TuUsuario\Downloads\Cipher_Forge.zip" TU_USUARIO@IP_DEL_SERVIDOR:/tmp/
```

**Deberías ver:** una barra de progreso que llega al 100 %.

---

## 6. Ejecutar el instalador

### 6.1 Conectarte al servidor

Desde PowerShell (o desde WinSCP, con el botón de terminal):

```powershell
ssh TU_USUARIO@IP_DEL_SERVIDOR
```

Si usas clave `.pem`:

```powershell
ssh -i "C:\ruta\a\tu_clave.pem" TU_USUARIO@IP_DEL_SERVIDOR
```

La primera vez te preguntará si confías en el servidor: escribe `yes` y presiona Enter.

### 6.2 Descomprimir el proyecto

Ya dentro del servidor, ejecuta:

```bash
sudo apt-get update
sudo apt-get install -y unzip
sudo mkdir -p /opt/cipher-forge
sudo chown -R $USER:$USER /opt/cipher-forge
cd /opt/cipher-forge
unzip "/tmp/Cipher_Forge.zip"
ls
```

> El instalador también instala `unzip`, pero lo necesitas **antes** para poder extraer el proyecto.

Si no aparece la carpeta `Gestion-fotografias` directamente, puede haber quedado dentro de otra carpeta. Búscala con:

```bash
find /opt/cipher-forge -maxdepth 3 -type d -name "Gestion-fotografias"
```

Si la ruta que muestra no es `/opt/cipher-forge/Gestion-fotografias`, muévela:

```bash
sudo mv "RUTA_QUE_MOSTRO" /opt/cipher-forge/
```

**Deberías ver:** una carpeta `Gestion-fotografias` con `backend`, `frontend-cliente`, `frontend-fotografo`, `lading-page` y `docs`.

### 6.3 Lanzar el instalador (una sola instrucción)

> **Importante:** `script.sh` se ejecuta **en el servidor Ubuntu**, no en tu Windows. Desde PowerShell solo te conectas por SSH; los comandos de esta sección ya se escriben dentro del servidor.

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh
```

El script te irá guiando. Preguntará:

1. **Tu dominio** (sin `https://` y sin `www`), por ejemplo `cipherforge.com`.
2. **Tu correo**, para los avisos del certificado y las pruebas.
3. Confirmaciones para operaciones delicadas (mover datos de prueba a una cuarentena segura, reemplazar archivos...). Puedes responder `s` (sí) o `n` (no).
4. Al final, los **datos SMTP** de tu proveedor de correo.

> **Antes de probarlo de verdad:** puedes hacer una **prueba segura** que no cambia nada en el servidor:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh --simular --dominio cipherforge.com --correo tu@correo.com
```

> Si vas a **migrar fotos reales** desde otro servidor, responde **no** cuando el script pregunte si quieres mover `uploads_export` a la cuarentena.

### 6.4 Opciones del script (por si las necesitas)

| Opción | Para qué sirve |
|---|---|
| `--dominio DOMINIO` | Evita que te pregunte el dominio |
| `--correo EMAIL` | Evita que te pregunte el correo |
| `--sin-https` | No instala HTTPS en esta ejecución (lo haces después) |
| `--sin-correo` | No configura el correo en esta ejecución |
| `--asumir-si` | Responde "sí" a las confirmaciones |
| `--simular` | Muestra lo que haría **sin cambiar nada** (prueba segura) |
| `--verificar` | Revisa el estado del sistema **sin modificar nada** |
| `--ayuda` | Muestra esta lista |

Puedes volver a ejecutar el script las veces que quieras: detecta lo que ya está hecho y no repite operaciones peligrosas. Si solo quieres saber cómo está todo (sin instalar ni cambiar nada), ejecuta:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh --verificar
```

> **Cuidado con `--asumir-si`:** responde "sí" a todas las confirmaciones. Úsalo solo en una instalación nueva y desatendida. Si vas a migrar fotos o datos existentes, ejecuta el script sin esa opción y revisa cada pregunta.

---

## 7. Qué hace el instalador por vos

Al ejecutar `script.sh`, el instalador hace automáticamente:

| Etapa | Qué automatiza |
|---|---|
| 1. Sistema | Actualiza el sistema, instala las herramientas básicas y configura la hora de Uruguay |
| 2. Docker | Instala Docker y Docker Compose |
| 3. Cuarentena | Mueve a una carpeta segura los respaldos de prueba, la carpeta `uploads_export` y la clave de desarrollo del `.zip` (solo instalación nueva, con tu confirmación) |
| 4. Configuración | Pide tu dominio y tu correo, genera contraseñas nuevas (solo en una instalación nueva), crea el archivo `.env`, ajusta los enlaces de los frontends y coloca la configuración de producción |
| 5. Arranque | Levanta la base de datos y la aplicación, espera a que respondan, comprueba las tablas y genera un respaldo |
| 6. Nginx | Publica el sitio, configura el cortafuegos y comprueba que la página responde |
| 7. HTTPS | Comprueba el DNS y pide el certificado gratuito (si el DNS ya está listo) |
| 8. Correo | Pide los datos SMTP, los guarda y hace una prueba de conexión y de envío |

**Mensajes del script:**

- `[INFO]` información de avance.
- `[ OK ]` una operación terminó correctamente.
- `[AVISO]` algo que conviene revisar, pero no detiene la instalación.
- `[ERROR]` un problema crítico: el script se detiene para que no dañe nada.

> El script **nunca guarda tus contraseñas dentro de sí mismo** ni ejecuta comandos que borren la base o las fotos.

---

## 8. Qué tienes que hacer tú (fuera del script)

Estas cosas dependen de páginas web externas y **no se pueden automatizar**:

1. **Contratar** el servidor, el dominio y el correo (sección 4).
2. **Abrir el firewall** del proveedor en los puertos **22, 80 y 443** (sección 4.2).
3. **Crear los registros DNS** `A` para `@` y `www` apuntando a la IP del servidor (sección 4.3).
4. **Verificar tu dominio** en el proveedor de correo cargando los registros SPF y DKIM (sección 4.4).
5. Si el script te dice que el DNS **todavía no está listo**, espera a que propague y **vuelve a ejecutar**:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh
```

> Para HTTPS es imprescindible que el dominio ya apunte al servidor. Si aún no lo hace, el script te lo dirá y podrás continuar más tarde sin romper nada.

---

## 9. Comprobar que todo funciona

### 9.1 Desde el propio servidor

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
sudo docker compose ps
```

**Deberías ver** tres servicios arriba: `cipher_forge_app`, `cipher_forge_worker` y `cipher_forge_db`. No debe aparecer Mailpit.

```bash
curl -s http://127.0.0.1:8080/api/ping
```

**Deberías ver** una respuesta JSON con `"ok": true` (puede estar en varias líneas).

Comprueba también el cortafuegos:

```bash
sudo ufw status
```

**Deberías ver** permisos para el puerto SSH (22 o el que uses), `80/tcp` y `443/tcp` (o los perfiles de Nginx).

### 9.2 Desde tu navegador

Abre estas direcciones (reemplaza `TU_DOMINIO`):

- `https://TU_DOMINIO/` → la página de inicio.
- `https://TU_DOMINIO/frontend-fotografo/pages/login.html` → ingreso del fotógrafo.
- `https://TU_DOMINIO/frontend-cliente/pages/login.html` → ingreso del cliente.

**Deberías ver** las tres páginas con el **candado** de HTTPS.

### 9.3 Probar el flujo completo

1. Regístrate como fotógrafo con un correo real.
2. Revisa tu correo: deberías recibir un código de 6 dígitos (mira también la carpeta de spam).
3. Ingresa el código e inicia sesión.
4. Crea una colección y sube una foto.
5. Genera un código QR y ábrelo en un celular con **datos móviles**.
6. Sube una foto desde el celular y apruébala en **Moderación**.

**Deberías ver** todo el flujo funcionando y el enlace del QR empezando con `https://TU_DOMINIO/` (no con `localhost` ni una IP).

### 9.4 Revisión rápida (sin cambiar nada)

Si quieres que el propio instalador revise el estado general (contenedores, API, Nginx, rutas privadas, base de datos, respaldos, HTTPS, DNS y correo configurado), ejecuta:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh --verificar
```

**Deberías ver** mensajes `[ OK ]` en las comprobaciones importantes. Los `[AVISO]` no detienen el sistema, pero conviene revisarlos. Los `[ERROR]` indican un problema que deberías resolver antes de usar el sitio con clientes.

> Esta revisión es de **solo lectura**: no instala, no reinicia y no cambia la configuración. Tampoco envía un correo de prueba.

---

## 10. Solución de problemas frecuentes

### No puedo conectarme por SSH

- Revisa que el servidor esté encendido y que la **IP** y el **usuario** sean correctos.
- Comprueba que el puerto **22** esté abierto en el firewall del proveedor.
- Si usas clave `.pem`, verifica la ruta del archivo.

### `permission denied` al usar Docker

Cierra la sesión SSH y vuelve a entrar. El script ya te agregó al grupo de Docker; el permiso se aplica al reconectar.

### La web da `502 Bad Gateway`

Nginx no puede hablar con la aplicación. Comprueba:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
sudo docker compose ps
sudo docker compose logs --tail=100 app
```

Suele pasar cuando la aplicación se reinicia por una contraseña mal escrita en el `.env`.

### El certificado (HTTPS) falla con `NXDOMAIN` o `Timeout`

- `NXDOMAIN`: el dominio todavía no apunta al servidor. Espera a que propague el DNS y vuelve a ejecutar el script.
- `Timeout`: el puerto 80 está bloqueado. Revisa el firewall del proveedor.

### El correo no llega

- Revisa la carpeta de spam.
- Comprueba que cargaste bien los registros SPF y DKIM.
- Verifica que el dominio esté **verificado** en el proveedor de correo.

> **Nota importante:** el sistema envía correo por SMTP. Algunos proveedores modernos **exigen cifrado TLS** en el puerto 587, y esta versión puede necesitar un ajuste técnico pequeño (Paso 47 del manual técnico). Si la prueba de correo falla con un mensaje de conexión, avísale al equipo técnico antes de un evento importante.

### `413 Request Entity Too Large` al subir un video

El archivo supera el límite permitido (video de 800 MB, imagen de 30 MB). Prueba con un archivo más pequeño.

### El enlace del QR muestra `localhost` o una IP

Vuelve a ejecutar el script para que actualice la dirección pública, y genera un **QR nuevo** (los QR viejos no se actualizan solos).

### Perdí el archivo `.env`

No vuelvas a ejecutar el instalador para que "genere claves nuevas": si ya hay una base de datos, las claves nuevas no coinciden con las antiguas y la aplicación no podrá conectarse. El script se detiene a propósito en ese caso.

Busca una copia del `.env` (por ejemplo, en un respaldo o en el gestor de contraseñas). Si no la encuentras, pide ayuda al equipo técnico **sin borrar los volúmenes de Docker**.

### El respaldo de la base no se genera

Comprueba los permisos de la carpeta de respaldos:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
sudo chown -R 33:33 backups
sudo chmod -R 775 backups
```

Después vuelve a ejecutar:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh --verificar
```

Si el problema continúa, revisa los logs del worker:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
sudo docker compose logs --tail=100 worker
```

### El script se detuvo con un mensaje `[ERROR]`

El script se detiene a propósito para no dejar el sistema a medias. **No vuelvas a ejecutarlo una y otra vez sin leer el mensaje.** Copia el texto completo y:

1. Revisa la salida de `--verificar`:

```bash
sudo bash /opt/cipher-forge/Gestion-fotografias/script.sh --verificar
```

2. Revisa los logs del servicio que menciona el error. Por ejemplo:

```bash
cd /opt/cipher-forge/Gestion-fotografias/backend
sudo docker compose logs --tail=100 app
sudo docker compose logs --tail=100 db
```

3. Si el mensaje habla de permisos, DNS, certificado o correo, busca esa sección en este mismo capítulo.

### Se llenó el disco (`No space left on device`)

```bash
df -h
```

Borra respaldos viejos (después de copiarlos a un lugar seguro) o amplía el disco desde el panel del proveedor.

Copia y guarda siempre: **el paso donde estabas, el mensaje de error completo** y la salida de `sudo docker compose logs --tail=100 app`. Con eso el equipo técnico puede ayudarte.

---

## 11. Ayuda y documentación técnica

Si necesitas el detalle de cada comando, cada archivo de configuración y cada caso especial, consulta:

- **Manual técnico:** [`manual-de-usuario-tecnico.md`](manual-de-usuario-tecnico.md)
- **Índice de documentación:** [`README.md`](README.md)

Ese documento explica paso por paso el procedimiento completo, incluye la sección de solución de problemas ampliada y las notas para el equipo. Este manual de usuario es la guía simplificada; ambos describen el mismo sistema.

---

## 12. Datos que conviene guardar

Guarda en un lugar seguro (gestor de contraseñas o papel cerrado):

- Dominio y acceso al panel de DNS.
- IP del servidor, usuario SSH y contraseña o clave.
- Las tres claves que el script genera y muestra en una **instalación nueva**: `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD` y `JWT_SECRET`. Si vuelves a ejecutarlo sobre una instalación existente, conserva las claves y **no** las vuelve a mostrar.
- Usuario y contraseña del correo (SMTP).
- Dónde están las cosas en el servidor:
  - Configuración: `/opt/cipher-forge/Gestion-fotografias/backend/.env`
  - Respaldos: `/opt/cipher-forge/Gestion-fotografias/backend/backups/`
  - Cuarentena de archivos de prueba: `/var/backups/cipher-forge/instalacion-FECHA/`

> No compartas el archivo `.env` por WhatsApp, correo ni GitHub. Si alguien lo necesita, pásalo por un gestor de contraseñas.

---

**Fin del manual.** Si tu web abre con candado, el registro envía correos y el código QR funciona desde un celular, ¡ya está publicada!
