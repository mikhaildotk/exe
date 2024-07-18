#FROM composer:lts AS composer-prep
#FROM php:8.3-fpm-alpine AS php-fpm

#------------------
#FROM composer-prep
FROM composer:lts AS composer-prep
LABEL homework="3"
COPY ./app/ /var/www/app/
WORKDIR /var/www/app
RUN composer update && composer install

#------------------
#FROM php-fpm
FROM php:8.3-fpm-alpine AS php-fpm
LABEL homework="3"
COPY --from=composer-prep /var/www/ /var/www/
