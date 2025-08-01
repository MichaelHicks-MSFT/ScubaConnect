### REQUIRED ###

variable "contact_emails" {
  description = "Emails to notify for alerts and before certificate expiry"
  type        = list(string)
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create and build resources in"
}

### OPTIONAL ###

variable "location" {
  default     = "East US"
  type        = string
  description = "Region to build resources in"
}

variable "schedule_interval" {
  default     = "Week"
  type        = string
  description = "The interval to run the scheduled job on."
  validation {
    condition     = contains(["Hour", "Day", "Week", "Month"], var.schedule_interval)
    error_message = "Must be one of 'Hour', 'Day', 'Week', 'Month'"
  }
}

variable "app_name" {
  default     = "ScubaConnect"
  type        = string
  description = "App name. Displayed in Azure console on installed tenants"
}

variable "app_multi_tenant" {
  type        = bool
  default     = false
  description = "If true, the app will be able to be installed in multiple tenants. By default, it is only available in this tenant"
}

variable "vnet" {
  default = null
  type = object({
    address_space          = string
    aci_subnet             = string
    allowed_access_ip_list = list(string)
  })
  description = "Configuration for the vnet, including the address space, ACI subnet, and a list of allowed IP ranges. All strings in CIDR format"
}

variable "firewall" {
  default = null
  type = object({
    resource_group = string
    vnet           = string
    pip            = string
    name           = string
  })
  description = "Configuration for an Azure Firewall; if not null, traffic will be routed through this firewall"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created. Application is done via policies"
  default     = {}
}

variable "serial_number" {
  default     = "01"
  type        = string
  description = "Increment by 1 when re-provisioning with the same resource group name"
}

variable "image_path" {
  default     = "./cisa_logo.png"
  type        = string
  description = "Path to image used for app logo. Displayed in Azure console on installed tenants"
}

### ADVANCED ###

variable "create_app" {
  default     = true
  type        = bool
  description = "If true, the app will be created. If false, the app will be imported"
}

variable "prefix_override" {
  default     = null
  type        = string
  description = "Prefix for resource names. If null, one will be generated from app_name"
}

variable "input_storage_container_url" {
  default     = null
  type        = string
  description = "If not null, input container to read configs from (must give permissions to service account). Otherwise by default will create storage container. Expect an https url pointing to a container"
}

variable "output_storage_container_url" {
  default     = null
  type        = string
  description = "If not null, output container to put results in (must give permissions to service account or use SAS). Otherwise by default will create storage container. Expect an https url pointing to a container"
}

variable "output_storage_container_sas" {
  default     = null
  type        = string
  description = "If not null, shared access signature token (query string) to use when writing results to the output storage container. Set this when the container is in an external tenant (the owner of that container will provide the value)."
  sensitive   = true
}

variable "tenants_dir_path" {
  default     = "./tenants"
  type        = string
  description = "Relative path to directory containing tenant configuration files in yaml"
}

variable "container_registry" {
  type = object({
    server   = string
    username = string
    password = string
  })
  default     = null
  description = "Credentials for logging into registry with container image"
}

variable "container_image" {
  type        = string
  default     = "ghcr.io/cisagov/scubaconnect-m365:latest"
  description = "Docker image to use for running ScubaGear."
}

variable "container_memory_gb" {
  type        = number
  description = "Amount of memory to allocate for ScubaGear container. Due to memory leaks in some dependencies, this may need to be increased if running on many tenants"
  default     = 3
  validation {
    condition     = var.container_memory_gb <= 16 && var.container_memory_gb >= 2
    error_message = "Container memory must be between 2GB and 16GB"
  }
}

variable "secondary_app_info" {
  description = <<EOF
    Information for a secondary app. This can be used for one ScubaConnect instance to handle multiple environments (e.g., GCC and GCC High).
    To use, manually create an app in the other environment and add the certificate created for the primary app to it.
    Set `environment_to_use` to the environment the manual app is in, either "commericial" or "gcchigh"
  EOF
  type = object({
    app_id = string
    environment_to_use = string
  })
  default = null
  validation {
    condition = var.secondary_app_info == null ? true : contains(["commercial", "gcchigh"], var.secondary_app_info.environment_to_use)
    error_message = "Valid values for create_mode are (Default, PointInTimeRestore, Replica)"
  }
}