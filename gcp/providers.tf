provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host = "https://${google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip}:6443"
  insecure = true  # kubeconfig 없이 간단하게
}