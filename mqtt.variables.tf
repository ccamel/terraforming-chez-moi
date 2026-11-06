variable "mqtt_published_port" {
  description = "Published localhost port for the MQTT broker"
  type        = number
  default     = 1883
}

variable "mqtt_homeassistant_password" {
  description = "MQTT password for Home Assistant"
  type        = string
  sensitive   = true
}
