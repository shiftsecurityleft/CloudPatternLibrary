
# Create a resource group

locals {
  use_existing_resource_group = var.resource_group_name != null
  resource_group_name         = local.use_existing_resource_group ? var.resource_group_name : "${var.resource_group_prefix}-rg"
  custom_user_data_provided = var.custom_user_data_path != "" && var.custom_user_data_path != null
  custom_user_data_file_exists = local.custom_user_data_provided ? fileexists(var.custom_user_data_path) : false
  
  user_data_path = local.custom_user_data_file_exists ? var.custom_user_data_path : "${path.module}/userdata.config/userdata_default_x86.tmpl"
}

data "azurerm_resource_group" "existing" {
  count = local.use_existing_resource_group ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "this" {
  count    = local.use_existing_resource_group ? 0 : 1
  name     = local.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "this" {
  name                = "${local.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  resource_group_name = local.resource_group_name

}

resource "azurerm_subnet" "this" {
  name                 = "${local.resource_group_name}-internal"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "this" {
  name                = "${local.resource_group_name}-pip"
  location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  #location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing.location : azurerm_resource_group.this.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "this" {
  name                = "${local.resource_group_name}-nic"
  location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  #location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing.location : azurerm_resource_group.this.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "${local.resource_group_name}-internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_security_group" "this" {
  name                = "${local.resource_group_name}-nsg"
  location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  #location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing.location : azurerm_resource_group.this.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_security_rule" "this" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.personal_ip_address
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = local.resource_group_name
}


resource "azurerm_network_security_rule" "xpra" {
  name                        = "xpra"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10000"
  source_address_prefix       = var.personal_ip_address
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = local.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "${local.resource_group_name}-personal"
  resource_group_name = local.resource_group_name
  location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  #location            = local.use_existing_resource_group ? data.azurerm_resource_group.existing.location : azurerm_resource_group.this.location
  size                = "${var.vm_size}"
  #user_data = base64encode(file("${path.root}/userdata.config/userdata_default_x86.tmpl"))
  user_data = base64encode(file(local.user_data_path))
  priority            = "Spot"
  eviction_policy     = "Deallocate"
  admin_username      = "${var.vm_admin_username}"
  max_bid_price       = "${var.vm_spot_bid_max_price}"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 250
  }
  source_image_reference {
    publisher = var.image_reference["publisher"]
    offer     = var.image_reference["offer"]
    sku       = var.image_reference["sku"]
    version   = var.image_reference["version"]
  }


}