module "zeroclaw_cyrus" {
  source = "./modules/zeroclaw"

  instance_name  = "cyrus"
  projects_root  = var.dsm_volume_projects
  published_port = 42617
  image          = var.zeroclaw_image
}

module "zeroclaw_lior" {
  source = "./modules/zeroclaw"

  instance_name  = "lior"
  projects_root  = var.dsm_volume_projects
  published_port = 42618
  image          = var.zeroclaw_image
}
