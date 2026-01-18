terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.47"
    }
  }
}


provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "devops-takehome-key"
  public_key = file("~/.ssh/id_ed25519.pub") 
}

# --- Development Environment ---
module "dev_infra" {
  source = "./modules/hcloud_infra"

  env                = "dev"
  location           = var.location           # Use Variable
  instance_type      = var.instance_type      # Use Variable
  api_instance_count = var.api_instance_count # Use Variable
  ssh_key_id         = hcloud_ssh_key.default.id
}

# --- Production Environment ---
module "prod_infra" {
  source = "./modules/hcloud_infra"

  env                = "prod"
  location           = var.location           # Use Variable
  instance_type      = var.instance_type      # Use Variable
  
  # For Production, we use one more than Dev for higher availability
  api_instance_count = var.api_instance_count + 1 
  
  ssh_key_id         = hcloud_ssh_key.default.id
}
