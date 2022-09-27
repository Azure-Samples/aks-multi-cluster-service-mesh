#!/bin/bash

# Variables
yamlDir="../yaml"

# Change the working directory to the yaml folder
cd $yamlDir

# Update
kubectl apply -f gateway-tls.yaml -f virtualservice-tls.yaml -f ingress-tls-e2e.yaml