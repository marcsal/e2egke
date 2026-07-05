terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  } # <-- Faltaba esta llave para cerrar required_providers
}

provider "google" {
  # Usamos las variables en lugar de dejar el texto fijo
  project = var.project_id 
  region  = var.region      
}

# Extraemos el token de autenticación dinámico de Google Cloud
data "google_client_config" "default" {}

# Configuramos el proveedor de Helm para que apunte al clúster recién creado
provider "helm" {
  kubernetes {
    # Cambiamos "primary" por "cluster_entrevista" para que coincida con tu main.tf
    host                   = "https://${google_container_cluster.cluster_entrevista.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.cluster_entrevista.master_auth[0].cluster_ca_certificate)
  }
}