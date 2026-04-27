#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Multipass VM의 IP 대역에서 LoadBalancer IP 범위를 설정
VM_IP=$(multipass list --format csv | awk -F',' 'NR>1 && $3!="--" {print $3; exit}')
if [[ -z "$VM_IP" ]]; then
  echo "[ERROR] Could not retrieve VM IP. Please ensure the VM is running and try again."
  exit 1
fi
NETWORK=$(echo "$VM_IP" | cut -d'.' -f1-3) 
export LB_CIDR="${NETWORK}.224/27"
echo "[INFO] MetalLB IP Pool: $LB_CIDR"

helm repo add metallb https://metallb.github.io/metallb
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# MetalLB 설치
helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system --create-namespace --wait --timeout 120s
kubectl wait --for condition=Established \
  crd/ipaddresspools.metallb.io \
  crd/l2advertisements.metallb.io \
  --timeout=120s
envsubst < "$SCRIPT_DIR"/values/metallb/metallb-config.yaml.tpl | kubectl apply -f -

# Ingress-Nginx 설치
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --wait --timeout 120s \
  -f "$SCRIPT_DIR"/values/ingress-nginx/nginx-values.yaml

# Local Path Provisioner (StorageClass) 설치
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path \
  -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

# ArgoCD 설치
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f "$SCRIPT_DIR"/values/argocd/argocd-values.yaml

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
