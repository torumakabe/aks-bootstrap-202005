output "aks_host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "aks_client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "aks_client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "aks_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}
