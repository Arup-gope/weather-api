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
## Continuous Integration (CI) and Continuous Deployment (CD)

### Continuous Integration (CI) with Jenkins

- **Trigger:** Jenkins detects a new commit in the GitHub repository.
- **Pipeline Steps:**
  - Executes unit tests
  - Runs security scans (Snyk/Trivy)
  - Builds the Docker image
  - Pushes the Docker image to the container registry
- **Manifest Update:** Jenkins automatically updates the image tag in Kubernetes or Docker Compose manifests in a dedicated GitOps repository.

---

### Continuous Deployment (CD) with ArgoCD

- **GitOps Pattern:** ArgoCD continuously monitors the Git repository for changes in infrastructure or application manifests.
- **Automatic Sync:** When Jenkins updates the image tag in Git, ArgoCD detects any drift between Git and the deployed environment.
- **Deployment:** ArgoCD performs a rolling update across all API nodes (2 Dev, 3 Prod), ensuring zero downtime during deployment.


## Prerequisites

Ensure the following are installed and available:

- Hetzner Cloud API token
- Terraform v1.0+
- Ansible v2.10+
- SSH Ed25519 key at `~/.ssh/id_ed25519`
- Docker Hub access

Environment variables:

```bash
$env:TF_VAR_hcloud_token="<hetzner_token>"
```
## Repository Structure

```text
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
```
## Deploying the Infrastructure
Provision all cloud resources using Terraform:
```bash
cd terraform
terraform init
terraform apply
```
This provisions the following components:

- Virtual network and firewall rules

- Load balancer

- API servers

- Database servers



## Configuring the Servers
```
cd ansible
ansible-playbook -i inventory/hcloud.yml site.yml
```
Hosts are discovered dynamically using Hetzner Cloud labels and configured according to their assigned roles.


** Figure 1: Ansible Configuration**
<img width="1713" height="935" alt="Ansible_Configuration_1" src="https://github.com/user-attachments/assets/4edd5a73-aefd-4aed-b885-798ddc4fe28d" />

** Figure 2: Ansible Configuration Overview **
<img width="1887" height="983" alt="Ansible_Configuration_2" src="https://github.com/user-attachments/assets/1463f2ac-5fb0-4305-a017-a74968802af7" />


##  Verifying the Deployment

Retrieve the load balancer IP address or DNS name from Terraform outputs.

Verify the health check endpoint:

```
curl http://<load_balancer_ip>/health
curl http://<load_balancer_ip>:80/weather

```
** Figure 3: Testing the deployment**

<img width="1017" height="270" alt="Ansible_Output_Test" src="https://github.com/user-attachments/assets/f188799b-9000-4959-ab44-2a27555a3da4" />







