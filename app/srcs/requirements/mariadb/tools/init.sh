#!/bin/sh
set -e

echo "🚀 Lancement de MariaDB..."

INIT_MARKER="/var/lib/mysql/.inception_init_done"

if [ ! -f "$INIT_MARKER" ]; then
    echo "📦 Initialisation de la base de données..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

    echo "⏳ Démarrage temporaire de MariaDB..."
    mysqld_safe --skip-networking --datadir=/var/lib/mysql &
    TEMP_PID=$!

    echo "⏳ En attente de MariaDB..."
    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "🔧 Création de la base et des utilisateurs..."
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "✅ Marquage de l'initialisation terminée..."
    touch "$INIT_MARKER"
    chown mysql:mysql "$INIT_MARKER"

    echo "🛑 Arrêt de l'instance MariaDB temporaire..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$TEMP_PID"
fi

echo "✅ Initialisation terminée."
echo "🚀 Démarrage final de MariaDB..."

exec mysqld_safe --datadir=/var/lib/mysql