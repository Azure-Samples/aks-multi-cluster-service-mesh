#!/bin/bash

# Variables
source ./00-variables.sh

# Change the working directory to the certificates folder
cd $certsDir

# Retrieve Azure Key Vault name
keyVaultName=$(az keyvault list --resource-group $sharedResourceGroupName --query [0].name --output tsv)

# Store the root certificate to Azure Key Vault as a secret
az keyvault secret set \
  --vault-name $keyVaultName \
  --name root-cert \
  --file root-cert.pem

for cluster in ${clusters[@]}; do
  cd $cluster

  # Create a PFX certificate using the CA certificate and private key
  openssl pkcs12 \
    -inkey ca-key.pem \
    -in ca-cert.pem \
    -export \
    -passout pass: \
    -out ca-cert-and-key.pfx

  # Store the root certificate chain to Azure Key Vault as a secret
  az keyvault secret set \
    --vault-name $keyVaultName \
    --name $cluster-cert-chain \
    --file cert-chain.pem

  # Store the CA certificate to Azure Key Vault as a certificate
  az keyvault certificate import \
    --vault-name $keyVaultName \
    --name $cluster-ca-cert \
    --file ca-cert-and-key.pfx

  cd ..
done
