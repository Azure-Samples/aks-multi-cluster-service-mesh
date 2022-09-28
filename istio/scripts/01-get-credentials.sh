#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
aksClusterOneResourceGroupName="$prefix-$aksClusterOneLocation-one-rg"
aksClusterTwoResourceGroupName="$prefix-$aksClusterTwoLocation-two-rg"

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
