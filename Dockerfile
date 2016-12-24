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

ENV NEXTCLOUD_VERSION 11.0.0

RUN curl -fsSL -o nextcloud.tar.bz2 "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
    curl -fsSL -o nextcloud.tar.bz2.asc "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    # gpg key from https://nextcloud.com/nextcloud.asc
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 28806A878AE423A28372792ED75899B9A724937A && \
    gpg --batch --verify nextcloud.tar.bz2.asc nextcloud.tar.bz2 && \
    rm -r "$GNUPGHOME" nextcloud.tar.bz2.asc && \
    mkdir -p /var/www && \
    tar -xjf nextcloud.tar.bz2 -C /var/www/ && \
    rm nextcloud.tar.bz2 && \
    mv /var/www/nextcloud /var/www/owncloud && \
    chown -R www-data:www-data /var/www/owncloud && \
    mkdir /files && \
    mv /var/www/owncloud/config/* /files

VOLUME ["/var/www/owncloud/config"]
CMD ["/start.sh"]
