FROM php:8.3-cli


# Create user
RUN groupadd --gid 2000 appgrp \
  && useradd --uid 2000 --gid appgrp --shell /bin/bash --create-home appusr

# Copy APP
# from composer
COPY  --chown=appusr:appgrp  ./app /opt/app
# from docker build
#COPY  --chown=appusr:appgrp  ./app /opt/app
WORKDIR /opt/app

# Add symfony repo
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash

# Install pkg
RUN apt-get update && apt-get install -y bash git 7zip symfony-cli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#RUN curl -sS https://get.symfony.com/cli/installer | bash
#RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

USER appusr
RUN composer update && composer install

CMD [ "symfony", "server:start" ]
#USER root
#CMD [ "/bin/bash" ]
