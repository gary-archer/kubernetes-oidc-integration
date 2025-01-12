#!/bin/bash

############################################################################
# Apply role based access control rules to restrict permissions to resources
############################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
kubectl apply -f resources/rbac.yaml
