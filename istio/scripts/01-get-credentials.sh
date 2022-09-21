#!/bin/bash

# Variables
prefix="nucuqt"
locationOne="westeurope"
locationTwo="eastus2"
aksClusterOneName="$prefix-$locationOne-aks-one"
aksClusterTwoName="$prefix-$locationTwo-aks-two"
aksClusterOneResourceGroupName="$prefix-$locationOne-one-rg"
aksClusterTwoResourceGroupName="$prefix-$locationTwo-two-rg"

# Get credentials for AKS cluster one
az aks get-credentials \
  --resource-group $aksClusterOneResourceGroupName \
  --name $aksClusterOneName

# Get credentials for AKS cluster two
az aks get-credentials \
  --resource-group $aksClusterTwoResourceGroupName \
  --name $aksClusterTwoName
