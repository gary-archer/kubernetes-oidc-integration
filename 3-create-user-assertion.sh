#!/bin/bash

#################################################
# Create a user assertion to supply to Kubernetes
#################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

cd mock-authorization-server
npm run create-user-assertion
