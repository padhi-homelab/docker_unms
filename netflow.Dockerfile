FROM ubnt/unms-netflow:1.2.6 as unms-netflow

FROM node:10-alpine

COPY --from=unms-netflow /home/app /home/app
COPY --from=unms-netflow /usr/local/bin/docker-entrypoint.sh /usr/local/bin/

RUN apk add --no-cache --update --virtual .build-deps \
        build-base \
        python \
 && apk add --no-cache --update \
        dumb-init \
 && cd /home/app \
 && rm -rf node_modules \
 && yarn install --production --no-cache --ignore-engines \
 && yarn cache clean \
 && apk del --purge .build-deps \
 && rm -rf /var/cache/apk/*

ENV UNMS_PG_HOST=postgres \
    UNMS_PG_PORT=5432 \
    UNMS_NETFLOW_PORT=2055 \
    UNMS_PG_PASSWORD=unms \
    UNMS_PG_USER=unms \
    UNMS_PG_DB=unms \
    UNMS_PG_SCHEMA=unms

EXPOSE 2055/udp

WORKDIR /home/app

ENTRYPOINT ["/usr/bin/dumb-init", "docker-entrypoint.sh"]

CMD ["index.js"]