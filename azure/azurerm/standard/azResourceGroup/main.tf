# Create a resource group

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_prefix}-rg"
  location = "${var.resource_group_location}"
}

# Output variable for the resource group name
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}