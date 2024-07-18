FROM debian:bookworm

# Create user
RUN groupadd --gid 2000 appgrp \
  && useradd --uid 2000 --gid appgrp --shell /bin/bash --create-home appusr

WORKDIR /opt/app

# Install dep package
RUN apt-get update && apt-get install -y git 7zip curl apt-transport-https

# Установка php8.3 для debian bookworm с зеркала репозитория surry но с официальным ключем
RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] http://debian.octopuce.fr/sury-php/ bookworm main" > /etc/apt/sources.list.d/surry-php-mirror.list'
RUN apt update && apt install -y  php8.3-common php8.3-cli php8.3-fpm php8.3-curl php8.3-bz2 php8.3-mbstring php8.3-intl php8.3-xml

# Copy APP
# COPY -chown=appusr:appgrp не сработает, так как она не выставляет права на родительскую директорию оставля их root:root а ииспользовать "." не целисообразно, так как хотелось бы сохранить оригинальную иерархию директорий из репозитория и по мимо app в образ попадут и другие директории.
COPY ./app /opt/app
RUN chown appusr:appgrp -R /opt/app

# Add symfony repo
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt-get update && apt-get install -y symfony-cli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER appusr
RUN composer update && composer install
EXPOSE 8000
CMD [ "symfony", "server:start" ]
#USER root
#CMD [ "/bin/bash" ]
