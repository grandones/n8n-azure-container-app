variable "location" {
  type        = string
  default     = "eastu2"
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
  nullable    = false
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Custom tags to apply to the resource."
}
