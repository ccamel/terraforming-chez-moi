variable "home_assistant_image" {
  description = "Home Assistant Container image"
  type        = string
  default     = "ghcr.io/home-assistant/home-assistant:stable"
}

variable "home_assistant_usb_device" {
  description = "Z-Wave USB device path exposed to the Home Assistant container"
  type        = string
  default     = "/dev/ttyUSB0"
}
