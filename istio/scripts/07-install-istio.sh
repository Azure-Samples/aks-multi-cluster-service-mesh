#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
yamlDir="../yaml"
istioRevision="1-14-1"
tag="1.14.1"

# Change the working directory to the yaml folder
cd $yamlDir

# Install Istio on cluster one
istioctl install -y \
  --context=$aksClusterOneName \
  --set profile=minimal \
  --revision=$istioRevision \
  --set tag=$tag \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-region-one.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway.yaml

# Install Istio on cluster two
istioctl install -y \
  --context=$aksClusterTwoName \
  --set profile=minimal \
  --revision=$istioRevision \
  --set tag=$tag \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-region-two.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway.yaml