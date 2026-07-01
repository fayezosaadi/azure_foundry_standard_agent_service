resource "azurerm_cognitive_account" "ai_foundry" {
  name                  = local.account_name
  custom_subdomain_name = local.account_name
  location              = var.location
  resource_group_name   = var.resource_group.name

  kind     = "AIServices"
  sku_name = "S0"

  identity {
    type = "SystemAssigned"
  }

  project_management_enabled    = true
  public_network_access_enabled = true
  local_auth_enabled            = true

  network_acls {
    default_action = "Allow"
  }

  tags = merge(var.tags, { what_is_this = "Foundry Account" })
}

resource "azurerm_cognitive_account_project" "ai_foundry_project" {
  name                 = local.project_name
  display_name         = local.project_name
  description          = "Foundry project"
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, { what_is_this = "Foundry Project" })

  depends_on = [azurerm_cognitive_account.ai_foundry]
}

resource "azurerm_cognitive_deployment" "deployments" {
  for_each             = var.deployments
  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = each.value.model.name
    version = each.value.model.version
  }

  sku {
    capacity = each.value.sku.capacity
    name     = "GlobalStandard"
  }

  depends_on = [azurerm_cognitive_account_project.ai_foundry_project]
}

resource "azurerm_search_service" "search" {
  name                          = local.ai_search_name
  resource_group_name           = var.resource_group.name
  location                      = var.search_location
  sku                           = "basic"
  semantic_search_sku           = "free"
  local_authentication_enabled  = true
  authentication_failure_mode   = "http401WithBearerChallenge"
  public_network_access_enabled = true
  tags                          = merge(var.tags, { what_is_this = "Azure AI Search" })
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                          = local.cosmos_account_name
  location                      = var.location
  resource_group_name           = var.resource_group.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = merge(var.tags, { what_is_this = "Cosmos DB" })

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_account" "storage" {
  name                            = local.storage_account_name
  resource_group_name             = var.resource_group.name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(var.tags, { what_is_this = "Storage Account" })

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_role_assignment" "ai_foundry_role_assignments" {
  for_each = var.role_assignments

  scope                = azurerm_cognitive_account.ai_foundry.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "search_index_data_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id
}

resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id
}

resource "azurerm_role_assignment" "cosmos_db_operator" {
  scope                = azurerm_cosmosdb_account.cosmos.id
  role_definition_name = "Cosmos DB Operator"
  principal_id         = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmos_contributor" {
  resource_group_name = var.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  role_definition_id  = "${azurerm_cosmosdb_account.cosmos.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id
  scope               = "${azurerm_cosmosdb_account.cosmos.id}/dbs/enterprise_memory"

  depends_on = [azapi_resource.project_capability_host]
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner_ai_foundry_project" {
  name                 = uuidv5("dns", "${azurerm_cognitive_account_project.ai_foundry_project.name}${azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id}${azurerm_storage_account.storage.name}storageblobdataowner")
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_cognitive_account_project.ai_foundry_project.identity[0].principal_id

  depends_on = [azapi_resource.project_capability_host]
}

resource "azapi_resource" "storage_connection" {
  type      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name      = azurerm_storage_account.storage.name
  parent_id = azurerm_cognitive_account_project.ai_foundry_project.id

  body = {
    properties = {
      category = "AzureStorageAccount"
      target   = azurerm_storage_account.storage.primary_blob_endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_storage_account.storage.id
        location   = azurerm_storage_account.storage.location
      }
    }
  }
}

resource "azapi_resource" "search_connection" {
  type      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name      = azurerm_search_service.search.name
  parent_id = azurerm_cognitive_account_project.ai_foundry_project.id

  body = {
    properties = {
      category = "CognitiveSearch"
      target   = "https://${azurerm_search_service.search.name}.search.windows.net"
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_search_service.search.id
        location   = azurerm_search_service.search.location
      }
    }
  }
}

resource "azapi_resource" "cosmos_connection" {
  type      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name      = azurerm_cosmosdb_account.cosmos.name
  parent_id = azurerm_cognitive_account_project.ai_foundry_project.id

  body = {
    properties = {
      category = "CosmosDb"
      target   = azurerm_cosmosdb_account.cosmos.endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_cosmosdb_account.cosmos.id
        location   = azurerm_cosmosdb_account.cosmos.location
      }
    }
  }
}

resource "time_sleep" "wait_for_rbac" {
  depends_on = [
    azurerm_role_assignment.storage_blob_data_contributor,
    azurerm_role_assignment.search_index_data_contributor,
    azurerm_role_assignment.search_service_contributor,
    azurerm_role_assignment.cosmos_db_operator
  ]
  create_duration = "60s"
}

resource "azapi_resource" "account_capability_host" {
  type                      = "Microsoft.CognitiveServices/accounts/capabilityHosts@2025-04-01-preview"
  name                      = "${azurerm_cognitive_account.ai_foundry.name}-capHost"
  parent_id                 = azurerm_cognitive_account.ai_foundry.id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind = "Agents"
    }
  }

  timeouts {
    create = "60m"
  }

  depends_on = [
    azurerm_cognitive_account_project.ai_foundry_project,
    azapi_resource.storage_connection,
    azapi_resource.search_connection,
    azapi_resource.cosmos_connection,
    time_sleep.wait_for_rbac
  ]
}

resource "azapi_resource" "project_capability_host" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
  name                      = "${azurerm_cognitive_account_project.ai_foundry_project.name}-capHost"
  parent_id                 = azurerm_cognitive_account_project.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind       = "Agents"
      storageConnections       = [azurerm_storage_account.storage.name]
      vectorStoreConnections   = [azurerm_search_service.search.name]
      threadStorageConnections = [azurerm_cosmosdb_account.cosmos.name]
    }
  }

  timeouts {
    create = "60m"
  }

  depends_on = [azapi_resource.account_capability_host]
}
