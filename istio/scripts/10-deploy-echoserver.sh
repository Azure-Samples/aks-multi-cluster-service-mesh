#!/bin/bash

# Variables
source ./00-variables.sh

# Create echoserver namespace in the first cluster
kubectl create --context=$aksClusterOneName namespace echoserver

# Enable automatic Istio sidecar injection for the echoserver namespace in the first cluster
kubectl label --context=$aksClusterOneName namespace echoserver istio.io/rev=$istioRevision

# Create the echoserver deployment and service in the echoserver namespace in the first cluster
kubectl apply --context=$aksClusterOneName -n echoserver -f $yamlDir/echoserver.yaml -f $yamlDir/echoserver-svc.yaml

# Create echoserver namespace in the second cluster
kubectl create --context=$aksClusterTwoName namespace echoserver

# Enable automatic Istio sidecar injection for the echoserver namespace in the second cluster
kubectl label --context=$aksClusterTwoName namespace echoserver istio.io/rev=$istioRevision

# Create the echoserver service in the echoserver namespace in the second cluster
kubectl apply --context=$aksClusterTwoName -n echoserver -f $yamlDir/echoserver-svc.yaml
