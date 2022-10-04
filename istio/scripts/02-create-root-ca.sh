#!/bin/bash

# Variables
source ./00-variables.sh

# Clone the Istio GitHub repo locally
git clone git@github.com:istio/istio.git $istioDir

# Create CA certificates folder
if [ ! -d $certsDir ]; then
  mkdir $certsDir
fi

# Create CA certificates
(
cd $certsDir
make -f ../istio/tools/certs/Makefile.selfsigned.mk root-ca
make -f ../istio/tools/certs/Makefile.selfsigned.mk $aksClusterOneName-cacerts
make -f ../istio/tools/certs/Makefile.selfsigned.mk $aksClusterTwoName-cacerts
)