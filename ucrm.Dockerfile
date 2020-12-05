FROM ubnt/unms-crm:3.3.2 as unms-crm

FROM php:8.0.0-fpm-alpine

ARG NGINX_VERSION=1.19.5
ADD "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    /tmp/nginx.tar.gz

COPY --from=unms-crm /data \
                     /data

COPY --from=unms-crm /etc/nginx/ \
                     /etc/nginx/
COPY --from=unms-crm /etc/logrotate.d/ \
                     /etc/logrotate.d/

COPY --from=unms-crm /root/.ssh/config \
                     /root/.ssh/config

COPY --from=unms-crm /tmp/crontabs/ \
                     /tmp/crontabs/
COPY --from=unms-crm /tmp/DoctrineMigrations/ \
                     /tmp/DoctrineMigrations/
COPY --from=unms-crm /tmp/supervisor.d \
                     /tmp/supervisor.d
COPY --from=unms-crm /tmp/supervisord \
                     /tmp/supervisord

COPY --from=unms-crm /usr/local/bin/crm* \
                     /usr/local/bin/
COPY --from=unms-crm /usr/local/etc/php/php.ini \
                     /usr/local/etc/php/php.ini
COPY --from=unms-crm /usr/local/etc/php-fpm.d/*.conf \
                     /usr/local/etc/php-fpm.d/

COPY --from=unms-crm /usr/src/ucrm \
                     /usr/src/ucrm

ENV TERM=xterm \
    POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_USER=ucrm \
    POSTGRES_PASSWORD=ucrm \
    POSTGRES_DB=unms \
    POSTGRES_SCHEMA=ucrm \
    UNMS_POSTGRES_SCHEMA=unms \
    MAILER_HOST=127.0.0.1 \
    MAILER_USERNAME=unms \
    MAILER_PASSWORD=unms \
    MAILER_AUTH_MODE=null \
    MAILER_ENCRYPTION=null \
    MAILER_PORT=null \
    MAILER_TRANSPORT=smtp \
    RABBITMQ_HOST=rabbitmq \
    RABBITMQ_PORT=5672 \
    RABBITMQ_USER=guest \
    RABBITMQ_PASSWORD=guest \
    NETFLOW_HOST=0.0.0.0 \
    NETFLOW_PORT=2055 \
    SECRET=enigma \
    SYMFONY_ENV=prod \
    FORCE_HTTPS=1 \
    TRUSTED_PROXIES=all \
    UCRM_USERNAME=unms \
    UCRM_PASSWORD=unms \
    UCRM_DISK_USAGE_DIRECTORY=/ \
    UAS_INSTALLATION= \
    UNMS_HOST=unms \
    UNMS_PORT=443 \
    UNMS_TOKEN=enigma \
    UNMS_VERSION=1.2.6 \
    SUSPEND_PORT=81 \
    CLOUD=0 \
    CLOUD_SMTP_PORT=null \
    CLOUD_SMTP_USERNAME=unms \
    CLOUD_SMTP_PASSWORD=unms \
    CLOUD_SMTP_HOSTNAME=127.0.0.1 \
    CLOUD_SMTP_TLS_ALLOW_UNAUTHORIZED=null \
    CLOUD_SMTP_SECURITY_MODE=null \
    CLOUD_MAPS_API_KEY=null \
    PUBLIC_HTTPS_PORT=443 \
    CLOUD_STRIPE_CONNECT_ONBOARDING_URL= \
    CLOUD_STRIPE_CONNECT_PROXY_SECRET_KEY= \
    CLOUD_STRIPE_CONNECT_PROXY_URL= \
    CLOUD_STRIPE_CONNECT_PUBLISHABLE_KEY=

RUN chmod -R 775 /usr/local/bin/crm-* \
 && apk add --no-cache --update --virtual .build-deps \
        autoconf \
        build-base bzip2-dev \
        dpkg-dev dpkg \
        file freetype-dev \
        git gmp-dev \
        icu-dev \
        libjpeg-turbo-dev libpng-dev libxml2-dev libwebp-dev libzip-dev linux-headers \
        make \
        openssl-dev \
        pcre-dev pkgconfig 'postgresql-dev<13' \
        re2c \
        zlib-dev \
 && apk add --no-cache --update \
        bzip2 bash \
        ca-certificates curl \
        dbus dumb-init \
        fontconfig \
        gd gettext gmp gnu-libiconv \
        icu imap-dev \
        jq \
        libgmpxx libpng libpq libwebp libxml2 libxml2-utils libzip logrotate \
        make \
        nodejs nodejs-npm \
        openssl \
        patch pcre 'postgresql-client<13' 'postgresql-libs<13' \
        su-exec supervisor \
        ttf-freefont tzdata \
        wget \
        yarn \
        zlib \
 && export LD_PRELOAD="/usr/lib/preloadable_libiconv.so php" \
 && touch /etc/ssl/openssl.cnf \
 && /usr/src/ucrm/scripts/update-certificates.sh \
 && pecl channel-update pecl.php.net \
 && pecl install apcu ds \
 && docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-webp-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-configure imap \
      --with-imap-ssl \
 && docker-php-ext-configure zip \
      --with-libzip=/usr/include/ \
 && docker-php-ext-enable apcu ds \
 && docker-php-ext-install -j$(nproc) \
      bcmath bz2 \
      exif \
      gd gmp \
      imap intl \
      opcache \
      pdo_pgsql \
      soap sockets sysvmsg sysvsem sysvshm \
      zip \
 && docker-php-source delete \
 && cd /tmp \
 && tar xzf nginx.tar.gz \
 && cd /tmp/nginx-$NGINX_VERSION \
 && ./configure \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/data/log/ucrm/nginx-src.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --user=nginx \
      --group=nginx \
      --with-debug \
      --with-threads \
      --with-file-aio \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_sub_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_auth_request_module \
      --with-http_random_index_module \
      --with-http_secure_link_module \
      --with-http_slice_module \
      --with-http_stub_status_module \
      --http-log-path=/data/log/ucrm/php/access.log \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --with-mail \
      --with-mail_ssl_module \
      --with-stream \
      --with-stream_ssl_module \
      --with-stream_realip_module \
 && make -j$(nproc) \
 && make install \
 && adduser -D nginx \
 && sed -i -e 's/#access_log  logs\/access.log  main;/access_log \/dev\/stdout;/' \
           -e 's/#error_log  logs\/error.log  notice;/error_log stderr notice;/' \
           /etc/nginx/nginx.conf \
 && cd /usr/src/ucrm/ \
 && ./scripts/dirs.sh \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && composer global require hirak/prestissimo \
 && composer install --classmap-authoritative --no-dev --no-interaction \
 && app/console assets:install --symlink web \
 && composer clear-cache \
 && apk del .build-deps \
 && cp web/assets/fonts/lato/fonts/*.ttf /usr/share/fonts/TTF/ \
 && fc-cache -f -v \
 && touch /tmp/UCRM_init.log \
 && mkdir -p /var/cache/nginx \
             /var/log/nginx \
             /var/lib/nginx \
             /run/nginx \
             /etc/nginx/enabled-servers \
             /usr/src/ucrm/app/cache/prod \
             /usr/src/ucrm/app/data \
             /usr/src/ucrm/web/media \
             /usr/src/ucrm/web/uploads \
             /usr/src/ucrm/web/_plugins \
 && chown -R nginx:nginx /var/lib/nginx \
                         /usr/src/ucrm/app \
                         /usr/src/ucrm/scripts \
                         /usr/src/ucrm/src \
                         /usr/src/ucrm/web \
                         /usr/src/ucrm/* \
                         /usr/src/ucrm \
 && chmod -R 775 /var/lib/nginx \
                 /usr/src/ucrm/app/cache \
                 /usr/src/ucrm/app/EmailQueue \
                 /usr/src/ucrm/app/data \
                 /usr/src/ucrm/web/media \
                 /usr/src/ucrm/web/uploads \
                 /usr/src/ucrm/web/assets \
                 /usr/src/ucrm/web/_plugins \
                 /usr/src/ucrm/scripts \
 && chmod -R 777 /tmp \
 && rm -rf /etc/logrotate.d/nginx \
           /tmp/nginx.tar.gz \
           /usr/bin/composer \
           /usr/src/ucrm/app/cache/prod/*

VOLUME [ "/data" ]

WORKDIR /usr/src/ucrm

ENTRYPOINT [ "dumb-init", "--", "make" ]
