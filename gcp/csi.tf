resource "google_service_account" "gce_pd_csi" {
  account_id   = "gce-pd-csi-sa"
  display_name = "GCE PD CSI Driver Service Account"
}

resource "google_project_iam_member" "csi_storage_admin" {
  project = var.project_id
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.gce_pd_csi.email}"
}

resource "google_project_iam_member" "csi_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gce_pd_csi.email}"
}

resource "google_service_account_key" "csi_key" {
  service_account_id = google_service_account.gce_pd_csi.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_project_iam_member" "csi_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"  # ← 추가
  member  = "serviceAccount:${google_service_account.gce_pd_csi.email}"
}

resource "google_project_iam_member" "csi_compute_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.gce_pd_csi.email}"
}