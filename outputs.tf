output "jumphost-group-info" {
  value       = data.google_compute_instance_group.jumphosts
  description = "jumphost group"
}

output "jumphost" {
  value       = data.google_compute_instance.jumphost
  description = "jumphost"
}
