FROM php:7.3.7-fpm-alpine
MAINTAINER shufo

RUN apk --update --no-cache add curl libzip-dev libpng-dev openssl-dev \
        autoconf make gcc g++ udev ttf-freefont \
        yarn \ 
        chromium \
        chromium-chromedriver && \ 
    rm -rf /var/cache/apk/* && \
    docker-php-ext-install pdo_mysql \
                           bcmath \
                           zip  \
                           opcache \
                           gd && \
    pecl install mongodb && \
    echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini && \ 
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    composer global require hirak/prestissimo
