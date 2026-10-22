resource "synology_filestation_folder" "transmission_config" {
  path           = "${var.dsm_volume_projects}/transmission/config"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "transmission" {
  source = "./modules/compose_stack"

  stack_name                   = "transmission"
  project_name                 = "transmission"
  remote_dir                   = dirname(synology_filestation_folder.transmission_config.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/transmission.compose.yaml.tftpl", {
    transmission_image          = var.transmission_image
    transmission_vpn_image      = var.transmission_vpn_image
    transmission_downloads_path = var.transmission_downloads_path
  })
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/transmission.env.tftpl", {
    transmission_username              = var.transmission_username
    transmission_password              = var.transmission_password
    transmission_vpn_service_provider  = var.transmission_vpn_service_provider
    transmission_wireguard_private_key = var.transmission_wireguard_private_key
  })

  depends_on = [
    synology_filestation_folder.transmission_config,
  ]
}
