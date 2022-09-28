#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
namespace="echoserver"
yamlDir="../yaml"

cat $yamlDir/virtualservice.yaml | sed -e "s/x.x.x.x/$(kubectl get ingress --context=$aksClusterOneName -n istio-ingress istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')/" |
kubectl apply --context=$aksClusterOneName -f -