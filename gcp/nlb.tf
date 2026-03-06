# ============================================================
# Internal TCP NLB — Control Plane HA 엔드포인트
# ============================================================

# 헬스체크 (API Server 6443)
resource "google_compute_health_check" "k8s_cp" {
  name    = "k8s-control-plane-hc"
  project = var.project_id

  tcp_health_check {
    port = 6443
  }
}

# 백엔드 서비스
resource "google_compute_region_backend_service" "k8s_cp" {
  name                  = "k8s-control-plane-backend"
  project               = var.project_id
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.k8s_cp.id]

  backend {
    group = google_compute_instance_group.control_planes.id
  }
}

# Forwarding Rule (NLB 진입점 — 내부 IP 자동 할당)
resource "google_compute_forwarding_rule" "k8s_cp" {
  name                  = "k8s-control-plane-nlb"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ports                 = ["6443"]
  backend_service       = google_compute_region_backend_service.k8s_cp.id
  network               = "default"

  # 내부 IP 고정 (원하면 지정, 아니면 주석처리하면 자동 할당)
  # ip_address = "10.178.15.100"
}