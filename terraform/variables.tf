# terraform/variables.tf

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "app_image" {
  description = "The Docker image to deploy"
  type        = string
  default     = "latest" # Valor por defecto por si acaso
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}