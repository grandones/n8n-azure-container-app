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
    "gpt-4o" = {
      name = "gpt-4o"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-07-18"
      }
      scale = {
        type     = "GlobalStandard"
        capacity = 8
      }
    }
  }

}