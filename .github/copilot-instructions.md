# Copilot instructions for terraforming-chez-moi

This repository is a personal Terraform configuration for shaping and managing home infrastructure — including a Synology DS415+, self-hosted services, and experiments.

## Architecture

- Terraform config for Synology NAS (DSM).
- Provider: `synology-community/synology`.
- Containers managed with Synology Container Manager.
- Persistent storage = DSM shared folders (bind mounts).

## Guidelines

- Never use named volumes.
- Always use bind mounts with the pattern: `${var.dsm_volume_projects}/<projectname>/folder-name`.
- Ports must be configurable via variables, never hard-coded.
- Sensitive values must be marked with `sensitive = true`.
- Use `just validate` to check syntax.
- Use `just fmt` to keep code formatted.
