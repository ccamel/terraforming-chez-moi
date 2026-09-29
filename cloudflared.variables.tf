variable "cloudflared_image" {
  description = "Cloudflare Tunnel connector image"
  type        = string
  default     = "cloudflare/cloudflared:latest"
}

variable "cloudflared_tunnel_token" {
  description = "Token for the remotely managed Cloudflare Tunnel"
  type        = string
  sensitive   = true
}
