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

locals {
  compose_deploy_ssh_host = coalesce(var.deploy_ssh_host, var.dsm_host)
  compose_deploy_ssh_user = coalesce(var.deploy_ssh_user, var.dsm_user)
}
