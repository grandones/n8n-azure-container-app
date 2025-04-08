module "openai" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "0.7.0"

  location            = azurerm_resource_group.this.location
  name                = module.naming.cognitive_account.name_unique
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  kind                = "OpenAI"
  sku_name            = "S0"
  tags                = var.tags

  cognitive_deployments = {
    "gpt-4o-mini" = {
      name = "gpt-4o-mini"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o-mini"
        version = "2024-07-18"
      }
      scale = {
        type     = "GlobalStandard"
        capacity = 8
      }
    }
  }

}