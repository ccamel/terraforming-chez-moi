# Copilot Instructions for terraforming-chez-moi

## Project Architecture

This is a personal Terraform configuration for managing home infrastructure on a Synology DS415+ NAS. The architecture follows a **modular service pattern** where each self-hosted service is defined as a separate Terraform module with dedicated `.tf`, `.variables.tf`, and `.docker-compose.yml` files.

### Core Components

- **Infrastructure Database** (`infra-db.*`): PostgreSQL with Adminer for data persistence
- **Synology Provider**: Uses `synology-community/synology` provider to manage containers and file structures

### Service Pattern

Each service follows this structure:

```
service-name.tf                    # Main resource definitions
service-name.variables.tf          # Service-specific variables
service-name.docker-compose.yml    # Container orchestration template
```

Example from `infra-db.tf`:

- Creates folder structure via `synology_filestation_folder`
- Deploys container project via `synology_container_project`
- Uses `templatefile()` to inject variables into docker-compose
- Generates `.env` files dynamically from Terraform variables

## Key Patterns

### Docker Volume Management

All services use templated volume paths: `${dsm_volume_docker}/service-name/data` where `dsm_volume_docker` defaults to `/volume1/docker`. This ensures consistent data persistence across the NAS filesystem.

### Container Networking

Services requiring inter-communication use shared Docker networks:

```terraform
resource "docker_network" "shared" {
  name = "app_shared_network"
  driver = "bridge"
}
```

### Environment Variable Injection

Sensitive configuration is injected via Terraform variables into `.env` files:

```terraform
content = <<-EOT
  POSTGRES_USER=${var.postgres_user}
  POSTGRES_PASSWORD=${var.postgres_password}
EOT
```

## Development Workflow

### Infrastructure Changes

1. Modify relevant `.tf` files for infrastructure changes
2. Update `.docker-compose.yml` templates for container configuration
3. Add variables to appropriate `.variables.tf` files
4. Run `terraform plan` to validate (automated in CI)

### Documentation Updates

- Terraform docs auto-generated via `.terraform-docs.yml` configuration
- README.md updated automatically by `update-docs.yml` workflow on main branch pushes
- Uses `terraform-docs/gh-actions` with markdown injection between `<!-- BEGIN_TF_DOCS -->` markers

### CI/CD Pipeline

- **Linting**: Validates Terraform syntax, YAML, Markdown, and conventional commits
- **Building**: Runs `terraform plan` on all PRs to validate changes
- **Documentation**: Auto-updates README.md with Terraform provider documentation

## Working with This Codebase

### Adding New Services

1. Create `service-name.tf` with folder and container resources
2. Add `service-name.variables.tf` for configuration
3. Create `service-name.docker-compose.yml` template with volume/network patterns
4. Ensure variables are marked `sensitive = true` for credentials

### Variable Management

- All sensitive data (credentials, hostnames) marked with `sensitive = true`
- Use descriptive variable names that match service configuration
- Default values only for non-sensitive infrastructure settings

### Network Integration

For services needing database connectivity, reference the shared PostgreSQL instance:

```yaml
DB_TYPE=postgres
DB_POSTGRESDB_HOST=postgres # Container name from infra-db service
```

### File Structure Conventions

- Root `main.tf` contains only provider configuration
- Service-specific resources isolated in dedicated files
- Docker Compose templates co-located with Terraform definitions
- Variables grouped by service functionality
