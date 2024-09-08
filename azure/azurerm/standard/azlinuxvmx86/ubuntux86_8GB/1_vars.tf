/* These are variables that will be read from github actions variables
    and passed to the terraform script
    */
variable "my_public_ip" {
  description = "SSH public key for VM admin user"
  type        = string
}
variable "ssh_public_key" {
  description = "SSH public key for VM admin user"
  type        = string
}

variable "app_symbol" {
  description = "Alphanumeric code that uniquely identifies the application"
  type        = string
}

variable "az_default_region" {
  description = "The default Azure region to deploy resources"
  type        = string
}