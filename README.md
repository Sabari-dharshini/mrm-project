# MRM PG - Deployment Guide

Full-stack PG management system deployed on AWS using Terraform + Docker.

## Services

| Service | Port | Description |
|---|---|---|
| mrmpg-backend | 5000 | Node.js REST API + Prisma + PostgreSQL |
| mrmpg-admin | 5174 | Admin dashboard (React) |
| mrmpg-member | 5175 | Member portal (React) |
| mrmpg-user | 5173 | Public website (React) |

## Quick Deploy (3 Steps)

### Step 1 — Prerequisites

Install on your local machine:
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- An SSH key pair: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`

Configure AWS CLI:
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (ap-south-1), Output (json)
```

### Step 2 — Configure Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
nano terraform.tfvars
```

### Step 3 — Deploy

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

After apply completes, Terraform prints your EC2 IP and app URLs.
The EC2 bootstrap script runs automatically and starts all containers.

> **Note:** First boot takes 8-12 minutes (Docker build). SSH in and run `tail -f /var/log/mrm-bootstrap.log` to monitor.

## Admin Credentials

After first deploy, insert the admin user into RDS:

```sql
INSERT INTO "Admin" (id, name, email, password, "pgType", "createdAt", "updatedAt")
VALUES (
  'cm_newid123', 'admin', 'admin@gmail.com',
  '$2a$12$ypM87aP9PCCO6SfEOUbMxunwArqrx.T.2kapeEVu50EibKUlboO/W',
  'MENS', NOW(), NOW()
);
```

**Login:** admin@gmail.com / Admin@123

## Useful Commands

```bash
# SSH into EC2
ssh -i ~/.ssh/id_rsa ubuntu@YOUR_EC2_IP

# View running containers
docker ps

# View logs
docker compose logs -f mrmpg-backend

# Restart all services
docker compose restart

# Rebuild and restart
docker compose --env-file .env up -d --build

# Destroy infrastructure (careful!)
cd terraform && terraform destroy
```

## Architecture

```
GitHub Repo
    │
    ▼ terraform apply
AWS VPC (10.0.0.0/16)
├── Public Subnet ── EC2 t2.micro (Ubuntu 22.04)
│                       └── Docker Compose
│                           ├── mrmpg-backend  :5000
│                           ├── mrmpg-admin    :5174
│                           ├── mrmpg-member   :5175
│                           └── mrmpg-user     :5173
└── Private Subnets ── RDS PostgreSQL db.t3.micro
```
