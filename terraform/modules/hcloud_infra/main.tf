terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.47"
    }
  }
}

# User data for base setup (Docker + firewall)
locals {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose ufw curl
    systemctl enable --now docker
    useradd -m -s /bin/bash ansible -G docker
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ansible
    ufw --force enable
    ufw allow 22
    ufw allow 80
    ufw allow 8080
  EOF
}

# Environment-specific Load Balancer
resource "hcloud_load_balancer" "lb" {
  name               = "${var.env}-weather-lb"
  load_balancer_type = "lb11"
  location           = var.location
}

resource "hcloud_load_balancer_service" "lb_http" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 8080

  health_check {
    protocol = "http"
    port     = 8080
    interval = 10
    timeout  = 5
    retries  = 3
    http {
      path = "/health"
    }
  }
}

# API servers (Scalable per environment)
resource "hcloud_server" "apis" {
  count       = var.api_instance_count
  name        = "${var.env}-api-${count.index + 1}"
  image       = "ubuntu-24.04"
  server_type = var.instance_type
  location    = var.location
  ssh_keys    = [var.ssh_key_id]
  user_data   = local.user_data
  labels = {
    role = "api"
    env  = var.env
  }
}

resource "hcloud_load_balancer_target" "api_targets" {
  count            = var.api_instance_count
  load_balancer_id = hcloud_load_balancer.lb.id
  type             = "server"
  server_id        = hcloud_server.apis[count.index].id
}

# Dedicated Database server
resource "hcloud_server" "db" {
  name        = "${var.env}-db"
  image       = "ubuntu-24.04"
  server_type = var.instance_type
  location    = var.location
  ssh_keys    = [var.ssh_key_id]
  # Ensures services start automatically on boot via package installation
  user_data   = "${local.user_data}\napt-get install -y postgresql postgresql-contrib"
  labels = {
    role = "db"
    env  = var.env
  }
}