#!/bin/bash
set -euo pipefail

echo "=== Add-on Verification ==="

ADDONS=(
  "metallb-system:metallb"
  "ingress-nginx:ingress-nginx"
  "argocd:argocd"
)

missing_any=false

for addon in "${ADDONS[@]}"; do
  ns="${addon%%:*}"
  release="${addon##*:}"
  echo ""
  echo "Helm release [${release}] in namespace [${ns}]"

  if helm status "${release}" -n "${ns}" > /dev/null 2>&1; then
    echo "  - Found"
  else
    echo "  - Not Found. Skipping verification for this add-on."
    missing_any=true
    continue
  fi

  if kubectl get ns "${ns}" > /dev/null 2>&1; then
    echo "  - Namespace [${ns}] exists"
  else
    echo "  - Namespace [${ns}] does not exist."
    missing_any=true
  fi

  running_pods=$(kubectl get pods -n "${ns}" --no-headers | grep -c "Running" || true)
  total_pods=$(kubectl get pods -n "${ns}" --no-headers 2>/dev/null | wc -l | tr -d ' ')
  echo "  - Pods Running: ${running_pods}/${total_pods}"

  lb_services=$(kubectl get svc -n "${ns}" --no-headers 2>/dev/null | grep -c "LoadBalancer" || true)
  echo "  - LoadBalancer Services: ${lb_services}"

  clusterip_services=$(kubectl get svc -n "${ns}" --no-headers 2>/dev/null | grep -c "ClusterIP" || true)
  echo "  - ClusterIP Services: ${clusterip_services}"
done

echo ""
echo "StorageClass [local-path]"
if kubectl get storageclass local-path > /dev/null 2>&1; then
  echo "  - Found"
  is_default=$(kubectl get storageclass local-path -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')
  if [[ "$is_default" == "true" ]]; then
    echo "  - Default: true"
  else
    echo "  - Default: false"
    missing_any=true
  fi
else
  echo "  - Not Found"
  missing_any=true
fi

if [[ "${missing_any}" == true ]]; then
  echo ""
  echo "Warning: Some add-ons are missing or not fully verified. Please check the output above for details."
else
  echo ""
  echo "All add-ons verified successfully."
fi

echo ""
echo "=== Add-on Verification Completed ==="
