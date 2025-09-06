resource "synology_filestation_folder" "infra_db_pgdata" {
  path           = "${var.dsm_volume_projects}/infra-db/postgres-data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "synology_container_project" "infra_db" {
  name       = "infra-db"
  run        = true
  share_path = "${var.dsm_volume_projects}/infra-db"

  services = {
    permfix = {
      image = "alpine:3.22"
      user  = "0:0"
      name  = "infra-db-permfix"

      volumes = [{
        type      = "bind"
        source    = synology_filestation_folder.infra_db_pgdata.real_path
        target    = "/fix"
        bind      = { create_host_path = true }
        read_only = false
      }]

      entrypoint = ["sh", "-lc"]
      command = [
        "chown -R 1001:1001 /fix && chmod 700 /fix && echo OK"
      ]

      restart = "no"

      healthcheck = {
        test         = ["CMD-SHELL", "[ -f /bin/true ] || exit 1"]
        interval     = "10s"
        timeout      = "2s"
        retries      = 1
        start_period = "1s"
      }

      logging = { driver = "json-file" }
    }


    "postgres" = {
      image = "bitnami/postgresql:17.5.0"
      name  = "infra-db-postgres"

      environment = {
        POSTGRESQL_USERNAME = var.postgres_user
        POSTGRESQL_PASSWORD = var.postgres_password
        TZ                  = "Europe/Paris"
      }

      volumes = [{
        type      = "bind"
        source    = synology_filestation_folder.infra_db_pgdata.real_path
        target    = "/bitnami/postgresql"
        bind      = { create_host_path = true }
        read_only = false
      }]

      healthcheck = {
        test         = ["CMD-SHELL", "pg_isready -U ${var.postgres_user} -d postgres -h 127.0.0.1 || exit 1"]
        interval     = "10s"
        timeout      = "3s"
        retries      = 10
        start_period = "120s"
      }


      restart = "unless-stopped"

      networks = {
        infra_net = {
        }
      }

      logging = { driver = "json-file" }
      depends_on = {
        permfix = {
          condition = "service_completed_successfully"
        }
      }
    }

    "adminer" = {
      image = "adminer:5.3.0"
      name  = "infra-db-adminer"

      ports = [{
        target    = 8080
        published = var.adminer_published_port
      }]

      environment = {
        ADMINER_DEFAULT_SERVER = "postgres"
      }

      restart = "unless-stopped"

      networks = {
        infra_net = {}
        edge_net  = {}
      }

      depends_on = {
        "postgres" = {
          condition = "service_healthy"
          restart   = true
        }
      }

      logging = { driver = "json-file" }
    }
  }

  networks = {
    infra_net = {
      attachable = true
      driver     = "bridge"
      name       = "infra"
      internal   = true
    }

    edge_net = {
      attachable = true
      driver     = "bridge"
      name       = "edge"
      internal   = false
    }
  }

  depends_on = [
    synology_filestation_folder.infra_db_pgdata
  ]
}
