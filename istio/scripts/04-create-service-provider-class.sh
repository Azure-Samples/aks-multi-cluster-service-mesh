#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
terraformDirectory=".."
clusters=($aksClusterOneName $aksClusterTwoName)

# Create istio-system namespace in AKS clusters
for cluster in ${clusters[@]} ; do 
  kubectl create --context=$cluster namespace istio-system
done

# Change the working directory to the Terraform folder
cd $terraformDirectory

# Create SecretProviderClass in the istio-system namespace in the first cluster
terraform output -raw secret_provider_class_location_one | kubectl --context=$aksClusterOneName -n istio-system apply -f -

# Create SecretProviderClass in the istio-system namespace in the second cluster
terraform output -raw secret_provider_class_location_two | kubectl --context=$aksClusterTwoName -n istio-system apply -f -