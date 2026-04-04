variable "instance_name" {
  description = "Instance suffix used to distinguish this ZeroClaw deployment"
  type        = string
}

variable "projects_root" {
  description = "Root path for projects volume on DSM"
  type        = string
}

variable "published_port" {
  description = "Published port on the Synology host for the ZeroClaw gateway"
  type        = number
}

variable "image" {
  description = "ZeroClaw container image"
  type        = string
}

variable "project_prefix" {
  description = "Prefix used for ZeroClaw DSM project names"
  type        = string
  default     = "zeroclaw"
}

variable "edge_network_name" {
  description = "Existing external Docker network used to expose the ZeroClaw gateway"
  type        = string
  default     = "edge"
}
