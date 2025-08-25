# n8n-azure-container-app

This Terraform configuration deploys an **n8n** instance on **Azure Container Apps**, along with an **Azure OpenAI Service** instance configured with the **GPT-4o** model. By leveraging Azure Container Apps, this setup provides a cost-effective alternative to deploying n8n on Azure Kubernetes Service (AKS), as described on the n8n [website](https://docs.n8n.io/hosting/installation/server-setups/azure/). Azure Container Apps simplify the deployment process while maintaining scalability and reducing operational overhead.
 
### Key Features:
- **n8n Workflow Automation**: Deploys n8n, a powerful workflow automation tool, in a highly available and scalable environment using Azure Container Apps.
- **Optional Azure MCP Server Container**: Optionally deploys an additional container app integrated with MCP/Azure, providing Azure-specific context to the agent in n8n. This container app includes an NGINX instance configured as a reverse proxy to the MCP server, ensuring seamless communication and enhanced functionality.
- **Azure OpenAI Integration**: Provisions an Azure OpenAI Service instance with the GPT-4o model, enabling advanced AI capabilities for your workflows.
- **Cost Optimization**: Utilizes Azure Container Apps to minimize costs compared to AKS, making it an ideal choice for small to medium-scale deployments.
- **Secure Configuration**: Integrates with Azure Key Vault to securely manage sensitive information, such as API keys and secrets.
- **Customizable Deployment**: Supports flexible configuration options for region, tags, telemetry, existing resource groups, and database availability zones.
- **Azure Verified Modules**: Leverages Azure Verified Modules (AVMs) to ensure the use of well-defined, tested, and Microsoft-supported modules, enhancing reliability and maintainability.

This repository was created to provide a more affordable and accessible way to host n8n in the Azure cloud, as the AKS-based solution was found to be expensive for smaller-scale use cases. This configuration offers a practical alternative, combining the power of n8n and Azure OpenAI with the cost-efficiency and simplicity of Azure Container Apps.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | >= 4, < 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | ~> 3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | 4.26.0 |
| <a name="provider_random"></a> [random](#provider_random) | 3.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_app_mcp"></a> [container_app_mcp](#module_container_app_mcp) | Azure/avm-res-app-containerapp/azurerm | 0.4.0 |
| <a name="module_container_app_n8n"></a> [container_app_n8n](#module_container_app_n8n) | Azure/avm-res-app-containerapp/azurerm | 0.4.0 |
| <a name="module_key_vault"></a> [key_vault](#module_key_vault) | Azure/avm-res-keyvault-vault/azurerm | 0.10.0 |
| <a name="module_naming"></a> [naming](#module_naming) | Azure/naming/azurerm | 0.4.0 |
| <a name="module_openai"></a> [openai](#module_openai) | Azure/avm-res-cognitiveservices-account/azurerm | 0.7.0 |
| <a name="module_postgresql"></a> [postgresql](#module_postgresql) | Azure/avm-res-dbforpostgresql-flexibleserver/azurerm | 0.1.4 |
| <a name="module_storage"></a> [storage](#module_storage) | Azure/avm-res-storage-storageaccount/azurerm | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_environment_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_storage) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_password.myadminpassword](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | Azure Subscription ID | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of an existing Resource Group to deploy into. If null, a new RG will be created. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input_location) | Azure region for deployments when creating a new RG. If using an existing RG, its location is inferred. | `string` | `"eastu2"` | no |
| <a name="input_postgres_zone"></a> [postgres_zone](#input_postgres_zone) | Availability Zone for PostgreSQL Flexible Server ("1", "2", or "3"). Set `null` to let Azure choose automatically. | `string` | `null` | no |
| <a name="input_deploy_mcp"></a> [deploy_mcp](#input_deploy_mcp) | Controls whether the MCP container app is deployed. | `bool` | `false` | no |
| <a name="input_enable_telemetry"></a> [enable_telemetry](#input_enable_telemetry) | Controls whether telemetry is enabled for AVM modules. See https://aka.ms/avm/telemetryinfo. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Custom tags to apply to resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_n8n_fqdn_url"></a> [n8n_fqdn_url](#output_n8n_fqdn_url) | HTTPS URL using ingress FQDN for accessing the n8n app. |
| <a name="output_mcp_endpoint_sse"></a> [mcp_endpoint_sse](#output_mcp_endpoint_sse) | SSE endpoint of the optional MCP Server. |
| <a name="output_openai_key_secret_url"></a> [openai_key_secret_url](#output_openai_key_secret_url) | HTTPS URL of the Key Vault secret containing the Azure OpenAI key. |
| <a name="output_openai_endpoint"></a> [openai_endpoint](#output_openai_endpoint) | Endpoint of the Azure OpenAI account. |
| <a name="output_openai_resource_name"></a> [openai_resource_name](#output_openai_resource_name) | Custom subdomain name of the Azure OpenAI account. |
| <a name="output_openai_deployment_name"></a> [openai_deployment_name](#output_openai_deployment_name) | Name of the Azure OpenAI deployment (e.g., `gpt-4o`). |
| <a name="output_openai_api_version"></a> [openai_api_version](#output_openai_api_version) | API version to use with Azure OpenAI (currently `2024-07-18`). |

<!-- END_TF_DOCS -->

## How to deploy (Azure Cloud Shell – PowerShell)

- **Select subscription and clone your fork**
  ```powershell
  az account show | Format-Table
  az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"

  # If needed
  # git clone <your-fork-url>
  # cd n8n-azure-container-app
  ```

- **Register required resource providers (one-time)**
  ```powershell
  $providers = @(
    "Microsoft.App",
    "Microsoft.CognitiveServices",
    "Microsoft.DBforPostgreSQL",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.ManagedIdentity"
  )
  $providers | % {
    if ((az provider show -n $_ --query registrationState -o tsv 2>$null) -ne "Registered") {
      az provider register --namespace $_ --wait | Out-Null
    }
  }
  ```

- **Initialize Terraform**
  ```powershell
  terraform init
  ```

- **Plan and apply (existing Resource Group)**
  ```powershell
  $sub = az account show --query id -o tsv
  $rg  = "RG-AuxilityChatApp-001"  # replace with your RG

  terraform plan -out tfplan `
    -var "subscription_id=$sub" `
    -var "resource_group_name=$rg" `
    -var "deploy_mcp=false"

  terraform apply tfplan
  ```
  Notes:
  - When `resource_group_name` is provided, the RG location is inferred. You don’t need to pass `location`.
  - If you create a new RG instead, pass a valid region (e.g., `-var "location=eastus2"`). The default `eastu2` is a typo in this repo and should be overridden.

- **Optional: set a specific Postgres zone**
  ```powershell
  # Discover available zones/SKUs in your region
  az postgres flexible-server list-skus -l westeurope `
    --query "[].{Sku:name, Tier:tier, vCores:vCores, Zones:capabilities[?name=='Zone'].value}" -o table

  # Then provide the zone explicitly if needed
  terraform plan -out tfplan `
    -var "subscription_id=$sub" `
    -var "resource_group_name=$rg" `
    -var "postgres_zone=2"
  ```

- **Retrieve outputs**
  ```powershell
  terraform output -raw n8n_fqdn_url
  terraform output -raw openai_endpoint
  terraform output -raw openai_deployment_name
  terraform output -raw openai_api_version
  terraform output -raw openai_key_secret_url
  ```

- **Fetch the Azure OpenAI key from Key Vault (optional)**
  ```powershell
  $secretId = terraform output -raw openai_key_secret_url
  az keyvault secret show --id $secretId --query value -o tsv
  ```

## Notes

- The deployment creates/uses:
  - `Azure Container Apps` with an n8n container, ingressed on port 5678 and an Azure Files mount at `/home/node/.n8n`.
  - `Azure PostgreSQL Flexible Server` with an `n8n` database; password stored in `Azure Key Vault`.
  - `Azure Storage Account` with a file share `n8nconfig`.
  - `Azure OpenAI` account with a `gpt-4o` deployment.
- If using Cloud Shell and you see storage data-plane auth errors, either run `az login --scope "https://storage.azure.com/.default"` or ensure `provider "azurerm"` does not force AAD for storage data-plane.