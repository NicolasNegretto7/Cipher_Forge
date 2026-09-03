# Dockerfile define las instrucciones para construir la imagen de la maquina virutal del backend: qué sistema operativo Linux usar (Debian), qué servidor web (Apache), qué versión de PHP (8.2) y qué librerías compilar (gd, pdo_mysql, zip).

FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    ffmpeg \
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

    RUN a2enmod rewrite

    WORKDIR /var/www/html

    # Copia el script de entrada que prepara las carpetas de uploads y arranca Apache.
    COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh

    ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
