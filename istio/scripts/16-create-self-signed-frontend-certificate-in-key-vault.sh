#!/bin/bash

# Variables
source ./00-variables.sh

sharedResourceGroupLocation="westeurope"
sharedResourceGroupName="$prefix-$sharedResourceGroupLocation-shared-rg"
certificateName="frontend-certificate"

# Retrieve Azure Key Vault name from the shared resource group
export keyVaultName=$(az keyvault list --resource-group $sharedResourceGroupName --query [].name --output tsv)

if [[ -z $keyVaultName ]]; then
    echo "There is no Key Vault resource in $sharedResourceGroupName resource group"
    exit -1
fi

# Create self-signed frontend certificate
az keyvault certificate create \
  --vault-name $keyVaultName \
  --name $certificateName \
  --policy "$(az keyvault certificate get-default-policy --output json)"