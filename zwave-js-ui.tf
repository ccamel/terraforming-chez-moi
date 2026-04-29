resource "synology_filestation_folder" "zwave_js_ui_store" {
  path           = "${var.dsm_volume_projects}/zwave-js-ui/store"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "zwave_js_ui" {
  source = "./modules/compose_stack"

  stack_name                   = "zwave-js-ui"
  project_name                 = "zwave-js-ui"
  remote_dir                   = dirname(synology_filestation_folder.zwave_js_ui_store.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml = templatefile("${path.module}/templates/zwave-js-ui.compose.yaml.tftpl", {
    zwave_js_ui_image = var.zwave_js_ui_image
  })
  env_file = templatefile("${path.module}/templates/zwave-js-ui.env.tftpl", {
    zwave_js_ui_published_port    = var.zwave_js_ui_published_port
    zwave_js_ui_ws_published_port = var.zwave_js_ui_ws_published_port
    zwave_js_ui_usb_device        = var.zwave_js_ui_usb_device
  })

  depends_on = [
    synology_filestation_folder.zwave_js_ui_store,
  ]
}
