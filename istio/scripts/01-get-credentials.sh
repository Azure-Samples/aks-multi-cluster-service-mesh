#!/bin/bash

# Variables
source ./00-variables.sh

# Get credentials for AKS cluster one
az aks get-credentials \
  --resource-group $aksClusterOneResourceGroupName \
  --name $aksClusterOneName \
  --overwrite-existing

# Get credentials for AKS cluster two
az aks get-credentials \
  --resource-group $aksClusterTwoResourceGroupName \
  --name $aksClusterTwoName \
  --overwrite-existing