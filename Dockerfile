# Pega aquí el contenido que te proporcionaron para el Dockerfile
# Usa una imagen base PHP de Alpine para ser ligero y con PHP-FPM
FROM php:8.2-fpm-alpine

# Instala dependencias del sistema necesarias
# nginx: servidor web para servir tu aplicación
# nodejs, npm: para compilar tus assets de frontend (Vite/Mix)
# git: útil para algunas operaciones de Composer/instalaciones
# supervisor: para gestionar PHP-FPM y Nginx en un solo contenedor
# libpq-dev: librerías de desarrollo para PostgreSQL (necesarias para pdo_pgsql)
# zip, unzip: para algunas operaciones de Composer/descargas
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    git \
    supervisor \
    libpq-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql pdo_pgsql \ # Instala las extensiones PDO para MySQL (por si acaso) y PostgreSQL (¡necesario!)
    && rm -rf /var/cache/apk/* # Limpia caché de paquetes para reducir el tamaño de la imagen

# Instala Composer globalmente
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Define el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de la aplicación al contenedor
COPY . /app

# Instala dependencias de Composer (¡solo las de producción!)
RUN composer install --no-dev --optimize-autoloader

# Si usas NPM (Vite/Laravel Mix) para tu frontend, instala dependencias y compila assets
# Asegúrate de que package.json y package-lock.json estén en la raíz de tu proyecto
RUN npm install && npm run build

# Opcional pero recomendado: Configura los permisos para los directorios de Laravel
# www-data es el usuario por defecto de Nginx/PHP-FPM en muchas imágenes de Docker
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
# Inicia Supervisor, que a su vez iniciará Nginx y PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]