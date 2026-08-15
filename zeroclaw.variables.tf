variable "zeroclaw_image" {
  description = "Prebuilt ZeroClaw runtime image published to GHCR"
  type        = string
  default     = "ghcr.io/ccamel/zeroclaw-runtime:v0.8.4-ubuntu24.04"
}
