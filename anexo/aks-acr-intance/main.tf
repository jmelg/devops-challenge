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

resource "azurerm_resource_group" "rg_instance" {
  name     = "instance"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr_instance" {
  name                = "instance20231014"
  resource_group_name = azurerm_resource_group.rg_instance.name
  location            = azurerm_resource_group.rg_instance.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks_instance" {
  name                = "aks-instance"
  location            = azurerm_resource_group.rg_instance.location
  resource_group_name = azurerm_resource_group.rg_instance.name
  dns_prefix          = "aksinstance"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

# Permitimos que el AKS pueda hacer pull de las imagenes del ACR instance
resource "azurerm_role_assignment" "acr_instance_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks_instance.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr_instance.id
  skip_service_principal_aad_check = true
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks_instance.kube_config_raw
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_instance.kube_config
  sensitive = true
}
