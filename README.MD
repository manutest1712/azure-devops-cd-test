# 🔭 Overview

This project implements a complete CI/CD pipeline using **Azure DevOps**, provisioning infrastructure with **Terraform**, deploying application components to Azure, and running automated test suites including Postman, Selenium, and JMeter.

---

## 🧩 Pipeline Workflow

| Stage | Purpose |
|-------|---------|
| 🏗 Build & Provision | Terraform installation, configuration, and infrastructure apply |
| 🧪 API Testing | Postman tests executed via Newman |
| 🖥 UI Testing | Selenium functional testing executed on virtual machine |
| 📦 Artifact Packaging | Archives and uploads automation test bundles |
| 🚀 Deployment | Web App deployed to Azure with service connection |
| ⚡ Load Testing | JMeter endurance + stress scenarios executed |
| 📊 Reporting | Test results and HTML output uploaded as artifacts |

---

## 🔧 Technology Stack

| Category | Tools |
|---------|-------|
| CI/CD | Azure DevOps Pipelines |
| IaC | Terraform (AzureRM backend) |
| API Testing | Postman + Newman (JUnit reports) |
| UI Testing | Selenium + Python |
| Load Testing | Apache JMeter |
| Deployment | Azure Web App Service |

---

## 📂 Pipeline Outputs

- 📄 Automated Test Reports (JUnit Format)
- 📦 Archived Selenium, Postman & JMeter bundles
- 📊 Performance logs & HTML dashboards

---

## ✔ Requirements

- Azure DevOps Service Connection configured
- Terraform backend storage provisioned
- Secure secret variables stored in pipeline settings

---

## 🏁 CI/CD Summary

This pipeline automates:

- Infrastructure provisioning
- Application deployment
- End-to-end testing validation
- Performance analysis
- Artifact archiving and publishing

> **Result: A fully automated DevOps workflow supporting continuous delivery and quality assurance.**


## Instructions

### Setup Azure devops organization
#### Step 1:  Create a Project
Create a new Azure DevOps project named DemoProject.
#### Step 2:  Create a Service Connection

    1. Go to **Project Settings** → **Service connections**
    2. Click **New service connection** → **Azure Resource Manager**
    2. Choose **App Registration or managed identity(manual) **
    3. Enter your Azure authentication details:
        a. Subscription ID
        b. Tenant ID
        c. Client ID
        d. Client Secret
    4. Name it: DemoConnection
    5. Grant access permission to all pipelines.

This service connection will be used by Terraform tasks to authenticate to Azure.

#### Step 3:  Create a Self-Hosted Agent Pool
You need a dedicated pool because the VM created by Terraform will register itself to this pool.

    1. Go to **Project Settings → Agent Pools**
    2. Click **Add pool**
    3. Choose **Self-hosted** as the pool type.
    4. Name it: myAgentPool
    5. Grant access permission to all pipelines.

**Note**: No need to add an agent manually — the infra setup will do that.

### Setup agents

#### Setup agent image
1. Navigate to the folder:
    ```bash
        azure-devops-cd-test\packer\agent-image
    ```
2. Open the file:
    variables.pkrvars.hcl
3. Update the required variables with your Azure details:
    ```bash
        client_id        = "xxxxxx"
        client_secret    = "xxxxxx"
        tenant_id        = "xxxxxx"
        subscription_id  = "xxxxxx"
    ```
    **Note**: Do not commit variables.pkrvars.hcl to Git
4. Run the following command to build the agent VM image:
    ```bash
        packer build -var-file="variables.pkrvars.hcl" packer-ci-vm.pkr.hcl
    ```

#### Install the Terraform Azure DevOps Extension

1. Navigate to your Azure DevOps organization settings
2. Go to "Extensions" and then "Browse marketplace."
3. Search for "Terraform" and locate the extension published by Microsoft DevLabs (or a suitable alternative if preferred)
4. Install the extension into your Azure DevOps organization. This makes Terraform tasks available for use in your pipelines.  


### Terraform Backend Setup with Azure Storage
This section explains how to set up a **Terraform remote backend** in **Azure** using a **storage account and blob container**. Storing the Terraform state remotely enables safe collaboration, state locking, and versioning.

#### Prerequisites
- **Azure CLI** installed and logged in:

```bash
az login
```

An Azure subscription with permissions to create resource groups and storage accounts.
Terraform installed (version >= 1.0 recommended).
**Note**: Make sure you are logged in to the correct Azure subscription.

#### Step 1: Create Azure Storage Account
Terraform requires a storage account to store the remote state:

```bash
az storage account create \
  --name tfstateaccount2025manu \
  --resource-group AzureDevops \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob
```

**Tip**: Ensure that the resource group AzureDevops exists. You can create it with:

```bash
az group create --name AzureDevops --location eastus
```

#### Step 2:  Create Blob Container

```bash
az storage container create \
  --name tfstate \
  --account-name tfstateaccount2025manu
```

#### Step 3:  Initialize Terraform
Run the following command to initialize the backend:

```bash
terraform init
```
**Note**: command needs to be executed from the folder:
azure-devops-cd-test/terraform\environments/test

### Azure DevOps Pipeline Secret Variables

The following environment variables are used in the Azure Pipeline to authenticate and manage resources in Azure via Terraform. These variables must be configured as secret variables in your Azure DevOps pipeline to ensure credentials are not exposed.

```yaml
env:
  # These must be set as Secret Variables in Azure DevOps
  TF_VAR_client_id: $(client_id)
  TF_VAR_client_secret: $(client_secret)
  TF_VAR_tenant_id: $(tenant_id)
  TF_VAR_subscription_id: $(subscription_id)
```

#### Description of Variables

| Variable Name     | Description                                                                                       |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| `client_id`       | Azure Service Principal Client ID. Used for Terraform authentication with Azure.                  |
| `client_secret`   | Azure Service Principal Client Secret. Must be kept secret to protect authentication credentials. |
| `tenant_id`       | Azure Tenant ID associated with the subscription.                                                 |
| `subscription_id` | Azure Subscription ID where resources will be deployed.                                           |


#### Steps to Configure in Azure DevOps

1. Navigate to your Azure DevOps pipeline.  
2. Click on **Edit**
2. Click on **Variables**  
3. Add the following variables: `client_id`, `client_secret`, `tenant_id`, `subscription_id`.  
4. Mark each variable as **secret** by checking the secret icon (🔒).  
5. Save the pipeline. Terraform will automatically use these environment variables during execution.  

**Note:** Never hard-code these credentials in the pipeline YAML or repository. Always use secret variables to ensure security.

