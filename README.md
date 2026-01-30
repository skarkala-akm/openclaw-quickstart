# Moltbot Linode VM Terraform Setup

This Terraform configuration creates a Linode VM with security hardening and automated setup for moltbot/clawdbot.

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed
2. Linode account with API token
3. SSH key pair generated

## Setup

1. **Generate SSH keys** (if you don't have them):
   ```bash
   ssh-keygen -t ed25519 -C "moltbot@example.com" -f ~/.ssh/moltbot
   ```

2. **Set your Linode API token**:
   ```bash
   export LINODE_TOKEN="your-linode-api-token"
   ```

3. **Create a `terraform.tfvars` file**:
   ```hcl
   linode_token     = "your-linode-api-token"
   public_key_path  = "~/.ssh/moltbot.pub"
   allowed_ssh_cidrs = ["YOUR_IP/32"]  # Replace with your IP
   region           = "us-east"  # or your preferred region
   instance_type    = "g6-nanode-1"  # or your preferred plan
   ```

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# View outputs (including generated root password)
terraform output -json

# SSH as moltbot user
ssh moltbot@$(terraform output -raw instance_ip)
```

## Notes

- The firewall allows SSH only from the specified CIDR blocks
- Password authentication is disabled via cloud-init
- Root login is restricted to key-based auth only
- The `moltbot` user has passwordless sudo access

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `linode_token` | Linode API token | Required |
| `public_key_path` | Path to SSH public key | Required |
| `allowed_ssh_cidrs` | CIDR blocks for SSH access | `["0.0.0.0/0"]` |
| `instance_label` | VM label | `"moltbot-vm"` |
| `region` | Linode region | `"us-east"` |
| `instance_type` | VM plan | `"g6-nanode-1"` |
| `root_password` | Root password (auto-generated if empty) | `""` |

## Outputs
| Output | Description |
|--------|-------------|
| `instance_ip` | Public IP of the VM |
| `ssh_command` | SSH command to connect |
| `root_password` | Root password (sensitive) |
| `firewall_id` | Firewall ID |


## Moltbot configuration
Moltbot (Clawdbot) is installed and ready to use out-of-the-box on the VM. 

SSH to the VM as `moltbot` user

```bash
ssh moltbot@$VMIP
```
and run 

```bash
clawdbot onboard --install-daemon
```

to begin the onboarding process - follow [upstream docs](https://docs.molt.bot/start/getting-started)
