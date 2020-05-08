provider "azurerm" {
  version = "~>2.9"
  features {}
}

provider "kubernetes" {
  version = "~>1.11"

  load_config_file       = false
  host                   = var.aks_host
  client_certificate     = base64decode(var.aks_client_certificate)
  client_key             = base64decode(var.aks_client_key)
  cluster_ca_certificate = base64decode(var.aks_cluster_ca_certificate)
}

resource "kubernetes_namespace" "flux" {
  metadata {
    name = "flux"
  }
}

resource "kubernetes_secret" "flux-git-auth" {
  metadata {
    name      = "flux-git-auth"
    namespace = "flux"
  }

  data = {
    GIT_AUTHUSER = var.git_authuser
    GIT_AUTHKEY  = var.git_authkey
  }

}

resource "helm_release" "flux" {
  name       = "flux"
  namespace  = "flux"
  repository = "https://charts.fluxcd.io/"
  chart      = "flux"
  version    = "1.3.0"

  set {
    name  = "helm.versions"
    value = "v3"
  }

  set {
    name  = "git.url"
    value = "https://${var.git_authuser}:${var.git_authkey}@github.com/${var.git_authuser}/${var.git_fluxrepo}"
  }

  set {
    name  = "env.secretName"
    value = "flux-git-auth"
  }

}

resource "helm_release" "helm-operator" {
  name       = "helm-operator"
  namespace  = "flux"
  repository = "https://charts.fluxcd.io/"
  chart      = "helm-operator"
  version    = "1.0.1"

  set {
    name  = "helm.versions"
    value = "v3"
  }

  set {
    name  = "git.ssh.secretName"
    value = "flux-git-deploy"
  }

}
