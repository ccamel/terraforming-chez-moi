
resource "synology_filestation_folder" "postgres_data" {
  path           = "/docker/postgres/data"
  create_parents = true
}

resource "synology_container_project" "infra_db" {
  name = "infra-db"
  run  = true

  depends_on = [synology_filestation_folder.postgres_data]

  configs = {
    "docker-compose.yml" = {
      name = "docker-compose.yml"
      file = "docker-compose.yml"
      content = templatefile("${path.module}/infra-db.docker-compose.yml", {
        dsm_volume_docker = var.dsm_volume_docker
      })
    }
    ".env" = {
      name    = ".env"
      file    = ".env"
      content = <<-EOT
        POSTGRES_USER=${var.postgres_user}
        POSTGRES_PASSWORD=${var.postgres_password}
      EOT
    }
  }
}
