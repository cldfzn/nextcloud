#!/bin/bash

rm -f /run/nginx.pid

if [ -d "/files" ]; then
    mv -n /files/* /var/www/owncloud/config
    rm -rf /files
fi

/etc/init.d/php5-fpm start
nginx -g "daemon off;"
