terraform {
  required_version = ">= 1.9"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

data "kubernetes_namespace_v1" "kratos_ns" {
  metadata {
    name = var.namespace
  }
}

locals {
  labels = merge(var.labels, {
    project   = var.project
    component = "kratos"
  })
  labels_migrations = merge(var.labels, {
    project   = var.project
    component = "kratos-migrations"
  })
  labels_courier = merge(var.labels, {
    project   = var.project
    component = "kratos-courier"
  })
}
