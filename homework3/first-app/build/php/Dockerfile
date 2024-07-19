ARG FROM_COMPOSER_TAG
ARG FROM_PHP_TAG

#------------------
FROM composer:${FROM_COMPOSER_TAG} AS composer-prep
LABEL homework="3"
COPY ./app/ /var/www/app/
WORKDIR /var/www/app
RUN composer update && composer install

#------------------
FROM php:${FROM_PHP_TAG} AS php-fpm
LABEL homework="3"
COPY --from=composer-prep /var/www/ /var/www/
