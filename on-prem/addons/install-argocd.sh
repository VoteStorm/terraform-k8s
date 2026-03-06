#!/bin/bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f values/argocd/argocd-values.yaml

HOSTS_FILE="./hosts.generated"
echo "" > "$HOSTS_FILE"

DOMAIN="argocd.chaos-lab.local"
ING_NS="argocd"
ING_NAME="argocd-server"
IP=$(kubectl get ingress -n ${ING_NS} ${ING_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [[ -n "$IP" ]]; then
  echo "$IP $DOMAIN" >> "$HOSTS_FILE"
else
  echo "Warning: No IP found for $DOMAIN"
fi

echo ""
echo "Generated hosts file at $HOSTS_FILE:"
echo "To apply, run: sudo bash -c 'cat $HOSTS_FILE >> /etc/hosts'"
