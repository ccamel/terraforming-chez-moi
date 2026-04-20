terraform {
  required_providers {
    synology = {
      source = "synology-community/synology"
    }
  }
}

locals {
  project_name = "${var.project_prefix}-${var.instance_name}"
}

resource "synology_filestation_folder" "data" {
  path           = "${var.projects_root}/${local.project_name}/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "compose_stack" {
  source = "../compose_stack"

  stack_name                   = local.project_name
  project_name                 = local.project_name
  remote_dir                   = dirname(synology_filestation_folder.data.real_path)
  ssh_host                     = var.deploy_ssh_host
  ssh_user                     = var.deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    project_name      = local.project_name
    edge_network_name = var.edge_network_name
    image             = var.image
    published_port    = var.published_port
  })
  external_networks = [
    {
      name     = var.edge_network_name
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/env.tftpl", {
    published_port = var.published_port
  })

  depends_on = [
    synology_filestation_folder.data,
  ]
}
