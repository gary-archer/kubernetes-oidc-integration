#!/bin/bash

#########################
# Create the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First create authorization server certificates
#
./mock-authorization-server/crypto/create-internal-certs.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Then create the authentication configuration that references the authorization server root CA
#
export INTERNAL_CA_CERT="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ./mock-authorization-server/crypto/internal-ca.crt)"
envsubst '$INTERNAL_CA_CERT' < resources/authenticationconfiguration-template.yaml > resources/authenticationconfiguration.yaml
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Next create a cluster that references the authentication configuration
#
kind create cluster --name=demo --config=resources/cluster.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
