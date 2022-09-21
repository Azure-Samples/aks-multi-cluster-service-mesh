#!/bin/bash

# Variables
prefix="nucuqt"
locationOne="westeurope"
locationTwo="eastus2"
aksClusterOneName="$prefix-$locationOne-aks-one"
aksClusterTwoName="$prefix-$locationTwo-aks-two"
terraformDirectory=".."
clusters=($aksClusterOneName $aksClusterTwoName)

# Create istio-system namespace in AKS clusters
for cluster in ${clusters[@]} ; do 
  kubectl create --context=$cluster namespace istio-system
done

# Change the working directory to the Terraform folder
cd $terraformDirectory

# Create SecretProviderClass in the istio-system namespace in each AKS cluster
terraform output -raw secret_provider_class_location_one | kubectl --context=$aksClusterOneName -n istio-system apply -f -
terraform output -raw secret_provider_class_location_two | kubectl --context=$aksClusterTwoName -n istio-system apply -f -