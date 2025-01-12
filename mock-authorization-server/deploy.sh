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
# Deploy a curl client to verify the connection
#
kubectl create namespace client 2>/dev/null
kubectl -n client apply -f kubernetes/client.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
