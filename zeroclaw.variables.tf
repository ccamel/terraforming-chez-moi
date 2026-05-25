variable "zeroclaw_image" {
  description = "Prebuilt ZeroClaw runtime image published to GHCR"
  type        = string
  default     = "ghcr.io/ccamel/zeroclaw-runtime:v0.7.5-ubuntu24.04"
}
