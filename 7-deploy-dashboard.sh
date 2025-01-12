#!/bin/bash

###########################################################
# Deploy a default installation of the Kubernetes dashboard
###########################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Install the dashboard using the Helm chart
#
echo 'Installing the Kubernetes dashboard ...'
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard 1>/dev/null
helm repo update
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace dashboard \
    --create-namespace \
    --set kong.proxy.http.enabled=true \
    --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Expose the dashboard front end at https://dashboard.test.example
#
kubectl -n dashboard apply -f resources/dashboard-ingress.yaml
