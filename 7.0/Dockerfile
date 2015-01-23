FROM cldfzn/nginx
MAINTAINER Alexander Johnson <alex@cldfzn.com>

ENV OWNCLOUD_VERSION 7.0.4

RUN apt-get  update && \
    apt-get -y install php5-fpm php5-gd php5-json php5-curl php5-sqlite php5-intl php5-mcrypt php5-imagick php5-apcu smbclient curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -k https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 | tar jx -C /var/www/ && \
    chown -R www-data:www-data /var/www/owncloud

COPY owncloud-key.pem /etc/ssl/nginx/owncloud-key.pem
COPY owncloud-cert.pem /etc/ssl/nginx/owncloud-cert.pem
COPY fpm.conf /etc/nginx/conf.d/fpm.conf
# Update max post size and max file size
COPY php.ini /etc/php5/fpm/php.ini
COPY owncloud /etc/nginx/sites-available/owncloud
COPY start.sh /start.sh

RUN rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/owncloud
RUN chmod +x /start.sh

VOLUME ["/var/www/owncloud/config", "/etc/nginx/sites-available", "/etc/ssl/nginx"]
CMD ["/start.sh"]
