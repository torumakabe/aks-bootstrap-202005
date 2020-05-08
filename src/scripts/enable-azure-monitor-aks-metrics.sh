#!/bin/bash

MSI_ID=$(az aks show -g $TF_VAR_aks_cluster_rg -n $TF_VAR_aks_cluster_name --query addonProfiles.omsagent.identity.clientId -o tsv)
AKS_ID=$(az aks show -g $TF_VAR_aks_cluster_rg -n $TF_VAR_aks_cluster_name --query id -o tsv)
az role assignment create --assignee $MSI_ID --scope $AKS_ID --role "Monitoring Metrics Publisher"
