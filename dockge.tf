resource "synology_filestation_folder" "dockge_data" {
  path           = "${var.dsm_volume_projects}/dockge/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "dockge" {
  source = "./modules/compose_stack"

  stack_name                   = "dockge"
  project_name                 = "dockge"
  remote_dir                   = dirname(synology_filestation_folder.dockge_data.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml                 = templatefile("${path.module}/templates/dockge.compose.yaml.tftpl", {})
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/dockge.env.tftpl", {
    dockge_published_port = var.dockge_published_port
    dockge_stacks_dir     = dirname(dirname(synology_filestation_folder.dockge_data.real_path))
  })

  depends_on = [
    synology_filestation_folder.dockge_data,
  ]
}
