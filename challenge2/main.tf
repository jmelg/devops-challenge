terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.acr_server_subscription
  tenant_id       = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
  client_id       = var.source_acr_client_id
  client_secret   = var.source_acr_client_secret
}

provider "null" {}


module "chart" {
  source                   = "./chart"
  acr_server               = var.acr_server
  acr_server_subscription  = var.acr_server_subscription
  source_acr_client_id     = var.source_acr_client_id
  source_acr_client_secret = var.source_acr_client_secret
  source_acr_server        = var.source_acr_server

  charts = [
    {
      chart_repository = "helm"
      chart_name       = "ping"
      chart_version    = "0.1.0"
      chart_namespace  = "test"
      chart_values = [{
        name  = "nombre"
        value = "valor"
      }]
      chart_sensitive_values = [{
        name  = "password"
        value = "P4sw0rd"
      }]
    }
  ]
}
