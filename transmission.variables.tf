variable "transmission_downloads_path" {
  description = "Path used for Transmission downloads"
  type        = string
}

variable "transmission_image" {
  description = "Transmission Docker image"
  type        = string
  default     = "lscr.io/linuxserver/transmission:4.0.6-r0-ls248"
}

variable "transmission_username" {
  description = "Username required by the Transmission RPC interface"
  type        = string
  sensitive   = true
}

variable "transmission_password" {
  description = "Password required by the Transmission RPC interface"
  type        = string
  sensitive   = true
}
