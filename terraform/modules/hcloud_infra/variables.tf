variable "env" {
  description = "Environment name (e.g., dev or prod)"
  type        = string
}

variable "location" {
  description = "Hetzner location"
  type        = string
}

variable "instance_type" {
  description = "Hetzner server type"
  type        = string
}

variable "api_instance_count" {
  description = "Number of API servers to provision"
  type        = number
}

variable "ssh_key_id" {
  description = "ID of the SSH key to inject"
  type        = any
}