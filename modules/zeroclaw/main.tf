terraform {
  required_providers {
    synology = {
      source = "synology-community/synology"
    }
  }
}

locals {
  project_name = "${var.project_prefix}-${var.instance_name}"
}

resource "synology_filestation_folder" "data" {
  path           = "${var.projects_root}/${local.project_name}/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "synology_container_project" "this" {
  name       = local.project_name
  run        = true
  share_path = "${var.projects_root}/${local.project_name}"

  services = {
    permfix = {
      image = "alpine:3.22"
      user  = "0:0"
      name  = "${local.project_name}-permfix"

      volumes = [{
        type      = "bind"
        source    = "./data"
        target    = "/fix"
        bind      = { create_host_path = true }
        read_only = false
      }]

      entrypoint = ["sh", "-lc"]
      command = [
        "chown -R 65534:65534 /fix && chmod 755 /fix && echo OK"
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

    zeroclaw = {
      image = var.image
      name  = local.project_name

      command = [
        "daemon",
        "--host",
        "0.0.0.0",
        "--port",
        "42617"
      ]

      ports = [{
        target    = 42617
        published = var.published_port
      }]

      volumes = [{
        type      = "bind"
        source    = "./data"
        target    = "/zeroclaw-data"
        bind      = { create_host_path = true }
        read_only = false
      }]

      healthcheck = {
        test         = ["CMD", "zeroclaw", "status", "--format=exit-code"]
        interval     = "60s"
        timeout      = "10s"
        retries      = 3
        start_period = "10s"
      }

      restart = "unless-stopped"

      networks = {
        edge_net = {}
      }

      depends_on = {
        permfix = { condition = "service_completed_successfully" }
      }

      logging = { driver = "json-file" }
    }
  }

  networks = {
    edge_net = {
      attachable = true
      driver     = "bridge"
      name       = var.edge_network_name
      external   = true
    }
  }

  depends_on = [
    synology_filestation_folder.data
  ]
}
