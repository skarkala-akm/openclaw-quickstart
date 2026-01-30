terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "linode" {
  token = var.linode_token
}

resource "random_password" "root_password" {
  count   = var.root_password == "" ? 1 : 0
  length  = 24
  special = true
}

data "local_file" "public_key" {
  filename = var.public_key_path
}

locals {
  root_pass = var.root_password != "" ? var.root_password : random_password.root_password[0].result
  cloud_init_rendered = templatefile("${path.module}/cloud-init.yaml", {
    public_key = trimspace(data.local_file.public_key.content)
  })
}

resource "linode_instance" "openclaw" {
  label  = var.instance_label
  region = var.region
  type   = var.instance_type
  tags   = var.tags

  metadata {
    user_data = base64encode(local.cloud_init_rendered)
  }
}

resource "linode_instance_disk" "boot" {
  linode_id       = linode_instance.openclaw.id
  label           = "boot"
  size            = var.disk_size
  image           = "linode/ubuntu24.04"
  authorized_keys = [trimspace(data.local_file.public_key.content)]
  root_pass       = local.root_pass
}

resource "linode_instance_disk" "swap" {
  linode_id  = linode_instance.openclaw.id
  label      = "swap"
  size       = 512
  filesystem = "swap"
}

resource "linode_instance_config" "boot_config" {
  linode_id = linode_instance.openclaw.id
  label     = "boot_config"
  kernel    = "linode/grub2"
  booted    = true

  device {
    device_name = "sda"
    disk_id     = linode_instance_disk.boot.id
  }

  device {
    device_name = "sdb"
    disk_id     = linode_instance_disk.swap.id
  }

  root_device = "/dev/sda"
}

resource "null_resource" "reboot" {
  triggers = {
    instance_id = linode_instance.openclaw.id
  }

  depends_on = [linode_instance_config.boot_config]

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo reboot"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      host        = tolist(linode_instance.openclaw.ipv4)[0]
      private_key = var.private_key_path != "" ? file(var.private_key_path) : null
      agent       = var.private_key_path == "" ? true : false
    }
  }
}

resource "linode_firewall" "openclaw_firewall" {
  label = "${var.instance_label}-firewall"
  tags  = var.tags

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.allowed_ssh_cidrs
  }

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound_policy = "ACCEPT"
  inbound_policy  = "DROP"

  linodes = [linode_instance.openclaw.id]
}
