#!/bin/bash

# Variables
source ./00-variables.sh

# Create a secret with credentials to allow Istio to access remote Kubernetes API servers in the first cluster
istioctl x create-remote-secret --context=$aksClusterTwoName --name=$aksClusterTwoName | kubectl --context=$aksClusterOneName apply -f -

# Create a secret with credentials to allow Istio to access remote Kubernetes API servers in the second cluster
istioctl x create-remote-secret --context=$aksClusterOneName --name=$aksClusterOneName | kubectl --context=$aksClusterTwoName apply -f -