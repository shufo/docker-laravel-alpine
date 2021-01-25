FROM php:7.4.13-fpm-alpine

ENV EXT_REDIS_VERSION=5.2.1
ENV EXT_IGBINARY_VERSION=3.1.2

# php extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache
RUN apk --update --no-cache add curl libzip-dev zlib-dev libpng-dev openssl-dev \
        autoconf make gcc g++ udev ttf-freefont git graphviz bash zsh automake
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
RUN apk upgrade -U -a 
RUN docker-php-source extract \
    # ext-opcache
    && docker-php-ext-enable opcache \
    # ext-igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    &&  curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary \
    # ext-redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis \
    # ext-sockets
    && docker-php-ext-install sockets \
    ## cleanup
    && docker-php-source delete
 
# install pcov
RUN pecl install pcov \
    && echo extension=pcov.so > /usr/local/etc/php/conf.d/pcov.ini

# packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a  && \
    apk --update --no-cache add curl libzip-dev zlib-dev libpng-dev openssl-dev \
        autoconf make gcc g++ udev ttf-freefont git graphviz bash zsh automake \
        nasm \
        yarn npm \
        vim python3 \ 
        chromium \
        chromium-chromedriver && \ 
        rm -rf /var/cache/apk/* 

# install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# set default environment variables
ENV PHP_MEMORY_LIMIT=2048M
ENV PHP_UPLOAD_MAX_FILESIZE=100M
ENV PHP_POST_MAX_SIZE=100M

COPY php.ini-development /usr/local/etc/php/conf.d/php.ini
ENV HOME /app
ENV XDG_CONFIG_HOME /app
ENV COMPOSER_HOME /composer

RUN mkdir /app && chown www-data:www-data /app && chown -R www-data:www-data /var/www
VOLUME /app
WORKDIR /app

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN mkdir /composer && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    chmod -fR 777 /composer
