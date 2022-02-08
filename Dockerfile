FROM php:8.1.2-fpm-alpine

ENV EXT_REDIS_VERSION=5.3.6
ENV EXT_IGBINARY_VERSION=3.2.5
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE" 

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --update --no-cache add curl libzip-dev libpng-dev && rm -rf /var/cache/apk/* && \
    # php extensions
    docker-php-ext-install pdo_mysql \
    											 bcmath \
    											 zip \
    											 gd \
    											 sockets && \

    docker-php-source extract && \
    # ext-opcache
    docker-php-ext-enable opcache && \
    # ext-redis
    mkdir -p /usr/src/php/ext/redis && \
    curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 && \
    docker-php-ext-install redis && \
    # ext-sockets
    ## cleanup
    docker-php-source delete && \ 
    # composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
