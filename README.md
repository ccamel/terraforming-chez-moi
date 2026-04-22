# terraforming-chez-moi

![terraforming-chez-moi banner](./assets/banner.webp)

> 🪐 Personal Terraform configuration for shaping and managing my home infrastructure - including my Synology DS415+, self-hosted services, and all the weird experiments that come with being a geek at home.

[![build](https://img.shields.io/github/actions/workflow/status/ccamel/terraforming-chez-moi/build-terraform.yml?branch=main&label=build%20terraform&style=for-the-badge&logo=github)](https://github.com/ccamel/terraforming-chez-moi/actions/workflows/build-terraform.yml)
[![lint](https://img.shields.io/github/actions/workflow/status/ccamel/terraforming-chez-moi/lint-terraform.yml?branch=main&label=lint%20terraform&style=for-the-badge&logo=github)](https://github.com/ccamel/terraforming-chez-moi/actions/workflows/lint-terraform.yml)
[![conventional commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge&logo=conventionalcommits)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg?style=for-the-badge)](https://opensource.org/licenses/BSD-3-Clause)

## Purpose

This repo is exploratory, idiosyncratic, and not intended as a universal template.  
But if you enjoy turning black-box appliances into programmable interfaces - welcome.

## Overview

<!-- BEGIN_DEPLOYED_OVERVIEW -->

This repository manages **7 self-hosted services** on my Synology NAS.

### Runtime Services

| Project          | Service    | Image Repo                        | Image                                                |
| ---------------- | ---------- | --------------------------------- | ---------------------------------------------------- |
| `bobine`         | `bobine`   | `denoland/deno`                   | `denoland/deno:debian-2.6.3`                         |
| `dockge`         | `dockge`   | `louislam/dockge`                 | `louislam/dockge:1`                                  |
| `infra-db`       | `adminer`  | `adminer`                         | `adminer:5.3.0`                                      |
| `infra-db`       | `postgres` | `bitnamilegacy/postgresql`        | `bitnamilegacy/postgresql:17.5.0`                    |
| `n8n`            | `n8n`      | `n8nio/n8n`                       | `n8nio/n8n:2.1.5-amd64`                              |
| `zeroclaw-cyrus` | `zeroclaw` | `ghcr.io/ccamel/zeroclaw-runtime` | `ghcr.io/ccamel/zeroclaw-runtime:v0.6.9-ubuntu24.04` |
| `zeroclaw-lior`  | `zeroclaw` | `ghcr.io/ccamel/zeroclaw-runtime` | `ghcr.io/ccamel/zeroclaw-runtime:v0.6.9-ubuntu24.04` |

### Platform Building Blocks

- Infrastructure state is managed by `Terraform` via `synology-community/synology` (~> 0.4).
- Runtime is rendered as Docker Compose stacks and applied remotely over SSH via `Ansible`.
- Synology-specific state is mostly limited to DSM folders provisioned through Terraform.
- Runtime technologies currently in play: `adminer`, `deno`, `dockge`, `n8n`, `postgresql`, `zeroclaw-runtime`.
- Shared runtime networks: `edge`, `infra`.
<!-- END_DEPLOYED_OVERVIEW -->

## Philosophy

This repository implements a simple GitOps approach for managing my home infrastructure: desired state is defined in [Terraform](https://developer.hashicorp.com/terraform), versioned in Git, and applied through automated workflows.

## Usage

This project uses [`just`](https://github.com/casey/just) as a command runner.

`apply` and `destroy` expect `Ansible` on the local machine plus SSH access to the NAS.

To see the available recipes, run: `just -l`.

<!-- BEGIN_JUST_RECIPES -->

```text
Available recipes:
    apply     # Apply infrastructure changes
    check-fmt # Check Terraform code formatting
    default   # Default recipe
    destroy   # Destroy infrastructure
    fmt       # Format Terraform code
    init      # Initialize Terraform
    plan      # Plan infrastructure changes
    tools     # Ensure required tools are available for recipes in this Justfile.
    validate  # Validate Terraform configuration
```

<!-- END_JUST_RECIPES -->

## Built Docker Images

<!-- BEGIN_BUILT_DOCKER_IMAGES -->

Docker images are defined under `docker/<image-name>/<image-tag>/Dockerfile`.

These are the image build contexts currently present in the repo:

| Image              | Tag                  | Platforms                              | Package                                                                                                                                 | Dockerfile                                                                                                       |
| ------------------ | -------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `zeroclaw-runtime` | `v0.6.8-ubuntu24.04` | `linux/amd64,linux/arm64,linux/arm/v7` | [`ghcr.io/ccamel/zeroclaw-runtime:v0.6.8-ubuntu24.04`](https://github.com/ccamel/terraforming-chez-moi/pkgs/container/zeroclaw-runtime) | [`docker/zeroclaw-runtime/v0.6.8-ubuntu24.04/Dockerfile`](docker/zeroclaw-runtime/v0.6.8-ubuntu24.04/Dockerfile) |
| `zeroclaw-runtime` | `v0.6.9-ubuntu24.04` | `linux/amd64,linux/arm64,linux/arm/v7` | [`ghcr.io/ccamel/zeroclaw-runtime:v0.6.9-ubuntu24.04`](https://github.com/ccamel/terraforming-chez-moi/pkgs/container/zeroclaw-runtime) | [`docker/zeroclaw-runtime/v0.6.9-ubuntu24.04/Dockerfile`](docker/zeroclaw-runtime/v0.6.9-ubuntu24.04/Dockerfile) |

<!-- END_BUILT_DOCKER_IMAGES -->

## Terraform Details

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="requirement_synology"></a> [synology](#requirement_synology) | ~> 0.4  |

## Providers

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="provider_synology"></a> [synology](#provider_synology) | 0.6.10  |

## Modules

| Name                                                                          | Source                  | Version |
| ----------------------------------------------------------------------------- | ----------------------- | ------- |
| <a name="module_bobine"></a> [bobine](#module_bobine)                         | ./modules/compose_stack | n/a     |
| <a name="module_dockge"></a> [dockge](#module_dockge)                         | ./modules/compose_stack | n/a     |
| <a name="module_infra_db"></a> [infra_db](#module_infra_db)                   | ./modules/compose_stack | n/a     |
| <a name="module_n8n"></a> [n8n](#module_n8n)                                  | ./modules/compose_stack | n/a     |
| <a name="module_zeroclaw_cyrus"></a> [zeroclaw_cyrus](#module_zeroclaw_cyrus) | ./modules/zeroclaw      | n/a     |
| <a name="module_zeroclaw_lior"></a> [zeroclaw_lior](#module_zeroclaw_lior)    | ./modules/zeroclaw      | n/a     |

## Resources

| Name                                                                                                                                                        | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [synology_filestation_folder.bobine_local](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder)    | resource |
| [synology_filestation_folder.dockge_data](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder)     | resource |
| [synology_filestation_folder.infra_db_pgdata](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |
| [synology_filestation_folder.n8n_data](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder)        | resource |

## Inputs

| Name                                                                                                                                       | Description                                                                        | Type     | Default                                                | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | -------- | ------------------------------------------------------ | :------: |
| <a name="input_adminer_published_port"></a> [adminer_published_port](#input_adminer_published_port)                                        | Published port on the Synology host for Adminer web UI                             | `number` | `8081`                                                 |    no    |
| <a name="input_bobine_ed25519_private_key_hex"></a> [bobine_ed25519_private_key_hex](#input_bobine_ed25519_private_key_hex)                | Ed25519 private key hex for bobine                                                 | `string` | n/a                                                    |   yes    |
| <a name="input_bobine_ed25519_public_key_hex"></a> [bobine_ed25519_public_key_hex](#input_bobine_ed25519_public_key_hex)                   | Ed25519 public key hex for bobine                                                  | `string` | n/a                                                    |   yes    |
| <a name="input_bobine_published_port"></a> [bobine_published_port](#input_bobine_published_port)                                           | Published port on the Synology host for bobine                                     | `number` | `8082`                                                 |    no    |
| <a name="input_deploy_ssh_host"></a> [deploy_ssh_host](#input_deploy_ssh_host)                                                             | SSH host used by Ansible to apply rendered Compose stacks on the Synology NAS      | `string` | `null`                                                 |    no    |
| <a name="input_deploy_ssh_port"></a> [deploy_ssh_port](#input_deploy_ssh_port)                                                             | SSH port used by Ansible to apply rendered Compose stacks on the Synology NAS      | `number` | `22`                                                   |    no    |
| <a name="input_deploy_ssh_private_key_path"></a> [deploy_ssh_private_key_path](#input_deploy_ssh_private_key_path)                         | Path to the SSH private key used by Ansible to reach the Synology NAS              | `string` | n/a                                                    |   yes    |
| <a name="input_deploy_ssh_strict_host_key_checking"></a> [deploy_ssh_strict_host_key_checking](#input_deploy_ssh_strict_host_key_checking) | Whether Ansible should enforce SSH host key checking when deploying Compose stacks | `bool`   | `false`                                                |    no    |
| <a name="input_deploy_ssh_user"></a> [deploy_ssh_user](#input_deploy_ssh_user)                                                             | SSH user used by Ansible to apply rendered Compose stacks on the Synology NAS      | `string` | `null`                                                 |    no    |
| <a name="input_dockge_published_port"></a> [dockge_published_port](#input_dockge_published_port)                                           | Published port on the Synology host for Dockge                                     | `number` | `8083`                                                 |    no    |
| <a name="input_dsm_host"></a> [dsm_host](#input_dsm_host)                                                                                  | The hostname of my Synology DSM instance                                           | `string` | n/a                                                    |   yes    |
| <a name="input_dsm_password"></a> [dsm_password](#input_dsm_password)                                                                      | DSM password                                                                       | `string` | n/a                                                    |   yes    |
| <a name="input_dsm_user"></a> [dsm_user](#input_dsm_user)                                                                                  | DSM username                                                                       | `string` | n/a                                                    |   yes    |
| <a name="input_dsm_volume_projects"></a> [dsm_volume_projects](#input_dsm_volume_projects)                                                 | Root path for projects volume on DSM                                               | `string` | `"/projects"`                                          |    no    |
| <a name="input_n8n_encryption_key"></a> [n8n_encryption_key](#input_n8n_encryption_key)                                                    | Encryption key for n8n sensitive data                                              | `string` | `"my-32-character-random-string"`                      |    no    |
| <a name="input_n8n_host"></a> [n8n_host](#input_n8n_host)                                                                                  | Host/IP that n8n should bind to (passed to the container as N8N_HOST)              | `string` | `"0.0.0.0"`                                            |    no    |
| <a name="input_n8n_postgres_db"></a> [n8n_postgres_db](#input_n8n_postgres_db)                                                             | PostgreSQL database name for n8n                                                   | `string` | `"n8n-db-name"`                                        |    no    |
| <a name="input_n8n_postgres_password"></a> [n8n_postgres_password](#input_n8n_postgres_password)                                           | PostgreSQL password for n8n                                                        | `string` | `"n8n-db-password"`                                    |    no    |
| <a name="input_n8n_postgres_user"></a> [n8n_postgres_user](#input_n8n_postgres_user)                                                       | PostgreSQL username for n8n                                                        | `string` | `"n8n-db-user"`                                        |    no    |
| <a name="input_n8n_published_port"></a> [n8n_published_port](#input_n8n_published_port)                                                    | Published port on the Synology host for n8n web UI                                 | `number` | `5678`                                                 |    no    |
| <a name="input_n8n_webhook_url"></a> [n8n_webhook_url](#input_n8n_webhook_url)                                                             | Public URL for n8n webhooks                                                        | `string` | `"localhost:5678"`                                     |    no    |
| <a name="input_postgres_password"></a> [postgres_password](#input_postgres_password)                                                       | Password for the PostgreSQL service                                                | `string` | `"postgres-password"`                                  |    no    |
| <a name="input_postgres_user"></a> [postgres_user](#input_postgres_user)                                                                   | Username for the PostgreSQL service                                                | `string` | `"postgres-user"`                                      |    no    |
| <a name="input_zeroclaw_image"></a> [zeroclaw_image](#input_zeroclaw_image)                                                                | Prebuilt ZeroClaw runtime image published to GHCR                                  | `string` | `"ghcr.io/ccamel/zeroclaw-runtime:v0.6.9-ubuntu24.04"` |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
