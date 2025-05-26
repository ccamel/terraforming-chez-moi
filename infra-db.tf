
resource "synology_filestation_folder" "postgres_data" {
  name           = "data"
  path           = "/docker/postgres"
  create_parents = true
}

resource "synology_container_project" "infra_db" {
  name = "infra-db"
  run  = true

  depends_on = [synology_filestation_folder.postgres_data]

  configs = {
    "docker-compose.yml" = {
      name    = "docker-compose.yml"
      file    = "docker-compose.yml"
      content = <<-EOT
        version: '3.8'
        services:
          postgres:
            image: bitnami/postgresql:17.5.0
            container_name: postgres
            restart: always
            ports:
              - "55432:5432"
            env_file:
              - .env
            volumes:
              - ${var.dsm_volume_docker}/postgres/data:/var/lib/postgresql/data

          adminer:
            image: adminer:5.3.0
            container_name: adminer
            restart: always
            ports:
              - "8081:8080"
      EOT
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
