variable "os_type" {
  description = "The type of OS to use for the virtual machine"
  type        = string
  validation {
    condition     = contains(["windows", "ubuntu", "redhat"], var.os_type)
    error_message = "os_type must be one of 'windows', 'ubuntu', or 'redhat'."
  }
}
