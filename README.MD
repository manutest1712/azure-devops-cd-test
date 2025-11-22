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


## 📘 Instructions

### ⚙️ Setup agents

#### 🧱 Create Build Agent Image with Packer
1. Navigate to the folder:
    ```bash
        azure-devops-cd-test\packer\agent-image
    ```
2. Open the file variables.pkrvars.hcl and update the Azure authentication fields:
    ```bash
        client_id        = "xxxxxx"
        client_secret    = "xxxxxx"
        tenant_id        = "xxxxxx"
        subscription_id  = "xxxxxx"
    ```
    ⚠️ **Important**: **Do NOT** commit variables.pkrvars.hcl to source control. Add it to .gitignore to prevent accidental secrets exposure
3. Build the VM image using Packer:
    ```bash
        packer build -var-file="variables.pkrvars.hcl" packer-ci-vm.pkr.hcl
    ```
Once the build completes, the custom image will be available in Azure and later used by Terraform to provision the self-hosted CI agent VM.

---
### 🧰 Azure DevOps Build & Test Agent Setup
This section outlines the steps required to configure Azure DevOps and prepare the environment for deploying self-hosted build and test agents created through Terraform

#### 1️⃣ Prerequisites
Before proceeding, ensure you have:
- An active Azure subscription
- Access to an Azure DevOps organization
- Required permissions to create:
  - Azure resources
  - Service connections
  - Agent pools

#### 2️⃣ Set Up Azure DevOps Organization

##### ✔️ Step 1: Create a Project
1. Sign in to **Azure DevOps**.
2. Create an organization if one is not there already
3. Go to the **Projects** section.
4. Create a new project and name it: DemoProject


##### ✔️ Step 2: Create a Service Connection
This connection will be used by Terraform tasks to authenticate to Azure.
1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Identity Type** as **App Registrationor Managed Identity (Manual)**
4. Choose **Credential** as **Secret**
5. Enter your Azure authentication details:
   - Subscription ID  
   - Tenant ID  
   - Client ID  
   - Client Secret
6. Name it: `DemoConnection`
7. Enable: **Grant access permission to all pipelines**


##### ✔️ Step 3: Create a Self-Hosted Agent Pool
The virtual machine deployed via Terraform will automatically register itself as an agent in this pool.

1. Go to **Project Settings → Agent Pools**
2. Select **Add pool**
3. Choose **Self-hosted** as the pool type
4. Name it: `myAgentPool`
5. Enable: **Grant access permission to all pipelines**

⚠️ **Note:** Do not manually add agents. The Terraform infrastructure will register the agent automatically.

##### ✔️ Step 4: Generate a Personal Access Token (PAT)

This token will be used by the VM agent to authenticate with Azure DevOps.

1. Go to **User Settings → Personal Access Tokens**
2. Click **New Token**
3. Set a descriptive name: `AgentRegistrationToken`
4. Set the expiry duration as needed (recommended: **90 days** or higher)
5. Assign scope: **Full access**
6. Click **Create** and copy the token

⚠️ **Important:** Store the PAT securely. You will not be able to view it again once you close the window.

##### 🚀 Step 5: Deploy Self-Hosted Agent Infrastructure with Terraform

1. Navigate to the Terraform environment folder:
   ```bash
   azure-devops-cd-test\terraform\environments\test\agent-infra
   ```

2. Open the file **terraform.tfvars** and update the required values:
   ```hcl
   subscription_id = "xxxxx"
   client_id       = "xxxxx"
   client_secret   = "xxxxx"
   tenant_id       = "xxxxx"

   azdo_url        = "https://dev.azure.com/xxxxx"
   azdo_pat        = "xxxxx"
   ```

   ⚠️ **Security Notice:** Do **NOT** commit `terraform.tfvars` to source control. Add it to `.gitignore` to prevent exposing sensitive credentials.

3. Initialize Terraform modules and providers:
   ```bash
   terraform init
   ```

4. Preview the infrastructure changes:
   ```bash
   terraform plan -out infraplan
   ```

5. Deploy the infrastructure:
   ```bash
   terraform apply "infraplan"
   ```

---

Once deployment completes:

- The virtual machine will automatically register itself as a **self-hosted agent** in the selected Azure DevOps agent pool.
- A virtual machine will be provisioned and configured for use as a **build execution environment**.
- Azure Storage Account created for storing Azure Pipeline Terraform state.

---

### ⚙️ Azure DevOps Environment Setup
This section explains how to create a deployment environment in Azure DevOps and connect a Linux Virtual Machine as a resource for automated UI testing using Selenium.

### 🧩 Environment Configuration

| Setting             | Value                                        |
| ------------------- | -------------------------------------------- |
| 🌍 Environment Name | `test-selenium-env`                          |
| 🖥 VM Resource Name | `selenium-test-vm`                           |
| 🏷 Purpose          | Execute Selenium automated UI test pipelines |


### 🚀 Steps to Configure

#### 1️⃣ Create Azure DevOps Environment

From the Azure DevOps **Pipelines → Environments** page:

1.  Click the **Create environment** button. 
2.  In the dialog box that appears:
    * **Name:** `test-selenium-env`
    * **Description (optional):** `Environment for Selenium UI testing on Linux VM.`
    * **Resource:** **Virtual machines**
3.  Click **Create** - this opens the **Add Resource** dialog
4.  Select **Operating system** as Linux
5.  Azure DevOps will generate a registration script. Copy this script and run it on the virtual machine.

> 📌 Note: The Virtual Machine will not appear in Azure DevOps until the generated registration script is executed on the target Linux VM.

#### 2️⃣ Run the Registration Script on the VM
* SSH into your virtual machine:
   ```bash
   ssh youruser@<VM_PUBLIC_IP>
   ```
* Paste the copied script into the terminal and run it. The script will handle:
    * Downloading the agent.
    * Configuring the agent to connect back to your Azure DevOps organization and the `test-selenium-env` environment.
* When prompted with **Enter Environment Virtual Machine resource tags? (Y/N) (press enter for N)**, type **Y** and press **Enter**
* When prompted with **Enter Comma separated list of tags (e.g web, db)**, type **selenium** and press **Enter**.

#### 3️⃣ Verification:
    * After the script runs successfully, return to the Azure DevOps Environment page.
    * The newly linked Virtual Machine - `selenium-test-vm` should appear under the **Resources** tab with a **Status** of **Never Deployed**. 

>💡 Tip: It may take a few seconds for the VM to appear; refresh the page if needed.
---

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

