terraform {
  required_version = "~> 0.12.24"
  backend "remote" {}
}

provider "azurerm" {
  version = "~>2.9"
  features {}
}

module "rg" {
  source = "../modules/rg"

  aks_cluster_rg       = var.aks_cluster_rg
  aks_cluster_location = var.aks_cluster_location
}

module "network" {
  source = "../modules/network"

  aks_cluster_rg       = module.rg.aks_cluster_rg_out
  aks_cluster_location = var.aks_cluster_location
}

module "aks" {
  source = "../modules/aks"

  aks_cluster_name            = lower(var.aks_cluster_name)
  aks_cluster_rg              = module.rg.aks_cluster_rg_out
  aks_cluster_location        = var.aks_cluster_location
  aks_cluster_systempool_name = var.aks_cluster_systempool_name
  aks_cluster_userpool_name   = var.aks_cluster_userpool_name
  aks_subnet_id               = module.network.aks_subnet_id
  la_workspace_name           = var.la_workspace_name
  la_workspace_rg             = var.la_workspace_rg
  enable_flux                 = var.enable_flux
  git_authuser                = var.git_authuser
  git_fluxrepo                = var.git_fluxrepo

}
