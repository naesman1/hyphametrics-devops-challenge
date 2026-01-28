# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # --- OPTION 1: Real Backend (For Cloud Mode / Production) ---
  # This uses the GCS bucket you created via the CLI
  # UNCOMMENT this block for Cloud Mode deployment
  backend "gcs" {
   bucket = "devops-challenge-485523-tfstate"
    prefix = "log-archiver/state"
  }

  # --- OPTION 2: Local Backend (For Mock Mode / Local Testing) ---
  # This stores state on your local machine
  # UNCOMMENT this block for Mock Mode testing
 #  backend "local" {
 #    path = "terraform.tfstate"
 #  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}