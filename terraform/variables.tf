variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Region del cluster (ej: us-central1)"
}

variable "cluster_name" {
  type        = string
  description = "Nombre del cluster GKE"
}

variable "namespace" {
  type        = string
  description = "Namespace a crear en Kubernetes"
  default     = "kambista-dev"
}
variable "repository" {
  type        = string
  description = "Nombre del repositorio de Artifact Registry"
  default     = "kambista-repo"
}

variable "image" {
  type        = string
  description = "Nombre de la imagen de la app"
  default     = "hello"
}
