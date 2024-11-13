# Usa la imagen oficial de PHP con FPM (FastCGI Process Manager)
FROM php:8.1-fpm

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código de la aplicación
COPY . /var/www/html

# Cambia los permisos de la carpeta para Nginx
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configuración de Nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Puerto expuesto por Nginx
EXPOSE 80

# Comando de inicio que lanzará PHP-FPM y Nginx
CMD service nginx start && php-fpm
