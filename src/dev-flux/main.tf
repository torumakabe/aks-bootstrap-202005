data "terraform_remote_state" "aks" {
  backend = "remote"

  config = {
    organization = "tomakabe"
    workspaces = {
      name = "dev-aks"
    }
  }
}

module "flux" {
  source                     = "../modules/flux"
  aks_host                   = data.terraform_remote_state.aks.outputs.aks_host
  aks_client_certificate     = data.terraform_remote_state.aks.outputs.aks_client_certificate
  aks_client_key             = data.terraform_remote_state.aks.outputs.aks_client_key
  aks_cluster_ca_certificate = data.terraform_remote_state.aks.outputs.aks_cluster_ca_certificate
  aks_cluster_name           = lower(var.aks_cluster_name)
  aks_cluster_rg             = var.aks_cluster_rg
  git_authuser               = var.git_authuser
  git_authkey                = var.git_authkey
  git_fluxrepo               = var.git_fluxrepo

}
