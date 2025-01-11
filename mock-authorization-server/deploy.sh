#!/bin/bash

####################################################
# Deploy the mock authorization server to Kubernetes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Configure the root CA that the Kubernetes API server must trust
#
export INTERNAL_CA_CERT="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ./crypto/internal-ca.crt)"
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
kubectl apply -f authenticationconfiguration.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
