output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}

output "aks_mi_principal_id" {
  value = module.aks.aks_mi_principal_id
}
