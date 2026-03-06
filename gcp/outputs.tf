output "control_plane_external_ip" {
  description = "Control Plane 외부 IP (SSH 접속용)"
  value       = google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip
}

output "control_plane_internal_ip" {
  description = "Control Plane 내부 IP (kubeadm init --apiserver-advertise-address 값)"
  value       = google_compute_instance.control_plane.network_interface[0].network_ip
}

output "worker_external_ips" {
  description = "Worker 노드 외부 IP 목록 (SSH 접속용)"
  value       = [for w in google_compute_instance.worker : w.network_interface[0].access_config[0].nat_ip]
}

output "worker_internal_ips" {
  description = "Worker 노드 내부 IP 목록"
  value       = [for w in google_compute_instance.worker : w.network_interface[0].network_ip]
}

output "ssh_control_plane" {
  description = "Control Plane SSH 접속 명령어"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip}"
}

output "ssh_workers" {
  description = "Worker SSH 접속 명령어 목록"
  value       = [for w in google_compute_instance.worker : "ssh ${var.ssh_user}@${w.network_interface[0].access_config[0].nat_ip}"]
}

output "kubeadm_init_command" {
  description = "Control Plane에서 실행할 kubeadm init 명령어"
  value       = "sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=${google_compute_instance.control_plane.network_interface[0].network_ip}"
}

output "nlb_internal_ip" {
  description = "NLB 내부 IP — HA Control Plane 대표 주소"
  value       = google_compute_forwarding_rule.k8s_cp.ip_address
}

output "kubeadm_init_config_hint" {
  description = "kubeadm-config.yaml controlPlaneEndpoint 값"
  value       = "${google_compute_forwarding_rule.k8s_cp.ip_address}:6443"
}

output "csi_sa_key" {
  value     = base64decode(google_service_account_key.csi_key.private_key)
  sensitive = true
}
