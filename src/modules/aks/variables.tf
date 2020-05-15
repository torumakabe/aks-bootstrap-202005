variable "aks_cluster_name" {
  type = string
}

variable "aks_cluster_rg" {
  type = string
}

variable "aks_cluster_location" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "la_workspace_name" {
  type = string
}

variable "la_workspace_rg" {
  type = string
}

variable "enable_flux" {
  type    = bool
  default = false
}

variable "git_authuser" {
  type = string
}

variable "git_fluxrepo" {
  type = string
}
