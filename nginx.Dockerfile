FROM ubnt/unms-nginx:1.3.3 as unms-nginx

FROM alpine:3.12
USER root

COPY --from=unms-nginx entrypoint.sh /real-entrypoint.sh
COPY --from=unms-nginx refresh-certificate.sh refresh-configuration.sh openssl.cnf ip-whitelist.sh /
COPY --from=unms-nginx /templates /templates
COPY --from=unms-nginx /www /www

ENV NGINX_VERSION=nginx-1.19.5 \
    NGINX_LUA_VERSION=0.10.14 \
    NGINX_DEVEL_KIT_VERSION=0.3.1 \
    LUAJIT_VERSION=2.1.0-beta3 \
    CERTBOT_VERSION=1.8.0

ADD "http://nginx.org/download/${NGINX_VERSION}.tar.gz" \
    /tmp/nginx.tar.gz
ADD "https://github.com/openresty/lua-nginx-module/archive/v${NGINX_LUA_VERSION}.tar.gz" \
    /tmp/lua-nginx-module.tar.gz
ADD "https://github.com/simpl/ngx_devel_kit/archive/v${NGINX_DEVEL_KIT_VERSION}.tar.gz" \
    /tmp/ndk.tar.gz
ADD "http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz" \
    /tmp/luajit.tar.gz

RUN chmod +x /real-entrypoint.sh /refresh-certificate.sh /refresh-configuration.sh /ip-whitelist.sh \
 && cd /tmp \
 && tar -zxvf lua-nginx-module.tar.gz \
 && tar -zxvf ndk.tar.gz \
 && tar -zxvf luajit.tar.gz \
 && tar -zxvf nginx.tar.gz \
 && apk add --no-cache --update --virtual .build-deps \
        build-base \
        libffi-dev \
        openssl-dev \
        pcre-dev \
        python3-dev \
        zlib-dev \
 && apk add --no-cache --update \
        coreutils \
        dumb-init \
        gettext \
        libgcc \
        openssl \
        pcre \
        py-pip \
        sudo \
 && pip install "certbot==${CERTBOT_VERSION}" \
 && cd "/tmp/LuaJIT-${LUAJIT_VERSION}" \
 && make amalg PREFIX='/usr' \
 && make install PREFIX='/usr' \
 && export LUAJIT_LIB=/usr/lib/libluajit-5.1.so \
 && export LUAJIT_INC=/usr/include/luajit-2.1 \
 && cd "/tmp/${NGINX_VERSION}" \
 && ./configure \
      --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
      --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now -fPIC' \
      --with-pcre-jit \
      --with-threads \
      --add-module="/tmp/lua-nginx-module-${NGINX_LUA_VERSION}" \
      --add-module="/tmp/ngx_devel_kit-${NGINX_DEVEL_KIT_VERSION}" \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_gzip_static_module \
      --with-http_secure_link_module \
      --without-mail_pop3_module \
      --without-mail_imap_module \
      --without-http_upstream_ip_hash_module \
      --without-http_memcached_module \
      --without-http_auth_basic_module \
      --without-http_userid_module \
      --without-http_fastcgi_module \
      --without-http_uwsgi_module \
      --without-http_scgi_module \
      --prefix=/var/lib/nginx \
      --sbin-path=/usr/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --http-log-path=/dev/stdout \
      --error-log-path=/dev/stderr \
      --lock-path=/tmp/nginx.lock \
      --pid-path=/tmp/nginx.pid \
      --http-client-body-temp-path=/tmp/body \
      --http-proxy-temp-path=/tmp/proxy \
 && make -j$(nproc) && make install \
 && apk del .build-deps \
 && rm -rf "/usr/bin/luajit-${LUAJIT_VERSION}" \
           /tmp/* \
           /var/cache/apk/* \
 && echo 'unms ALL=(ALL) NOPASSWD: /usr/sbin/nginx -s *' >> /etc/sudoers \
 && echo 'unms ALL=(ALL) NOPASSWD: /bin/cat *' >> /etc/sudoers \
 && echo 'unms ALL=(ALL) NOPASSWD:SETENV: /refresh-configuration.sh *' >> /etc/sudoers \
 && echo -e '#!/bin/sh\n/real-entrypoint.sh\nchown -R unms:unms /cert /config/cert\n/real-entrypoint.sh "$@"' > /entrypoint.sh \
 && chmod +x /entrypoint.sh

ENV NGINX_UID=1000 \
    HTTP_PORT=80 \
    HTTPS_PORT=443 \
    SUSPEND_PORT=81 \
    WS_PORT=443 \
    UNMS_HOST=unms \
    UNMS_HTTP_PORT=8081 \
    UNMS_WS_PORT=8082 \
    UNMS_WS_SHELL_PORT=8083 \
    UNMS_WS_API_PORT=8084 \
    UNMS_IP_WHITELIST="" \
    UCRM_HOST=ucrm \
    UCRM_HTTP_PORT=80 \
    UCRM_SUSPEND_PORT=81 \
    PUBLIC_HTTPS_PORT=443 \
    SECURE_LINK_SECRET=enigma

EXPOSE 80 81 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
