variable "homepage_image" {
  description = "Homepage Docker image"
  type        = string
  default     = "ghcr.io/gethomepage/homepage:v1.12.2"
}

variable "homepage_docker_socket_proxy_image" {
  description = "Docker socket proxy image used by Homepage"
  type        = string
  default     = "ghcr.io/tecnativa/docker-socket-proxy:v0.4.2"
}

variable "homepage_published_port" {
  description = "Published port on the Synology host for Homepage"
  type        = number
  default     = 8085
}

variable "homepage_allowed_hosts" {
  description = "Comma-separated hostnames and host:port values allowed by Homepage"
  type        = string
  sensitive   = true
}

variable "homepage_url" {
  description = "Browser-visible URL for Homepage, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "dockge_url" {
  description = "Browser-visible URL for Dockge, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "uptime_kuma_url" {
  description = "Browser-visible URL for Uptime Kuma, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "adminer_url" {
  description = "Browser-visible URL for Adminer, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "n8n_url" {
  description = "Browser-visible URL for n8n, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "bobine_url" {
  description = "Browser-visible URL for bobine, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "home_assistant_url" {
  description = "Browser-visible URL for Home Assistant, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "zwave_js_ui_url" {
  description = "Browser-visible URL for Z-Wave JS UI, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "zeroclaw_cyrus_url" {
  description = "Browser-visible URL for ZeroClaw Cyrus, without a trailing slash"
  type        = string
  sensitive   = true
}

variable "zeroclaw_lior_url" {
  description = "Browser-visible URL for ZeroClaw Lior, without a trailing slash"
  type        = string
  sensitive   = true
}
