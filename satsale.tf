resource "synology_filestation_folder" "satsale_data" {
  path           = "${var.dsm_volume_projects}/satsale/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "satsale" {
  source = "./modules/compose_stack"

  stack_name                   = "satsale"
  project_name                 = "satsale"
  remote_dir                   = dirname(synology_filestation_folder.satsale_data.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/satsale.compose.yaml.tftpl", {
    port = var.satsale_port
    uid  = var.satsale_uid
    gid  = var.satsale_gid
  })
  extra_files = {
    "config.toml" = {
      content = templatefile("${path.module}/templates/satsale.config.toml.tftpl", {
        xpub = var.satsale_xpub
        bip  = var.satsale_bip
      })
      mode = "0600"
    }
  }

  depends_on = [synology_filestation_folder.satsale_data]
}
