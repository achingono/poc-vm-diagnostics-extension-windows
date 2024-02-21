# POC: Azure Virtual Machines, Azure Diagnostics extension

This repository demonstrates a sample bicep template deploying a [Virtual Machine](https://azure.microsoft.com/en-us/products/virtual-machines/) to azure with the [Azure Diagnostics extension](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/diagnostics-extension-overview) enabled.

## Getting Started

The deployment process involves the following steps:
1. Provision the architecture using Bicep
1. Create application deployment package
1. Publish application deployment package

### Prerequisites

1. Local bash shell with Azure CLI or [Azure Cloud Shell](https://ms.portal.azure.com/#cloudshell/)
1. Azure Subscription. [Create one for free](https://azure.microsoft.com/free/).
1. Clone or fork of this repository.

### QuickStart

A bash script is included for quickly provisioning a fully functional environment in Azure. The script requires the following parameters:

```
-n: The deployment name.
-l: The region where resources will be deployed.
-c: A unique string that will ensure all resources provisioned are globally unique.
-u: The virtual machine administrator username
-p: The virtual machine administrator password
```
> **NOTE:** Please refer to the [Resource Name Rules](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftweb) to learn more about globally unique resources.

Follow the steps below to quickly deploy using the bash script:

1. Clone the repository to local machine.
    ```
    git clone https://github.com/achingono/poc-vm-diagnostics-extension-windows.git
    ```
1. Switch to the cloned folder
    ```
    cd poc-vm-diagnostics-extension-windows
    ```

1. Make the bash script executable
    ```
    chmod +x ./deploy.sh
    ```

1. Login to Azure and ensure the correct subscription is selected
    ```
    az login
    az account set --subscription <subscription id>
    az account show
    ```

1. Run the script and provide required parameters
    ```
    ./deploy.sh -n sharedsession -l eastus2 -c poc -u azureuser -p <secure password>
    ```
    In the above command, `sharedsession` is the name of the environment, and `poc` is the variant. This generates a resource group named `rg-sharedsession-eastus2-poc`.

## Cleanup

Clean up the deployment by deleting the single resource group that contains the entire infrastructure.

> **WARNING:** This will delete ALL the resources inside the resource group.

1. Make the bash script executable
    ```
    chmod +x ./destroy.sh
    ```

2. Login to Azure and ensure the correct subscription is selected
    ```
    az login
    az account set --subscription <subscription id>
    az account show
    ```

3. Run the script and provide required parameters
    ```
    ./destroy.sh -n sharedsession -l eastus2 -c poc
    ```