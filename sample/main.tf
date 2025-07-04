terraform {
  required_version = ">= 1.4"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.39"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.57"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.19"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azuread" {
  tenant_id = var.azure.tenant_id
}

provider "azurerm" {
  tenant_id       = var.azure.tenant_id
  subscription_id = var.azure.subscription_id

  features {}
}

provider "kubernetes" {
  host                   = var.kubernetes.host
  config_context         = var.kubernetes.config_context
  config_context_cluster = var.kubernetes.config_context_cluster
  cluster_ca_certificate = var.kubernetes.cluster_ca_certificate
}

data "azuread_client_config" "current" {}

data "azuread_user" "current_user" {
  object_id = data.azuread_client_config.current.object_id
}

resource "azurerm_resource_group" "sample" {
  name     = var.project
  location = var.location
}

resource "kubernetes_namespace_v1" "sample" {
  metadata {
    name = var.project
    labels = {
      project = var.project
    }
  }
}

provider "postgresql" {
  host      = module.sample.postgresql_provider_config.host
  database  = module.sample.postgresql_provider_config.database
  username  = module.sample.postgresql_provider_config.username
  password  = module.sample.postgresql_provider_config.password
  superuser = module.sample.postgresql_provider_config.superuser
  sslmode   = module.sample.postgresql_provider_config.sslmode
}

module "sample" {
  depends_on = [azurerm_resource_group.sample, kubernetes_namespace_v1.sample]
  source     = "../azure-standalone"

  postgresql = {
    resource_group_name = azurerm_resource_group.sample.name
    server = {
      name                = "${var.project}-db"
      version             = "14"
      sku_name            = "B_Standard_B1ms"
      storage_mb          = 32768
      administrator_login = "${replace(var.project, "-", "")}_sa"
      tags = {
        project = var.project
      }
    }
    ad_admin = {
      tenant_id      = data.azuread_client_config.current.tenant_id
      object_id      = data.azuread_client_config.current.object_id
      principal_name = data.azuread_user.current_user.user_principal_name
      principal_type = "User"
    }
    firewall = {
      allow_all         = true
      allowed_k8s_ip    = var.kubernetes.egress_ip
      allowed_office_ip = var.office_ip
    }
  }

  kratos = {
    namespace    = kubernetes_namespace_v1.sample.metadata[0].name
    project      = var.project
    ingress_host = "auth.${var.domain}"
    labels       = {}
    image        = "docker.io/oryd/kratos:v1.0.0"
    replicas     = 2
    courier_mode = "standalone"

    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }

    courier_resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }

    config_files = {
      for f in fileset("./kratos", "*") : f => file("./kratos/${f}")
    }

    config_yaml = templatefile("./kratos.yaml", {
      additional_cors_allowed_origins = []
      additional_allowed_return_urls  = []
      domain                          = var.domain
      totp_issuer                     = var.project_title
      oidc_config                     = var.oidc_config
    })

    courier_smtp_connection_uri = "smtps://apikey:${var.sendgrid_api_key}@smtp.sendgrid.net:465"
  }
}
