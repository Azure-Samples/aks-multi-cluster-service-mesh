#!/bin/bash

# Variables
source ./00-variables.sh

# Change the working directory to the certificates folder
cd $certsDir

# Create CA certificates folder
if [ ! -d $echoserverDir ]; then
  mkdir $echoserverDir
fi

# Change the working directory to the echoserver folder
cd $echoserverDir

# Generate a new certificate for the echoserver service in the echoserver namespace
openssl req \
  -out echoserver.echoserver.svc.cluster.local.csr \
  -newkey rsa:2048 \
  -nodes \
  -keyout echoserver.echoserver.svc.cluster.local.key \
  -subj "/CN=echoserver.echoserver.svc.cluster.local/O=Istio Services"

# Sign the certificate with the root-cert.pem CA certificate
openssl x509 \
  -req \
  -sha256 \
  -days 365 \
  -CA ../root-cert.pem \
  -CAkey ../root-key.pem \
  -set_serial 1 \
  -in echoserver.echoserver.svc.cluster.local.csr  \
  -out echoserver.echoserver.svc.cluster.local.pem

# Create a PFX certificate using the certificate and private key
openssl pkcs12 \
  -inkey echoserver.echoserver.svc.cluster.local.key \
  -in echoserver.echoserver.svc.cluster.local.pem \
  -export \
  -passout pass: \
  -out echoserver.pfx

# Retrieve Azure Key Vault name from the shared resource group
export keyVaultName=$(az keyvault list --resource-group $sharedResourceGroupName --query [].name --output tsv)

if [[ -z $keyVaultName ]]; then
    echo "There is no Key Vault resource in $sharedResourceGroupName resource group"
    exit -1
fi

# Import the certificate in Azure Key Vault
az keyvault certificate import \
  --vault-name $keyVaultName \
  --name $echoserverCertificateName \
  --file echoserver.pfx