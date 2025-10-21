# Astro Terraform Example

Minimal setup for the [astronomer/astro](https://registry.terraform.io/providers/astronomer/astro/latest) Terraform provider. The config creates an Astro workspace, optionally provisions a dedicated cluster, and deploys two sample environments (dev and prod).

## Quickstart

1. Export an Astro API token and note your organization ID.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`, then fill in your values (`organization_id` and any overrides such as `enable_cluster = false`, `create_cluster = false`, `existing_cluster_name = "My Dedicated Cluster"`, or custom `environments`).
3. Run `terraform init`, `terraform plan`, and `terraform apply`.
4. Check the outputs for workspace, cluster, and deployment IDs. Use `terraform destroy` to tear it all down.

When reusing an existing dedicated cluster, set `enable_cluster = true`, `create_cluster = false`, supply the name via `existing_cluster_name`, and keep any deployments that should use it with `enable_cluster = true` (either globally or inside the relevant entry of `var.environments`). If `enable_cluster` ends up false, deployments automatically fall back to `STANDARD` and use whatever `cloud_provider` / `region` you set in the environment definition.

## Files

- `main.tf` — provider + resources (workspace, optional cluster, deployments).
- `variables.tf` — input variables, defaults for the sample environments.
- `terraform.tfvars.example` — template variable file.
- `outputs.tf` — IDs for reuse in automation.

More resource details: [Terraform Registry docs](https://registry.terraform.io/providers/astronomer/astro/latest/docs).
