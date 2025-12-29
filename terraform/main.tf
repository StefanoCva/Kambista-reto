provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.gke.endpoint}"

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "kambista-dev"
  }

  lifecycle {
    ignore_changes = all
  }
}
resource "kubernetes_deployment_v1" "hello_app" {
  metadata {
    name      = "hello-app"
    namespace = var.namespace

    labels = {
      app = "hello"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hello"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello"
        }
      }

      spec {
        container {
          name  = "hello"
          image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository}/${var.image}:1.0"

          # 👇 AQUÍ va el port, dentro del container
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "hello_service" {
  metadata {
    name      = "hello-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "hello"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

terraform {
  backend "gcs" {
    bucket = "luminous-style-482114-e5-tfstate"
    prefix = "kambista-reto/state"
  }
}





