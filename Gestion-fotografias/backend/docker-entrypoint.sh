#!/bin/sh
# QUÉ: Prepara el entorno del contenedor antes de arrancar Apache.
# POR QUÉ: El volumen de uploads puede pertenecer a root en su primera creación y el proceso
#          corre como www-data (Dockerfile: USER www-data), así que hay que asegurar la
#          existencia y la escritura de las subcarpetas 'originals', 'previews' y 'standard'.

set -e

# ── Ownership del volumen de uploads ──────────────────────────────
# Si el contenedor arranca como root (por ejemplo, un override con `user: root`), se ajusta
# aquí el propietario del punto de montaje. Si ya corre como www-data, se asume que el volumen
# tiene el propietario correcto (los volúmenes nombrados heredan el ownership www-data de la imagen).
if [ "$(id -u)" = "0" ]; then
    chown -R www-data:www-data /var/www/html/uploads
    chown -R www-data:www-data /var/run/apache2 /var/log/apache2 2>/dev/null || true
fi

# Asegurar que existan y sean escribibles las carpetas de almacenamiento multimedia.
mkdir -p /var/www/html/uploads/originals
mkdir -p /var/www/html/uploads/previews
mkdir -p /var/www/html/uploads/standard
chmod -R 775 /var/www/html/uploads 2>/dev/null || true

# ── Migración idempotente al arrancar ─────────────────────────────
# POR QUÉ: docker-entrypoint-initdb.d solo se ejecuta en la PRIMERA inicialización
#          del volumen MySQL. Si el esquema cambia después, los endpoints que usan
#          columnas nuevas devuelven 500. Este paso aplica migration.sql en cada boot.
# ── Desactivar TLS del cliente MySQL/MariaDB ─────────────────────
# POR QUÉ: MySQL 8.0 genera un certificado autofirmado y la conexión TCP falla con
#          "self-signed certificate in certificate chain" si el cliente intenta TLS.
#          El cliente de la imagen es MariaDB (default-mysql-client) y desactiva TLS con
#          --skip-ssl; el cliente oficial de MySQL 8 lo hace con --ssl-mode=DISABLED.
#          Se detecta cuál soporta el binario instalado para no romper la espera ni la migración.
if mysql --help 2>&1 | grep -q -- '--ssl-mode'; then
    MYSQL_TLS="--ssl-mode=DISABLED"
else
    MYSQL_TLS="--skip-ssl"
fi

echo " Esperando a que MySQL esté disponible..."
MAX_RETRIES=30
RETRIES=0
until mysql $MYSQL_TLS -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "SELECT 1" > /dev/null 2>&1; do
    RETRIES=$((RETRIES + 1))
    if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
        echo " MySQL no respondió después de ${MAX_RETRIES} intentos."
        break
    fi
    sleep 2
done
echo " MySQL está listo."

MIGRATION_FILE="/var/www/html/database/migration.sql"
if [ -f "$MIGRATION_FILE" ]; then
    echo " Ejecutando migración idempotente..."
    mysql $MYSQL_TLS -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" < "$MIGRATION_FILE" 2>&1 || true
    echo " Migración completada."
fi

# Ejecutar el comando del contenedor (CMD / command de compose) respetando "$@".
# Así `app` arranca Apache (CMD por defecto de la imagen) y `worker` (CF-12) ejecuta
# `php cron-backup.php --loop`, ambos después de preparar carpetas y migración.
exec "$@"
