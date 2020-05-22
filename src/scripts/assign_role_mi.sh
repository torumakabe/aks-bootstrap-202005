#!/bin/bash

MI_PID=$(terraform output aks_mi_principal_id)
AKS_SUBNET_ID=$(terraform output aks_subnet_id)
az role assignment create --assignee $MI_PID --scope $AKS_SUBNET_ID --role "Contributor"
