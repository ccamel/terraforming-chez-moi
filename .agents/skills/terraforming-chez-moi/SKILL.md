---
name: terraforming-chez-moi
description: Work on the terraforming-chez-moi repository, a personal Terraform configuration for Synology DSM home infrastructure. Use when adding or changing self-hosted services, Terraform modules, Compose templates, Docker image contexts, Ansible deployment flow, CI-managed README documentation, or repo-specific validation for this folder.
---

# Terraforming Chez Moi

## Checklist

- Start from a nearby service. Use `dockge` for a simple edge stack, `bobine` for sensitive env values, `n8n` for infra-db bootstrap, and `infra-db` only for shared database support.
- Model normal services with `modules/compose_stack`: one `<project>.tf`, optional `<project>.variables.tf`, `templates/<project>.compose.yaml.tftpl`, and optional `templates/<project>.env.tftpl`.
- Provision persistent data with `synology_filestation_folder` at `${var.dsm_volume_projects}/<project>/<folder>` and `prevent_destroy = true`.
- Mount persistence as relative bind mounts from the rendered stack directory, for example `./data:/app/data`. Never add Docker named volumes.
- Set module `remote_dir` from the DSM folder parent: `dirname(synology_filestation_folder.<name>.real_path)`.
- Pass deploy settings from `local.compose_deploy_ssh_host`, `local.compose_deploy_ssh_user`, and `var.deploy_ssh_*`.
- Declare every external Compose network in both Terraform `external_networks` and the Compose template. Use `edge` for reachable services and `infra` for private support traffic.
- Escape Compose/runtime env vars as `$${NAME}` in `.tftpl`; pass configurable or sensitive values through `env_file = templatefile(...)`.
- Keep published host ports in Terraform variables. Mark credentials, keys, users, hostnames, webhook URLs, and app secrets as `sensitive = true`.
- Add `permfix` only for images that require specific ownership or permissions; make the main service depend on its `service_completed_successfully`.
- Prefer pinned, reputable production images. Add healthchecks for databases, stateful services, and web services.
- Do not edit generated README sections for normal changes. `.github/workflows/update-docs-readme.yml` owns them.

Read `references/repo-patterns.md` only for exact file map or skeleton snippets.

```bash
just fmt
just validate
```

Use `just check-fmt` when only checking formatting. Use `just plan` only when deployment impact is requested and required `TF_VAR_*` values are available.
