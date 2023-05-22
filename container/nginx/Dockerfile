ARG NGINX_IMAGE=nginx
ARG NGINX_IMAGE_TAG=alpine
FROM ${NGINX_IMAGE}:${NGINX_IMAGE_TAG}

RUN apk update && apk add --no-cache logrotate openssl

COPY --chmod=755 nginx-start.sh /nginx-start.sh

ENTRYPOINT ["/nginx-start.sh"]
CMD service cron start && nginx -g 'daemon off;'
