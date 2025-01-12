#!/bin/bash

######################################
# Deploy the mock authorization server
######################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Build the code
#
./mock-authorization-server/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the service
#
./mock-authorization-server/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi
