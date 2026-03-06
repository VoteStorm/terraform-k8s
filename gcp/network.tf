# ============================================================
# 방화벽 — Control Plane
# ============================================================
# Control Plane — 외부 허용 (API Server만)
resource "google_compute_firewall" "k8s_control_plane_external" {
  name    = "k8s-control-plane-external"
  network = "default"
  project = var.project_id

  # API Server — Worker 및 외부 kubectl 접속
  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  target_tags   = ["k8s-control-plane"]
  source_ranges = ["0.0.0.0/0"]
}

# Control Plane — 내부 노드만 (etcd, kubelet)
resource "google_compute_firewall" "k8s_control_plane_internal" {
  name    = "k8s-control-plane-internal"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["2379-2380", "10250"]
  }

  target_tags = ["k8s-control-plane"]
  source_tags = ["k8s-node"]          # source_ranges 없음
}

# ============================================================
# 방화벽 — Worker Node
# ============================================================
# Worker — kubelet (내부 노드만)
resource "google_compute_firewall" "k8s_worker_internal" {
  name    = "k8s-worker-internal"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  target_tags = ["k8s-worker"]
  source_tags = ["k8s-node"]
}

# Worker — NodePort (외부 허용)
resource "google_compute_firewall" "k8s_worker_nodeport" {
  name    = "k8s-worker-nodeport"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  target_tags   = ["k8s-worker", "k8s-control-plane"]
  source_ranges = ["0.0.0.0/0"]   # 외부 허용
}
# ============================================================
# 방화벽 — SSH (모든 노드)
# ============================================================
resource "google_compute_firewall" "k8s_ssh" {
  name    = "k8s-ssh"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["k8s-node"]
  source_ranges = ["0.0.0.0/0"]
}

# ============================================================
# 방화벽 — Ingress (HTTP / HTTPS)
# ============================================================
resource "google_compute_firewall" "k8s_ingress" {
  name    = "k8s-ingress"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags   = ["k8s-worker"]
  source_ranges = ["0.0.0.0/0"]
}

# ============================================================
# 방화벽 — 노드 간 내부 통신 (CNI Calico용)
# ============================================================
resource "google_compute_firewall" "k8s_internal" {
  name    = "k8s-internal"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  # k8s 노드끼리만 허용
  source_tags = ["k8s-node"]
  target_tags = ["k8s-node"]
}

# ============================================================
# 방화벽 — GCP Load Balancer Health Check 허용
# ============================================================

# NLB 헬스체크용 방화벽 (GCP가 자동으로 날리는 probe 허용)
resource "google_compute_firewall" "k8s_nlb_healthcheck" {
  name    = "k8s-nlb-healthcheck"
  network = "default"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  # GCP 헬스체크 프로버 IP 대역
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["k8s-control-plane"]
}