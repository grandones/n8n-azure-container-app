module "openai" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "0.7.0"

  location            = local.resource_group_location
  name                = module.naming.cognitive_account.name_unique
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  kind                = "OpenAI"
  sku_name            = "S0"
  tags                = var.tags

  cognitive_deployments = {
    "gpt-5" = {
      name = "gpt-5"
      model = {
        format  = "OpenAI"
        name    = "gpt-5"
        version = "2025-08-07"
      }
      scale = {
        type     = "GlobalStandard"
        capacity = 8
      }
    }
  }

}