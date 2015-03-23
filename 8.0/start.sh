#!/bin/bash

rm -f /run/nginx.pid

/etc/init.d/php5-fpm start
nginx -g "daemon off;"
