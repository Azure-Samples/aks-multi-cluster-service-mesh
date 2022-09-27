#!/bin/bash

# Variables
prefix="zqsbwx"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
certsDir="../certificates"
istioDir="../istio"

# Clone the Istio GitHub repo locally
git clone git@github.com:istio/istio.git $istioDir

# Create CA certificates folder
if [ ! -d $certsDir ]; then
  mkdir $certsDir
fi

# Create CA certificates
cd $certsDir
make -f ../istio/tools/certs/Makefile.selfsigned.mk root-ca
make -f ../istio/tools/certs/Makefile.selfsigned.mk $aksClusterOneName-cacerts
make -f ../istio/tools/certs/Makefile.selfsigned.mk $aksClusterTwoName-cacerts
