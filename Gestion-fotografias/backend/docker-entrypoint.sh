#!/bin/sh
# QUÉ: Prepara el entorno del contenedor antes de arrancar Apache.
# POR QUÉ: El volumen de uploads es propiedad de root y el proceso www-data no puede
#          crear las subcarpetas 'originals' y 'previews'. Este script las crea y
#          otorga permisos de escritura en cada arranque.

set -e

# Asegurar que existan y sean escribibles las carpetas de almacenamiento multimedia.
mkdir -p /var/www/html/uploads/originals
mkdir -p /var/www/html/uploads/previews
mkdir -p /var/www/html/uploads/standard
chown -R www-data:www-data /var/www/html/uploads
chmod -R 775 /var/www/html/uploads

# ── Migración idempotente al arrancar ─────────────────────────────
# POR QUÉ: docker-entrypoint-initdb.d solo se ejecuta en la PRIMERA inicialización
#          del volumen MySQL. Si el esquema cambia después, los endpoints que usan
#          columnas nuevas devuelven 500. Este paso aplica migration.sql en cada boot.
echo "⏳ Esperando a que MySQL esté disponible..."
MAX_RETRIES=30
RETRIES=0
until mysql --skip-ssl -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "SELECT 1" > /dev/null 2>&1; do
    RETRIES=$((RETRIES + 1))
    if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
        echo "❌ MySQL no respondió después de ${MAX_RETRIES} intentos."
        break
    fi
    sleep 2
done
echo "✅ MySQL está listo."

MIGRATION_FILE="/var/www/html/database/migration.sql"
if [ -f "$MIGRATION_FILE" ]; then
    echo "🔄 Ejecutando migración idempotente..."
    mysql --skip-ssl -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" < "$MIGRATION_FILE" 2>&1 || true
    echo "✅ Migración completada."
fi

# Ejecutar el comando del contenedor (CMD / command de compose) respetando "$@".
# Así `app` arranca Apache (CMD por defecto de la imagen) y `worker` (CF-12) ejecuta
# `php cron-backup.php --loop`, ambos después de preparar carpetas y migración.
exec "$@"

