FROM php:7.3.11-fpm-alpine
MAINTAINER shufo

RUN mkdir /app && chown www-data:www-data /app
VOLUME /app
WORKDIR /app

RUN apk --update --no-cache add curl libzip-dev libpng-dev openssl-dev \
        autoconf make gcc g++ udev ttf-freefont git graphviz bash python automake \
        yarn npm \ 
        chromium \
        chromium-chromedriver && \ 
    rm -rf /var/cache/apk/* && \
    docker-php-ext-install pdo_mysql \
                           bcmath \
                           zip  \
                           opcache \
                           gd && \
    pecl install mongodb && \
    echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini 

ENV HOME /app
ENV XDG_CONFIG_HOME /app
ENV COMPOSER_HOME /composer
RUN mkdir /composer && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    composer global require hirak/prestissimo && \
    chmod -fR 777 /composer
