output "workspace_id" {
  description = "Identifier for the workspace created by this example."
  value       = astro_workspace.platform.id
}

output "cluster_id" {
  description = "Identifier for the dedicated cluster shared by production-grade deployments."
  value       = local.dedicated_cluster_id
}

output "deployment_ids" {
  description = "Map of environment keys to the Astro deployment IDs that Terraform manages."
  value       = { for key, deployment in astro_deployment.environment : key => deployment.id }
}
