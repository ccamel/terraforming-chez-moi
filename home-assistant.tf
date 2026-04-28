resource "synology_filestation_folder" "home_assistant_config" {
  path           = "${var.dsm_volume_projects}/home-assistant/config"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "home_assistant" {
  source = "./modules/compose_stack"

  stack_name                   = "home-assistant"
  project_name                 = "home-assistant"
  remote_dir                   = dirname(synology_filestation_folder.home_assistant_config.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/home-assistant.compose.yaml.tftpl", {
    home_assistant_image      = var.home_assistant_image
    home_assistant_usb_device = var.home_assistant_usb_device
  })

  depends_on = [
    synology_filestation_folder.home_assistant_config,
  ]
}
