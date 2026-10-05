# Telecom GCP Infrastructure as Code

Enterprise-grade IaC for Telecom platform on GCP.

## Architecture

Terraform 1.6+ | Terragrunt 0.52+ | Workload Identity Federation
Services: Cloud Run, Spanner, BigTable, BigQuery, Pub/Sub, Firestore, VPC, KMS, Monitoring

## Directory Structure

terraform/
  bootstrap/              Workload Identity Federation setup
  modules/                Reusable Terraform modules
  projects/dev            DEV environment
  projects/staging        Staging environment
  projects/production     Production environment
  envvars.hcl             Global variables
  terragrunt.hcl          Root configuration

.github/workflows/
  terraform-dev-deploy.yml       Auto-deploy DEV
  terraform-staging-plan.yml     Plan Staging
  terraform-staging-apply.yml    Apply Staging

## Quick Start

1. Deploy Bootstrap: cd terraform/bootstrap && terraform apply
2. Deploy DEV: cd terraform/projects/dev && terragrunt run-all apply
3. Deploy Staging: cd terraform/projects/staging && terragrunt run-all apply

## GitHub Secrets Required

GCP_WORKLOAD_IDENTITY_PROVIDER_DEV
GCP_SERVICE_ACCOUNT_DEV
GCP_WORKLOAD_IDENTITY_PROVIDER_STAGING
GCP_SERVICE_ACCOUNT_STAGING
SLACK_WEBHOOK_URL

## CI/CD Workflows

terraform-dev-deploy.yml - Auto-applies on main push
terraform-staging-plan.yml - Plan on PR
terraform-staging-apply.yml - Manual apply

## Enterprise Standards

Terraform + Terragrunt IaC
Workload Identity Federation (no long-lived keys)
Multi-environment isolation
Remote GCS state
Automated CI/CD
Least-privilege IAM
Slack notifications
