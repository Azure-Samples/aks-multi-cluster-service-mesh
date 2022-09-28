#!/bin/bash

# Variables
yamlDir="../yaml"
prefix="ifwfhi"
aksClusterOneLocation="westeurope"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"

# Change the working directory to the yaml folder
cd $yamlDir

# Update
kubectl --context=$aksClusterOneName apply -f gateway-tls.yaml -f virtualservice-tls.yaml -f ingress-tls-e2e.yaml
