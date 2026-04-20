resource "synology_filestation_folder" "n8n_data" {
  path           = "${var.dsm_volume_projects}/n8n/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "n8n" {
  source = "./modules/compose_stack"

  stack_name                   = "n8n"
  project_name                 = "n8n"
  remote_dir                   = dirname(synology_filestation_folder.n8n_data.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml                 = templatefile("${path.module}/templates/n8n.compose.yaml.tftpl", {})
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
  env_file = templatefile("${path.module}/templates/n8n.env.tftpl", {
    postgres_user         = var.postgres_user
    postgres_password     = var.postgres_password
    n8n_published_port    = var.n8n_published_port
    n8n_host              = var.n8n_host
    n8n_webhook_url       = var.n8n_webhook_url
    n8n_encryption_key    = var.n8n_encryption_key
    n8n_postgres_db       = var.n8n_postgres_db
    n8n_postgres_user     = var.n8n_postgres_user
    n8n_postgres_password = var.n8n_postgres_password
  })
  extra_files = {
    "init.sql" = {
      content = templatefile("${path.module}/templates/n8n.init.sql.tftpl", {
        n8n_postgres_db       = var.n8n_postgres_db
        n8n_postgres_user     = var.n8n_postgres_user
        n8n_postgres_password = var.n8n_postgres_password
      })
      mode = "0644"
    }
  }

  depends_on = [
    synology_filestation_folder.n8n_data,
    module.infra_db,
  ]
}
