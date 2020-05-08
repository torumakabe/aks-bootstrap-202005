module "flux" {
  source = "../modules/flux"

  aks_cluster_name = lower(var.aks_cluster_name)
  aks_cluster_rg   = var.aks_cluster_rg
  git_authuser     = var.git_authuser
  git_authkey      = var.git_authkey
  git_fluxrepo     = var.git_fluxrepo

}
