resource "synology_filestation_folder" "n8n_data" {
  path           = "${var.dsm_volume_projects}/n8n/data"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "synology_container_project" "n8n" {
  name       = "n8n"
  run        = true
  share_path = "${var.dsm_volume_projects}/n8n"

  services = {
    permfix = {
      image = "alpine:3.22"
      user  = "0:0"
      name  = "n8n-permfix"

      volumes = [{
        type      = "bind"
        source    = synology_filestation_folder.n8n_data.real_path
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

    db_bootstrap = {
      image = "postgres:17-alpine"
      name  = "n8n-db-bootstrap"

      environment = {
        PGPASSWORD = var.postgres_password
        TZ         = "Europe/Paris"
      }

      configs = [
        { source = "n8n-bootstrap", target = "/bootstrap/init.sql", uid = 0, gid = 0, mode = "0440" },
      ]

      entrypoint = ["sh", "-lc"]
      command = [<<-EOC
        set -e
        echo "🚀 Starting n8n database bootstrap..."

        echo "Waiting for PostgreSQL to be ready..."
        until pg_isready -h postgres -U ${var.postgres_user}; do
          echo "🙅 PostgreSQL not ready, retrying in 2s..."
          sleep 2
        done
        echo "✅ PostgreSQL is ready!"

        echo "Initializing n8n database and user..."
        psql -v ON_ERROR_STOP=1 \
             -h postgres -U ${var.postgres_user} -d postgres \
             -f /bootstrap/init.sql

        echo "✅ n8n database initialization completed successfully"

        touch /.bootstrap_completed
        echo "🎉 Bootstrap process finished!"
      EOC
      ]

      restart = "no"

      healthcheck = {
        test         = ["CMD-SHELL", "[ -f /.bootstrap_completed ] || exit 1"]
        interval     = "5s"
        timeout      = "3s"
        retries      = 1
        start_period = "1s"
      }

      networks = {
        n8n_infra_net = {}
      }

      logging = { driver = "json-file" }
    }

    "n8n" = {
      image = "n8nio/n8n:1.110.1-amd64"
      name  = "n8n-n8n"

      ports = [{
        target    = 5678
        published = var.n8n_published_port
      }]

      environment = {
        N8N_HOST                            = var.n8n_host
        N8N_PORT                            = "5678"
        N8N_PROTOCOL                        = "http"
        N8N_ENCRYPTION_KEY                  = var.n8n_encryption_key
        WEBHOOK_URL                         = var.n8n_webhook_url
        GENERIC_TIMEZONE                    = "Europe/Paris"
        N8N_LOG_LEVEL                       = "info"
        N8N_LOG_OUTPUT                      = "console"
        N8N_DISABLE_PRODUCTION_MAIN_PROCESS = "false"
        N8N_METRICS                         = "false"

        DB_TYPE                = "postgresdb"
        DB_POSTGRESDB_HOST     = "postgres"
        DB_POSTGRESDB_PORT     = "5432"
        DB_POSTGRESDB_DATABASE = var.n8n_postgres_db
        DB_POSTGRESDB_USER     = var.n8n_postgres_user
        DB_POSTGRESDB_PASSWORD = var.n8n_postgres_password
        DB_POSTGRESDB_SCHEMA   = "public"
      }

      volumes = [{
        type      = "bind"
        source    = synology_filestation_folder.n8n_data.real_path
        target    = "/home/node/.n8n"
        bind      = { create_host_path = true }
        read_only = false
      }]

      healthcheck = {
        test         = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1"]
        interval     = "30s"
        timeout      = "10s"
        retries      = 5
        start_period = "60s"
      }

      restart = "unless-stopped"

      networks = {
        n8n_infra_net = {}
        n8n_edge_net  = {}
      }

      depends_on = {
        permfix      = { condition = "service_completed_successfully" }
        db_bootstrap = { condition = "service_completed_successfully" }
      }

      logging = { driver = "json-file" }
    }
  }

  configs = {
    "n8n-bootstrap" = {
      name    = "n8n-bootstrap.sql"
      content = <<-SQL
        -- n8n Database Bootstrap Script
        -- Initializes user, database and permissions for n8n application

        -- Create user with conditional logic (idempotent)
        DO $$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${replace(var.n8n_postgres_user, "'", "''")}') THEN
                CREATE ROLE "${replace(var.n8n_postgres_user, "'", "''")}" LOGIN PASSWORD '${replace(var.n8n_postgres_password, "'", "''")}';
                RAISE NOTICE 'Created user: ${replace(var.n8n_postgres_user, "'", "''")}';
            ELSE
                ALTER ROLE "${replace(var.n8n_postgres_user, "'", "''")}" WITH LOGIN PASSWORD '${replace(var.n8n_postgres_password, "'", "''")}';
                RAISE NOTICE 'Updated password for user: ${replace(var.n8n_postgres_user, "'", "''")}';
            END IF;
        END
        $$ LANGUAGE plpgsql;

        -- Create database (outside transaction, with IF NOT EXISTS)
        \echo 'Creating database if it does not exist...'
        SELECT 'CREATE DATABASE "${replace(var.n8n_postgres_db, "'", "''")}" OWNER "${replace(var.n8n_postgres_user, "'", "''")}"'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${replace(var.n8n_postgres_db, "'", "''")}') \gexec

        -- Ensure ownership and privileges (idempotent)
        \echo 'Setting ownership and privileges...'
        ALTER DATABASE "${replace(var.n8n_postgres_db, "'", "''")}" OWNER TO "${replace(var.n8n_postgres_user, "'", "''")}";
        GRANT ALL PRIVILEGES ON DATABASE "${replace(var.n8n_postgres_db, "'", "''")}" TO "${replace(var.n8n_postgres_user, "'", "''")}";

        \echo '✅ Bootstrap completed successfully!'
      SQL
    }
  }

  networks = {
    n8n_infra_net = {
      attachable = true
      driver     = "bridge"
      name       = "infra"
      external   = true
    }

    n8n_edge_net = {
      attachable = true
      driver     = "bridge"
      name       = "edge"
      external   = true
    }
  }

  depends_on = [
    synology_filestation_folder.n8n_data,
    synology_container_project.infra_db
  ]
}
