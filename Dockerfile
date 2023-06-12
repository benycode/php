FROM php:8.2.4-cli-buster

RUN apt-get update && apt-get -y install git libjpeg-dev libmagickwand-dev \
    libmemcached-dev libpng-dev libpq-dev libsqlite3-dev libxml2-dev \
    libzip-dev uuid-dev unzip wget zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-jpeg && docker-php-ext-install bcmath \
    gd intl opcache pcntl pdo pdo_mysql pdo_pgsql pdo_sqlite soap sockets zip
RUN pecl install apcu-5.1.22 ast-1.1.0 imagick-3.7.0 mongodb-1.15.1 \
    && git clone https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize \
    && ./configure && make && make install && cd ../ && rm -rf php-memcached \
    && git clone https://github.com/php/pecl-networking-uuid.git && cd pecl-networking-uuid && phpize \
    && ./configure && make && make install && cd ../ && rm -rf pecl-networking-uuid \
    && git clone https://github.com/phpredis/phpredis.git && cd phpredis && phpize \
    && ./configure && make && make install && cd ../ && rm -rf phpredis \
    && docker-php-ext-enable apcu ast imagick memcached mongodb uuid redis

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini && \
    rm $PHP_INI_DIR/php.ini-development && \
    sed 's/short_open_tag=On/short_open_tag=Off/' $PHP_INI_DIR/php.ini && { \
		echo 'memory_limit=2048M'; \
		echo 'upload_max_filesize=128M'; \
		echo 'post_max_size=128M'; \
	} > /usr/local/etc/php/conf.d/memory-limit.ini
