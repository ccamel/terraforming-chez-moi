# terraforming-chez-moi

> 🪐 Personal Terraform configuration for shaping and managing my home infrastructure - including my Synology DS415+, self-hosted services, and all the weird experiments that come with being a geek at home.

[![lint](https://img.shields.io/github/actions/workflow/status/ccamel/terraforming-chez-moi/lint.yml?branch=main&label=lint&style=for-the-badge&logo=github)](https://github.com/ccamel/terraforming-chez-moi/actions/workflows/lint.yml)
[![conventional commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg?style=for-the-badge&logo=conventionalcommits)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg?style=for-the-badge)](https://opensource.org/licenses/BSD-3-Clause)

## Overview

This repo is exploratory, idiosyncratic, and not intended as a universal template.  
But if you enjoy turning black-box appliances into programmable interfaces - welcome.

## Philosophy

This repository implements a simple GitOps approach for managing my home infrastructure: desired state is defined in [Terraform](https://developer.hashicorp.com/terraform), versioned in Git, and applied through automated workflows.
