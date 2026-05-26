FROM debian:bullseye

# Installation de MariaDB
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Préparer les dossiers
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

# Copier le script d'init
COPY ./tools/init.sh /docker-entrypoint-initdb.d/init.sh
COPY ./conf/my.cnf /etc/mysql/my.cnf
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

EXPOSE 3306

CMD ["sh", "/docker-entrypoint-initdb.d/init.sh"]
