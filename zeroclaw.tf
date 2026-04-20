module "zeroclaw_cyrus" {
  source = "./modules/zeroclaw"

  instance_name                       = "cyrus"
  projects_root                       = var.dsm_volume_projects
  published_port                      = 42617
  image                               = var.zeroclaw_image
  deploy_ssh_host                     = local.compose_deploy_ssh_host
  deploy_ssh_user                     = local.compose_deploy_ssh_user
  deploy_ssh_port                     = var.deploy_ssh_port
  deploy_ssh_private_key_path         = var.deploy_ssh_private_key_path
  deploy_ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
}

module "zeroclaw_lior" {
  source = "./modules/zeroclaw"

  instance_name                       = "lior"
  projects_root                       = var.dsm_volume_projects
  published_port                      = 42618
  image                               = var.zeroclaw_image
  deploy_ssh_host                     = local.compose_deploy_ssh_host
  deploy_ssh_user                     = local.compose_deploy_ssh_user
  deploy_ssh_port                     = var.deploy_ssh_port
  deploy_ssh_private_key_path         = var.deploy_ssh_private_key_path
  deploy_ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
}
