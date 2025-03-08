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
  private_key_path = var.ssh_public_key  # .pem file
}

# VCN Module
module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region

  vcn_name      = "swarm-vcn"
  vcn_dns_label = "swarmvcn"
  vcn_cidrs     = ["10.0.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}

# Security List
resource "oci_core_security_list" "public_subnet_swarm" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "swarm-public-subnet"

  # Ingress Rules
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    description = "SSH"
    tcp_options { 
      max = 22 
      min = 22 
      }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP"
    tcp_options { 
      max = 80 
      min = 80 
      }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS"
    tcp_options { 
      max = 443       
      min = 443 
      }
  }

  # Egress Rule
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Public Subnet
resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = "10.0.0.0/24"
  display_name      = "swarm-public-subnet"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public_subnet_swarm.id]
  dns_label                  = "swarmpublic" 
  prohibit_public_ip_on_vnic = false 
}

# Availability Domains Data Source
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}