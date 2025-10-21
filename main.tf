terraform {
  required_version = ">= 1.5.0"

  required_providers {
    astro = {
      source  = "astronomer/astro"
      version = "~> 1.0"
    }
  }
}

provider "astro" {
  organization_id = var.organization_id
  host            = var.astro_host
}

data "astro_clusters" "existing" {
  count = var.create_cluster || var.existing_cluster_name == null ? 0 : 1

  names = [var.existing_cluster_name]
}

resource "astro_workspace" "platform" {
  name                  = var.workspace_name
  description           = var.workspace_description
  cicd_enforced_default = true
}

resource "astro_cluster" "primary" {
  count = var.create_cluster ? 1 : 0

  type             = "DEDICATED"
  name             = var.cluster_name
  region           = var.cluster_region
  cloud_provider   = var.cluster_cloud_provider
  vpc_subnet_range = var.cluster_vpc_subnet_range
  workspace_ids    = [astro_workspace.platform.id]

  timeouts = {
    create = "3h"
    update = "2h"
    delete = "1h"
  }
}

locals {
  dedicated_cluster_id = length(astro_cluster.primary) > 0 ? astro_cluster.primary[0].id : try(tolist(data.astro_clusters.existing[0].clusters)[0].id, null)
  environment_cluster_enabled_map = {
    for key, env in var.environments :
    key => coalesce(try(env.enable_cluster, null), var.enable_cluster)
  }
  environment_effective_type_map = {
    for key, env in var.environments :
    key => (local.environment_cluster_enabled_map[key] ? env.type : "STANDARD")
  }
}

resource "astro_deployment" "environment" {
  for_each = var.environments

  name                    = each.value.name
  description             = each.value.description
  type                    = local.environment_effective_type_map[each.key]
  workspace_id            = astro_workspace.platform.id
  executor                = each.value.executor
  scheduler_size          = each.value.scheduler_size
  contact_emails          = length(each.value.contact_emails) > 0 ? each.value.contact_emails : var.notification_emails
  default_task_pod_cpu    = each.value.default_task_pod_cpu
  default_task_pod_memory = each.value.default_task_pod_memory
  resource_quota_cpu      = each.value.resource_quota_cpu
  resource_quota_memory   = each.value.resource_quota_memory
  is_cicd_enforced        = try(each.value.is_cicd_enforced, true)
  is_dag_deploy_enabled   = try(each.value.is_dag_deploy_enabled, true)
  is_development_mode     = each.value.is_development_mode
  is_high_availability    = each.value.is_high_availability
  environment_variables   = try(each.value.environment_variables, [])
  worker_queues = length(try(each.value.worker_queues, [])) > 0 ? each.value.worker_queues : null

  cluster_id     = local.environment_cluster_enabled_map[each.key] ? local.dedicated_cluster_id : null
  cloud_provider = local.environment_effective_type_map[each.key] == "STANDARD" ? each.value.cloud_provider : null
  region         = local.environment_effective_type_map[each.key] == "STANDARD" ? each.value.region : null

  depends_on = [astro_workspace.platform]

  lifecycle {
    precondition {
      condition     = !(local.environment_cluster_enabled_map[each.key] && local.dedicated_cluster_id == null)
      error_message = "enable_cluster is true but no dedicated cluster is available. Either set create_cluster = true or provide existing_cluster_name."
    }
  }
}
