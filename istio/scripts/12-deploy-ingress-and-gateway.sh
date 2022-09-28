#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
yamlDir="../yaml"

# Deploy the Istio gateway to the istio-ingress namespace in the first cluster
kubectl apply --context=$aksClusterOneName -f $yamlDir/gateway.yaml

# Deploy the ingress to the echoserver namespace in the first cluster
kubectl apply --context=$aksClusterOneName -f $yamlDir/ingress.yaml