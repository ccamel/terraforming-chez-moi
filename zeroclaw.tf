module "zeroclaw_cyrus" {
  source = "./modules/zeroclaw"

  instance_name  = "cyrus"
  projects_root  = var.dsm_volume_projects
  published_port = 42617
  image          = var.zeroclaw_image
}
