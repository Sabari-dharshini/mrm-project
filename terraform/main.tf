# ─────────────────────────────────────────────────────────────
#  MRM PG - Terraform Infrastructure
#  Provider: AWS  |  Free Tier optimized
#  Resources: VPC · Subnets · IGW · EC2 · RDS · Security Groups
# ─────────────────────────────────────────────────────────────

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ─────────────────────────────────────────────────────
resource "aws_vpc" "mrm_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "mrm-vpc"
    Project = "mrm-pg"
  }
}

# ── Internet Gateway ─────────────────────────────────────────
resource "aws_internet_gateway" "mrm_igw" {
  vpc_id = aws_vpc.mrm_vpc.id

  tags = {
    Name    = "mrm-igw"
    Project = "mrm-pg"
  }
}

# ── Public Subnet (EC2 lives here) ──────────────────────────
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.mrm_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "mrm-public-subnet"
    Project = "mrm-pg"
  }
}

# ── Private Subnet A (RDS lives here) ───────────────────────
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.mrm_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "mrm-private-subnet-a"
    Project = "mrm-pg"
  }
}

# ── Private Subnet B (RDS needs 2 AZs) ──────────────────────
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.mrm_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name    = "mrm-private-subnet-b"
    Project = "mrm-pg"
  }
}

# ── Route Table (public) ─────────────────────────────────────
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.mrm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mrm_igw.id
  }

  tags = {
    Name    = "mrm-public-rt"
    Project = "mrm-pg"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
