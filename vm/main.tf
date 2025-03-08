terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
}

provider "oci" {
  region = var.region
  private_key_path = var.ssh_public_key  # .pem file for authentication on OCI Cloud

}
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate" 
  }
}

# Ubuntu ARM64 Image Data Source
data "oci_core_images" "ubuntu_arm64" {
  compartment_id           = data.terraform_remote_state.infra.outputs.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal aarch64"
  shape                    = "VM.Standard.A1.Flex"
}

# Compute Instance
resource "oci_core_instance" "SRV1" {
  compartment_id      = data.terraform_remote_state.infra.outputs.compartment_id
  availability_domain = data.terraform_remote_state.infra.outputs.availability_domain_name
  display_name        = "SRV1"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
    }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm64.images[0].id
    boot_volume_size_in_gbs = 200
  }

  create_vnic_details {
    subnet_id        = data.terraform_remote_state.infra.outputs.public_subnet_id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key2  # .pub file to insert in .ssh Authorized Keys file and SSH access
  }
}
