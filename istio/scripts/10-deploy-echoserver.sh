#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
yamlDir="../yaml"
istioRevision="1-14-1"

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