ARG NGINX_IMAGE=nginx
ARG NGINX_IMAGE_TAG=stable-alpine
FROM ${NGINX_IMAGE}:${NGINX_IMAGE_TAG}

RUN apk update && apk add --no-cache logrotate openssl

ADD logrotate.conf /etc/logrotate.d/nginx
ADD --chmod=755 nginx-start.sh /1.sh

RUN tr -d '\r' < /1.sh >/nginx-start.sh && chmod +x nginx-start.sh

ENTRYPOINT ["/nginx-start.sh"]
CMD service cron start && nginx -g 'daemon off;'
