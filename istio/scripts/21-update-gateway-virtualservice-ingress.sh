#!/bin/bash

# Variables
source ./00-variables.sh

# Change the working directory to the yaml folder
(
cd $yamlDir

# Update
kubectl --context=$aksClusterOneName apply -f gateway-tls.yaml -f virtualservice-tls.yaml -f ingress-tls-e2e.yaml
)