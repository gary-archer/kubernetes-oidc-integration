#!/bin/bash

#######################################################################################
# Create internal development SSL certificates for the mock authorization server
# The Kubernetes API server requires SSL endpoints to get the token signing public keys
#######################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -f ./internal.ssl.key ]; then
  echo 'Internal SSL certificate files already exist'
  exit 0
fi

echo 'Using OpenSSL to create internal SSL certificates'
openssl ecparam -name prime256v1 -genkey -noout -out internal-ca.key
if [ $? -ne 0 ]; then
  exit 1
fi
chmod 644 internal-ca.key

openssl req \
    -x509 \
    -new \
    -key internal-ca.key \
    -out internal-ca.crt \
    -subj "/CN=Internal Development CA" \
    -days 3650 \
    -addext 'basicConstraints=critical,CA:TRUE'
if [ $? -ne 0 ]; then
  exit 1
fi

openssl ecparam -name prime256v1 -genkey -noout -out internal-ssl.key
if [ $? -ne 0 ]; then
  exit 1
fi
chmod 644 internal-ssl.key

openssl req \
    -x509 \
    -new \
    -CA internal-ca.crt \
    -CAkey internal-ca.key \
    -key internal-ssl.key \
    -out internal-ssl.crt \
    -subj "/CN=mockauthorizationserver" \
    -days 365 \
    -addext 'basicConstraints=critical,CA:FALSE' \
    -addext 'extendedKeyUsage=serverAuth' \
    -addext "subjectAltName=DNS:mockauthorizationserver.identity.svc"
if [ $? -ne 0 ]; then
  exit 1
fi
echo 'All internal SSL certificates generated successfully'
