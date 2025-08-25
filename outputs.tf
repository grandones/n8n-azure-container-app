output "n8n_fqdn_url" {
  description = "https url that contains ingress's fqdn, could be used to access the n8n app."
  value       = module.container_app_n8n.fqdn_url
}

output "mcp_endpoint_sse" {
  description = "The sse endpoint of the MCP Server"
  value = try("${module.container_app_mcp[0].fqdn_url}/sse", null)
}

output "openai_key_secret_url" {
  description = "https url that contains the openai key secret in the key vault."
  value       = module.key_vault.secrets["openai-key"].versionless_id
}

output "openai_endpoint" {
  description = "The endpoint of the OpenAI deployment."
  value       = module.openai.endpoint
}

output "openai_resource_name" {
  description = "The name of the OpenAI deployment."
  value       = module.openai.resource.custom_subdomain_name
}

output "openai_deployment_name" {
  description = "The name of the OpenAI deployment."
  value       = module.openai.resource_cognitive_deployment["gpt-4o"].name
}

output "openai_api_version" {
  description = "The version of the OpenAI API to n8n credential. See https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation"
  value       = "2024-07-18"
}

