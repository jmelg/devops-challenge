variable "acr_server" {
  description = "The server URL for Azure Container Registry."
  type        = string
}

variable "acr_server_subscription" {
  description = "The subscription ID for the Azure Container Registry."
  type        = string
}

variable "source_acr_client_id" {
  description = "The client ID for the Azure Container Registry."
  type        = string
}

variable "source_acr_client_secret" {
  description = "The client secret for the Azure Container Registry."
  type        = string
  sensitive   = true
}

variable "source_acr_server" {
  description = "The server for the Azure Container Registry."
  type        = string
}

variable "charts" {
  description = ""
  type = list(object({
    chart_name       = string
    chart_version    = string
    chart_repository = string
    chart_namespace  = string
    chart_values = list(object({
      name  = string
      value = string
    }))
    chart_sensitive_values = list(object({
      name  = string
      value = string
    }))
  }))
}
