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
<!-- END_JUST_RECIPES -->

## Overview

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="requirement_synology"></a> [synology](#requirement_synology) | ~> 0.4  |

## Providers

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="provider_synology"></a> [synology](#provider_synology) | 0.5.1   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [synology_container_project.infra_db](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project)          | resource |
| [synology_container_project.n8n](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project)               | resource |
| [synology_filestation_folder.infra_db_pgdata](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |
| [synology_filestation_folder.n8n_data](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder)        | resource |

## Inputs

| Name                                                                                                | Description                                                           | Type     | Default                           | Required |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------- | --------------------------------- | :------: |
| <a name="input_adminer_published_port"></a> [adminer_published_port](#input_adminer_published_port) | Published port on the Synology host for Adminer web UI                | `number` | `8081`                            |    no    |
| <a name="input_dsm_host"></a> [dsm_host](#input_dsm_host)                                           | The hostname of my Synology DSM instance                              | `string` | n/a                               |   yes    |
| <a name="input_dsm_password"></a> [dsm_password](#input_dsm_password)                               | DSM password                                                          | `string` | n/a                               |   yes    |
| <a name="input_dsm_user"></a> [dsm_user](#input_dsm_user)                                           | DSM username                                                          | `string` | n/a                               |   yes    |
| <a name="input_dsm_volume_projects"></a> [dsm_volume_projects](#input_dsm_volume_projects)          | Root path for projects volume on DSM                                  | `string` | `"/projects"`                     |    no    |
| <a name="input_n8n_encryption_key"></a> [n8n_encryption_key](#input_n8n_encryption_key)             | Encryption key for n8n sensitive data                                 | `string` | `"my-32-character-random-string"` |    no    |
| <a name="input_n8n_host"></a> [n8n_host](#input_n8n_host)                                           | Host/IP that n8n should bind to (passed to the container as N8N_HOST) | `string` | `"0.0.0.0"`                       |    no    |
| <a name="input_n8n_postgres_db"></a> [n8n_postgres_db](#input_n8n_postgres_db)                      | PostgreSQL database name for n8n                                      | `string` | `"n8n-db-name"`                   |    no    |
| <a name="input_n8n_postgres_password"></a> [n8n_postgres_password](#input_n8n_postgres_password)    | PostgreSQL password for n8n                                           | `string` | `"n8n-db-password"`               |    no    |
| <a name="input_n8n_postgres_user"></a> [n8n_postgres_user](#input_n8n_postgres_user)                | PostgreSQL username for n8n                                           | `string` | `"n8n-db-user"`                   |    no    |
| <a name="input_n8n_published_port"></a> [n8n_published_port](#input_n8n_published_port)             | Published port on the Synology host for n8n web UI                    | `number` | `5678`                            |    no    |
| <a name="input_n8n_webhook_url"></a> [n8n_webhook_url](#input_n8n_webhook_url)                      | Public URL for n8n webhooks                                           | `string` | `"localhost:5678"`                |    no    |
| <a name="input_postgres_password"></a> [postgres_password](#input_postgres_password)                | Password for the PostgreSQL service                                   | `string` | `"postgres-password"`             |    no    |
| <a name="input_postgres_user"></a> [postgres_user](#input_postgres_user)                            | Username for the PostgreSQL service                                   | `string` | `"postgres-user"`                 |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
