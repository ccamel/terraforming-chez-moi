terraform {
  required_providers {
    synology = {
      source  = "synology-community/synology"
      version = "~> 0.4"
    }
  }
}

provider "synology" {
  host     = "https://${var.dsm_host}"
  user     = var.dsm_user
  password = var.dsm_password
}
