#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"

# Lists the remote clusters the first cluster is connected to
istioctl remote-clusters --context=$aksClusterOneName

# Lists the remote clusters the second cluster is connected to
istioctl remote-clusters --context=$aksClusterTwoName