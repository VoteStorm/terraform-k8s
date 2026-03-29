#!/bin/bash

HOSTS_FILE="./hosts.generated"
echo "" > "$HOSTS_FILE"

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
    echo "Warning: No IP found for $domain"
  fi
done

echo ""
echo "Generated hosts file at $HOSTS_FILE:"
echo "To apply, run: sudo bash -c 'cat $HOSTS_FILE >> /etc/hosts'"
