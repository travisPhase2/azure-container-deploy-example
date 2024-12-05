resource "random_pet" "rg_name" {
    prefix = var.resource_group_name_prefix
}

resource "random_string" "container_name" {
    length = 25
    lower = true
    upper = false
    special = false
}

resource "azurerm_resource_group" "rg" {
    name = random_pet.rg_name.id
    location = var.resource_group_location
}

resource "azurerm_container_registry" "acr" {
    name                = "trav-container-registry"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Basic"
    admin_enabled       = true
}

resource "azurerm_container_group" "container" {
    name = "${var.container_group_name_prefix}-${random_string.container_name.result}"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_address_type = "Public"
    os_type = "Linux"
    restart_policy = var.restart_policy

    container {
        name = "${var.container_name_prefix}${random_string.container_name.result}"
        image = "${azurerm_container_registry.acr.login_server}/${var.image}"
        cpu = var.cpu_cores
        memory = var.memory_in_gb

        ports {
          port = var.port
          protocol = "TCP"
        }
    }
}