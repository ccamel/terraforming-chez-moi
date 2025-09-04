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
