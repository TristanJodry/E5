#!/bin/bash

mkdir -p /etc/ssl/private

openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048

openssl req -x509 -nodes -newkey rsa:2048 -sha256 -key out \
/etc/ssl/private/pure-ftpd.pem \
-out /etc/ssl/private/pure-ftpd.pem

chmod 600 /etc/ssl/private/*.pem

service pure-ftpd stop

echo 2 > /etc/pure-ftpd/conf/TLS

service pure-ftpd start
