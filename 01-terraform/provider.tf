terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "project-f81a0dd3-83db-4115-80b" # Tu proyecto de pruebas
  region  = "europe-southwest1"              # Madrid
}