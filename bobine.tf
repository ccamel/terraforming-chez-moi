resource "synology_filestation_folder" "bobine_local" {
  path           = "${var.dsm_volume_projects}/bobine/local"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "bobine" {
  source = "./modules/compose_stack"

  stack_name                   = "bobine"
  project_name                 = "bobine"
  remote_dir                   = dirname(synology_filestation_folder.bobine_local.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml                 = templatefile("${path.module}/templates/bobine.compose.yaml.tftpl", {})
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/bobine.env.tftpl", {
    bobine_published_port          = var.bobine_published_port
    bobine_ed25519_private_key_hex = var.bobine_ed25519_private_key_hex
    bobine_ed25519_public_key_hex  = var.bobine_ed25519_public_key_hex
  })

  depends_on = [
    synology_filestation_folder.bobine_local,
  ]
}
