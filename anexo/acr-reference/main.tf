terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  tenant_id       = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  client_id       = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  client_secret   = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
}

resource "azurerm_resource_group" "rg_reference" {
  name     = "reference"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr_reference" {
  name                = "reference"
  resource_group_name = azurerm_resource_group.rg_reference.name
  location            = azurerm_resource_group.rg_reference.location
  sku                 = "Basic"
  admin_enabled       = true
}

data "azurerm_container_registry" "acr_reference" {
  name                = azurerm_container_registry.acr_reference.name
  resource_group_name = azurerm_resource_group.rg_reference.name
}

output "source_acr_server" {
  value = data.azurerm_container_registry.acr_reference.login_server
}

output "source_acr_client_id" {
  value = data.azurerm_container_registry.acr_reference.id
}
