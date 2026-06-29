locals {
  environment_map = {
    "dev"     = "dev"
    "default" = "dev"
  }

  owner                = lower(var.network_identity.owner)
  workspace            = lower(var.network_identity.workspace)
  iteration            = format("%02d", var.network_identity.iteration)
  environment          = local.environment_map[terraform.workspace]
  name_suffix          = "${local.environment}${local.iteration}"
  account_name         = "${substr("${local.owner}-foundry-${local.workspace}-account", 0, 58)}-${local.name_suffix}"
  project_name         = "${substr("${local.owner}-foundry-${local.workspace}-project", 0, 58)}-${local.name_suffix}"
  cosmos_account_name  = "${substr("${local.owner}-${local.workspace}-cosmosdb", 0, 58)}-${local.name_suffix}"
  ai_search_name       = "${substr("${local.owner}-${local.workspace}-aisearch", 0, 58)}-${local.name_suffix}"
  storage_account_name = substr("${local.owner}${local.workspace}blob${local.name_suffix}", 0, 24)
}
