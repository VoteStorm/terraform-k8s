#!/bin/bash

# Loki, Promtail, Prometheus, Grafana를 ArgoCD로 설치
kubectl apply -f https://raw.githubusercontent.com/VoteStorm/chaoslab-gitops/refs/heads/feature/on-prem/%234-argocd-addon/bootstrap/local/monitoring-appset.yaml
