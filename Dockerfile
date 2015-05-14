FROM nginx:1.9
MAINTAINER Alexander Johnson <alex@cldfzn.com>

ENV OWNCLOUD_VERSION 8.0.3

RUN apt-get update && \
    apt-get -y install php5-fpm php5-gd php5-json php5-curl php5-sqlite php5-intl php5-mcrypt php5-imagick php5-apcu php5-mysql smbclient curl bzip2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/www && \
    curl -k https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 | tar jx -C /var/www/ && \
    chown -R www-data:www-data /var/www/owncloud

COPY fpm.conf /etc/nginx/conf.d/fpm.conf
# Update max post size and max file size
COPY nginx.conf /etc/nginx/nginx.conf
COPY owncloud.conf /etc/nginx/conf.d/owncloud.conf
RUN sed -i 's/^post_max_size.*/post_max_size = 513M/' /etc/php5/fpm/php.ini
RUN sed -i 's/^upload_max_filesize.*/upload_max_filesize = 512M/' /etc/php5/fpm/php.ini
RUN sed -i 's/^;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/' /etc/php5/fpm/php.ini

COPY start.sh /start.sh
RUN chmod +x /start.sh

VOLUME ["/var/www/owncloud/config", "/etc/nginx/conf.d", "/etc/ssl/nginx"]
CMD ["/start.sh"]
