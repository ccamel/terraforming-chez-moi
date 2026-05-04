resource "synology_filestation_folder" "homepage_config" {
  path           = "${var.dsm_volume_projects}/homepage/config"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "homepage" {
  source = "./modules/compose_stack"

  stack_name                   = "homepage"
  project_name                 = "homepage"
  remote_dir                   = dirname(synology_filestation_folder.homepage_config.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/homepage.compose.yaml.tftpl", {
    homepage_image                     = var.homepage_image
    homepage_docker_socket_proxy_image = var.homepage_docker_socket_proxy_image
    homepage_url                       = var.homepage_url
  })
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/homepage.env.tftpl", {
    homepage_published_port = var.homepage_published_port
    homepage_allowed_hosts  = var.homepage_allowed_hosts
  })
  extra_files = {
    "config/bookmarks.yaml" = {
      content = templatefile("${path.module}/templates/homepage.bookmarks.yaml.tftpl", {})
      mode    = "0644"
    }
    "config/docker.yaml" = {
      content = templatefile("${path.module}/templates/homepage.docker.yaml.tftpl", {})
      mode    = "0644"
    }
    "config/services.yaml" = {
      content = templatefile("${path.module}/templates/homepage.services.yaml.tftpl", {})
      mode    = "0644"
    }
    "config/settings.yaml" = {
      content = templatefile("${path.module}/templates/homepage.settings.yaml.tftpl", {})
      mode    = "0644"
    }
    "config/widgets.yaml" = {
      content = templatefile("${path.module}/templates/homepage.widgets.yaml.tftpl", {})
      mode    = "0644"
    }
  }

  depends_on = [
    synology_filestation_folder.homepage_config,
  ]
}
