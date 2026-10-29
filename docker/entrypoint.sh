#!/bin/sh
# Render assigns the port through $PORT; Apache's stock config listens on 80.
set -e

PORT="${PORT:-10000}"

sed -ri "s/^Listen 80$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

exec apache2-foreground
