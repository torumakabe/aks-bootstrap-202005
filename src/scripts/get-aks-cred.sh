#!/bin/bash

az aks get-credentials -g $TF_VAR_aks_cluster_rg -n $TF_VAR_aks_cluster_name --admin --overwrite-existing
