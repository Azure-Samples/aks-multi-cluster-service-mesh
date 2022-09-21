#!/bin/bash

# Variables
prefix="nucuqt"
locationOne="westeurope"
locationTwo="eastus2"
aksClusterOneName="$prefix-$locationOne-aks-one"
aksClusterTwoName="$prefix-$locationTwo-aks-two"
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
