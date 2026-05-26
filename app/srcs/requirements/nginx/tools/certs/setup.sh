# srcs/requirements/nginx/tools/setup.sh
#!/bin/bash
set -e

mkdir -p /etc/ssl/private /etc/ssl/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/localhost.key \
  -out /etc/ssl/certs/localhost.crt \
  -subj "/C=FR/ST=France/L=Paris/O=42/OU=Student/CN=localhost"
