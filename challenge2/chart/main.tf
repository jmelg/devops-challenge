data "azurerm_kubernetes_cluster" "aks_instance" {
  name                = "aks-instance"
  resource_group_name = "instance"
}

resource "null_resource" "install_chart" {

  count = length(var.charts)
  
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<-EOT
      helm pull oci://${var.source_acr_server}/${var.charts[count.index].chart_repository}/${var.charts[count.index].chart_name} --version ${var.charts[count.index].chart_version} \
                --username ${var.source_acr_client_id} \
                --password ${var.source_acr_client_secret}
      helm registry login ${var.acr_server} -u ${var.source_acr_client_id} -p ${var.source_acr_client_secret}
      helm push ${var.charts[count.index].chart_name}-${var.charts[count.index].chart_version}.tgz oci://${var.acr_server}/${var.charts[count.index].chart_repository}
      echo $KUBECONFIG > kubeconfig
      helm install ${var.charts[count.index].chart_name} \
           oci://${var.acr_server}/${var.charts[count.index].chart_repository}/${var.charts[count.index].chart_name} \
           --version ${var.charts[count.index].chart_version} \
           -n ${var.charts[count.index].chart_namespace}  --create-namespace $VALUES $SENSITIVE_VALUES \
           --kubeconfig=kubeconfig
    EOT
    environment = {
      KUBECONFIG = jsonencode(yamldecode(data.azurerm_kubernetes_cluster.aks_instance.kube_config_raw))
      VALUES = join(" ", [for item in var.charts[count.index].chart_values : format("--set %s=%s", item.name, item.value)])
      SENSITIVE_VALUES = join(" ", [for item in var.charts[count.index].chart_sensitive_values : format("--set %s=%s", item.name, item.value)])
    }
  }
}
