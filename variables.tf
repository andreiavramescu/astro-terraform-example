variable "organization_id" {
  description = "Existing Astro organization ID to operate against."
  type        = string
}

variable "astro_host" {
  description = "Astro control plane host. Override only when targeting a non-production Astro installation."
  type        = string
  default     = "https://api.astronomer.io"
}

variable "workspace_name" {
  description = "Name for the workspace that will contain all sample assets."
  type        = string
  default     = "example-data-platform"
}

variable "workspace_description" {
  description = "Friendly description for the sample workspace."
  type        = string
  default     = "Workspace managed by Terraform for demonstration purposes."
}

variable "cluster_name" {
  description = "Name for the dedicated cluster that backs the production deployment."
  type        = string
  default     = "example-prod-cluster"
}

variable "cluster_region" {
  description = "Cloud region for the dedicated cluster."
  type        = string
  default     = "westeurope"
}

variable "cluster_vpc_subnet_range" {
  description = "CIDR range for the dedicated cluster's VPC. Adjust to fit your network plan."
  type        = string
  default     = "172.20.0.0/20"
}

variable "cluster_cloud_provider" {
  description = "Cloud provider identifier supported by Astro (AWS, AZURE, or GCP)."
  type        = string
  default     = "AZURE"
}

variable "create_cluster" {
  description = "Set to false to skip provisioning the dedicated cluster. Ensure any deployments also set enable_cluster = false."
  type        = bool
  default     = true
}

variable "enable_cluster" {
  description = "Global toggle controlling whether deployments should attach to a dedicated cluster when available."
  type        = bool
  default     = true
}

variable "existing_cluster_name" {
  description = "Optional name of an existing dedicated Astro cluster to attach deployments to when create_cluster is false."
  type        = string
  default     = null
}

variable "notification_emails" {
  description = "Primary notification list used across the sample deployments."
  type        = list(string)
  default     = ["data-platform@example.com"]
}

variable "environments" {
  description = "Map of environment configurations that will be materialized as Astro deployments."
  type = map(object({
    name                    = string
    description             = string
    type                    = string
    executor                = string
    scheduler_size          = string
    contact_emails          = list(string)
    default_task_pod_cpu    = string
    default_task_pod_memory = string
    resource_quota_cpu      = string
    resource_quota_memory   = string
    is_cicd_enforced        = optional(bool, true)
    is_dag_deploy_enabled   = optional(bool, true)
    is_development_mode     = bool
    is_high_availability    = bool
    enable_cluster          = optional(bool)
    cloud_provider          = optional(string)
    region                  = optional(string)
    worker_queues = optional(list(object({
      name               = string
      astro_machine      = string
      is_default         = bool
      min_worker_count   = number
      max_worker_count   = number
      worker_concurrency = number
    })), [])
    environment_variables = optional(list(object({
      key       = string
      value     = string
      is_secret = bool
    })), [])
  }))

  default = {
    dev = {
      name                    = "example-dev"
      description             = "Development deployment managed by Terraform."
      type                    = "STANDARD"
      executor                = "CELERY"
      scheduler_size          = "SMALL"
      contact_emails          = []
      default_task_pod_cpu    = "0.25"
      default_task_pod_memory = "0.5Gi"
      resource_quota_cpu      = "6"
      resource_quota_memory   = "12Gi"
      is_cicd_enforced        = true
      is_dag_deploy_enabled   = true
      is_development_mode     = true
      is_high_availability    = false
      cloud_provider          = "AWS"
      region                  = "us-east-1"
      worker_queues = [{
        name               = "default"
        astro_machine      = "A5"
        is_default         = true
        min_worker_count   = 0
        max_worker_count   = 3
        worker_concurrency = 1
      }]
      environment_variables = [{
        key       = "LOG_LEVEL"
        value     = "DEBUG"
        is_secret = false
      }]
    }
    prod = {
      name                    = "example-prod"
      description             = "Production deployment pinned to a dedicated cluster."
      type                    = "DEDICATED"
      executor                = "KUBERNETES"
      scheduler_size          = "MEDIUM"
      contact_emails          = []
      default_task_pod_cpu    = "0.5"
      default_task_pod_memory = "1Gi"
      resource_quota_cpu      = "20"
      resource_quota_memory   = "40Gi"
      is_cicd_enforced        = true
      is_dag_deploy_enabled   = true
      is_development_mode     = false
      is_high_availability    = true
      cloud_provider          = "AWS"
      region                  = "us-east-1"
      worker_queues           = []
      environment_variables = [{
        key       = "LOG_LEVEL"
        value     = "INFO"
        is_secret = false
      }]
    }
  }
}
