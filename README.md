# Azure Foundry Standard Agent Service Module

This module provisions standard AI agent processing services inside Microsoft Azure.

## Private Module Consumption

Pin the module to a released tag when consuming it from private repositories.

```hcl
module "azure_foundry_standard_agent_service" {
  source = "git::https://github.com/fayezosaadi/azure_foundry_standard_agent_service.git?ref=v1.2.3"

  network_identity = {
    workspace = "my-workspace"
  }

  resource_group = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
    name = "rg-example"
  }

  location        = "eastus"
  search_location = "eastus"
  tags            = {}
}
```

## Custom Usage Notes

* Ensure your Azure Service Principal has contributor access before running.
* Network peering must be completed separately.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0, < 5.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.10.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.79.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.account_capability_host](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.cosmos_connection](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.project_capability_host](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.search_connection](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.storage_connection](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_cognitive_account.ai_foundry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_account_project.ai_foundry_project](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account_project) | resource |
| [azurerm_cognitive_deployment.deployments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_cosmosdb_account.cosmos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_role_assignment.cosmos_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_role_assignment) | resource |
| [azurerm_role_assignment.ai_foundry_role_assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cosmos_db_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.search_index_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.search_service_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_blob_data_owner_ai_foundry_project](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_search_service.search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [time_sleep.wait_for_rbac](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | n/a | <pre>map(object({<br/>    model = object({<br/>      name    = string<br/>      format  = string<br/>      version = optional(string, null)<br/>    })<br/>    sku = object({<br/>      name     = string<br/>      capacity = optional(number, 1)<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_network_identity"></a> [network\_identity](#input\_network\_identity) | n/a | <pre>object({<br/>    owner     = optional(string, "tech4life")<br/>    workspace = string<br/>    iteration = optional(number, 1)<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | <pre>object({<br/>    id   = string<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | n/a | <pre>map(object({<br/>    role_definition_name = string<br/>    principal_id         = string<br/>  }))</pre> | `{}` | no |
| <a name="input_search_location"></a> [search\_location](#input\_search\_location) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `object({})` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ai_foundry_account_id"></a> [ai\_foundry\_account\_id](#output\_ai\_foundry\_account\_id) | Resource ID of the Azure AI Foundry account. |
| <a name="output_ai_foundry_project_id"></a> [ai\_foundry\_project\_id](#output\_ai\_foundry\_project\_id) | Resource ID of the Azure AI Foundry project. |
| <a name="output_ai_foundry_project_principal_id"></a> [ai\_foundry\_project\_principal\_id](#output\_ai\_foundry\_project\_principal\_id) | Managed identity principal ID of the Azure AI Foundry project. |
| <a name="output_cosmos_account_id"></a> [cosmos\_account\_id](#output\_cosmos\_account\_id) | Resource ID of the Cosmos DB account linked to the project. |
| <a name="output_search_service_id"></a> [search\_service\_id](#output\_search\_service\_id) | Resource ID of the Azure AI Search service linked to the project. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Resource ID of the storage account linked to the project. |
<!-- END_TF_DOCS -->

## Contact & Support

For issues, open a ticket with the platform architecture team.
