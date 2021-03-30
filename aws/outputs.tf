output "public_ip" {
  value = aws_instance.kbn_vm.public_ip
}

output "kibana_url" {
  value       = "http://${aws_instance.kbn_vm.*.public_dns[0]}:${var.kibana_server_port}"
  description = "Please allow a few minutes for the Kibana server to start and the optimizer to run."
}

output "ssh_access" {
  value = "ssh ${var.aws_ec2_admin_username}@${aws_instance.kbn_vm.public_ip}"
}
