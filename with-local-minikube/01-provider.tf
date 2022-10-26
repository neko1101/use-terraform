terraform {
  required_providers {
    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.0.4"
    }
  }
}

provider "minikube" { 
  kubernetes_version = "v1.24.3"
}

provider "helm" {
  kubernetes {
    config_context_cluster = "minikube"
  }
}