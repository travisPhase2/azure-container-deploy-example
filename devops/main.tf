resource "random_pet" "rg_name" {
    prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
    name = random_pet.rg_name.id
    location = var.resource_group_location
}

resource "azurerm_user_assigned_identity" "container_identity" {
    name = "container-app-identity"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

resource "azurerm_container_registry" "acr" {
    name                = "travcontainerregistry"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Basic"
    admin_enabled       = false
}

resource "azurerm_role_assignment" "acr_pull" {
    scope                = azurerm_container_registry.acr.id
    role_definition_name = "AcrPull"
    principal_id         = azurerm_user_assigned_identity.deployment_identity.principal_id
}

resource "azurerm_user_assigned_identity" "deployment_identity" {
    name                = "deployment-identity"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "trav-analytics-ws"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "trav-container-app-env"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "example" {
  name                         = "trav-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "trav-container-app"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}