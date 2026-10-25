variable "transmission_downloads_path" {
  description = "Path used for Transmission downloads"
  type        = string
}

variable "transmission_image" {
  description = "Transmission image with the SMTP completion-notification hook"
  type        = string
  default     = "ghcr.io/ccamel/transmission-mail:4.0.6-r0-ls248"
}

variable "transmission_vpn_image" {
  description = "VPN gateway image routing Transmission through WireGuard"
  type        = string
  default     = "qmcgaw/gluetun@sha256:c2ee4191762fca6b6a3c3359a731198a95d9c9af4db32d466e223bf3a84e779b"
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

variable "transmission_vpn_service_provider" {
  description = "Gluetun VPN service provider identifier"
  type        = string
  sensitive   = true
}

variable "transmission_wireguard_private_key" {
  description = "WireGuard private key"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9+/]{43}=$", var.transmission_wireguard_private_key))
    error_message = "transmission_wireguard_private_key must be a base64 WireGuard private key."
  }
}

variable "transmission_mail_address" {
  description = "Sender address for Transmission completion notifications"
  type        = string
  sensitive   = true
}

variable "transmission_mail_password" {
  description = "Mail credential for Transmission completion notifications"
  type        = string
  sensitive   = true
}

variable "transmission_notification_to" {
  description = "Recipient address for Transmission completion notifications"
  type        = string
  sensitive   = true
}
