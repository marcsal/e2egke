# 1. Red Privada (Aislamiento de seguridad)
resource "google_compute_network" "vpc_red_plataforma" {
  name                    = "vpc-plataforma"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_gke" {
  name          = "subnet-gke-madrid"
  region        = "europe-southwest1"
  network       = google_compute_network.vpc_red_plataforma.name
  ip_cidr_range = "10.10.0.0/24"
}

# 2. El Clúster GKE (Control Plane gestionado por Google)
resource "google_container_cluster" "cluster_entrevista" {
  name     = "cluster-plataforma-e2e"
  location = "europe-southwest1-a" # Usamos una zona específica (Zonal cluster) para ahorrar

  network    = google_compute_network.vpc_red_plataforma.name
  subnetwork = google_compute_subnetwork.subnet_gke.name

  # Borramos el pool por defecto para tener control total sobre los workers
  remove_default_node_pool = true
  initial_node_count       = 1
}

# 3. Nodos Worker (Donde vivirá ArgoCD, Prometheus y tu App)
resource "google_container_node_pool" "nodos_trabajo" {
  name       = "pool-herramientas"
  location   = "europe-southwest1-a"
  cluster    = google_container_cluster.cluster_entrevista.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    preemptible  = true  # Fundamental para FinOps: Nodos un 70% más baratos para dev

    # Etiquetas para que Kubernetes sepa qué corre aquí
    labels = {
      entorno = "desarrollo"
      equipo  = "plataforma"
    }
  }
}