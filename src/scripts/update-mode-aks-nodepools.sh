#!/bin/bash

az aks nodepool update -g $TF_VAR_aks_cluster_rg --cluster-name $TF_VAR_aks_cluster_name -n system --mode system

az aks nodepool update -g $TF_VAR_aks_cluster_rg --cluster-name $TF_VAR_aks_cluster_name -n default --mode user
