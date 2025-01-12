#!/bin/bash

###################################################################
# Create development SSL certificates for API gateway external URLs
###################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Return if already created, to prevent the need to reconfigure trust on every deployment
#
if [ -f 'external.ssl.key' ]; then
  exit 0
fi

#
# Require up to date OpenSSL
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install openssl version 3 or higher before running this script'
  exit 1
fi

#
# Create the root authority
#
openssl ecparam -name prime256v1 -genkey -noout -out 'external-ca.key'
if [ $? -ne 0 ]; then
  exit 1
fi

openssl req \
    -x509 \
    -new \
    -key 'external-ca.key' \
    -out 'external-ca.crt' \
    -subj '/CN=Developer CA for test.example' \
    -days 3650 \
    -addext 'basicConstraints=critical,CA:TRUE'
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a wildcard SSL certificate
# 
openssl ecparam -name prime256v1 -genkey -noout -out 'external-ssl.key'
if [ $? -ne 0 ]; then
  exit 1
fi

openssl req \
    -x509 \
    -new \
    -CA 'external-ca.crt' \
    -CAkey 'external-ca.key' \
    -key 'external-ssl.key' \
    -out 'external-ssl.crt' \
    -subj '/CN=*.test.example' \
    -days 365 \
    -addext 'basicConstraints=critical,CA:FALSE' \
    -addext 'extendedKeyUsage=serverAuth' \
    -addext 'subjectAltName=DNS:test.example,DNS:login.test.example,DNS:dashboard.test.example'
if [ $? -ne 0 ]; then
  exit 1
fi
