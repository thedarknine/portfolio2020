FROM composer:1.9 AS composer

FROM php:7.3-fpm

MAINTAINER TheDarkNine <thedarknine@gmail.com>

RUN apt-get update && apt-get install -y \
    unzip

RUN docker-php-ext-install pdo pdo_mysql

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/app
