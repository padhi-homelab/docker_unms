FROM ubnt/unms:1.2.7 as unms

FROM node:10-alpine

ARG LIBVIPS_VERSION=8.10.0

ADD "https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.gz" \
    /tmp/libvips.tar.gz

COPY --from=unms /home/app/unms /home/app/unms
COPY --from=unms /usr/local/bin/docker-entrypoint.sh /usr/local/bin/

RUN sed -i 's#dirs=(#dirs=(\n  \${DATA_DIR}/cache#g' \
        /usr/local/bin/docker-entrypoint.sh \
 && apk add --no-cache --update --virtual .build-deps \
        build-base \
        gnupg \
        make \
        pkgconfig \
        python \
 && apk add --no-cache --update \
        bash \
        dumb-init \
        expat-dev \
        giflib-dev \
        glib-dev \
        gzip \
        imagemagick-dev \
        libcap \
        libexif-dev \
        libheif-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        openssl \
        postgresql \
        redis \
        su-exec \
        tiff-dev \
 && cd /tmp \
 && tar -zxvf libvips.tar.gz \
 && cd vips-${LIBVIPS_VERSION} && ./configure \
 && make -j$(nproc) && make install && ldconfig / \
 && cd /home/app/unms \
 && rm -rf node_modules \
 && sed -i 's/"@sentry\/cli": "1.49.0"/"@sentry\/cli": "1.55.2"/g' package.json \
 && sed -i "/postinstall/d" package.json \
 && CHILD_CONCURRENCY=1 yarn install --ignore-engines \
                                     --network-timeout 1000000 \
                                     --no-cache \
                                     --production \
 && yarn add npm --production \
 && yarn cache clean \
 && mkdir -p -m 777 "public/site-images" \
 && cp -r /home/app/unms/node_modules/npm /home/app/unms/ \
 && apk del --purge .build-deps \
 && rm -rf /var/cache/apk/* /tmp/* \
 && setcap cap_net_raw=pe /usr/local/bin/node

ENV HOME=/home/app \
    PATH=/home/app/unms/node_modules/.bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    UCRM_HOST=ucrm \
    UCRM_PORT=80 \
    UNMS_NGINX_HOST=nginx \
    UNMS_NGINX_PORT=12345 \
    UNMS_PG_HOST=postgres \
    UNMS_PG_PORT=5432 \
    UNMS_RABBITMQ_HOST=rabbitmq \
    UNMS_RABBITMQ_PORT=5672 \
    UNMS_REDISDB_HOST=redis \
    UNMS_REDISDB_PORT=6379 \
    UNMS_SIRIDB_HOST=siridb \
    UNMS_SIRIDB_PORT=9000 \
    NODE_ENV=production \
    HTTP_PORT=8081 \
    WS_PORT=8082 \
    WS_SHELL_PORT=8083 \
    UNMS_WS_API_PORT=8084 \
    UNMS_NETFLOW_PORT=2055 \
    PUBLIC_HTTPS_PORT=443 \
    PUBLIC_WS_PORT=443 \
    NGINX_HTTPS_PORT=443 \
    NGINX_WS_PORT=443 \
    SUSPEND_PORT=81 \
    BRANCH=master \
    SECURE_LINK_SECRET=enigma \
    UNMS_TOKEN=enigma \
    CLUSTER_SIZE=auto \
    UNMS_PG_PASSWORD=unms \
    UNMS_PG_USER=unms \
    UNMS_PG_DB=unms \
    UNMS_PG_SCHEMA=unms \
    USE_LOCAL_DISCOVERY=true

WORKDIR /home/app/unms

ENTRYPOINT ["/usr/bin/dumb-init", "docker-entrypoint.sh"]

CMD ["index.js"]

HEALTHCHECK --start-period=5m --interval=120s --timeout=5s --retries=3 \
        CMD ["wget", "--tries", "5", "-qSO", "/dev/null", "http://localhost:8081"]
