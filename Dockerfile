FROM php:7.4.12-fpm-alpine AS ext-mongodb

ENV EXT_MONGODB_VERSION=1.7.4

RUN docker-php-source extract \
    && apk upgrade -U -a \
    && apk add --update git \
    && git clone --branch $EXT_MONGODB_VERSION --depth 1 https://github.com/mongodb/mongo-php-driver.git /usr/src/php/ext/mongodb \
    && cd /usr/src/php/ext/mongodb && git submodule update --init \
    && docker-php-ext-install mongodb

FROM php:7.4.12-fpm-alpine

RUN mkdir /app && chown www-data:www-data /app
VOLUME /app
WORKDIR /app

# packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a  && \
    apk --update --no-cache add curl libzip-dev libpng-dev openssl-dev \
        autoconf make gcc g++ udev ttf-freefont git graphviz bash zsh automake \
        nasm \
        yarn npm \
        vim python3 \ 
        chromium \
        chromium-chromedriver && \ 
        rm -rf /var/cache/apk/* 

# install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# php extensions
RUN docker-php-ext-install pdo_mysql \
                           bcmath \
                           zip  \
                           opcache \
                           gd 

# ext-mongodb
COPY --from=ext-mongodb /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini
COPY --from=ext-mongodb /usr/local/lib/php/extensions/no-debug-non-zts-20190902/mongodb.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/mongodb.so

ENV EXT_REDIS_VERSION=5.2.1
ENV EXT_IGBINARY_VERSION=3.1.2

# set default environment variables
ENV PHP_MEMORY_LIMIT=2048M
ENV PHP_UPLOAD_MAX_FILESIZE=100M
ENV PHP_POST_MAX_SIZE=100M

COPY php.ini-development /usr/local/etc/php/conf.d/php.ini

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

ENV HOME /app
ENV XDG_CONFIG_HOME /app
ENV COMPOSER_HOME /composer
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN mkdir /composer && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \ 
    chmod -fR 777 /composer
