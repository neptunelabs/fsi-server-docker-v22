ARG NGINX_VERSION=latest
FROM nginx:${NGINX_VERSION}

ADD nginx-start.sh /nginx-start.sh

ENTRYPOINT ["/nginx-start.sh"]
