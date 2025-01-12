#!/bin/bash

################################################
# Deploy the API gateway to enable external URLs
################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Apply Kubernetes Gateway API custom resource definitions
#
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml 2>/dev/null

#
# Deploy the API gateway
#
helm install nginx oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
  --namespace nginx \
  --create-namespace \
  --set nginxGateway.replicaCount=2 \
  --wait
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Get the service's external IP address from the cloud provider
#
EXTERNAL_IP=$(kubectl get svc -n nginx nginx-nginx-gateway-fabric -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "The load balancer external IP address is $EXTERNAL_IP"

#
# Create a secret that references the external certificate and key
#
kubectl -n nginx create secret tls external-tls \
  --cert=resources/external-certificates/external-ssl.crt \
  --key=resources/external-certificates/external-ssl.key
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kubernetes TLS secret for the API gateway'
  exit 1
fi

#
# Deploy API gateway custom resources
#
kubectl -n nginx apply -f resources/api-gateway.yaml
if [ $? -ne 0 ]; then
  exit 1
fi
