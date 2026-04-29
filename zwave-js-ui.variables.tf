variable "zwave_js_ui_image" {
  description = "Z-Wave JS UI image"
  type        = string
  default     = "zwavejs/zwave-js-ui:latest"
}

variable "zwave_js_ui_published_port" {
  description = "Published port on the Synology host for the Z-Wave JS UI web interface"
  type        = number
  default     = 8091
}

variable "zwave_js_ui_ws_published_port" {
  description = "Published port on the Synology host for the Z-Wave JS WebSocket server"
  type        = number
  default     = 3000
}

variable "zwave_js_ui_usb_device" {
  description = "Z-Wave USB device path exposed to the Z-Wave JS UI container"
  type        = string
  default     = "/dev/ttyUSB0"
}
