# Multicluster Istio on AKS

## Deploy Kubernetes clusters

The Terraform code in this repository is a demo that will deploy 2 AKS clusters in the regions westeurope and eastus.
The Azure Virtual Networks are going to be connected with a Virtual Network Peering.
The AKS clusters have multiple Node Pools and each node pools has a dedicated subnet.
The Istio CA is managed offline and the cluster certificates are stored in Azure Key Vault.

To run the Terraform code:

```
cp  tfvars .tfvars
vim .tfvars #customize if needed
terraform init -upgrade && terraform apply -var-file=.tfvars
```

Get clusters credentials:

```
az aks get-credentials --resource-group istio-aks-westeurope --name westeurope-aks
az aks get-credentials --resource-group istio-aks-eastus --name eastus-aks
```

Test credentials:

```
kubectl --context=eastus-aks get nodes
kubectl --context=westeurope-aks get nodes

```

## Istio CA

By default the Istio installation creates a self signed CA. Two Istio installations with two different self-signed CA cannot trust each other.
For this reason the first step to deploy Istio in multicluster is to create a Certification Authority that will be trusted by both clusters.

This is documented in detail here:
https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/

Short summary:

```
git clone git@github.com:istio/istio.git
cd istio
mkdir certs
cd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca
make -f ../tools/certs/Makefile.selfsigned.mk westeurope-aks-cacerts
make -f ../tools/certs/Makefile.selfsigned.mk eastus-aks-cacerts
```

This will create a Root CA and certificate per each cluster.

## Istio CA with Key Vault

Now we want to store the cluster certificates we created at the previous step into Azure Key Vault.

Store the CA Certificate first: we are going to store only the certificate and not the private key that we want to keep offline:

```
export keyvaultname=$(az keyvault list -g keyvault-rg -o json |jq -r '.[0].name')
az keyvault secret set --vault-name $keyvaultname --name root-cert -f root-cert.pem
```

Combine the cluster certificate and the key in a single file and upload the certificate to Azure Key Vault:
```
for cluster in eastus-aks westeurope-aks ; do
( cd $cluster &&
cat ca-cert.pem ca-key.pem > ca-cert-and-key.pem &&
az keyvault secret set --vault-name $keyvaultname --name $cluster-cert-chain --file cert-chain.pem &&
az keyvault certificate import --vault-name $keyvaultname -n $cluster-ca-cert -f ca-cert-and-key.pem );
done
```

> If the `az keyvault certificate import` step fails complaining about the PEM format, try the workaround published here: https://github.com/Azure/azure-cli/issues/8099#issuecomment-795180979

# Create the ServiceProviderClass

Now we create the Service Provider Class that will allow us to consume secrets from the Azure Key Vault.
The Service Provider Class needs to stay in the istio-system namespace that we create now.
Run these commands from your Terraform folder:

```
for cluster in eastus-aks westeurope-aks ; do kubectl create --context=$cluster namespace istio-system; done
terraform output -raw secret-provider-class-eastus | kubectl --context=eastus-aks -n istio-system apply -f -
terraform output -raw secret-provider-class-westeurope | kubectl --context=westeurope-aks -n istio-system apply -f -
```

## Install Istio in the clusters

Lets create the `istio-ingress` namespace to install the Istio Ingressgateways for the North/South traffic, and lets enable injection in this namespace.

```
kubectl create --context=eastus-aks ns istio-ingress
kubectl label --context=eastus-aks ns istio-ingress istio.io/rev=1-14-1
kubectl create --context=westeurope-aks ns istio-ingress
kubectl label --context=westeurope-aks ns istio-ingress istio.io/rev=1-14-1
```

We are now ready to install istio on both clusters:


```
(cd istio-installation &&
istioctl install -y \
  --context=eastus-aks \
  --set profile=minimal \
  --revision=1-14-1 \
  --set tag=1.14.1 \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-eastus.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway.yaml &&
istioctl install -y \
  --context=westeurope-aks \
  --set profile=minimal \
  --revision=1-14-1 \
  --set tag=1.14.1 \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-westeurope.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway.yaml
)
```

# Configure the remote endpoints secret

This step configures in each cluster the secret to reach the other one. Note that the Kubernetes secret contains also the cluster endpoint, it is like a `kubectl configuration`.

```
istioctl x create-remote-secret --context=westeurope-aks --name=westeurope-aks | k apply -f - --context=eastus-aks
istioctl x create-remote-secret --context=eastus-aks --name=eastus-aks | k apply -f - --context=westeurope-aks
```

# Validate multicluster east west connectivity

At this point verify that the clusters are connected and synced:

```
$ istioctl remote-clusters --context=eastus-aks
NAME               SECRET                                              STATUS     ISTIOD
westeurope-aks     istio-system/istio-remote-secret-westeurope-aks     synced     istiod-1-14-1-689c9f5f7-n9r4p

$ istioctl remote-clusters --context=westeurope-aks
NAME           SECRET                                          STATUS     ISTIOD
eastus-aks     istio-system/istio-remote-secret-eastus-aks     synced     istiod-1-14-1-67d5b5fdfc-nm6w5
```

Let's deploy a echoserver and let's access it from the other cluster.

We are going to create a deployment `echoserver` only in westeurope. The service `echoserver` will be created in both regions, because this will make possible to resolve the DNS name echoserver.

```
kubectl create --context=eastus-aks ns echoserver
kubectl label --context=eastus-aks ns echoserver istio.io/rev=1-14-1
kubectl create --context=westeurope-aks ns echoserver
kubectl label --context=westeurope-aks ns echoserver istio.io/rev=1-14-1
kubectl apply --context=westeurope-aks -n echoserver -f istio-installation/echoserver.yaml -f istio-installation/echoserver-svc.yaml
kubectl apply --context=eastus-aks -n echoserver -f istio-installation/echoserver-svc.yaml
```

Now lets access the echoserver from the remote cluster in eastus:

```
kubectl run --context=eastus-aks -n echoserver -ti curlclient --image=nicolaka/netshoot /bin/bash
$ curl echoserver:8080
```
# Expose the Istio ingress gateway

Before we begin remember that in `004-ingress-gateway.yaml` we patched the `istio-ingressgateway` service to be
`ClusterIP`, because we are going to expose it now with an Application Gateway.

We are now going to expose the `istio-ingressgateway` on 1 AKS cluster, you can apply the following both clusters if you want.

Lets configure the ingress and the gateway:

```
kubectl apply -f istio-installation/gateway.yaml
kubectl apply -f istio-installation/ingress.yaml
```

Now you can reach the envoy of the `istio-ingressgateway` and you will get a HTTP 404:

```
curl -v $(kubectl get ingress -n istio-ingress istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
*   Trying x.x.x.x:80...
* Connected to x.x.x.x (x.x.x.x) port 80 (#0)
> GET / HTTP/1.1
> Host: x.x.x.x
> User-Agent: curl/7.79.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
< Date: Wed, 13 Jul 2022 12:05:00 GMT
< Content-Length: 0
< Connection: keep-alive
< server: istio-envoy
<
* Connection #0 to host x.x.x.x left intact
```

To actually reach the echoserver create the `VirtualService`

```
 sed -i -e "s/x.x.x.x/$(kubectl get ingress -n istio-ingress istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')/" istio-installation/virtualservice.yaml
kubectl apply -f istio-installation/virtualservice.yaml
```

Now you have to use the hostname to `curl`:

```
curl -v $(kubectl get ingress -n istio-ingress istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip').nip.io
```

In the above command we leverage the [nip.io](https://nip.io/) free service that makes it easy to quickly have a DNS name for any IP address for troubleshooting and testing.

In this section you configured:

* The application gateway with the file `istio-installation/ingress.yaml`
* The `istio-ingressgateway` with the files `istio-installation/gateway.yaml` and `istio-installation/virtualservice.yaml`

# End to End TLS

Now that you understand the basics of exposing the `istio-ingressgateway` behind an Application Gateway Ingress,
let's extend our configuration to use TLS.

The goal is to have TLS in the frontend exposed to the Internet, and also in the backend using a TLS connection from the Application Gateway to the backend that is the `istio-ingressgateway` Pod.

What we describe in the following is a summary of the 2 documentation pages:

* https://azure.github.io/application-gateway-kubernetes-ingress/features/appgw-ssl-certificate/
* https://azure.github.io/application-gateway-kubernetes-ingress/tutorials/tutorial.e2e-ssl/

For simplicity we are going to show the steps for the cluster `westeurope-aks` only.

## Frontend certificate

The frontend certificate, is the certificate the application gateway will serve to the clients on the Internet. For the sake of simplicity we just create a self signed certificate in our Azure Key Vault:

```
export keyvaultname=$(az keyvault list -g keyvault-rg -o json |jq -r '.[0].name')
az keyvault certificate create --vault-name $keyvaultname -n mycert -p "$(az keyvault certificate get-default-policy -o json)"
versionedSecretId=$(az keyvault certificate show -n mycert --vault-name $keyvaultname --query "sid" -o tsv)
unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5) # remove the version from the url
```

The above steps create a certificate with `CN=CLIGetDefaultPolicy`. You can modify the default-policy or provide a proper certificate if you wish.

Now we import that certificate from Azure Key Vault to the application gateway. To do this we also need to make sure the application gateway has the permission to read secrets from the Azure Key Vault.

```
# Get the resource group name of the AKS cluster
aksResourceGroupName=$(az aks show --name westeurope-aks --resource-group istio-aks-westeurope --query nodeResourceGroup --output tsv)

# get principalId of the AGIC managed identity
agicIdentityPrincipalId=$(az identity show --name ingressapplicationgateway-westeurope-aks --resource-group $aksResourceGroupName --query principalId --output tsv)

# One time operation, create user-assigned managed identity
az identity create -n appgw-id -g istio-aks-westeurope -l westeurope
identityID=$(az identity show -n appgw-id -g istio-aks-westeurope -o tsv --query "id")
identityPrincipal=$(az identity show -n appgw-id -g istio-aks-westeurope -o tsv --query "principalId")

# One time operation, assign AGIC identity to have operator access over AppGw identity
az role assignment create --role "Managed Identity Operator" --assignee $agicIdentityPrincipalId --scope $identityID

# One time operation, assign the identity to Application Gateway
az network application-gateway identity assign \
                              --gateway-name aks-agw-westeurope \
                              --resource-group istio-aks-westeurope \
                              --identity $identityID

# One time operation, assign the identity GET secret access to Azure Key Vault
az keyvault set-policy \
            -n $keyvaultname \
            -g istio-aks-westeurope \
            --object-id $identityPrincipal \
            --secret-permissions get

# Now that the application-gateway can read secrets from Azure Key Vault we can import the certificate:
az network application-gateway ssl-cert create \
                               -n mykvsslcert \
                               --gateway-name  aks-agw-westeurope \
                               --resource-group $aksResourceGroupName \
                               --key-vault-secret-id $unversionedSecretId

```

The name `mykvsslcert` is going to be used later in the ingress annotations to reference this certificate.

## Backend certificate

For the connection to the backend, we need the `application-gateway` to trust certificates emitted by the Istio CA, because we are going to use a Istio CA certificate for the `istio-ingressgateway` pod. To do this we add our `root-cert.pem` certificate to the `application-gateway`:

```
 az network application-gateway root-cert create \
                                --gateway-name aks-agw-westeurope \
                                -g $aksResourceGroupName \
                                --name backend-tls \
                                --cert-file root-cert.pem
```

The name `backend-tls` will be used later in the ingress annotations to reference this CA.

Let's generate a x509 certificate signed by the Istio CA and lets upload it to Azure Key Vault:

```
cd <istiorepo>/certs
mkdir echoserver
cd echoserver
openssl req -out echoserver.echoserver.svc.cluster.local.csr -newkey rsa:2048 -nodes -keyout echoserver.echoserver.svc.cluster.local.key -subj "/CN=echoserver.echoserver.svc.cluster.local/O=Istio Services"

openssl x509 -req -sha256 -days 365 -CA ../root-cert.pem -CAkey ../root-key.pem -set_serial 1 -in echoserver.echoserver.svc.cluster.local.csr  -out echoserver.echoserver.svc.cluster.local.pem

cat echoserver.echoserver.svc.cluster.local.pem echoserver.echoserver.svc.cluster.local.key > echoserver.pem
export keyvaultname=$(az keyvault list -g keyvault-rg -o json |jq -r '.[0].name')
az keyvault certificate import --vault-name $keyvaultname -n echoserver -f echoserver.pem

```

We need to create a `SecretProviderClass` in the `istio-ingress` namespace to read this certificate from Kubernetes. We also need to patch the `ingressgateway` deployment to mount the certificate in the pods.

```
terraform output -raw secret-provider-class-ingress | kubectl --context=westeurope-aks -n istio-ingress apply -f -

cd cd istio-installation

istioctl install -y \
  --context=westeurope-aks \
  --set profile=minimal \
  --revision=1-14-1 \
  --set tag=1.14.1 \
  -f 001-accessLogFile.yaml \
  -f 002-multicluster-westeurope.yaml \
  -f 003-istiod-csi-secrets.yaml \
  -f 004-ingress-gateway-csi.yaml # <-- note the "-csi" file
```

Now that all the certificates needed are in place, we can patch our existing `gateway`, `virtualService` and `ingress` to use TLS.

```
kubectl apply -f gateway-tls.yaml -f virtualservice-tls.yaml -f ingress-tls-e2e.yaml
```

# Verify and troubleshoot

Lets try to reach the echoserver exposed with the Ingress using TLS:

```
curl -kv https://$(kubectl get ingress -n istio-ingress istio-ingress-application-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip').nip.io
```

Note that the `-k` parameter in curl is needed because we used a self-signed certificate for the frontend.
