#!/bin/bash

#########################
# Delete the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"
kind delete cluster --name=demo
if [ $? -ne 0 ]; then
  exit 1
fi
