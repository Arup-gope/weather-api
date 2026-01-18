# High-Availability Weather API on Hetzner Cloud

## Architecture Overview

This project deploys a highly available, multi-tier Weather API platform on Hetzner Cloud using Infrastructure as Code (Terraform) and Configuration as Code (Ansible).

### Logical Architecture

- **Load Balancer Layer**
  - Public Hetzner Load Balancer
  - Round-robin traffic distribution
  - Health checks on `/health`

- **Application Layer**
  - Multiple Go-based Weather API servers
  - Deployed as Docker containers
  - Horizontally scalable
  - Containers run as non-root users

- **Data Layer**
  - Dedicated PostgreSQL servers
  - Managed via systemd
  - Persistent volumes for data durability
  - Network access restricted to API nodes only

The same architecture is deployed for both **development** and **production** environments using variable-driven configuration.

---

## Prerequisites

Ensure the following are installed and available:

- Hetzner Cloud API token
- Terraform v1.0+
- Ansible v2.10+
- SSH Ed25519 key at `~/.ssh/id_ed25519`
- Docker Hub access

Environment variables:

```bash
export TF_VAR_hcloud_token="<your_hetzner_token>"
export HCLOUD_TOKEN="<your_hetzner_token>"
```
.
├── terraform/
│   ├── modules/
│   │   └── hcloud_infra/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory/
│   │   └── hcloud.yml
│   ├── roles/
│   │   ├── docker/
│   │   ├── api/
│   │   └── db/
│   └── site.yml
├── docker/
│   ├── Dockerfile
│   └── compose.yaml
└── README.md
