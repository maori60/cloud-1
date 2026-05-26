FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      nginx openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Génère un certificat autosigné aux CHEMINS attendus par nginx.conf
# CN = vbui.42.fr pour matcher le server_name
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/server.key \
      -out    /etc/nginx/ssl/server.crt \
      -days 365 \
      -subj "/C=FR/ST=IDF/L=Paris/O=Inception/OU=Dev/CN=vbui.42.fr"

# Copie la conf unique (aucun autre vhost actif)
COPY conf/nginx.conf /etc/nginx/nginx.conf

# (Recommandé) Nettoie toute conf par défaut parasite
RUN rm -f /etc/nginx/conf.d/* /etc/nginx/sites-enabled/* /etc/nginx/sites-available/* || true

# Prépare le docroot (partagé par volume)
RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www

EXPOSE 443
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
