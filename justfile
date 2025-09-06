# Load variables from .env if it exists
set dotenv-load := true

# Variables for the mask tool
mask_repository := 'github.com/ThorstenHans/mask'
mask_version    := 'latest'

# Default recipe
default:
    @just --list

# Initialize Terraform
init:
    @terraform init

# Validate Terraform configuration
validate:
    @terraform validate

# Plan infrastructure changes
plan:
    @just mask-stream terraform plan --input=false

# Apply infrastructure changes
apply:
    @just mask-stream terraform apply --input=false

# Destroy infrastructure
destroy:
    @terraform destroy --input=false

# Format Terraform code
fmt:
    @terraform fmt -recursive

# Check Terraform code formatting
check-fmt:
    @terraform fmt -check -recursive

# Ensure required tools are available for recipes in this Justfile.
tools:
    @just ensure-mask

[private]
mask-stream cmd *args: ensure-mask
    #!/usr/bin/env bash
    set -euo pipefail

    work="$(mktemp -d .mask.XXXX)"
    trap 'rm -rf "$work"' EXIT
    export HOME="$PWD/$work"

    while IFS='=' read -r k v; do
      ./.bin/mask add -- "$v" >/dev/null || true
    done < <(env | grep '^TF_VAR_' || true)

    bash -c "{{cmd}} {{args}}" 2>&1 | ./.bin/mask

[private]
ensure-mask:
    #!/usr/bin/env bash
    echo "🔍 Checking for 'mask' tool..."
    if [ -f "./.bin/mask" ]; then exit 0; fi
    echo "🚀 Installing 'mask' tool..."
    GOBIN="$(pwd)/.bin" go install {{mask_repository}}@{{mask_version}}
