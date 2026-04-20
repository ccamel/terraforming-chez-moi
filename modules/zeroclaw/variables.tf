variable "instance_name" {
  description = "Instance suffix used to distinguish this ZeroClaw deployment"
  type        = string
}

variable "projects_root" {
  description = "Root path for projects volume on DSM"
  type        = string
}

variable "published_port" {
  description = "Published port on the Synology host for the ZeroClaw gateway"
  type        = number
}

variable "image" {
  description = "ZeroClaw runtime image"
  type        = string
}

variable "project_prefix" {
  description = "Prefix used for ZeroClaw DSM project names"
  type        = string
  default     = "zeroclaw"
}

variable "edge_network_name" {
  description = "Existing external Docker network used to expose the ZeroClaw gateway"
  type        = string
  default     = "edge"
}

variable "deploy_ssh_host" {
  description = "SSH host used by Ansible to apply rendered Compose stacks"
  type        = string
}

variable "deploy_ssh_user" {
  description = "SSH user used by Ansible to apply rendered Compose stacks"
  type        = string
}

variable "deploy_ssh_port" {
  description = "SSH port used by Ansible to apply rendered Compose stacks"
  type        = number
  default     = 22
}

variable "deploy_ssh_private_key_path" {
  description = "Path to the SSH private key used by Ansible to reach the remote host"
  type        = string
}

variable "deploy_ssh_strict_host_key_checking" {
  description = "Whether SSH host key checking should remain enabled during Ansible runs"
  type        = bool
  default     = false
}
