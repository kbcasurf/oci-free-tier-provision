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
}

data "oci_identity_availability_domains" "swarm_provision" {
  compartment_id = var.tenancy_ocid
}

resource "random_shuffle" "swarm_provision" {
  input = data.oci_identity_availability_domains.swarm_provision.availability_domains[*].name

  result_count = 1
}

resource "oci_core_instance" "ubuntu" {
  count = 2

  availability_domain = one(
    [
      for m in data.oci_core_shapes.swarm_provision :
      m.availability_domain
      if contains(m.shapes[*].name, local.instance.ubuntu.shape)
    ]
  )
  compartment_id = oci_identity_compartment.swarm_provision.id
  shape          = local.instance.ubuntu.shape

  display_name         = "Ubuntu ${count.index + 1}"
  preserve_boot_volume = false

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.swarm_provision["ubuntu"].rendered
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  create_vnic_details {
    display_name   = "Ubuntu ${count.index + 1}"
    hostname_label = "ubuntu-${count.index + 1}"
    nsg_ids        = [oci_core_network_security_group.swarm_provision.id]
    subnet_id      = oci_core_subnet.swarm_provision.id
  }

  source_details {
    source_id               = data.oci_core_images.swarm_provision["ubuntu"].images.0.id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
  }

  lifecycle {
    ignore_changes = [source_details.0.source_id]
  }
}

data "oci_core_private_ips" "swarm_provision" {
  ip_address = oci_core_instance.oracle.private_ip
  subnet_id  = oci_core_subnet.swarm_provision.id
}

resource "oci_core_public_ip" "swarm_provision" {
  compartment_id = oci_identity_compartment.swarm_provision.id
  lifetime       = "RESERVED"

  display_name  = oci_core_instance.oracle.display_name
  private_ip_id = data.oci_core_private_ips.swarm_provision.private_ips.0.id
}
