variable "postgres_user" {
  description = "Username for the PostgreSQL service"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "Password for the PostgreSQL service"
  type        = string
  sensitive   = true
}

variable "adminer_published_port" {
  description = "Published port on the Synology host for Adminer web UI"
  type        = number
  default     = 8081
}
