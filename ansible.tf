
variable "create_ansible" {
  description = "Boolean to make module or not"
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "Username for SSH"
  type        = string
  default     = "ubuntu"
}

## Enable flags
variable "node_exporter_enabled" {
  description = "Bool to enable node exporter"
  type        = bool
  default     = true
}

variable "health_check_enabled" {
  description = "Bool to enable client health check agent"
  type        = bool
  default     = true
}

variable "consul_enabled" {
  description = "Bool to enable Consul"
  type        = bool
  default     = true
}

variable "source_of_truth_enabled" {
  description = "Bool to enable SoT sync (for use with library nodes)"
  type        = bool
  default     = false
}

# Node exporter
variable "node_exporter_user" {
  description = "User for node exporter"
  type        = string
  default     = "node_exporter_user"
}

variable "node_exporter_password" {
  description = "Password for node exporter"
  type        = string
  default     = "node_exporter_password"
}

variable "node_exporter_url" {
  description = "URL to Node Exporter binary"
  type        = string
  default     = "https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"
}

variable "node_exporter_hash" {
  description = "SHA256 hash of Node Exporter binary"
  type        = string
  default     = "b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"
}

# Client
//variable "network_settings" {
//  description = "Map of network settings to apply. Use either this or set individual variables."
//  type        = map(map(string))
//  default     = null
//}

variable "network_settings" {
  description = "Map of network settings to apply. Use either this or set individual variables."
  type = map(object({
    name                = string
    shortname           = string
    api_health          = string
    polkadot_prometheus = string
    json_rpc            = string
    ws_rpc              = string
  }))
  //  default     = {
  //    polkadot = {
  //      name                = "polkadot"
  //      shortname           = "polkadot"
  //      api_health          = "5000"
  //      polkadot_prometheus = "9610"
  //      json_rpc            = "9933"
  //      ws_rpc              = "9944"
  //    }
  //  }
  default = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name, overrides source of truth IAM."
  type        = string
  default     = ""
}

variable "network_stub" {
  description = "The stub name of the Polkadot chain (polkadot = polkadot, kusama = ksmcc3)"
  type        = string
  default     = "ksmcc3"
}

variable "network_name" {
  description = "The network name, ie kusama / polkadot"
  type        = string
  default     = "polkadot"
}

variable "polkadot_client_url" {
  description = "URL to Polkadot client binary"
  type        = string
  default     = "https://github.com/w3f/polkadot/releases/download/v0.8.23/polkadot"
}

variable "polkadot_client_hash" {
  description = "SHA256 hash of Polkadot client binary"
  type        = string
  default     = "cdf31d39ed54e66489d1afe74ed7549d5bcdf8ff479759e8fc476d17d069901e"
}

variable "polkadot_restart_enabled" {
  description = "Bool to enable client restart cron job"
  type        = bool
  default     = false
}

variable "polkadot_restart_minute" {
  description = "Client cron restart minute"
  type        = string
  default     = ""
}

variable "polkadot_restart_hour" {
  description = "Client cron restart hour"
  type        = string
  default     = ""
}

variable "polkadot_restart_day" {
  description = "Client cron restart day"
  type        = string
  default     = ""
}

variable "polkadot_restart_month" {
  description = "Client cron restart month"
  type        = string
  default     = ""
}

variable "polkadot_restart_weekday" {
  description = "Client cron restart weekday"
  type        = string
  default     = ""
}

variable "sync_bucket_uri" {
  description = "S3 bucket URI for SoT sync"
  type        = string
  default     = null
}

variable "project" {
  description = "Name of the project for node name"
  type        = string
  default     = "project"
}

variable "instance_count" {
  description = "Iteration number for this instance"
  type        = string
  default     = "0"
}

variable "logging_filter" {
  description = "String for polkadot logging filter"
  type        = string
  default     = "sync=trace,afg=trace,babe=debug"
}

variable "telemetry_url" {
  description = "WSS URL for telemetry"
  type        = string
  default     = ""
}

variable "default_telemetry_enabled" {
  description = "Bool to enable telemetry submission to telemetry.polkadot.io"
  type        = bool
  default     = false
}

variable "base_path" {
  description = "Alternate base path for Polkadot client"
  type        = string
  default     = ""
}

variable "polkadot_additional_common_flags" {
  description = "Optional common flags for Polkadot client"
  type        = string
  default     = ""
}

variable "polkadot_additional_validator_flags" {
  description = "Optional validator flags for Polkadot client"
  type        = string
  default     = ""
}

variable "rpc_api_port" {
  description = "Port number for the JSON RPC API"
  type        = string
  default     = "9933"
}

variable "wss_api_port" {
  description = "Port number for the Websockets API"
  type        = string
  default     = "9944"
}

variable "health_check_port" {
  description = "Port number for the health check"
  type        = string
  default     = "5500"
}

variable "polkadot_prometheus_port" {
  description = "Port number for the Prometheus Metrics exporter built into the Polkadot client"
  type        = string
  default     = "9610"
}

module "ansible" {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.12.0"
  create = var.create_ansible && var.create

  ip                     = join("", aws_eip_association.this.*.public_ip)
  user                   = "ubuntu"
  private_key_path       = var.private_key_path
  playbook_file_path     = "${path.module}/ansible/${var.node_purpose}.yml"
  requirements_file_path = "${path.module}/ansible/requirements.yml"
  forks                  = 1

  playbook_vars = {
    id       = var.name
    ssh_user = var.ssh_user

    # enable flags
    node_exporter_enabled = var.node_exporter_enabled
    health_check_enabled  = var.health_check_enabled
    consul_enabled        = var.consul_enabled
    use_source_of_truth   = var.source_of_truth_enabled

    # node exporter
    node_exporter_user            = var.node_exporter_user
    node_exporter_password        = var.node_exporter_password
    node_exporter_binary_url      = var.node_exporter_url
    node_exporter_binary_checksum = "sha256:${var.node_exporter_hash}"

    # polkadot client
    polkadot_binary_url      = var.polkadot_client_url
    polkadot_binary_checksum = "sha256:${var.polkadot_client_hash}"

    polkadot_restart_enabled = var.polkadot_restart_enabled
    polkadot_restart_minute  = var.polkadot_restart_minute
    polkadot_restart_hour    = var.polkadot_restart_hour
    polkadot_restart_day     = var.polkadot_restart_day
    polkadot_restart_month   = var.polkadot_restart_month
    polkadot_restart_weekday = var.polkadot_restart_weekday

    network_settings = jsonencode(local.network_settings)

    project                   = var.project
    instance_count            = var.instance_count
    loggingFilter             = var.logging_filter
    telemetryUrl              = var.telemetry_url
    default_telemetry_enabled = var.default_telemetry_enabled
    base_path                 = var.base_path

    # Validator
    polkadot_additional_common_flags    = var.polkadot_additional_common_flags
    polkadot_additional_validator_flags = var.polkadot_additional_validator_flags

    # SOT
    region          = data.aws_region.this.name
    sync_bucket_uri = local.create_source_of_truth ? aws_s3_bucket.sync[0].bucket_domain_name : var.sync_bucket_uri
  }

  module_depends_on = aws_instance.this
}
