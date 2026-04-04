# terraforming-chez-moi

> 🪐 Personal Terraform configuration for shaping and managing my home infrastructure - including my Synology DS415+, self-hosted services, and all the weird experiments that come with being a geek at home.

[![lint](https://img.shields.io/github/actions/workflow/status/ccamel/terraforming-chez-moi/lint.yml?branch=main&label=lint&style=for-the-badge&logo=github)](https://github.com/ccamel/terraforming-chez-moi/actions/workflows/lint.yml)
[![conventional commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge&logo=conventionalcommits)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg?style=for-the-badge)](https://opensource.org/licenses/BSD-3-Clause)

## Purpose

This repo is exploratory, idiosyncratic, and not intended as a universal template.  
But if you enjoy turning black-box appliances into programmable interfaces - welcome.

## Philosophy

This repository implements a simple GitOps approach for managing my home infrastructure: desired state is defined in [Terraform](https://developer.hashicorp.com/terraform), versioned in Git, and applied through automated workflows.

## Usage

This project uses [`just`](https://github.com/casey/just) as a command runner.

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

## Overview

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_synology"></a> [synology](#requirement\_synology) | ~> 0.4 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_synology"></a> [synology](#provider\_synology) | 0.6.9 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_zeroclaw_cyrus"></a> [zeroclaw\_cyrus](#module\_zeroclaw\_cyrus) | ./modules/zeroclaw | n/a |

### Resources

| Name | Type |
|------|------|
| [synology_container_project.bobine](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project) | resource |
| [synology_container_project.infra_db](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project) | resource |
| [synology_container_project.n8n](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project) | resource |
| [synology_filestation_folder.bobine_local](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |
| [synology_filestation_folder.infra_db_pgdata](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |
| [synology_filestation_folder.n8n_data](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adminer_published_port"></a> [adminer\_published\_port](#input\_adminer\_published\_port) | Published port on the Synology host for Adminer web UI | `number` | `8081` | no |
| <a name="input_bobine_ed25519_private_key_hex"></a> [bobine\_ed25519\_private\_key\_hex](#input\_bobine\_ed25519\_private\_key\_hex) | Ed25519 private key hex for bobine | `string` | n/a | yes |
| <a name="input_bobine_ed25519_public_key_hex"></a> [bobine\_ed25519\_public\_key\_hex](#input\_bobine\_ed25519\_public\_key\_hex) | Ed25519 public key hex for bobine | `string` | n/a | yes |
| <a name="input_bobine_published_port"></a> [bobine\_published\_port](#input\_bobine\_published\_port) | Published port on the Synology host for bobine | `number` | `8082` | no |
| <a name="input_dsm_host"></a> [dsm\_host](#input\_dsm\_host) | The hostname of my Synology DSM instance | `string` | n/a | yes |
| <a name="input_dsm_password"></a> [dsm\_password](#input\_dsm\_password) | DSM password | `string` | n/a | yes |
| <a name="input_dsm_user"></a> [dsm\_user](#input\_dsm\_user) | DSM username | `string` | n/a | yes |
| <a name="input_dsm_volume_projects"></a> [dsm\_volume\_projects](#input\_dsm\_volume\_projects) | Root path for projects volume on DSM | `string` | `"/projects"` | no |
| <a name="input_n8n_encryption_key"></a> [n8n\_encryption\_key](#input\_n8n\_encryption\_key) | Encryption key for n8n sensitive data | `string` | `"my-32-character-random-string"` | no |
| <a name="input_n8n_host"></a> [n8n\_host](#input\_n8n\_host) | Host/IP that n8n should bind to (passed to the container as N8N\_HOST) | `string` | `"0.0.0.0"` | no |
| <a name="input_n8n_postgres_db"></a> [n8n\_postgres\_db](#input\_n8n\_postgres\_db) | PostgreSQL database name for n8n | `string` | `"n8n-db-name"` | no |
| <a name="input_n8n_postgres_password"></a> [n8n\_postgres\_password](#input\_n8n\_postgres\_password) | PostgreSQL password for n8n | `string` | `"n8n-db-password"` | no |
| <a name="input_n8n_postgres_user"></a> [n8n\_postgres\_user](#input\_n8n\_postgres\_user) | PostgreSQL username for n8n | `string` | `"n8n-db-user"` | no |
| <a name="input_n8n_published_port"></a> [n8n\_published\_port](#input\_n8n\_published\_port) | Published port on the Synology host for n8n web UI | `number` | `5678` | no |
| <a name="input_n8n_webhook_url"></a> [n8n\_webhook\_url](#input\_n8n\_webhook\_url) | Public URL for n8n webhooks | `string` | `"localhost:5678"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | Password for the PostgreSQL service | `string` | `"postgres-password"` | no |
| <a name="input_postgres_user"></a> [postgres\_user](#input\_postgres\_user) | Username for the PostgreSQL service | `string` | `"postgres-user"` | no |
| <a name="input_zeroclaw_image"></a> [zeroclaw\_image](#input\_zeroclaw\_image) | ZeroClaw container image. Use the upstream :debian variant if the default image has runtime issues on your Synology | `string` | `"ghcr.io/zeroclaw-labs/zeroclaw:v0.6.8"` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
