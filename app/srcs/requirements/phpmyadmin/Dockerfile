FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    phpmyadmin \
    php-mysqli \
    php-mbstring \
    php-zip \
    php-gd \
    php-json \
    php-curl \
    mariadb-client \
    && ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
