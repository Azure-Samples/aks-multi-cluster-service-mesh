#!/bin/bash

# Variables
source ./00-variables.sh

# Clone the Istio GitHub repo locally
( cd ..
curl https://storage.googleapis.com/istio-release/releases/1.14.4/istio-1.14.4-linux-amd64.tar.gz | tar -zxvf -
)

# Create CA certificates folder
if [ ! -d $certsDir ]; then
  mkdir $certsDir
fi

# Create CA certificates
(
cd $certsDir
make -f $istioDir/tools/certs/Makefile.selfsigned.mk root-ca
make -f $istioDir/tools/certs/Makefile.selfsigned.mk $aksClusterOneName-cacerts
make -f $istioDir/tools/certs/Makefile.selfsigned.mk $aksClusterTwoName-cacerts
)