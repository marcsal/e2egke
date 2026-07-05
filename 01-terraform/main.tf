# 1. Red Privada (Aislamiento de seguridad)
resource "google_compute_network" "vpc_red_plataforma" {
  name                    = "vpc-plataforma"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_gke" {
  name          = "subnet-gke-madrid"
  region        = var.region
  network       = google_compute_network.vpc_red_plataforma.name
  ip_cidr_range = "10.10.0.0/24"
}

# 2. El Clúster GKE
resource "google_container_cluster" "cluster_entrevista" {
  name     = var.cluster_name
  location = var.cluster_zone

  network    = google_compute_network.vpc_red_plataforma.name
  subnetwork = google_compute_subnetwork.subnet_gke.name

  remove_default_node_pool = true
  initial_node_count       = 1
}

# 3. Nodos Worker
resource "google_container_node_pool" "nodos_trabajo" {
  name       = "pool-herramientas"
  location   = var.cluster_zone
  cluster    = google_container_cluster.cluster_entrevista.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    preemptible  = true  # FinOps

    labels = {
      entorno = "desarrollo"
      equipo  = "plataforma"
    }
  }
}