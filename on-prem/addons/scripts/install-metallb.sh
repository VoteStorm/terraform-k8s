#!/bin/bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update

helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system --create-namespace \
sleep 40 # MetalLB가 완전히 배포될 때까지 대기
kubectl apply -f ../values/metallb/metallb-config.yaml
