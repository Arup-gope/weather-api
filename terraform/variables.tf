variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Default location for resources"
  type        = string
}

variable "api_instance_count" {
  description = "Number of API instances per environment"
  type        = number
}

variable "instance_type" {
  description = "Server type for Hetzner instances"
  type        = string
}