resource "azurerm_container_app_environment" "this" {
  location            = local.resource_group_location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = local.resource_group_name
}

resource "azurerm_container_app_environment_storage" "this" {
  name                         = "n8nconfig"
  access_key                   = module.storage.resource.primary_access_key
  access_mode                  = "ReadWrite"
  account_name                 = module.storage.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  share_name                   = "n8nconfig"
}

module "container_app_n8n" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.4.0"

  name                                  = "${module.naming.container_app.name_unique}-n8n"
  resource_group_name                   = local.resource_group_name
  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  enable_telemetry                      = var.enable_telemetry
  revision_mode                         = "Single"
  tags                                  = var.tags

  template = {
    containers = [
      {
        name   = "n8n"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "docker.io/n8nio/n8n:latest"

        env = [
          {
            name  = "DB_TYPE"
            value = "postgresdb"
          },
          {
            name  = "DB_POSTGRESDB_HOST"
            value = module.postgresql.fqdn
          },
          {
            name  = "DB_POSTGRESDB_PORT"
            value = "5432"
          },
          {
            name  = "DB_POSTGRESDB_DATABASE"
            value = "n8n"
          },
          {
            name  = "DB_POSTGRESDB_USER"
            value = "psqladmin"
          },
          {
            name        = "DB_POSTGRESDB_PASSWORD"
            secret_name = "dbpassword"
          },
          {
            name  = "N8N_PROTOCOL"
            value = "http"
          },
          {
            name  = "N8N_PORT"
            value = "5678"
          },
          {
            name  = "N8N_RUNNERS_ENABLED"
            value = "true"
          },
          {
            name  = "WEBHOOK_URL"
            value = "https://${module.naming.container_app.name_unique}-n8n.${azurerm_container_app_environment.this.default_domain}"
          },
          {
            name  = "DB_POSTGRESDB_SSL_ENABLED"
            value = "true"
          },
          {
            name  = "AZURE_CLIENT_ID"
            value = azurerm_user_assigned_identity.this.client_id
          },
          {
            name  = "AZURE_TENANT_ID"
            value = data.azurerm_client_config.current.tenant_id
          },
          {
            name  = "APPSETTING_WEBSITE_SITE_NAME"
            value = "azcli-workaround"
          },
          {
            name  = "GENERIC_TIMEZONE"
            value = "Europe/Brussels"
          },
          {
            name  = "TZ"
            value = "Europe/Brussels"
          }
        ]

        volume_mounts = [
          {
            name = "n8nconfig"
            path = "/home/node/.n8n"
          }
        ]
      }
    ]

    volumes = [
      {
        name         = "n8nconfig"
        storage_type = "AzureFile"
        storage_name = azurerm_container_app_environment_storage.this.name
        #mount_options = "dir_mode=0600,file_mode=0600,uid=1000,gid=1000"
      }
    ]
  }

  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  ingress = {
    allow_insecure_connections = false
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 5678
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }

  secrets = {
    db_password = {
      name                = "dbpassword"
      key_vault_secret_id = module.key_vault.secrets_resource_ids["psqladmin-password"].id
      identity            = azurerm_user_assigned_identity.this.id
    }
  }
}

module "container_app_mcp" {
  count = var.deploy_mcp ? 1 : 0

  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.4.0"

  name                                  = "${module.naming.container_app.name_unique}-mcp"
  resource_group_name                   = local.resource_group_name
  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  enable_telemetry                      = var.enable_telemetry
  revision_mode                         = "Single"
  tags                                  = var.tags

  template = {
    containers = [
      {
        name   = "mcp-server"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "docker.io/mcp/azure:latest"

        env = [
          {
            name  = "AZMCP_TRANSPORT"
            value = "sse"
          },
          {
            name  = "AZURE_MCP_INCLUDE_PRODUCTION_CREDENTIALS"
            value = "true"
          },
          {
            name  = "AZURE_TENANT_ID"
            value = data.azurerm_client_config.current.tenant_id
          },
          {
            name  = "AZURE_CLIENT_ID"
            value = azurerm_user_assigned_identity.this.client_id
          }
        ]
      },
      {
        name   = "nginx"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "nginx:latest"

        # When running the MCP node behind a reverse proxy like nginx, it is necessary  
        # to disable proxy buffering for the MCP endpoint to ensure proper handling 
        # of Server-Sent Events (SSE). Additional recommendations include disabling 
        # gzip compression, chunked transfer encoding, and removing the Connection 
        # header to avoid conflicts with inherited nginx configurations.
        # 
        # https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/#running-the-mcp-server-trigger-node-with-a-reverse-proxy
        #

        command = [
          "sh", "-c",
          <<EOT
echo "server {
  listen 80;
  location / {
    proxy_http_version          1.1;
    proxy_buffering             off;
    gzip                        off;
    chunked_transfer_encoding   off;

    proxy_set_header            Connection '';

    proxy_pass http://localhost:5008;
  }
}" > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
EOT
        ]
      }
    ]
  }

  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  ingress = {
    allow_insecure_connections = false
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 80
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }
}