output "instance_id" {
  value = oci_core_instance.SRV1.id
}

output "instance_display_name" {
  value = oci_core_instance.SRV1.display_name
}

output "instance_public_ip" {
  value = oci_core_instance.SRV1.public_ip
}

output "instance_private_ip" {
  value = oci_core_instance.SRV1.private_ip
}