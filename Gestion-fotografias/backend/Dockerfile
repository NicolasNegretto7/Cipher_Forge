# Dockerfile define las instrucciones para construir la imagen del backend: qué sistema operativo
# Linux usar (Debian), qué servidor web (Apache), qué versión de PHP (8.2) y qué librerías compilar
# (gd, pdo_mysql, zip).

FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    ffmpeg \
    default-mysql-client \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip

# Endurecimiento de Apache (C-01, C-02, H-02, V-B4):
#   - El servidor escucha en 8080 (puerto no privilegiado) para poder correr como usuario sin privilegios.
#   - El DocumentRoot pasa a public/: el resto del backend (src, database, backups, uploads, .env,
#     docs, probe_*.php) queda FUERA del árbol web y deja de servirse por HTTP.
#   - Se deniega explícitamente /uploads como defensa en profundidad.
RUN a2enmod rewrite \
    && sed -ri 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
    && sed -ri 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf \
    && sed -ri 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && printf '%s\n' \
        '<Directory "/var/www/html/uploads">' \
        '    Require all denied' \
        '</Directory>' \
        > /etc/apache2/conf-available/cipher-forge-hardening.conf \
    && a2enconf cipher-forge-hardening

WORKDIR /var/www/html

# Configuración PHP del contenedor (límites de subida alineados a la app:
# imagen 30 MB / video 800 MB). Sobrescribe los valores por defecto de php:8.2-apache.
COPY php.ini /usr/local/etc/php/conf.d/99-cipher-forge.ini

# Copia el script de entrada que prepara las carpetas de uploads y arranca Apache.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# V-B4: el proceso corre como usuario sin privilegios (www-data, UID 33).
# Se preparan los directorios que el usuario no privilegiado necesita escribir.
RUN mkdir -p /var/www/html/uploads/originals /var/www/html/uploads/previews /var/www/html/uploads/standard \
    && chown -R www-data:www-data /var/www/html/uploads /var/run/apache2 /var/log/apache2 \
    && chmod -R 775 /var/www/html/uploads

USER www-data

EXPOSE 8080

# Comando por defecto (CF-12): Apache en primer plano. El entrypoint respeta "$@",
# por lo que el servicio `worker` de compose lo reemplaza por `php cron-backup.php --loop`.
CMD ["apache2-foreground"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
