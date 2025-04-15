# Используем официальный образ PHP с Apache
FROM php:8.2-apache

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip pdo pdo_pgsql opcache

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Включаем mod_rewrite для Apache
RUN a2enmod rewrite

# Копируем файлы проекта
COPY . /var/www/html/

# Устанавливаем права
RUN chown -R www-data:www-data /var/www/html/var

# Устанавливаем рабочую директорию
WORKDIR /var/www/html

# Устанавливаем зависимости, если есть composer.json
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; fi

# Порт, который будет слушать Apache
EXPOSE 80
