FROM nginx:1.10.1
MAINTAINER Alexander Johnson <alex@cldfzn.com>

RUN apt-get update && \
    apt-get -y install php5-fpm php5-gd php5-json php5-curl php5-sqlite php5-intl php5-mcrypt php5-imagick php5-mysql php5-redis smbclient curl bzip2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY fpm.conf /etc/nginx/conf.d/fpm.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY owncloud.conf /etc/nginx/conf.d/owncloud.conf

RUN sed -i 's/^post_max_size.*/post_max_size = 513M/' /etc/php5/fpm/php.ini && \
    sed -i 's/^upload_max_filesize.*/upload_max_filesize = 512M/' /etc/php5/fpm/php.ini && \
    sed -i 's/^;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/' /etc/php5/fpm/php.ini && \
    sed -i 's/^;env\[PATH\]/env[PATH]/' /etc/php5/fpm/pool.d/www.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV OWNCLOUD_VERSION 9.0.2

RUN mkdir /var/www && \
    curl -k https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 | tar jx -C /var/www/ && \
    chown -R www-data:www-data /var/www/owncloud

RUN mkdir /files && \
    mv /var/www/owncloud/config/* /files

VOLUME ["/var/www/owncloud/config", "/etc/nginx/conf.d", "/etc/ssl/nginx"]
CMD ["/start.sh"]
