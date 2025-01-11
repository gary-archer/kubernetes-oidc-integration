#!/bin/bash

####################################################
# Deploy the mock authorization server to Kubernetes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Set the runtime root CA as a single YAML line
#
export INTERNAL_CA_CERT="$(openssl base64 -in ./crypto/internal-ca.crt | tr -d '\n')"
envsubst '$INTERNAL_CA_CERT' < authenticationconfiguration-template.yaml > authenticationconfiguration.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the mock authorization server within its namespace
#
kubectl create namespace identity 2>/dev/null
kubectl -n identity apply -f authorizationserver.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Apply the authentication configuration as a global resource
#
kubectl create namespace identity 2>/dev/null
kubectl apply -f authenticationconfiguration.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

