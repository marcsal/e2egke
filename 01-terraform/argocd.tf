# 0. Lectura de la IP estática pre-creada de forma persistente en GCP
data "google_compute_address" "ip_estatica_ingress" {
  name   = "ip-estatica-plataforma"
  region = var.region
}

# 1. Instalación automatizada del Nginx Ingress Controller mediante Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1" # Versión estable del chart

  # Frenamos la instalación hasta que el clúster y sus nodos estén listos
  depends_on = [
    google_container_cluster.cluster_entrevista,
    google_container_node_pool.nodos_trabajo
  ]

  # MÁGICA: Vinculamos el LoadBalancer a la IP estática recuperada del bloque data
  set {
    name  = "controller.service.loadBalancerIP"
    value = data.google_compute_address.ip_estatica_ingress.address
  }
}

# 2. Instalación automatizada de ArgoCD mediante Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.7"

  depends_on = [
    google_container_cluster.cluster_entrevista,
    google_container_node_pool.nodos_trabajo
  ]

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
}

# 3. El cierre del círculo (Bootstrap de la aplicación raíz de GitOps)
resource "null_resource" "argocd_bootstrap" {
  # CRÍTICO: No inyectamos la app raíz hasta que ArgoCD Y el Ingress Nginx estén instalados
  depends_on = [
    helm_release.argocd,
    helm_release.ingress_nginx
  ]

  provisioner "local-exec" {
    command = <<EOT
      # 1. Autenticación automática en el nuevo clúster
      gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.cluster_zone} --project ${var.project_id}
      
      # 2. Margen de seguridad para que el API Server asimile los CRDs de ArgoCD
      sleep 20
      
      # 3. Aplicamos el manifiesto que activa todo el ecosistema GitOps
      kubectl apply -f ../02-gitops-apps/idp-argocd.yaml
    EOT
  }
}