variable "region" {
  type        = string
  description = "The region to provision the resources in"
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for connecting OCI API"
}

variable "ssh_public_key2" {
  type        = string
  description = "The SSH public key to input on the .ssh authorized keys inside the VM"
}