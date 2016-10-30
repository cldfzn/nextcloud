#!/bin/bash

rm -f /run/nginx.pid

if [ -d "/files" ]; then
    mv -n /files/* /var/www/owncloud/config
    rm -rf /files
fi

FILES_MISSING=false
if [ ! -f "${OWNCLOUD_SSL_CERT}" ]; then
    FILES_MISSING=true
    print "Cert file does not exist: ${OWNCLOUD_SSL_CERT}"
fi
if [ ! -f "${OWNCLOUD_SSL_KEY}" ]; then
    FILES_MISSING=true
    print "Key file does not exist: ${OWNCLOUD_SSL_KEY}"
fi
if $FILES_MISSING; then
    exit 1;
fi

envsubst '${OWNCLOUD_HOSTNAME} ${OWNCLOUD_SSL_CERT} ${OWNCLOUD_SSL_KEY}' < /etc/nginx/conf.d/owncloud.conf > /tmp/owncloud.conf
mv /tmp/owncloud.conf /etc/nginx/conf.d/owncloud.conf

/etc/init.d/php5-fpm start
nginx -g "daemon off;"
