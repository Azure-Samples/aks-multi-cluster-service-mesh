#!/bin/bash

# Variables
source ./00-variables.sh

# Get the name of the node resource group of the AKS cluster
aksClusterOneNodeResourceGroupName=$(az aks show \
  --name $aksClusterOneName \
  --resource-group $aksClusterOneResourceGroupName \
  --query nodeResourceGroup \
  --output tsv)

# Import the backend certificate from file into Application Gateway
az network application-gateway root-cert create \
  --gateway-name $applicationGatewayName \
  --resource-group $aksClusterOneNodeResourceGroupName \
  --name $rootCertificateName \
  --cert-file $rootCertificateFile

# List the certificates to verify that the certificate was properly created
az network application-gateway root-cert list \
  --gateway-name  $applicationGatewayName \
  --resource-group $aksClusterOneNodeResourceGroupName