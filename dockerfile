# Usa la imagen de PHP con Apache
FROM php:8.2-apache

# Instala dependencias del sistema y PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd fileinfo

# Habilita mod_rewrite para Laravel
RUN a2enmod rewrite

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código del proyecto al contenedor
COPY . /var/www/html

# Establece permisos adecuados para los directorios de Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configura el directorio de trabajo
WORKDIR /var/www/html

# Copia el archivo de configuración de Apache
COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Expone el puerto 80 para HTTP
EXPOSE 80

# Ejecuta Apache en primer plano
CMD ["apache2-foreground"]
