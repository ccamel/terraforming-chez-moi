variable "zeroclaw_image" {
  description = "ZeroClaw container image. Use the upstream :debian variant if the default image has runtime issues on your Synology"
  type        = string
  default     = "ghcr.io/zeroclaw-labs/zeroclaw:v0.6.8"
}
