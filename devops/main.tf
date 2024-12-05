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

resource "azurerm_container_app_environment" "example" {
    name                = "trav-app-environment"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "example" {
    name                          = "trav-app"
    container_app_environment_id  = azurerm_container_app_environment.example.id
    resource_group_name           = azurerm_resource_group.rg.name
    revision_mode                 = "Single"

    identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.deployment_identity.id]
    }

    ingress {
        external_enabled = true
        target_port     = 8000

        traffic_weight {
            latest_revision = true
            percentage     = 100
        }
    }

    template {
        container {
            name   = "app"
            image  = "${var.image}"
            cpu    = 0.5
            memory = "1Gi"
        }
    }
}
