#!/bin/bash

# Variables
source ./00-variables.sh

prefix="zqsbwx"
aksClusterLocation="westeurope"
sharedResourceGroupLocation="westeurope"
aksClusterOneResourceGroupName="$prefix-$aksClusterLocation-one-rg"
sharedResourceGroupName="$prefix-$sharedResourceGroupLocation-shared-rg"
aksClusterOneName="$prefix-$aksClusterLocation-aks-one"
applicationGatewayName="aks-appgw-$aksClusterLocation"
certificateName="frontend-certificate"

# Retrieve Azure Key Vault name from the shared resource group
export keyVaultName=$(az keyvault list --resource-group $sharedResourceGroupName --query [].name --output tsv)

if [[ -z $keyVaultName ]]; then
    echo "There is no Key Vault resource in $sharedResourceGroupName resource group"
    exit -1
fi

# Get the versioned secret id of the frontend certificate in key vault
versionedSecretId=$(az keyvault certificate show \
  --name $certificateName \
  --vault-name $keyVaultName \
  --query sid \
  --output tsv)

# Get the unversioned secret id of the frontend certificate in key vault
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5)

# Get the name of the node resource group of the AKS cluster
aksClusterOneNodeResourceGroupName=$(az aks show \
  --name $aksClusterOneName \
  --resource-group $aksClusterOneResourceGroupName \
  --query nodeResourceGroup \
  --output tsv)

# Get principalId of the AGIC managed identity
agicIdentityPrincipalId=$(az identity show \
  --name ingressapplicationgateway-$aksClusterOneName \
  --resource-group $aksClusterOneNodeResourceGroupName \
  --query principalId \
  --output tsv)

# Create user-assigned managed identity for the application gateway
az identity create \
  --name appgw-id \
  --resource-group $aksClusterOneResourceGroupName \
  --location $aksClusterLocation

# Retrieve the resource id of the managed identity
identityID=$(az identity show \
  --name appgw-id \
  --resource-group $aksClusterOneResourceGroupName \
  --output tsv \
  --query "id")

# Retrieve the principal id of the managed identity
identityPrincipal=$(az identity show \
  --name appgw-id \
  --resource-group $aksClusterOneResourceGroupName \
  --output tsv \
  --query "principalId")

# One time operation, assign AGIC identity to have operator access over AppGw identity
az role assignment create \
  --role "Managed Identity Operator" \
  --assignee $agicIdentityPrincipalId \
  --scope $identityID

# One time operation, assign the identity to Application Gateway
az network application-gateway identity assign \
  --gateway-name $applicationGatewayName \
  --resource-group $aksClusterOneNodeResourceGroupName \
  --identity $identityID

# One time operation, assign the identity GET secret access to Azure Key Vault
az keyvault set-policy \
  --name $keyVaultName \
  --resource-group $sharedResourceGroupName \
  --object-id $identityPrincipal \
  --secret-permissions get

# Now that the application-gateway can read secrets from Azure Key Vault we can import the certificate
az network application-gateway ssl-cert create \
  --name $certificateName \
  --gateway-name  $applicationGatewayName \
  --resource-group $aksClusterOneNodeResourceGroupName \
  --key-vault-secret-id $unversionedSecretId

# List the certificates to verify that the certificate was properly created
az network application-gateway ssl-cert list \
  --gateway-name  $applicationGatewayName \
  --resource-group $aksClusterOneNodeResourceGroupName