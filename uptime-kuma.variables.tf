variable "uptime_kuma_image" {
  description = "Uptime Kuma Docker image"
  type        = string
  default     = "louislam/uptime-kuma:2"
}

variable "uptime_kuma_published_port" {
  description = "Published port on the Synology host for Uptime Kuma"
  type        = number
  default     = 8084
}
