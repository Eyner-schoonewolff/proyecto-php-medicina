# Usa una imagen oficial de PHP con Apache y Composer
FROM php:8.2-apache

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Habilita mod_rewrite para Laravel
RUN a2enmod rewrite

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código del proyecto al contenedor
COPY . /var/www/html

# Establece permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Configura el directorio de trabajo
WORKDIR /var/www/html

# Instala las dependencias de Laravel
RUN composer install --optimize-autoloader --no-dev

# Genera la clave de la aplicación
RUN php artisan key:generate

# Ejecuta las migraciones y las semillas de la base de datos
RUN php artisan migrate --seed

# Copia el archivo de configuración virtualhost
COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Expone el puerto 8080 (puedes usar otro puerto si lo necesitas)
EXPOSE 8080

# Comando de inicio para levantar el servidor
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
