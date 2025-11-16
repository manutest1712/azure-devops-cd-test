# Overview

This project provides a cloud-hosted Flask web application that predicts housing prices using a trained machine-learning model.  
Users can send property details to the `/predict` API and instantly receive price predictions in JSON format.  
Automation is built in: a Makefile simplifies setup, testing, and deployment.
Continuous Integration runs through GitHub Actions, which installs dependencies, runs pylint for code analysis and pytest to execute unit test cases on every push to the main branch.
Azure Pipelines provides continuous delivery by packaging the application and deploying it directly to an Azure Web App.  
The result is a reliable, scalable, and automated solution that supports rapid development and real-time model inference.

## Project Plan

[Trello board for the Housing Trend Project Planner](https://trello.com/b/9a9XvYIE/fask-housing-trend-weekly-plan)

[Project Plan In Excel](https://docs.google.com/spreadsheets/d/1QsJpxNEZldNpzWKBwi_6Fmf42sGRiEYL/edit?usp=sharing&ouid=109875377807326084890&rtpof=true&sd=true)

## Instructions

### Install the Terraform Azure DevOps Extension

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
