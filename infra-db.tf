resource "synology_filestation_folder" "infra_db_pgdata" {
  path           = "${var.dsm_volume_projects}/infra-db/postgres-data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "infra_db" {
  source = "./modules/compose_stack"

  stack_name                   = "infra-db"
  project_name                 = "infra-db"
  remote_dir                   = dirname(synology_filestation_folder.infra_db_pgdata.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml                 = templatefile("${path.module}/templates/infra-db.compose.yaml.tftpl", {})
  external_networks = [
    {
      name     = "infra"
      internal = true
    },
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/infra-db.env.tftpl", {
    postgres_user          = var.postgres_user
    postgres_password      = var.postgres_password
    adminer_published_port = var.adminer_published_port
  })

  depends_on = [
    synology_filestation_folder.infra_db_pgdata,
  ]
}
