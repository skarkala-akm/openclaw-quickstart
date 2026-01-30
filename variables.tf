variable "linode_token" {
  description = "Linode API Personal Access Token"
  type        = string
  sensitive   = true
}

variable "instance_label" {
  description = "The label for the Linode instance"
  type        = string
  default     = "openclaw-vm"
}

variable "region" {
  description = "The Linode region to deploy to"
  type        = string
  default     = "us-ord"
}

variable "instance_type" {
  description = "The Linode instance type/plan"
  type        = string
  default     = "g6-nanode-1"
}

variable "disk_size" {
  description = "Size of the boot disk in MB"
  type        = number
  default     = 25088
}

variable "root_password" {
  description = "Root password for the VM. If not provided, a random password will be generated."
  type        = string
  sensitive   = true
  default     = ""
}

variable "public_key_path" {
  description = "Path to the SSH public key file for key-based authentication"
  type        = string
}

variable "private_key_path" {
  description = "Path to the SSH private key file for provisioning (used for automated reboot)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to Linode resources"
  type        = list(string)
  default     = ["openclaw", "production"]
}
