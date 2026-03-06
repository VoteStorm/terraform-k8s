terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "chaosproject-485114-tfstate"
    prefix = "kubeadm/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
