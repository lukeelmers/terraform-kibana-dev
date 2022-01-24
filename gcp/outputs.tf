output "public_ip" {
  value = google_compute_instance.kbn_vm.network_interface.0.access_config.0.nat_ip
}

output "kibana_url" {
  value       = "http://${google_compute_instance.kbn_vm.network_interface.0.access_config.0.nat_ip}:${var.kibana_server_port}"
  description = "Please allow a few minutes for the Kibana server to start and the optimizer to run."
}

output "kibana_elastic_password" {
  value       = local.kibana_used_elastic_password
  description = "Password of elastic user"
  sensitive = true
}

output "ssh_access" {
  value = "ssh ${var.gcp_vm_admin_username}@${google_compute_instance.kbn_vm.network_interface.0.access_config.0.nat_ip}"
}
