FROM php:8.2-apache

# MySQL PDO driver, URL rewriting and a document root that reads .htaccess.
RUN docker-php-ext-install pdo_mysql \
    && a2enmod rewrite \
    && sed -ri 's|AllowOverride None|AllowOverride All|g; s|Options Indexes FollowSymLinks|Options -Indexes +FollowSymLinks|g' /etc/apache2/apache2.conf \
    && printf 'date.timezone=Asia/Manila\n' > /usr/local/etc/php/conf.d/zz-app.ini \
    && echo 'ServerName localhost' >> /etc/apache2/apache2.conf

COPY docker/entrypoint.sh /usr/local/bin/render-entrypoint
RUN chmod +x /usr/local/bin/render-entrypoint

WORKDIR /var/www/html
COPY . /var/www/html

# Render routes traffic to $PORT (10000 by default); entrypoint.sh rebinds Apache to it.
ENV PORT=10000
EXPOSE 10000

CMD ["render-entrypoint"]
