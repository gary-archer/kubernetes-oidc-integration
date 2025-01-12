#!/bin/bash

################################################################
# Create a user assertion to supply to the Kubernetes API server
################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

cd mock-authorization-server
npm run create-user-assertion $1
