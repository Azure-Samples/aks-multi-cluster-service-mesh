#!/bin/bash

# Variables
source ./00-variables.sh

# Lists the remote clusters the first cluster is connected to
istioctl remote-clusters --context=$aksClusterOneName

# Lists the remote clusters the second cluster is connected to
istioctl remote-clusters --context=$aksClusterTwoName
