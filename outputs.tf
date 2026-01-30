output "instance_id" {
  description = "The ID of the Linode instance"
  value       = linode_instance.openclaw.id
}

output "instance_label" {
  description = "The label of the Linode instance"
  value       = linode_instance.openclaw.label
}

output "instance_ip" {
  description = "The public IP address of the Linode instance"
  value       = tolist(linode_instance.openclaw.ipv4)[0]
}

output "instance_ipv6" {
  description = "The IPv6 address of the Linode instance"
  value       = linode_instance.openclaw.ipv6
}

output "ssh_command" {
  description = "SSH command to connect as openclaw user"
  value       = "ssh openclaw@${tolist(linode_instance.openclaw.ipv4)[0]}"
}

output "root_password" {
  description = "The root password for the VM (auto-generated if not specified)"
  value       = var.root_password != "" ? var.root_password : random_password.root_password[0].result
  sensitive   = true
}

output "firewall_id" {
  description = "The ID of the created firewall"
  value       = linode_firewall.openclaw_firewall.id
}

output "firewall_label" {
  description = "The label of the created firewall"
  value       = linode_firewall.openclaw_firewall.label
}
