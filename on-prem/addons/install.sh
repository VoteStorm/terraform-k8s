#!/bin/bash
helm repo add metallb https://metallb.github.io/metallb
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# MetalLB 설치
helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system --create-namespace \
sleep 40 # MetalLB가 완전히 배포될 때까지 대기
kubectl apply -f ../values/metallb/metallb-config.yaml

# Ingress-Nginx 설치
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  -f ../values/ingress-nginx/nginx-values.yaml

# Local Path Provisioner (StorageClass) 설치
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path \
  -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

# ArgoCD 설치
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f ../values/argocd/argocd-values.yaml

# Loki, Promtail, Prometheus, Grafana를 ArgoCD로 설치
kubectl apply -f https://raw.githubusercontent.com/VoteStorm/chaoslab-gitops/refs/heads/feature/on-prem/%234-argocd-addon/bootstrap/local/monitoring-appset.yaml


# 서비스 매핑
HOSTS_FILE="./hosts.generated"
echo "" > "$HOSTS_FILE"

# DOMAIN:SERVICE.NAMESPACE
SERVICE_MAP="argocd.chaos-lab.local:argocd-server.argocd grafana.chaos-lab.local:prometheus-grafana.monitoring"

for entry in $SERVICE_MAP; do
  domain="${entry%%:*}"
  ing_ns="${entry##*:}"
  ing_name="${ing_ns%%.*}"
  ing_ns_only="${ing_ns##*.}"
  ip=$(kubectl get ingress -n ${ing_ns_only} ${ing_name} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ -n "$ip" ]]; then
    echo "$ip $domain" >> "$HOSTS_FILE"
    echo "[OK] $domain -> $ip"
  else
    echo "[WARN] No IP found for $domain"
  fi
done

echo ""
echo "[INFO] Generated hosts file at $HOSTS_FILE:"
echo "[INFO] To apply, run: sudo bash -c 'cat $HOSTS_FILE >> /etc/hosts'"
