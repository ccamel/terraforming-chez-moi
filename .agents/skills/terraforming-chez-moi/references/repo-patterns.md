# Repository Patterns

## File Map

- Root Terraform provider and shared locals: `main.tf`
- Global DSM and deploy variables: `variables.tf`
- Generic Compose deploy module: `modules/compose_stack/`
- Specialized ZeroClaw module: `modules/zeroclaw/`
- Service definitions: `<project>.tf`
- Service variables: `<project>.variables.tf`
- Compose templates: `templates/<project>.compose.yaml.tftpl`
- Env templates: `templates/<project>.env.tftpl`
- Extra rendered support files: `templates/<project>.*.tftpl`
- Remote deploy and destroy playbooks: `ansible/deploy-compose-stack.yml`, `ansible/destroy-compose-stack.yml`
- README generated sections: managed by `.github/workflows/update-docs-readme.yml`, which runs `.github/scripts/render_readme_overview.py` and `.github/scripts/render_readme_docker_images.py`
- Docker image contexts: `docker/<image-name>/<image-tag>/Dockerfile`

## Compose Stack Module Shape

Use this structure for a normal service:

```hcl
resource "synology_filestation_folder" "<project>_<folder>" {
  path           = "${var.dsm_volume_projects}/<project>/<folder>"
  create_parents = true

  lifecycle {
    prevent_destroy = true
  }
}

module "<project>" {
  source = "./modules/compose_stack"

  stack_name                   = "<project>"
  project_name                 = "<project>"
  remote_dir                   = dirname(synology_filestation_folder.<project>_<folder>.real_path)
  ssh_host                     = local.compose_deploy_ssh_host
  ssh_user                     = local.compose_deploy_ssh_user
  ssh_port                     = var.deploy_ssh_port
  ssh_private_key_path         = var.deploy_ssh_private_key_path
  ssh_strict_host_key_checking = var.deploy_ssh_strict_host_key_checking
  compose_yaml                 = templatefile("${path.module}/templates/<project>.compose.yaml.tftpl", {})
  external_networks = [
    {
      name     = "edge"
      internal = false
    },
  ]
  env_file = templatefile("${path.module}/templates/<project>.env.tftpl", {
    <project>_published_port = var.<project>_published_port
  })

  depends_on = [
    synology_filestation_folder.<project>_<folder>,
  ]
}
```

## Compose Template Conventions

Use external networks by alias and explicit names:

```yaml
networks:
  edge_net:
    external: true
    name: edge
```

Use escaped environment variables for values supplied by the `.env` file:

```yaml
ports:
  - "$${APP_PUBLISHED_PORT}:8080"
environment:
  TZ: Europe/Paris
```

Use relative bind mounts for DSM-backed project data:

```yaml
volumes:
  - ./data:/app/data
```

## Variable Conventions

Published ports are non-sensitive numbers:

```hcl
variable "<project>_published_port" {
  description = "Published port on the Synology host for <project>"
  type        = number
  default     = 8080
}
```

Secrets and private deployment coordinates are sensitive:

```hcl
variable "<project>_token" {
  description = "Token for <project>"
  type        = string
  sensitive   = true
}
```

## Shared Infrastructure

- `infra-db` provides PostgreSQL and Adminer on the `infra` and `edge` networks.

## Existing Service Examples

- `n8n` shows the pattern for using `infra-db`, a rendered `.env`, an `extra_files` SQL bootstrap file, and a one-shot bootstrap service.
- `dockge` shows a simple single-service stack on `edge`.
- `bobine` shows sensitive key variables passed through an env template.
