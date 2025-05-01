#!/bin/bash

set -euo pipefail

ZABBIX_DB="zabbix"
ZABBIX_DB_USER="zabbix"
ZABBIX_DB_PASSWORD="StrongPassword123"
PG_VERSION="14"

apt install gnupg -y
#postgres
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#zabbix
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb

apt update

DEBIAN_FRONTEND=noninteractive apt install -y \
    zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent \
    snmpd \
    postgresql-$PG_VERSION \
    postgresql-client-$PG_VERSION \
    php-pgsql php-bcmath php-mbstring php-gd php-xml php-ldap php-curl php-json php-php-gettext php-soap php-intl

systemctl enable postgresql
systemctl start postgresql

sudo -u postgres psql <<EOF
CREATE DATABASE $ZABBIX_DB ENCODING 'UTF8' TEMPLATE template0;
CREATE USER $ZABBIX_DB_USER WITH PASSWORD '$ZABBIX_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $ZABBIX_DB TO $ZABBIX_DB_USER;
EOF
#works fine
zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix 
#
sed -i "s/^# DBPassword=/DBPassword=$ZABBIX_DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
sed -i "s/^# DBName=zabbix/DBName=$ZABBIX_DB/" /etc/zabbix/zabbix_server.conf
sed -i "s/^# DBUser=zabbix/DBUser=$ZABBIX_DB_USER/" /etc/zabbix/zabbix_server.conf

NGINX_CONF="/etc/zabbix/nginx.conf"
sed -i 's|^#\s+listen 8080;|    listen 80;|' "$NGINX_CONF"
sed -i 's|^#\s+server_name example.com;|    server_name localhost;|' "$NGINX_CONF"

cp /etc/zabbix/nginx.conf /etc/nginx/sites-available/zabbix
ln -s /etc/nginx/sites-available/zabbix /etc/nginx/sites-enabled/zabbix

systemctl restart zabbix-server zabbix-agent nginx
systemctl enable zabbix-server zabbix-agent nginx

locale-gen "en_US.UTF-8"

echo "[*] Installation done, pls restart server."
echo "[*] http://$(hostname -I | awk '{print $1}'):8080"
