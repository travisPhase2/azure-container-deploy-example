# resource "azurerm_resource_provider_registration" "app" {
#     name = "Microsoft.App"
# }

resource "azurerm_resource_group" "rg" {
  name     = "Compellier"
  location = var.resource_group_location
}

# logging analytics workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "Compellier-LAW"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# container registry
resource "azurerm_container_registry" "cr" {
  name                = "CompellierContainerRegistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.cr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_registry.cr.identity[0].principal_id
}

resource "azurerm_container_app_environment" "cae" {
  name                       = "Compellier-CAE"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "ca" {
  name                         = "containerapp"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      # 100% of traffic to the latest revision of container
      percentage      = 100
      latest_revision = true
    }
  }

  # required for the container app to pull from the container registry
  identity {
    type = "SystemAssigned"
  }
}
