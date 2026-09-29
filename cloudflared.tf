resource "synology_filestation_folder" "cloudflared" {
  path           = "${var.dsm_volume_projects}/cloudflared"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "cloudflared" {
  source = "./modules/compose_stack"

  stack_name                   = "cloudflared"
  project_name                 = "cloudflared"
  remote_dir                   = synology_filestation_folder.cloudflared.real_path
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/cloudflared.compose.yaml.tftpl", {
    cloudflared_image = var.cloudflared_image
  })
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/cloudflared.env.tftpl", {
    cloudflared_tunnel_token = var.cloudflared_tunnel_token
  })

  depends_on = [
    synology_filestation_folder.cloudflared,
  ]
}
