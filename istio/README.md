# Multicluster Istio on AKS

This sample shows how to Install an [Istio](https://istio.io/) mesh across multiple [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes) clusters. For more information, see [Install Multicluster](https://istio.io/latest/docs/setup/install/multicluster/) in the Istio documentation.

## Deploy Kubernetes clusters

The Terraform code in this repository is provided for demo purposes and deploys the network topology shown in the following diagram.

![Deployment in two separate regions](../images/two-regions.png)

The infrastructure is composed of two regional sites each hosting an AKS cluster. In each region, the infrastructure is composed of the following resources:

- A virtual network in each region with the following subnets:
  - `System` used by the AKS system node pool
  - `User` used by the AKS user node pool
  - `AppGateway` used by the Application Gateway
  - `AzureBastionSubnet` used bu Azure Bastion
  - `PrivateEndpoints` used by Azure Private Endpoints
- A virtual network peering between the two regional virtual networks
- A user-defined managed identity used as identity by the AKS cluster
- An AKS cluster uses composed of two node pools, each in separate subnet:
  - `System` node pool hosting only critical system pods and services. The worker nodes have node taint which prevents application pods from beings scheduled on this node pool.
  - `User` node pool hosting user workloads and artifacts.
- An Azure Key Vault instance.
- An Azure Bastion resource that provides secure and seamless SSH connectivity to the AKS agent nodes over SSL
- An Azure Container Registry (ACR) to build, store, and manage container images and artifacts in a private registry for all types of container deployments.
- When the ACR SKU is equal to Premium:
  - The registry has two replicas, one in each region.
  - A Private Endpoint is created to allow the private AKS cluster to access ACR via a private IP address. For more information, see [Connect privately to an Azure container registry using Azure Private Link](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-private-link).
- A Private DNS Zone for the name resolution of ACR and Key Vault private endpoints.
- A Virtual Network Link between each Private DNS Zone and the two regional virtual networks.
- A Log Analytics workspace to collect the diagnostics logs and metrics of both the AKS cluster and other Azure services.

When deploying the two AKS clusters to the same region, the Terraform module deploys a single Azure Bastion Host and Azure Log Analytics workspace as shown by the following diagram:

![Deployment in one region](../images/one-region.png)

The Istio CA is managed offline and the cluster certificates are stored in Azure Key Vault.

## Requirements

Install the following software to your computer:

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

## Deploy the infrastructure via Terraform

Change the working directory to the `istio` folder which contains Terraform modules and run the following command to install the entire infrastructure to Azure:

```sh
terraform init -upgrade && terraform apply -var-file=terraform.tfvars
```

Before starting, make sure to properly set values for the variables imported and used by all the scripts in the [00-variables.sh](scripts/00-variables.sh) file in the `scripts` folder.

Use the [01-get-credentials.sh](scripts/01-get-credentials.sh) script under the `istio/scripts` folder to get access credentials for the AKS clusters.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/01-get-credentials.sh#L1-L16

You can test credentials by running the following script:

```sh
aksClusterOneName="<aks-cluster-one-name>"
aksClusterTwoName="<aks-cluster-two-name>"

kubectl --context=$aksClusterOneName get nodes
kubectl --context=$aksClusterTwoName get nodes
```

## Install Istio

In this section you will find scripts and steps to install `Istio` on the two clusters deployed using Terraform modules.

### Istio CA

By default the Istio installation creates a self-signed Certification Authority (CA) along with a root certificate and key and uses them to sign the workload certificates.
Two Istio installations with two different self-signed CAs cannot trust each other.
For this reason the first step to deploy Istio in multicluster is to create a Certification Authority that will be trusted by both clusters.

This process is documented in detail in [Plug in CA Certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/)

The [02-create-root-ca.sh](scripts/02-create-root-ca.sh) script under the `istio/scripts` folder creates a root CA and certificate per each cluster.:

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/02-create-root-ca.sh#L1-L18

### Istio CA with Key Vault

You can run the [03-store-certs-to-key-vault.sh](scripts/03-store-certs-to-key-vault.sh) script under the `istio/scripts` folder to store the cluster certificates we created at the previous step into Azure Key Vault.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/03-store-certs-to-key-vault.sh#L1-L42

### Create the ServiceProviderClass

The [Azure Key Vault Provider for Secrets Store CSI Driver](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver) allows for the integration of an Azure key vault as a secrets
store with an Azure Kubernetes Service (AKS) cluster via a CSI volume.
Now let's create a `SecretProviderClass` that will allow Istio to consume secrets from the Azure Key Vault.
The `SecretProviderClass` object needs to be created in the `istio-system` namespace.
Run the  [04-create-service-provider-class.sh](scripts/04-create-service-provider-class.sh) script under the `istio/scripts` folder to create the `istio-system namespace` and `SecretProviderClass` entity in each AKS cluster:

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/04-create-service-provider-class.sh#L1-L20

### Create the istio-ingress namespace

Let's create the `istio-ingress` namespace to install the [Istio Ingress Gateways](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/) for the North/South traffic, and let's enable injection in this namespace.

Create the `istio-ingress` namespace running [05-create-istio-ingress-ns.sh](scripts/05-create-istio-ingress-ns.sh)

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/05-create-istio-ingress-ns.sh#L1-L16

### Install Istioctl

Before installing Istio on AKS cluster, mek sure to install [istioctl](https://istio.io/latest/docs/reference/commands/istioctl/) command line utility for service operators to debug and diagnose their Istio mesh.
For more information, see [Install istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/#install-hahahugoshortcode-s2-hbhb). You can install the `istioctl` binary using the [06-install-istioctl.sh](scripts/06-install-istioctl.sh) script in the `scripts` folder:

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/06-install-istioctl.sh#L1-L6

You can optionally enable the [auto-completion option](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/#enabling-auto-completion) when working with a bash or ZSH console.

### Install Istio in the clusters

This sample will guide you through the necessary steps to install the Istio control plane on two AKS clusters, making each a primary cluster.
Both clusters reside in their own virtual network in the same region or different regions.
The two virtual networks are peered, meaning there is direct connectivity between the pods in both clusters.
For more information on this Istio configuration, see [Install Multi-Primary](https://istio.io/latest/docs/setup/install/multicluster/multi-primary/).

![Multi-Primary Installation](../images/multi-primary-istio.png)

We are now ready to install istio on both clusters using `istioctl`. For more information, see [Install with Istioctl](https://istio.io/latest/docs/setup/install/istioctl/). Run the [07-install-istio.sh](scripts/07-install-istio.sh) script.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/07-install-istio.sh#L1-L32

### Configure secrets for the remote endpoints

To attach the remote cluster to its control plane, we give the control plane in first cluster access to the API Server in the second cluster and vice versa. This will do the following:

- Enables the control plane to authenticate connection requests from workloads running in the remote cluster. Without API Server access, the control plane will reject the requests.
- Enables discovery of service endpoints running in the remote cluster.

This step configures in each cluster the secret to reach the other one. Note that the Kubernetes secret contains also the cluster endpoint, it is like a `kubectl configuration`.
You can use the [08-configure-remote-endpoint-secret.sh](scripts/08-configure-remote-endpoint-secret.sh) script in the `scripts` folder to create the secrets in the AKS clusters.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/08-configure-remote-endpoint-secret.sh#L1-L10

### Validate multicluster East-West connectivity

Now we can verify that the multicluster Istio installation is working properly and cluster are connected to each other.
You can use the [09-validate-istio-multicluster.sh](scripts/09-validate-istio-multicluster.sh) script in the `scripts` folder to accomplish this verification.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/09-validate-istio-multicluster.sh#L1-L10


If the validation succeeds, you should see an output like the following one:

```sh
NAME                      SECRET                                                      STATUS ISTIOD
prefix-eastus2-aks-two    istio-system/istio-remote-secret-prefix-eastus2-aks-two     synced istiod-1-14-1-db758fdc5-47g96
NAME                      SECRET                                                      STATUS ISTIOD
prefix-westeurope-aks-one istio-system/istio-remote-secret-prefix-westeurope-aks-one  synced istiod-1-14-1-5df557b459-hkb8j
```

## Deploy a test application

Let's deploy an `echoserver` and let's access it from the other cluster. An `echoserver` is an application that allows a client and a server to connect so a client can send a message to the server and the server can receive the message and send, or echo, it back to the client. We use the `10-deploy-echoserver.sh` script in the `scripts` folder to create a deployment called `echoserver` only in the first region. In order to make the `echoserver` service callable from any cluster, the DNS lookup must succeed in each cluster. We can achieve this by creating a `ClusterIP` service called `echoserver` in both regions. This will make it possible to resolve the DNS name `echoserver`.

### Create deployment and services

You can use the [10-deploy-echoserver.sh](scripts/10-deploy-echoserver.sh) script in the `scripts` folder to create the deployment

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/10-deploy-echoserver.sh#L1-L23

You can run the [11-call-echoserver-service-from-cluster-two.sh](scripts/11-call-echoserver-service-from-cluster-two.sh) script in the `scripts` folder to call the `echoserver` service from the remote cluster in the second region:

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/11-call-echoserver-service-from-cluster-two.sh#L1-L26


### Expose the Istio ingress gateway

Before we begin remember that in `004-ingress-gateway.yaml` we patched the `istio-ingressgateway` service to be `ClusterIP`, because we are going to expose the service via the [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview) that was deployed by the Terraform module along with each AKS cluster and the related  [Azure Application Gateway Ingress Controller](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview).

We are now going to expose the `istio-ingressgateway` only in the AKS cluster in the first region. You can apply the following configuration to both clusters if you want.

Let's configure the Kubernetes ingress object to expose the service and the Istio gateway.
A [Kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) is an API object that manages external access to the services in a cluster, typically via HTTP/S. Ingress may provide load balancing, SSL termination and name-based virtual hosting.
An [Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/) describes a load balancer operating at the edge of the mesh receiving incoming or outgoing HTTP/TCP connections. The specification describes a set of ports that should be exposed, the type of protocol to use, SNI configuration for the load balancer, etc.

For demo purposes, let's first use an ingress defined in the `ingress.yaml` manifest in the `yaml` folder that exposes the `echoserver` service via the `HTTP` protocol.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: istio-ingress-application-gateway
  annotations:
     kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ingressgateway
            port:
              number: 80
```

The `gateway.yaml` manifest in the `yaml` folder contains the definition of the Istio Gateway.

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: istio-ingressgateway
  namespace: istio-ingress
spec:
  selector:
    app: istio-ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - '*'
```

In a production environment we strongly recommend to configure the `ingress` object to expose the service via `HTTPS` with a TLS certificate and related host.
In the next section, we'll see how to expose the `echoserver` service via `HTTPS` using another ingress object.

You can use the [12-deploy-ingress-and-gateway.sh](scripts/12-deploy-ingress-and-gateway.sh) script in the `scripts` folder to deploy the ingress and gateway object to the `echoserver` namespace in the first cluster.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/12-deploy-ingress-and-gateway.sh#L1-L10


The gateway object that we just created is responsible to create a load balancer and expose ports, but it0s not responsible for request routing.
You can call the public endpoint exposed by the ingress object using the [13-call-echoserver-without-virtual-service.sh](scripts/13-call-echoserver-without-virtual-service.sh) script in the `scripts` folder.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/13-call-echoserver-without-virtual-service.sh#L1-L7

The `curl` call will reach the Istio ingress gateway which will not be able to route the request to the downstream `echoserver` service.
Hence, the call will fail with a `HTTP 404 Not Found` error.

```sh
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

An Istio VirtualService defines a set of traffic routing rules to apply when a host is addressed. Each routing rule defines matching criteria for traffic of a specific protocol. If the traffic is matched, then it is sent to a named destination service (or subset/version of it) defined in the registry. For more information, see [VirtualService](https://istio.io/latest/docs/reference/config/networking/virtual-service/). The `virtualservice.yaml` manifest in the `yaml` folder contains the definition of the VirtualService object used to route calls to the `echoserver` service.

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: echoserver
  namespace: istio-ingress
spec:
  hosts:
    - x.x.x.x.nip.io
  gateways:
    - istio-ingress/istio-ingressgateway
  http:
  - match:
    - uri:
        prefix: "/"
    route:
    - destination:
        host: echoserver.echoserver.svc.cluster.local
```

This sample makes use of the [nip.io](https://nip.io/) free service which allows to map any IP Address to a hostname using the different formats which includes mapping a public IP `a.b.c.d` to the hostname `a.b.c.d.nip.io`.
The [nip.io](https://nip.io/) service makes it easy to quickly have a public DNS name for any IP address for troubleshooting and testing purposes.

You can use the [14-deploy-virtual-service.sh](scripts/14-deploy-virtual-service.sh) script in the `scripts` folder to create a VirtualService in the `istio-ingress` namespace.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/14-deploy-virtual-service.sh#L1-L8


### Call the echoserver via HTTP

Now you can call the `echoserver` service via HTTP using the [15-call-echoserver-via-http.sh](scripts/15-call-echoserver-via-http.sh) script in the `scripts` folder.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/15-call-echoserver-via-http.sh#L1-L7

In this section, we configured the following artifacts:

- The ingress for the [Azure Application Gateway Ingress Controller](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) with the file `istio/yaml/ingress.yaml`
- The `istio-ingressgateway` with the files `istio/yaml/gateway.yaml` and `istio/yaml/virtualservice.yaml`

## Implement end-to-end TLS

Now that you understand the basics of exposing the `istio-ingressgateway` behind the [Azure Application Gateway Ingress Controller](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview),
we can extend our configuration to use `HTTPS` instead of `HTTP`. The goal is to expose the `echoserver` service public endpoint to the public internet via an [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview) listener configured to use the `HTTPS` transport protocol, and configure the backend pool and HTTP setting used by the Application Gateway to establish a TLS connection to the backend that in our case is composed of the `istio-ingressgateway` pods. For more information on this configuration, see:

- [Create a certificate and configure the certificate to AppGw](https://azure.github.io/application-gateway-kubernetes-ingress/features/appgw-ssl-certificate/)
- [Tutorial: Setting up E2E SSL](https://azure.github.io/application-gateway-kubernetes-ingress/tutorials/tutorial.e2e-ssl/)

For simplicity, we are going to show the steps only for the one of the two clusters.

### Frontend certificate

The frontend certificate is the certificate the Application Gateway listener will use to encrypt and protect the communications with clients over the Internet. For testing purposes, you can use the [16-create-self-signed-frontend-certificate-in-key-vault.sh](scripts/16-create-self-signed-frontend-certificate-in-key-vault.sh) script in the `scripts` folder to create a self-signed certificate in our Azure Key Vault.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/16-create-self-signed-frontend-certificate-in-key-vault.sh#L1-L22

The above steps create a certificate with `CN=CLIGetDefaultPolicy`. You can modify the default-policy to change the parameters of the frontend certificate.
In a production environment, you should import a digital certificate issued by a well-known certificate authority (CA) into Azure Key Vault using the [az keyvault certificate import](https://learn.microsoft.com/en-us/cli/azure/keyvault/certificate?view=azure-cli-latest#az-keyvault-certificate-import) command.

Now we can import the certificate from Azure Key Vault into the Application Gateway. To do this we also need to make sure the Application Gateway has the permission to read secrets from the Azure Key Vault. Run the script [17-import-frontend-certificate-into-app-gateway.sh](scripts/17-import-frontend-certificate-into-app-gateway.sh).

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/17-import-frontend-certificate-into-app-gateway.sh#L1-L88

We'll use the name of the frontend certificate (`frontend-certificate`) later in the ingress annotations to reference this certificate.

### Backend certificate

For the connection to the backend, we need the Azure Application Gateway to trust certificates emitted by the Istio CA, because we are going to use a Istio CA certificate for the `istio-ingressgateway` pods.
We can use the [18-add-istio-ca-certificate-to-application-gateway.sh](scripts/18-add-istio-ca-certificate-to-application-gateway.sh) script in the `scripts` folder to import the `root-cert.pem` certificate to the Azure Application Gateway as a root certificate:

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/18-add-istio-ca-certificate-to-application-gateway.sh#L1-23

The name `root-certificate` will be used later in the ingress annotations to reference this certificate. Now we can generate a x509 certificate signed by the Istio CA and upload it to Azure Key Vault, using the [19-create-signed-certificate.sh](scripts/19-create-signed-certificate.sh) script.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/19-create-signed-certificate.sh#L1-L57

### Configure Istio for HTTPS endpoint

Then we need to create a `SecretProviderClass` in the `istio-ingress` namespace to read this certificate from Kubernetes. We also need to patch the `ingressgateway` deployment to mount the certificate in the pods. You can use the [20-create-and-install-objects-for-https.sh](scripts/20-create-and-install-objects-for-https.sh) script in the `scripts` folder to perform these steps.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/20-create-and-install-objects-for-https.sh#L1-L28

Now that all the certificates needed are in place, we can patch our existing `gateway`, `virtualService` and `ingress` to use TLS. You can use the [21-update-gateway-virtualservice-ingress.sh](scripts/21-update-gateway-virtualservice-ingress.sh) script in the `scripts` folder to perform these steps.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/21-update-gateway-virtualservice-ingress.sh#L1-L12

if you look at the `ingress-tls-e2e.yaml` in the `yaml` folder you will note that the ingress objects uses the [annotations](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/) of the [Azure Application Gateway Ingress Controller](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) to control the configuration of listeners, backend pools, and backend settings created by the controller.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: istio-ingress-application-gateway
  namespace: istio-ingress
  annotations:
    appgw.ingress.kubernetes.io/appgw-ssl-certificate: "frontend-certificate"
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/backend-protocol: "https"
    appgw.ingress.kubernetes.io/backend-hostname: "echoserver.echoserver.svc.cluster.local"
    appgw.ingress.kubernetes.io/appgw-trusted-root-certificate: "root-certificate"
    appgw.ingress.kubernetes.io/health-probe-hostname: "echoserver.echoserver.svc.cluster.local"
    appgw.ingress.kubernetes.io/health-probe-port: "8443"
    appgw.ingress.kubernetes.io/health-probe-path: "/"
spec:
  ingressClassName: azure-application-gateway
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ingressgateway
            port:
              number: 443
```

### Call the echoserver via HTTPS

Now you can call the `echoserver` service via HTTPS using the [22-call-echoserver-via-https.sh](scripts/22-call-echoserver-via-https.sh) script in the `scripts` folder.

https://github.com/Azure-Samples/aks-multi-cluster-service-mesh/blob/0655ce19e05b044edf4b9aa4251a9807de8dbf85/istio/scripts/22-call-echoserver-via-https.sh#L1-L7

> **NOTE**
> The `-k` parameter in curl is needed because we used a self-signed certificate in the Application Gateway listener.
