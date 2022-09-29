#!/bin/bash

# Download istioctl
curl -sL https://istio.io/downloadIstioctl | sh -

# Add the `istioctl` client to your path, on a macOS or Linux system
export PATH=$HOME/.istioctl/bin:$PATH
