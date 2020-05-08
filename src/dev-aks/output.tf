output "aks_host" {
  value = module.aks.aks_host
}

output "aks_client_certificate" {
  value = module.aks.aks_client_certificate
}

output "aks_client_key" {
  value = module.aks.aks_client_key
}

output "aks_cluster_ca_certificate" {
  value = module.aks.aks_cluster_ca_certificate
}
