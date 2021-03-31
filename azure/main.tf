terraform {
  required_version = ">= 0.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.52.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  features {}
}

resource "azurerm_resource_group" "kbn_rg" {
  name     = "kbn_rg"
  location = var.azure_region
}

resource "azurerm_linux_virtual_machine" "kbn_vm" {
  name                = "kbn_vm"
  resource_group_name = azurerm_resource_group.kbn_rg.name
  location            = var.azure_region
  size                = var.azure_vm_size

  computer_name  = "kbn"
  admin_username = var.azure_vm_admin_username

  network_interface_ids = [
    azurerm_network_interface.kbn_ni.id
  ]

  admin_ssh_key {
    username   = var.azure_vm_admin_username
    public_key = file(var.public_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 100
  }

  provisioner "file" {
    source      = "../bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "file" {
    source      = "../kibana.dev.yml"
    destination = "/tmp/kibana.dev.yml"
  }

  # Change permissions on bash script and execute from azure-user.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install build-essential -y",
      "chmod +x /tmp/bootstrap.sh",
      "nohup /tmp/bootstrap.sh ${var.kibana_repo_url} ${var.kibana_repo_branch}",
    ]
  }

  # Login to the azure-user with the private key.
  connection {
    type        = "ssh"
    user        = var.azure_vm_admin_username
    password    = ""
    private_key = file(var.private_key_path)
    host        = self.public_ip_address
  }
}
