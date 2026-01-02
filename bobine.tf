resource "synology_filestation_folder" "bobine_local" {
  path           = "${var.dsm_volume_projects}/bobine/local"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "synology_container_project" "bobine" {
  name       = "bobine"
  run        = true
  share_path = "${var.dsm_volume_projects}/bobine"

  services = {
    permfix = {
      image = "alpine:3.22"
      user  = "0:0"
      name  = "bobine-permfix"

      volumes = [{
        type      = "bind"
        source    = "./local"
        target    = "/fix"
        bind      = { create_host_path = true }
        read_only = false
      }]

      entrypoint = ["sh", "-lc"]
      command = [
        "chown -R 1000:1000 /fix && chmod 755 /fix && echo OK"
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

    bobine = {
      image = "denoland/deno:debian-2.6.3"
      name  = "bobine-bobine"
      user  = "1000:1000"

      ports = [{
        target    = 8080
        published = var.bobine_published_port
      }]

      volumes = [{
        type      = "bind"
        source    = "./local"
        target    = "/app/local"
        bind      = { create_host_path = true }
        read_only = false
      }]

      environment = {
        DATABASE_PATH           = "./local/database.db"
        SCRIPTS_PATH            = "./local/scripts"
        ED25519_PRIVATE_KEY_HEX = var.bobine_ed25519_private_key_hex
        ED25519_PUBLIC_KEY_HEX  = var.bobine_ed25519_public_key_hex
      }

      entrypoint = ["sh", "-lc"]
      command = [<<-EOC
        set -eu

        export DENO_DIR="/app/local/deno-dir"
        export DENO_INSTALL_ROOT="/app/local/deno-install"
        export PATH="$$DENO_INSTALL_ROOT/bin:$$PATH"

        mkdir -p "$$DENO_DIR" "$$DENO_INSTALL_ROOT" /app/local/scripts /tmp/bobine

        if ! command -v bobine >/dev/null 2>&1; then
          deno install --root "$$DENO_INSTALL_ROOT" -g -f -A npm:@hazae41/bobine
        fi

        printf "DATABASE_PATH=%s\nSCRIPTS_PATH=%s\nED25519_PRIVATE_KEY_HEX=%s\nED25519_PUBLIC_KEY_HEX=%s\n" \
          "$$DATABASE_PATH" \
          "$$SCRIPTS_PATH" \
          "$$ED25519_PRIVATE_KEY_HEX" \
          "$$ED25519_PUBLIC_KEY_HEX" \
          > /tmp/bobine/.env

        cd /app
        exec bobine serve --env=/tmp/bobine/.env --port=8080 --dev
      EOC
      ]

      healthcheck = {
        test         = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1"]
        interval     = "30s"
        timeout      = "10s"
        retries      = 5
        start_period = "30s"
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
      name       = "edge"
      external   = true
    }
  }

  depends_on = [
    synology_filestation_folder.bobine_local
  ]
}
