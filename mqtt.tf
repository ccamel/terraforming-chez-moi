resource "synology_filestation_folder" "mqtt_data" {
  path           = "${var.dsm_volume_projects}/mqtt/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "mqtt" {
  source = "./modules/compose_stack"

  stack_name                   = "mqtt"
  project_name                 = "mqtt"
  remote_dir                   = dirname(synology_filestation_folder.mqtt_data.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/mqtt.compose.yaml.tftpl", {
    mqtt_config_checksum = filesha256("${path.module}/templates/mqtt.mosquitto.conf")
  })
  env_file = templatefile("${path.module}/templates/mqtt.env.tftpl", {
    mqtt_published_port         = var.mqtt_published_port
    mqtt_homeassistant_password = var.mqtt_homeassistant_password
  })
  extra_files = {
    "mosquitto.conf" = {
      content = file("${path.module}/templates/mqtt.mosquitto.conf")
    }
  }

  depends_on = [
    synology_filestation_folder.mqtt_data,
  ]
}
