output "public_subnet_id" {
  value = oci_core_subnet.vcn_public_subnet.id
}

output "security_list_id" {
  value = oci_core_security_list.public_subnet_swarm.id
}

output "availability_domain_name" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "compartment_id" {
  value = var.compartment_id
}