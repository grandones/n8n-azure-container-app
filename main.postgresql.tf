resource "random_password" "myadminpassword" {
  length           = 16
  override_special = "_%@"
  special          = true
}

module "postgresql" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.1.4"

  location                      = local.resource_group_location
  name                          = module.naming.postgresql_server.name_unique
  resource_group_name           = local.resource_group_name
  administrator_login           = "psqladmin"
  administrator_password        = random_password.myadminpassword.result
  enable_telemetry              = var.enable_telemetry
  high_availability             = null
  public_network_access_enabled = true
  server_version                = 16
  sku_name                      = "B_Standard_B1ms"
  tags                          = var.tags
  zone                          = var.postgres_zone

  databases = {
    n8n = {
      charset   = "UTF8"
      collation = "en_US.utf8"
      name      = "n8n"
    }
  }

  firewall_rules = {
    azure_access = {
      name             = "azure_access"
      end_ip_address   = "0.0.0.0"
      start_ip_address = "0.0.0.0"
    }
  }
}
