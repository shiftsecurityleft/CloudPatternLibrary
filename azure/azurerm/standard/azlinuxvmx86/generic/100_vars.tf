# Azure Linux VM Input Variables

variable "resource_group_name" {
  description = "The name of the existing resource group to use, if any"
  type        = string
  default     = null
}

variable "resource_group_prefix" {
  description = "The prefix to use for creating a new resource group, if resource_group_name is not provided"
  type        = string
  default     = null
}

variable "resource_group_location" {
    type = string
    default = "West US 3"
}
variable "vm_size" {
    type = string
    #default = "Standard_E4-2as_v4"
    #default = "Standard_D4ps_v5"
    #default = "Standard_NC24ads_A100_v4"
}

variable "vm_spot_bid_max_price" {
    type = string
    default = "0.89"
}
variable "vm_source_image" {
    type = string
    #default = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
}

variable "vm_admin_username" {
    type = string
    default = "adminuser"
}

variable "personal_ip_address" {
    type = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM admin user"
  type        = string
}


variable "image_reference" {
  description = "The reference for the AzureRM platform image"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

}

variable "custom_user_data_path" {
  description = "Path to custom user data file. If not provided or the file does not exist, default user data will be used."
  type        = string
  default     = ""
}

