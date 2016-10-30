FROM nginx:stable
MAINTAINER Alexander Johnson <alex@cldfzn.com>

ENV OWNCLOUD_HOSTNAME owncloud.example.com
ENV OWNCLOUD_SSL_CERT /etc/ssl/nginx/owncloud-cert.pem
ENV OWNCLOUD_SSL_KEY /etc/ssl/nginx/owncloud-key.pem

COPY start.sh /start.sh
COPY fpm.conf /etc/nginx/conf.d/fpm.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY owncloud.conf /etc/nginx/conf.d/owncloud.conf

RUN chmod +x /start.sh

RUN apt-get update && \
    apt-get -y install curl bzip2 php5-fpm php5-gd php5-json php5-curl php5-sqlite php5-intl php5-mcrypt php5-imagick php5-mysql php5-redis smbclient && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^post_max_size.*/post_max_size = 513M/' /etc/php5/fpm/php.ini && \
    sed -i 's/^upload_max_filesize.*/upload_max_filesize = 512M/' /etc/php5/fpm/php.ini && \
    sed -i 's/^;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/' /etc/php5/fpm/php.ini && \
    sed -i 's/^;env\[PATH\]/env[PATH]/' /etc/php5/fpm/pool.d/www.conf

ENV OWNCLOUD_VERSION 10.0.1

RUN mkdir /var/www && \
    curl -k https://download.nextcloud.com/server/releases/nextcloud-${OWNCLOUD_VERSION}.tar.bz2 | tar jx -C /var/www/ && \
    mv /var/www/nextcloud /var/www/owncloud && \
    chown -R www-data:www-data /var/www/owncloud && \
    mkdir /files && \
    mv /var/www/owncloud/config/* /files

VOLUME ["/var/www/owncloud/config"]
CMD ["/start.sh"]
