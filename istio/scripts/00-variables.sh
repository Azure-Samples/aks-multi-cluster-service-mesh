# Variables
prefix="<resource-prefix>"
aksClusterOneLocation="<aks-location-one>"
aksClusterTwoLocation="<aks-location-two>"
aksClusterOneName="$prefix-$aksClusterOneLocation-aks-one"
aksClusterTwoName="$prefix-$aksClusterTwoLocation-aks-two"
aksClusterOneResourceGroupName="$prefix-$aksClusterOneLocation-one-rg"
aksClusterTwoResourceGroupName="$prefix-$aksClusterTwoLocation-two-rg"
sharedResourceGroupLocation="<shared-resource-group-location>"
sharedResourceGroupName="$prefix-$sharedResourceGroupLocation-shared-rg"
certsDir="../certificates"
istioDir="../istio"
scriptsDir="./scripts"
clusters=($aksClusterOneName $aksClusterTwoName)
terraformDirectory=".."
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