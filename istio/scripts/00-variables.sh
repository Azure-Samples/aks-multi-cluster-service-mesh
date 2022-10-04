# Variables

# Edit the following
prefix="mhhiuj"
aksClusterOneLocation="westeurope"
aksClusterTwoLocation="eastus2"
sharedResourceGroupLocation="westeurope"

# Edit if you want to modify this project to add new features:
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
aksClusterOneResourceGroupName="$prefix-$aksClusterOneLocation-one-rg"
aksClusterTwoResourceGroupName="$prefix-$aksClusterTwoLocation-two-rg"
sharedResourceGroupName="$prefix-$sharedResourceGroupLocation-shared-rg"
terraformDirectory=".."
certsDir="../certificates"
tag="1.14.4"
istioDir="../istio-$tag"
yamlDir="../yaml"
clusters=($aksClusterOneName $aksClusterTwoName)
istioRevision="1-14-4"
yamlDir="../yaml"
namespace="echoserver"
podName="curlclient"
containerName="curlclient"
imageName="nginx"
command="curl echoserver:8080"
certificateName="frontend-certificate"
applicationGatewayName="aks-appgw-$aksClusterOneLocation"
rootCertificateName="root-certificate"
rootCertificateFile="../certificates/$aksClusterOneName/root-cert.pem"
echoserverCertificateName="echoserver"
echoserverDir="echoserver"

# Add the `istioctl` client to your path, on a macOS or Linux system
export PATH=$HOME/.istioctl/bin:$PATH