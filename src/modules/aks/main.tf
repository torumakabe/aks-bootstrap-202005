provider "azurerm" {
  version = "~>2.8"
  features {}
}

data "azurerm_log_analytics_workspace" "aks" {
  name                = var.la_workspace_name
  resource_group_name = var.la_workspace_rg
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  kubernetes_version  = "1.17.3"
  location            = var.aks_cluster_location
  resource_group_name = var.aks_cluster_rg
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name                = "pool1"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    vnet_subnet_id      = var.aks_subnet_id
    availability_zones  = [1, 2, 3]
    node_count          = 3
    min_count           = 3
    max_count           = 3
    vm_size             = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    load_balancer_profile {
      managed_outbound_ip_count = 1
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.aks.id
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials -g ${var.aks_cluster_rg} -n ${self.name} --admin --overwrite-existing
    EOT
  }
}

resource "null_resource" "azure_monitor_aks_metrics_enabler" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  provisioner "local-exec" {
    command = <<EOT
      MSI_ID=$(az aks show -g ${var.aks_cluster_rg} -n ${azurerm_kubernetes_cluster.aks.name} --query addonProfiles.omsagent.identity.clientId -o tsv)
      az role assignment create --assignee $MSI_ID --scope ${azurerm_kubernetes_cluster.aks.id} --role "Monitoring Metrics Publisher"
    EOT

  }
}

provider "kubernetes" {
  version = "~>1.11"

  load_config_file       = false
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.aks.id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "kubernetes_cluster_role" "log_reader" {
  metadata {
    name = "containerhealth-log-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log", "events"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "log_reader" {
  metadata {
    name = "containerhealth-read-logs-global"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "containerhealth-log-reader"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "User"
    name      = "clusterUser"
    api_group = "rbac.authorization.k8s.io"
  }
}

provider "helm" {
  version = "~>1.1"

  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

resource "kubernetes_storage_class" "managed-premium-bind-wait" {
  metadata {
    name = "managed-premium-bind-wait"
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    storageaccounttype = "Premium_LRS"
    kind               = "Managed"
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}

data "helm_repository" "fluxcd" {
  name = "fluxcd"
  url  = "https://charts.fluxcd.io/"
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

resource "null_resource" "helmrelease_crds_creator" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
      sleep 30

    EOT

  }
}

resource "helm_release" "flux" {
  depends_on = [null_resource.helmrelease_crds_creator]
  name       = "flux"
  namespace  = "flux"
  repository = data.helm_repository.fluxcd.metadata[0].name
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
  depends_on = [null_resource.helmrelease_crds_creator]
  name       = "helm-operator"
  namespace  = "flux"
  repository = data.helm_repository.fluxcd.metadata[0].name
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
