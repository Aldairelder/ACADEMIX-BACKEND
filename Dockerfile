FROM php:8.2-fpm-alpine

# Instala dependencias necesarias
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

# Instala Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /app

# Copia todo el proyecto
COPY . /app

# Instala dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Permisos de Laravel
RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/storage \
    && chmod -R 775 /app/bootstrap/cache

# Crea los logs de nginx (opcional pero recomendado)
RUN mkdir -p /var/log/nginx && touch /var/log/nginx/access.log /var/log/nginx/error.log

# Copia configs de Nginx y Supervisor
COPY docker/nginx.conf /etc/nginx/nginx.conf

COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expone puertos
EXPOSE 80 9000

# Comando de arranque
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
