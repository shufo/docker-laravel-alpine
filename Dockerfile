FROM php:7.3.7-fpm-alpine
MAINTAINER shufo

RUN apk --update --no-cache add curl  && rm -rf /var/cache/apk/* && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install bcmath && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    composer global require hirak/prestissimo
