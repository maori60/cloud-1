#!/bin/bash

# Crée les répertoires si besoin
mkdir -p /etc/ssl/certs /etc/ssl/private

# Génère le certificat auto-signé
openssl req -x509 -nodes -days 365 \
  -subj "/C=FR/ST=France/L=Paris/O=42/CN=localhost" \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx.key \
  -out /etc/ssl/certs/nginx.crt
