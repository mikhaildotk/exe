FROM composer:lts AS composer-prep
FROM php:8.3-fpm-alpine AS php-fpm

#------------------
FROM composer-prep
LABEL homework="3"
WORKDIR /usr/src/app
RUN composer update && composer install

#------------------
FROM php-fpm
LABEL homework="3"
