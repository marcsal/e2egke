variable "project_id" {
  description = "TU_PROYECTO_DE_GCP_AQUI"
  type        = string
}

variable "region" {
  description = "Región de la red y subred"
  type        = string
  default     = "europe-southwest1"
}

variable "cluster_zone" {
  description = "Zona específica para el clúster zonal"
  type        = string
  default     = "europe-southwest1-a"
}

variable "cluster_name" {
  description = "Nombre del clúster de GKE en Google Cloud"
  type        = string
  default     = "cluster-plataforma-e2e"
}