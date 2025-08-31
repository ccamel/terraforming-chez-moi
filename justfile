# Load variables from .env if it exists
set dotenv-load := true

# Default recipe
default:
    @just --list

# Initialize Terraform
init:
    terraform init

# Validate Terraform configuration
validate:
    terraform validate

# Plan infrastructure changes
plan:
    terraform plan --input=false

# Apply infrastructure changes
apply:
    terraform apply --input=false

# Destroy infrastructure
destroy:
    terraform destroy --input=false

# Format Terraform code
fmt:
    terraform fmt -recursive

# Check Terraform code formatting
check-fmt:
    terraform fmt -check -recursive
