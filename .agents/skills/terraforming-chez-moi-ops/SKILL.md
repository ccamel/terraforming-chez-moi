---
name: terraforming-chez-moi-ops
description: Operate and diagnose the live Synology DSM runtime managed by the terraforming-chez-moi repository. Use when inspecting deployed Docker Compose stacks, SSH access, Docker containers, logs, networks, bind mounts, permissions, runtime drift, failed deployments, or service health on the Synology host.
---

# Terraforming Chez Moi Ops

## Policy

- Default to read-only inspection: `docker ps`, `docker compose ps`, logs, inspect, network ls/inspect, file listing, permissions checks.
- Do not run mutating commands (`terraform apply`, `terraform destroy`, `docker compose up/down/restart`, `docker rm`, `docker network rm`, `chown`, `chmod`, file edits on the NAS) unless the user explicitly asks for runtime action.
- Prefer durable fixes in Terraform/templates when runtime state differs from desired state.
- Treat `.env`, Terraform state, logs, and rendered Compose files as potentially sensitive. Do not paste secrets back to the user.
- Use `deploy_ssh_*` settings when present; otherwise infer SSH host/user from `dsm_*` values only when the environment exposes them.
- Keep diagnostics scoped to the named stack/service. Avoid broad destructive cleanup.

## Diagnostic Order

1. Identify the stack name and remote directory from `<project>.tf` or `modules/compose_stack` inputs.
2. Check local repo validity when relevant: `just validate`; use `just plan` only when the user asks for deployment impact and required `TF_VAR_*` values exist.
3. Establish SSH command from env or Terraform variables without printing sensitive values.
4. Inspect Docker runtime: containers, Compose project status, recent logs, health state, restart count, image, networks, mounts.
5. Inspect support resources: external networks, bind mount paths, folder ownership/mode, companion files such as `.env` or `init.sql`.
6. Compare runtime findings with `templates/*.compose.yaml.tftpl`, `*.tf`, and `*.variables.tf`.
7. Report whether the issue is runtime-only, configuration drift, missing remote resource, bad image/app config, permissions, or network/database dependency.
8. If a fix is needed, edit the repo first unless the user requested an immediate runtime intervention.

Read `references/runtime-commands.md` for concrete SSH and Docker command patterns.
