module "myRG" {
  source = "git::https://github.com/shiftsecurityleft/CloudPatternLibrary.git//azure/azurerm/standard/azResourceGroup"
  resource_group_location = var.az_default_region
  resource_group_prefix =  var.app_symbol

}

data "azurerm_platform_image" "example" {
  location  = "West US 3"
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
}

output "id" {
  value = data.azurerm_platform_image.example.id
}


module "os_images" {
  source = "git::https://github.com/shiftsecurityleft/CloudPatternLibrary.git//azure/azurerm/standard/azOsImages"
  os_type = "ubuntu"  # Change to "windows" or "redhat" as needed
}

module "azlinuxvm" {
  source = "git::https://github.com/shiftsecurityleft/CloudPatternLibrary.git//azure/azurerm/standard/azlinuxvmx86/generic"
  resource_group_name = module.myRG.resource_group_name
  #resource_group_prefix = "example" #Optional
  custom_user_data_path = "${path.root}/userdata.config/userdata_default_x86_docker.tmpl"
  resource_group_location = var.az_default_region
  vm_size = "Standard_D2s_v3"
  vm_spot_bid_max_price  = "0.02"
  vm_source_image = "${data.azurerm_platform_image.example.id}"
  image_reference = module.os_images.image_reference
  vm_admin_username = "adminuser"
  personal_ip_address = var.my_public_ip
  ssh_public_key = var.ssh_public_key
  depends_on = [ module.myRG, module.os_images ]
}

