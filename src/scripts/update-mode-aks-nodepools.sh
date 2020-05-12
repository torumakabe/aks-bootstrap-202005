#!/bin/bash

az aks nodepool update -g $TF_VAR_aks_cluster_rg --cluster-name $TF_VAR_aks_cluster_name -n $TF_VAR_aks_cluster_systempool_name --mode system

az aks nodepool update -g $TF_VAR_aks_cluster_rg --cluster-name $TF_VAR_aks_cluster_name -n $TF_VAR_aks_cluster_userpool_name --mode user
