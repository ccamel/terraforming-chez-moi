variable "stack_name" {
  description = "Logical stack name used for deployment metadata"
  type        = string
}

variable "project_name" {
  description = "Docker Compose project name. Defaults to stack_name when omitted."
  type        = string
  default     = null
  nullable    = true
}

variable "remote_dir" {
  description = "Absolute directory on the remote host where compose.yaml and related files are stored"
  type        = string
}

variable "ssh_host" {
  description = "SSH host used by Ansible to apply the Compose stack"
  type        = string
}

variable "ssh_user" {
  description = "SSH user used by Ansible to apply the Compose stack"
  type        = string
}

variable "ssh_port" {
  description = "SSH port used by Ansible to apply the Compose stack"
  type        = number
  default     = 22
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key used by Ansible to reach the remote host"
  type        = string
}

variable "ssh_strict_host_key_checking" {
  description = "Whether SSH host key checking should remain enabled during Ansible runs"
  type        = bool
  default     = false
}

variable "compose_yaml" {
  description = "Rendered compose.yaml content for the stack"
  type        = string
}

variable "external_networks" {
  description = "Docker networks that must exist before applying the Compose stack"
  type = list(object({
    name     = string
    internal = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "env_file" {
  description = "Rendered .env content for the stack"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "extra_files" {
  description = "Additional files written next to compose.yaml before applying the stack"
  type = map(object({
    content = string
    mode    = optional(string, "0644")
  }))
  default   = {}
  nullable  = false
  sensitive = true
}
