FROM php:7.4.3-fpm-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --update --no-cache add curl libzip-dev libpng-dev && rm -rf /var/cache/apk/* && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip && \
    docker-php-ext-install opcache && \
    docker-php-ext-install gd && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    composer global require hirak/prestissimo
