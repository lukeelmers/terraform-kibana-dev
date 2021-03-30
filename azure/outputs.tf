output "public_ip" {
  value = azurerm_linux_virtual_machine.kbn_vm.public_ip_address
}

output "kibana_url" {
  value       = "http://${azurerm_public_ip.kbn_ip.fqdn}:${var.kibana_server_port}"
  description = "Please allow a few minutes for the Kibana server to start and the optimizer to run."
}

output "ssh_access" {
  value = "ssh ${var.azure_vm_admin_username}@${azurerm_linux_virtual_machine.kbn_vm.public_ip_address}"
}
