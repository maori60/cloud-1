FROM debian:bullseye

# Installer les paquets nécessaires
RUN apt-get update && \
    apt-get install -y \
        php7.4 php7.4-fpm php7.4-mysql \
        php7.4-curl php7.4-mbstring php7.4-xml \
        php7.4-zip php7.4-gd php7.4-sqlite3 \
        mariadb-client \
        curl wget unzip less vim git \
        sqlite3 libsqlite3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Créer les répertoires nécessaires
RUN mkdir -p /run/php /var/www/wordpress

# Définir le dossier de travail
WORKDIR /var/www/wordpress

# Installer wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copier les fichiers de configuration PHP-FPM
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./conf/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

# Copier le script de setup
COPY ./tools/setup.sh /tools/setup.sh
RUN chmod +x /tools/setup.sh

# Exposer le port PHP-FPM
EXPOSE 9000

# Lancer le script d'initialisation, qui finira par exec php-fpm
CMD ["/tools/setup.sh"]