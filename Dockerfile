# Usa una imagen base PHP de Alpine para ser ligero y con PHP-FPM
FROM php:8.2-fpm-alpine

# Instala dependencias del sistema necesarias
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    git \
    supervisor \
    libpq-dev \
    zip \
    unzip && \
    docker-php-ext-install pdo_mysql pdo_pgsql && \
    rm -rf /var/cache/apk/*

# Instala Composer globalmente
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Define el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de la aplicación al contenedor
COPY . /app

# Instala dependencias de Composer (¡solo las de producción!)
RUN composer install --no-dev --optimize-autoloader

# Si usas NPM (Vite/Laravel Mix) para tu frontend, instala dependencias y compila assets
RUN npm install && npm run build

# Configura los permisos para los directorios de Laravel
RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/storage \
    && chmod -R 775 /app/bootstrap/cache

# Copia la configuración de Nginx al contenedor
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copia la configuración de Supervisor al contenedor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expone los puertos que Nginx (80) y PHP-FPM (9000) usarán dentro del contenedor
EXPOSE 80 9000

# Comando principal que se ejecutará cuando el contenedor se inicie
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
