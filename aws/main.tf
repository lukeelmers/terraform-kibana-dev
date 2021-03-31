terraform {
  required_version = ">= 0.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=3.33.0"
    }
  }
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_shared_credentials_file
  profile                 = var.aws_profile
}

resource "aws_key_pair" "kbn_keypair" {
  public_key = file(var.public_key_path)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "kbn_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.kbn_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.kbn_sg.id]
  subnet_id                   = aws_subnet.kbn_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
  }

  provisioner "file" {
    source      = "../bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "file" {
    source      = "../kibana.dev.yml"
    destination = "/tmp/kibana.dev.yml"
  }

  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install build-essential -y",
      "chmod +x /tmp/bootstrap.sh",
      "nohup /tmp/bootstrap.sh ${var.kibana_repo_url} ${var.kibana_repo_branch}",
    ]
  }

  # Login to the ec2-user with the private key.
  connection {
    type        = "ssh"
    user        = var.aws_ec2_admin_username
    password    = ""
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}
