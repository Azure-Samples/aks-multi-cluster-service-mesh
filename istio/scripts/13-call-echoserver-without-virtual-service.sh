#!/bin/bash

# Variables
source ./00-variables.sh


curl -v $(kubectl get ingress -n istio-ingress --context=$aksClusterOneName istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')