# Variables

# Edit the following
prefix="<resource-prefix>"
aksClusterOneLocation="<aks-location-one>"
aksClusterTwoLocation="<aks-location-two>"
sharedResourceGroupLocation="<shared-resource-group-location>"

# Edit if you want to modify this project to add new features:
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
aksClusterOneResourceGroupName="$prefix-$aksClusterOneLocation-one-rg"
aksClusterTwoResourceGroupName="$prefix-$aksClusterTwoLocation-two-rg"
sharedResourceGroupName="$prefix-$sharedResourceGroupLocation-shared-rg"
terraformDirectory=".."
certsDir="../certificates"
istioDir="../istio"
yamlDir="../yaml"
clusters=($aksClusterOneName $aksClusterTwoName)
istioRevision="1-14-1"
yamlDir="../yaml"
tag="1.14.1"
namespace="echoserver"
podName="curlclient"
containerName="curlclient"
imageName="nginx"
command="curl echoserver:8080"
certificateName="frontend-certificate"
applicationGatewayName="aks-appgw-$aksClusterLocation"
rootCertificateName="root-certificate"
rootCertificateFile="../certificates/$aksClusterOneName/root-cert.pem"
echoserverCertificateName="echoserver"
echoserverDir="echoserver"