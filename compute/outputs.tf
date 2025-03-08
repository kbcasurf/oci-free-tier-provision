output "instance_id" {
  description = "OCID of created instance"
  value       = oci_core_instance.free_instance0.id
}

output "instance_display_name" {
  description = "Display name of created instance"
  value       = oci_core_instance.free_instance0.display_name
}

output "instance_private_ip" {
  description = "Private IP of created instance"
  value       = oci_core_instance.free_instance0.private_ip
}

output "instance_public_ip" {
  description = "Public IP of created instance"
  value       = oci_core_instance.free_instance0.public_ip
}