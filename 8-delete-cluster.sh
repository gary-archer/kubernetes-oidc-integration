#!/bin/bash

#########################
# Delete the KIND cluster
#########################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Delete the cluster
#
kind delete cluster --name=demo

#
# Stop the load balancer
#
LOADBALANCER=$(docker ps | grep envoyproxy | awk '{print $1}')
if [ "$LOADBALANCER" != '' ]; then
  docker kill $LOADBALANCER 2>/dev/null
fi