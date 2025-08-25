module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  location                      = local.resource_group_location
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = local.resource_group_name
  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  enable_telemetry              = var.enable_telemetry
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  tags                          = var.tags

  network_rules = null

  shares = {
    n8nconfig = {
      name        = "n8nconfig"
      quota       = 2
      access_tier = "Hot"
    }
  }
}
