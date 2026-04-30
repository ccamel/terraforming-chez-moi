resource "synology_filestation_folder" "uptime_kuma_data" {
  path           = "${var.dsm_volume_projects}/uptime-kuma/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "uptime_kuma" {
  source = "./modules/compose_stack"

  stack_name                   = "uptime-kuma"
  project_name                 = "uptime-kuma"
  remote_dir                   = dirname(synology_filestation_folder.uptime_kuma_data.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/uptime-kuma.compose.yaml.tftpl", {
    uptime_kuma_image = var.uptime_kuma_image
  })
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/uptime-kuma.env.tftpl", {
    uptime_kuma_published_port = var.uptime_kuma_published_port
  })

  depends_on = [
    synology_filestation_folder.uptime_kuma_data,
  ]
}
