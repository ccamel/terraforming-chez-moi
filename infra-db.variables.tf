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
