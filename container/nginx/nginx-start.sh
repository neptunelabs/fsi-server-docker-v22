#!/bin/sh

if [ ! -d "/etc/nginx/certificates" ]
then
  mkdir /etc/nginx/certificates
fi

if [ -w "/etc/nginx/certificates" ]
then
  if [ ! -f "/etc/nginx/certificates/localhost.crt" ] || [ ! -f "/etc/nginx/certificates/localhost.key" ]
  then
    echo "Create 'localhost' certificates"
    openssl req -x509 \
      -out /etc/nginx/certificates/localhost.crt \
      -keyout /etc/nginx/certificates/localhost.key \
      -newkey rsa:4096 -nodes -sha256 \
      -subj '/CN=localhost' -extensions EXT \
      -config <(printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
    echo "Certificates for 'localhost' generated for test purposes."
  fi
fi

crond
nginx -g 'daemon off;'
