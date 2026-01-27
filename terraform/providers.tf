# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # --- OPTION 1: Real Backend (Active for your local testing) ---
  # This uses the bucket you created via the CLI
  backend "gcs" {
    bucket = "devops-challenge-485523-tfstate"
    prefix = "log-archiver/state"
  }

  # --- OPTION 2: Mocked Backend (For documentation/evaluation) ---
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "log-archiver/state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}