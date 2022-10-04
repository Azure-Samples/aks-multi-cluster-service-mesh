#!/bin/bash

# Variables
source ./00-variables.sh

# Change the working directory to the Terraform folder
(
cd $terraformDirectory

# Create the SecretProviderClass object
terraform output -raw secret_provider_class_ingress_one | kubectl --context=$aksClusterOneName apply -f -
)

(
# Change the working directory to the yaml folder
cd $yamlDir

# Generate an Istio install manifest and apply it to a cluster
istioctl install -y \
  --context=$aksClusterOneName \
  --set profile=minimal \
  --revision=$istioRevision \
  --set tag=$tag \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-region-one.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway-csi.yaml # <-- note the "-csi" file
)