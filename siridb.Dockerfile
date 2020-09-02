FROM ubnt/unms-siridb:1.2.6 as unms-siridb
FROM siridb/siridb-server:2.0.38 as siridb

FROM alpine:3.12

COPY --from=siridb /usr/local/bin/siridb-server /usr/local/bin/
COPY --from=siridb /usr/lib/libcleri* /usr/lib/

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
