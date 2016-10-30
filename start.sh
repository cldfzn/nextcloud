#!/bin/bash

rm -f /run/nginx.pid

if [ -d "/files" ]; then
    mv -n /files/* /var/www/owncloud/config
    rm -rf /files
fi

envsubst '${OWNCLOUD_HOSTNAME} ${OWNCLOUD_SSL_CERT} ${OWNCLOUD_SSL_KEY}' < /etc/nginx/conf.d/owncloud.conf > /etc/nginx/conf.d/owncloud.conf

/etc/init.d/php5-fpm start
nginx -g "daemon off;"
