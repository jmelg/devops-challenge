# Con values
acr_server = "instance20231014.azurecr.io"
acr_server_subscription = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

source_acr_client_id = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
source_acr_client_secret = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
source_acr_server = "reference.azurecr.io"

charts = [
  {
    chart_repository = "helm"
    chart_name = "ping"
    chart_version = "0.1.0"
    chart_namespace = "test3"
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
