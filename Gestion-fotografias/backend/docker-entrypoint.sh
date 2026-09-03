#!/bin/sh
# QUÉ: Prepara el entorno del contenedor antes de arrancar Apache.
# POR QUÉ: El volumen de uploads es propiedad de root y el proceso www-data no puede
#          crear las subcarpetas 'originals' y 'previews'. Este script las crea y
#          otorga permisos de escritura en cada arranque.

set -e

# Asegurar que existan y sean escribibles las carpetas de almacenamiento multimedia.
mkdir -p /var/www/html/uploads/originals
mkdir -p /var/www/html/uploads/previews
chown -R www-data:www-data /var/www/html/uploads
chmod -R 775 /var/www/html/uploads

# Arrancar Apache en primer plano (heredando la configuración de la imagen base).
exec apache2-foreground
