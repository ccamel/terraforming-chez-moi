variable "dsm_host" {
  description = "The hostname of my Synology DSM instance"
  type        = string
  sensitive   = true
}

variable "dsm_user" {
  description = "DSM username"
  type        = string
  sensitive   = true
}

variable "dsm_password" {
  description = "DSM password"
  type        = string
  sensitive   = true
}

variable "dsm_volume_projects" {
  description = "Root path for projects volume on DSM"
  default     = "/projects"
  sensitive   = false
}

variable "deploy_ssh_host" {
  description = "SSH host used by Ansible to apply rendered Compose stacks on the Synology NAS"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "deploy_ssh_user" {
  description = "SSH user used by Ansible to apply rendered Compose stacks on the Synology NAS"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "deploy_ssh_port" {
  description = "SSH port used by Ansible to apply rendered Compose stacks on the Synology NAS"
  type        = number
  default     = 22
}

variable "deploy_ssh_private_key_path" {
  description = "Path to the SSH private key used by Ansible to reach the Synology NAS"
  type        = string
}

variable "deploy_ssh_strict_host_key_checking" {
  description = "Whether Ansible should enforce SSH host key checking when deploying Compose stacks"
  type        = bool
  default     = false
}
