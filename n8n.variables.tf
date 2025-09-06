variable "n8n_published_port" {
  description = "Published port on the Synology host for n8n web UI"
  type        = number
  default     = 5678
}

variable "n8n_host" {
  description = "Host/IP that n8n should bind to (passed to the container as N8N_HOST)"
  type        = string
  default     = "0.0.0.0"
}

variable "n8n_webhook_url" {
  description = "Public URL for n8n webhooks"
  type        = string
  sensitive   = true
  default     = "localhost:5678"
}

variable "n8n_encryption_key" {
  description = "Encryption key for n8n sensitive data"
  type        = string
  sensitive   = true
  default     = "my-32-character-random-string"
}

variable "n8n_postgres_db" {
  description = "PostgreSQL database name for n8n"
  type        = string
  sensitive   = true
  default     = "n8n-db-name"
}

variable "n8n_postgres_user" {
  description = "PostgreSQL username for n8n"
  type        = string
  sensitive   = true
  default     = "n8n-db-user"
}

variable "n8n_postgres_password" {
  description = "PostgreSQL password for n8n"
  type        = string
  sensitive   = true
  default     = "n8n-db-password"
}
