#!/bin/bash

#########################
# Create the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First create API gateway certificates that the authorization server uses
#
./resources/external-certificates/create.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Then create the authentication configuration that references the root CA
#
export EXTERNAL_CA_CERT="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ./resources/external-certificates/external-ca.crt)"
envsubst '$EXTERNAL_CA_CERT' < resources/authenticationconfiguration-template.yaml > resources/authenticationconfiguration.yaml
if [ $? -ne 0 ]; then
  exit 1
fi


kind create cluster --name=demo --config=resources/cluster.yaml
