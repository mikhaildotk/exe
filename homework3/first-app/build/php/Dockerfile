ARG COMPOSER_TAG=lts
ARG PHP_TAG=8.3-fpm-alpine

#FROM composer:${COMPOSER_TAG} AS composer-prep
#FROM php:${PHP_TAG} AS php-fpm

#------------------
#FROM composer-prep
FROM composer:${COMPOSER_TAG} AS composer-prep
LABEL homework="3"
COPY ./app/ /var/www/app/
WORKDIR /var/www/app
RUN composer update && composer install

#------------------
#FROM php-fpm
FROM php:${PHP_TAG} AS php-fpm
LABEL homework="3"
COPY --from=composer-prep /var/www/ /var/www/
