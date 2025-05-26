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

## Overview

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_synology"></a> [synology](#requirement\_synology) | ~> 0.4 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_synology"></a> [synology](#provider\_synology) | 0.4.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [synology_container_project.infra_db](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/container_project) | resource |
| [synology_filestation_folder.postgres_data](https://registry.terraform.io/providers/synology-community/synology/latest/docs/resources/filestation_folder) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dsm_host"></a> [dsm\_host](#input\_dsm\_host) | The hostname of my Synology DSM instance | `string` | n/a | yes |
| <a name="input_dsm_password"></a> [dsm\_password](#input\_dsm\_password) | DSM password | `string` | n/a | yes |
| <a name="input_dsm_user"></a> [dsm\_user](#input\_dsm\_user) | DSM username | `string` | n/a | yes |
| <a name="input_dsm_volume_docker"></a> [dsm\_volume\_docker](#input\_dsm\_volume\_docker) | Root path for docker volume on DSM | `string` | `"/volume1/docker"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | Password for the PostgreSQL service | `string` | n/a | yes |
| <a name="input_postgres_user"></a> [postgres\_user](#input\_postgres\_user) | Username for the PostgreSQL service | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
