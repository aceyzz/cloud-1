#!/bin/sh
set -e
envsubst '${SERVER_URL} ${PATH_SSL_CERT} ${PATH_SSL_KEY}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf
exit 0