FROM php:7.4.13-fpm-alpine

ENV EXT_REDIS_VERSION=5.3.2
ENV EXT_IGBINARY_VERSION=3.2.1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --update --no-cache add curl libzip-dev libpng-dev && rm -rf /var/cache/apk/* && \
    # php extensions
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip && \
    docker-php-ext-install gd && \

    docker-php-source extract && \
    # ext-opcache
    docker-php-ext-enable opcache && \
    # ext-igbinary
    mkdir -p /usr/src/php/ext/igbinary && \
    curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 && \
    docker-php-ext-install igbinary && \
    # ext-redis
    mkdir -p /usr/src/php/ext/redis && \
    curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 && \
    docker-php-ext-configure redis --enable-redis-igbinary && \
    docker-php-ext-install redis && \
    # ext-sockets
    docker-php-ext-install sockets && \
    ## cleanup
    docker-php-source delete && \ 
    # composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    composer global require hirak/prestissimo
