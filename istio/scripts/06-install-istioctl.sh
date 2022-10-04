#!/bin/bash

source ./00-variables.sh

# Download istioctl
curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=$tag sh -