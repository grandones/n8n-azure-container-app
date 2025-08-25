module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azurerm_resource_group" "this" {
  count    = var.resource_group_name == null ? 1 : 0
  location = var.location
  name     = module.naming.resource_group.name_unique
}

data "azurerm_client_config" "current" {
  # This data source is used to get the current Azure client configuration
}

data "azurerm_resource_group" "existing" {
  count = var.resource_group_name != null ? 1 : 0
  name  = var.resource_group_name
}

locals {
  resource_group_name     = try(data.azurerm_resource_group.existing[0].name, azurerm_resource_group.this[0].name)
  resource_group_location = try(data.azurerm_resource_group.existing[0].location, azurerm_resource_group.this[0].location)
}

resource "azurerm_user_assigned_identity" "this" {
  location            = local.resource_group_location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = local.resource_group_name
}
