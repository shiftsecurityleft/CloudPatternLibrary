locals {
  image_references = {
    windows = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-azure-edition"
      version   = "latest"
    }
    ubuntu = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
    redhat = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "7.7"
      version   = "latest"
    }
  }
}

output "image_reference" {
  value = local.image_references[var.os_type]
}
