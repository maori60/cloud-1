#!/bin/sh
set -eu

# Chemins & outils
export PATH="$PATH:/usr/local/bin"
WP_PATH="/var/www/wordpress"

# DB depuis .env
DB_HOST="${MYSQL_HOST:-mariadb}"
DB_USER="${MYSQL_USER}"
DB_PASS="${MYSQL_PASSWORD}"
DB_NAME="${MYSQL_DATABASE}"

# Optionnel : thème à activer automatiquement
WP_THEME="${WP_THEME:-}"

log()  { printf "\033[1;32m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[setup]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[setup]\033[0m %s\n" "$*"; }

# 1) Attendre MariaDB
log "En attente de MariaDB (${DB_HOST})..."
until mysql -h "${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "USE ${DB_NAME}" >/dev/null 2>&1; do
  sleep 2
done
log "MariaDB OK."

# 2) Préparer le répertoire WP + droits
mkdir -p "${WP_PATH}"
chown -R www-data:www-data "${WP_PATH}"
find "${WP_PATH}" -type d -exec chmod 755 {} \; || true
find "${WP_PATH}" -type f -exec chmod 644 {} \; || true

cd "${WP_PATH}"

# 3) Installer WordPress si nécessaire
if [ ! -f wp-config.php ]; then
  log "Téléchargement de WordPress..."
  wp core download --allow-root

  log "Création wp-config.php..."
  wp config create --allow-root \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}"

  log "Installation de WordPress..."
  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  log "Création de l'utilisateur secondaire..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=author \
    --allow-root
else
  log "WordPress déjà installé, on applique la config."
fi

# 4) Forcer une config saine
log "Forçage des options de fichier (FS_METHOD=direct)..."
wp config set FS_METHOD direct --type=constant --allow-root

if wp config has DISALLOW_FILE_MODS --type=constant --allow-root; then
  wp config set DISALLOW_FILE_MODS false --type=constant --raw --allow-root
fi

# 5) Synchroniser les URLs avec WP_URL
if [ -n "${WP_URL:-}" ]; then
  log "Sync des URLs WordPress avec WP_URL=${WP_URL}..."
  wp option update siteurl "${WP_URL}" --allow-root
  wp option update home "${WP_URL}" --allow-root
fi

# 6) Thème optionnel
if [ -n "${WP_THEME}" ]; then
  log "Installation/activation du thème '${WP_THEME}'..."
  if ! wp theme is-installed "${WP_THEME}" --allow-root; then
    wp theme install "${WP_THEME}" --allow-root
  fi
  wp theme activate "${WP_THEME}" --allow-root || warn "Impossible d'activer le thème ${WP_THEME}"
fi

# 7) Bonus Redis : safe si absent
if ! wp plugin is-installed redis-cache --allow-root; then
  log "Installation du plugin redis-cache..."
  wp plugin install redis-cache --allow-root
fi

wp plugin activate redis-cache --allow-root || warn "Activation plugin redis-cache non critique"

if ! wp config has WP_REDIS_HOST --allow-root; then
  wp config set WP_REDIS_HOST redis --allow-root
fi

if wp redis enable --allow-root >/dev/null 2>&1; then
  log "Redis object cache activé."
else
  warn "Redis non disponible pour le moment (c'est OK)."
fi

# 8) Droits finaux
chown -R www-data:www-data "${WP_PATH}"

log "Setup terminé."
log "Démarrage de PHP-FPM..."

exec php-fpm7.4 --nodaemonize --fpm-config /etc/php/7.4/fpm/php-fpm.conf