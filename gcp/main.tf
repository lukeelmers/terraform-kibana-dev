terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=3.61.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = file(var.gcp_credentials_file)
}

resource "google_compute_instance" "kbn_vm" {
  name         = var.gcp_name
  machine_type = var.gcp_instance_type

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      size  = 100
    }
  }

  metadata = {
    ssh-keys = "${var.gcp_vm_admin_username}:${file(var.public_key_path)}"
  }

  # For unknown reasons, this needs to be run in `metadata_startup_script` instead of via
  # the `remote-exec` provisioner in order for GCP to succcessfully install build-essential.
  metadata_startup_script = "sudo apt-get update; sudo apt-get install build-essential jq -y"

  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }

  # Apply firewall rules via tags
  tags = ["kbn-server"]

  provisioner "file" {
    source      = "../scripts/"
    destination = "/tmp/"
  }

  # Change permissions on bash script and execute from ubuntu user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/install.sh ${var.kibana_repo_url} ${var.kibana_repo_branch} && /tmp/bootstrap.sh && /tmp/start.sh && /tmp/check_server_online.sh ",
    ]
  }

  # Login to the ubuntu user with the private key.
  connection {
    type        = "ssh"
    user        = var.gcp_vm_admin_username
    password    = ""
    private_key = file(var.private_key_path)
    host        = google_compute_instance.kbn_vm.network_interface.0.access_config.0.nat_ip
  }
}
