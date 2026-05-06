variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"  # Mumbai - closest to Madurai
}

variable "ec2_ami" {
  description = "Ubuntu 22.04 LTS AMI ID (region-specific)"
  type        = string
  # Ubuntu 22.04 LTS - ap-south-1 (Mumbai)
  # Find latest: https://cloud-images.ubuntu.com/locator/ec2/
  default     = "ami-0f5ee92e2d63afc18"
}

variable "ec2_public_key" {
  description = "Your SSH public key content (from ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "db_password" {
  description = "Password for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "database_url" {
  description = "Full PostgreSQL connection URL for backend"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret (long random string)"
  type        = string
  sensitive   = true
}

variable "email_user" {
  description = "SMTP email username"
  type        = string
}

variable "email_pass" {
  description = "SMTP email app password"
  type        = string
  sensitive   = true
}

variable "email_from" {
  description = "From email address"
  type        = string
}

variable "company_name" {
  description = "Company name for emails"
  type        = string
  default     = "MRM PG"
}

variable "github_repo_url" {
  description = "GitHub repo URL (https, public or with token)"
  type        = string
}
