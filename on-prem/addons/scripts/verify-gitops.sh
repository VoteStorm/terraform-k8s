#!/bin/bash
set -euo pipefail

ARGOCD_APPS=(
  "prometheus"
  "loki"
)

for app in "${ARGOCD_APPS[@]}"; do
  echo ""
  echo "ArgoCD Application [${app}]"

  if kubectl get application "${app}" -n argocd > /dev/null 2>&1; then
    echo "  - Found"

    health=$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.health.status}')
    sync=$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.sync.status}')
    echo "  - Health: ${health}"
    echo "  - Sync: ${sync}"

    if [[ "${health}" != "Healthy" || "${sync}" != "Synced" ]]; then
      missing_any=true
    fi
  else
    echo "  - Not Found"
    missing_any=true
  fi
done
