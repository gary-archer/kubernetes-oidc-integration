#!/bin/bash

####################################################
# Deploy the mock authorization server to Kubernetes
####################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy the mock authorization server
#
kubectl create namespace service 2>/dev/null
kubectl -n service apply -f kubernetes/service.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a configmap for the root CA
#
kubectl create namespace applications 2>/dev/null
kubectl -n applications create configmap rootca-configmap --from-file=crypto/internal-ca.crt
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy a curl client to verify the connection
#
kubectl -n applications apply -f kubernetes/client.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

