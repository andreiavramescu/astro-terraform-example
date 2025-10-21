# Astro Terraform Example

Minimal setup for the [astronomer/astro](https://registry.terraform.io/providers/astronomer/astro/latest) Terraform provider. The config creates an Astro workspace, optionally provisions a dedicated cluster, and deploys two sample environments (dev and prod).

## Quickstart

1. Export an Astro API token and note your organization ID.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`, then fill in your values (`organization_id` and any overrides such as `enable_cluster = false`, `create_cluster = false`, `existing_cluster_name = "My Dedicated Cluster"`, or custom `environments`).
3. Run `terraform init`, `terraform plan`, and `terraform apply`.
4. Check the outputs for workspace, cluster, and deployment IDs. Use `terraform destroy` to tear it all down.

Reusing an existing dedicated cluster? Turn on `enable_cluster`, leave `create_cluster` off, and point `existing_cluster_name` at the cluster you want. Keep the deployments that should attach to it flagged with `enable_cluster = true` (globally or per environment). If the toggle ends up false, Terraform defaults to `STANDARD` deployments that rely on the `cloud_provider` / `region` values in each environment.

## Files

- `main.tf` — provider + resources (workspace, optional cluster, deployments).
- `variables.tf` — input variables, defaults for the sample environments.
- `terraform.tfvars.example` — template variable file.
- `outputs.tf` — IDs for reuse in automation.

More resource details: [Terraform Registry docs](https://registry.terraform.io/providers/astronomer/astro/latest/docs).
