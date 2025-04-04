#!/bin/bash
pushd /var/lib/gel/data >/dev/null
mkdir -p certs
cp /path/to/server.crt certs/
cp /path/to/server.key certs/
sed -i "s/^#ssl = off/ssl = on/" gel.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" gel.conf
popd >/dev/null
