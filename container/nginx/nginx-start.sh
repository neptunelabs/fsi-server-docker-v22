#!/usr/bin/env sh

if [ -w "/etc/nginx/certificates" ]
then
  if [ ! -f "/etc/nginx/certificates/localhost.crt" ] || [ ! -f "/etc/nginx/certificates/localhost.key" ]
  then
    openssl req -x509 -out /etc/nginx/certificates/localhost.crt \
      -keyout /etc/nginx/certificates/localhost.key \
      -newkey rsa:4096 -nodes -sha256 \
      -subj '/CN=localhost' -extensions EXT \
      -config <(printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
  fi
fi

crond
nginx -g 'daemon off;'
