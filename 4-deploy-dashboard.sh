#!/bin/bash

###########################################################
# Deploy a default installation of the Kubernetes dashboard
###########################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Apply role based access control rules
#
kubectl apply -f resources/rbac.yaml

#
# Install the dashboard using the Helm chart
#
echo 'Installing the Kubernetes dashboard ...'
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard 1>/dev/null
helm repo update
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace dashboard \
    --create-namespace \
    --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Run the dashboard front end
#
echo 'Exposing the Kubernetes dashboard using port forwarding'
#kubectl -n dashboard port-forward kubernetes-dashboard 9090
