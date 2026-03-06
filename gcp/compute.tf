# ============================================================
# Control Plane VM
# ============================================================
# 인스턴스 그룹 (Control Plane VM들 묶기)
resource "google_compute_instance" "control_plane" {
  name         = "k8s-control-plane"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # SSH 키 등록
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(pathexpand(var.ssh_pub_key_path))}"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  tags   = ["k8s-node", "k8s-control-plane"]
  labels = { role = "control-plane" }
}

# ============================================================
# 인스턴스 그룹 — NLB 백엔드용
# ============================================================
resource "google_compute_instance_group" "control_planes" {
  name    = "k8s-control-planes"
  project = var.project_id
  zone    = var.zone

  instances = [google_compute_instance.control_plane.id]

  named_port {
    name = "k8s-api"
    port = 6443
  }
}

# ============================================================
# Worker Node VM
# ============================================================
resource "google_compute_instance" "worker" {
  count        = var.worker_count
  name         = "k8s-worker-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(pathexpand(var.ssh_pub_key_path))}"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  tags   = ["k8s-node", "k8s-worker"]
  labels = { role = "worker" }
}