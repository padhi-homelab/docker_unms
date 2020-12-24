FROM alpine:3.12 as builder

ARG LIBCLERI_VERSION=0.12.1
ARG SIRIDB_VERSION=2.0.42

RUN apk update \
 && apk upgrade \
 && apk add --no-cache --update \
        gcc \
        git \
        libuv-dev \
        linux-headers \
        make \
        musl-dev \
        pcre2-dev \
        util-linux-dev \
        yajl-dev \
 && git clone https://github.com/transceptor-technology/libcleri.git \
              /tmp/libcleri \
 && cd /tmp/libcleri \
 && git checkout $LIBCLERI_VERSION \
 && cd Release \
 && make all \
 && make install \
 && git clone https://github.com/SiriDB/siridb-server.git \
        /tmp/siridb-server \
 && cd /tmp/siridb-server \
 && git checkout $SIRIDB_VERSION \
 && cd Release \
 && make clean \
 && make


FROM ubnt/unms-siridb:1.3.5 as unms-siridb

FROM alpine:3.12

COPY --from=builder /tmp/siridb-server/Release/siridb-server /usr/local/bin/
COPY --from=builder /usr/lib/libcleri* /usr/lib/

COPY --from=unms-siridb /entrypoint.sh /entrypoint.sh
COPY --from=unms-siridb /etc/siridb/siridb.conf /etc/siridb/siridb.conf

RUN apk add --no-cache --update \
        dumb-init \
        libuuid \
        libuv \
        pcre2 \
        su-exec \
        yajl \
 && mkdir -p /etc/siridb \
 && mkdir -p /var/lib/siridb \
 && chmod +x /entrypoint.sh /usr/local/bin/*

VOLUME ["/var/lib/siridb/"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["siridb-server", "--log-level", "debug"]
