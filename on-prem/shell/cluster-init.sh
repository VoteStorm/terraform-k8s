#!/bin/bash
if hostname | grep -q "k8s-master-0"; then
  MASTER_IP=$(hostname -I | awk '{print $1}')

  kubeadm init \
    --apiserver-advertise-address "${MASTER_IP}" \
    --upload-certs \
    --pod-network-cidr=10.244.0.0/16

  mkdir -p $HOME/.kube
  cp /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  apt-get install -y tar  
  CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
  CLI_ARCH=amd64
  if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

  curl -L --fail --remote-name-all \
    https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

  sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
  tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
  rm -f cilium-linux-${CLI_ARCH}.tar.gz cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

  cilium install --set ipam.mode=kubernetes
  cilium status --wait

  JOIN_CMD=$(kubeadm token create --print-join-command)
  echo "sudo $JOIN_CMD" > /home/ubuntu/join.sh
  chmod +x /home/ubuntu/join.sh

  kubeadm token create --print-join-command --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -n1) > /home/ubuntu/join-controlplane.sh
  CERT_KEY=$(kubeadm init phase upload-certs --upload-certs | tail -n1)
  JOIN_CP_CMD=$(kubeadm token create --print-join-command --certificate-key $CERT_KEY)
  echo "sudo $JOIN_CP_CMD" > /home/ubuntu/join-controlplane.sh
  chmod +x /home/ubuntu/join-controlplane.sh
fi
